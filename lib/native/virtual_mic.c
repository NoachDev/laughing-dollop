#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <math.h>
#include <pipewire/pipewire.h>
#include <spa/param/audio/format-utils.h>
#include <spa/param/audio/raw.h>
#include <spa/param/props.h>
#include <spa/pod/builder.h>
#include <spa/utils/string.h>

// Configuartions
static uint32_t RATE = 48000;
static uint32_t CHANNELS = 2;
static const char *NODE_NAME = "virtual_mic_from_c";
static bool initiailized = false;

// PipeWiere base functions
static struct pw_main_loop *loop = NULL;
static struct pw_context *context = NULL;
static struct pw_core *core = NULL;
static struct pw_stream *stream = NULL;
static struct spa_hook stream_listener;
static struct pw_registry *registry;
static struct pw_thread_loop *thread_loop = NULL;
double phase = 0.0;

// Stream callbacks
static void stream_state_changed(void *data, enum pw_stream_state old, enum pw_stream_state state, const char *error){
  fprintf(stderr, "stream state: %s\n", pw_stream_state_as_string(state));

  if (state == PW_STREAM_STATE_ERROR)
      fprintf(stderr, "stream error: %s\n", error);
}

static struct spa_pod *make_audio_format(struct spa_pod_builder *builder){
  return spa_format_audio_raw_build(
    builder, SPA_PARAM_EnumFormat,
    &SPA_AUDIO_INFO_RAW_INIT(
      .format = SPA_AUDIO_FORMAT_S16_LE,
      .rate = RATE,
      .channels = CHANNELS
    )
  );
}

int wirite_frames(int16_t *frames_buf, size_t frames_count){
  if (!stream || !initiailized) return -1;
  
  struct pw_buffer *b = pw_stream_dequeue_buffer(stream);
  struct spa_buffer *buf;

  int i, c;
  int16_t *dst, val;

  size_t stride = CHANNELS * sizeof(int16_t);

  if (b == NULL){
    pw_log_warn("out of buffers: %m");
    return -1;
  }

  buf = b->buffer;
  dst = buf->datas[0].data;

  if (dst == NULL) return -1;

  memcpy(dst, frames_buf, frames_count * stride);
  
  buf->datas[0].chunk->offset = 0;
  buf->datas[0].chunk->stride = stride;
  buf->datas[0].chunk->size = frames_count * stride;
  
  pw_stream_queue_buffer(stream, b);

}

/// Send a sin wave to microphone, debug only
///
/// for see the sin wave open an recorder.
static void on_process(void *data) {
  const size_t block = 256;
  double inc = 2*M_PI / (double)RATE;

  if (phase > 2*M_PI){
    phase = 0.0;
  }

  int16_t *buf = malloc(sizeof(int16_t) * block);

  for (size_t i = 0; i < block; ++i) {
    phase += inc;
    int16_t s = (int16_t)(sin(phase) * 32767.0);
    buf[i] = s;
  }

  wirite_frames(buf, block);
  free(buf);
  
}

// Crete one virtual mic
int create_virtual_mic(char *name, bool debug){
  if (stream) return 0; // already created

  struct pw_properties *props = pw_properties_new(
        PW_KEY_NODE_NAME, "virtual-microphone",
        PW_KEY_MEDIA_CLASS, "Audio/Source",
        PW_KEY_MEDIA_ROLE, "virtual",
        NULL);


  stream = pw_stream_new(core, name ? name : NODE_NAME, props); /// The chanel for wirite in microphone

  if (!stream) return -1;

  if (debug){ /// Enable debug funtions and logs
    static struct pw_stream_events events = { PW_VERSION_STREAM_EVENTS };
    events.state_changed = stream_state_changed; 
    events.process = on_process; 

    pw_stream_add_listener(stream, &stream_listener, &events, NULL); 
  }

  uint8_t buffer[1024];
  struct spa_pod_builder builder = SPA_POD_BUILDER_INIT(buffer, sizeof(buffer));
  const struct spa_pod *params[1];
  params[0] = make_audio_format(&builder);

  int res = pw_stream_connect(
    stream,
    PW_DIRECTION_OUTPUT, /// we provide a source: other apps read from our output
    PW_ID_ANY,
    PW_STREAM_FLAG_AUTOCONNECT | PW_STREAM_FLAG_MAP_BUFFERS | PW_STREAM_FLAG_RT_PROCESS,
    params,
    1
  );

  if (debug){
    pw_main_loop_run(loop); /// block the process, until pw_main_loop_quit() 
  }
  else{
    thread_loop = pw_thread_loop_new_full(pw_main_loop_get_loop(loop), "mic_thread", NULL);
    pw_thread_loop_start(thread_loop);
  }

  return 0;
  
}

void start_pipewire(void){
  if (initiailized) return;

  pw_init(NULL, NULL); /// start the pipewire.

  loop = pw_main_loop_new(NULL); /// the main function for blok the process
  context = pw_context_new(pw_main_loop_get_loop(loop), NULL, 0);
  core = pw_context_connect(context, NULL, 0);
  registry = pw_core_get_registry(core, PW_VERSION_REGISTRY, 0);

  initiailized = true;
}

void stop_pipewire(void *userdata, int signal_number){
  if (!initiailized) return;

  if (thread_loop != NULL){
    pw_thread_loop_stop(thread_loop);
    pw_thread_loop_destroy(thread_loop);
  }

  pw_stream_destroy(stream);
  pw_main_loop_destroy(loop);
  pw_context_destroy(context);
  pw_core_disconnect(core);
  pw_deinit();
  
  stream = NULL;
  loop = NULL;
  context = NULL;
  core = NULL;
  registry = NULL;
  initiailized = false;
}

#ifdef VMIC_STANDALONE
void main(void){
  start_pipewire();
  create_virtual_mic(NULL, true); // allowed logs
}
#endif
// gcc -shared -fPIC -o libvirtual_mic.so virtual_mic.c $(pkg-config --cflags --libs libpipewire-0.3)
// gcc -DVMIC_STANDALONE -fPIC -o mic virtual_mic.c $(pkg-config --cflags --libs libpipewire-0.3) -lm