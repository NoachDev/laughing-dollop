#define _GNU_SOURCE
#include "audio_listener.h"
#include "base.h"
#include <pipewire/pipewire.h>
#include <spa/param/audio/format-utils.h>
#include <spa/param/audio/raw.h>
#include <spa/param/props.h>
#include <spa/pod/builder.h>
#include <spa/utils/string.h>

#include <unistd.h>

const char *NODE_AUDIO_NAME = "virtual_audio_from_c";
static struct pw_stream *audio_stream = NULL;

/// show the data, debug only
void audio_debug(uint8_t *data, int size){
  printf("buffer %d\n", *data);
}

/// On have audio send to listener. 
void on_process_audio(void *data){
  void (*listener)(uint8_t *data, int size) = data;

  struct pw_buffer *b = pw_stream_dequeue_buffer(audio_stream);
  struct spa_buffer *buf;
  uint8_t *p;

  if (b == NULL){
    pw_log_warn("out of buffers: %m");
    return;
  }

  buf = b->buffer;
  p = buf->datas[0].data;

  int stride = sizeof(float) * CHANNELS;
  int n_frames = buf->datas[0].maxsize / stride;

  if (b->requested)
    n_frames = SPA_MIN((int)b->requested, n_frames);

  buf->datas[0].chunk->offset = 0;
  buf->datas[0].chunk->stride = stride;
  buf->datas[0].chunk->size = n_frames * stride;

  pw_stream_queue_buffer(audio_stream, b);

  if (*p != 0){
    listener(p, n_frames);
  }

}

int create_audio_listener(char *name, bool debug, void (*listener)(uint8_t *data, int size)){
  if (audio_stream) return 0; // already created

  struct pw_properties *props = pw_properties_new(
    PW_KEY_NODE_NAME, "audio-listener",
    PW_KEY_MEDIA_CATEGORY, "Capture",
    PW_KEY_MEDIA_ROLE, "Music",
    NULL
  );

  audio_stream = pw_stream_new(core, name ? name : NODE_AUDIO_NAME, props); /// The chanel for wirite in microphone

  if (!audio_stream) return -1;

  static struct pw_stream_events events = { PW_VERSION_STREAM_EVENTS };
  events.process = on_process_audio; 

  if (debug){ /// Enable logs
    events.state_changed = stream_state_changed; 
  }

  pw_stream_add_listener(audio_stream, &stream_listener, &events, listener); 

  uint8_t buffer[1024];

  struct spa_pod_builder builder = SPA_POD_BUILDER_INIT(buffer, sizeof(buffer));
  const struct spa_pod *params[1];
  
  params[0] = spa_format_audio_raw_build(
    &builder,
    SPA_PARAM_EnumFormat,
    &SPA_AUDIO_INFO_RAW_INIT(
      .format = SPA_AUDIO_FORMAT_F32
    )
  );

  pw_stream_connect(audio_stream,
    PW_DIRECTION_INPUT,
    PW_ID_ANY,
    PW_STREAM_FLAG_AUTOCONNECT |
    PW_STREAM_FLAG_MAP_BUFFERS |
    PW_STREAM_FLAG_RT_PROCESS,
    params, 1
  );

  if(!thread_loop){
    if (debug){
      pw_main_loop_run(loop); /// block the process, until pw_main_loop_quit() 
    }
    else{
      thread_loop = pw_thread_loop_new_full(pw_main_loop_get_loop(loop), "audio_thread", NULL);
      pw_thread_loop_start(thread_loop);
    }
  }


  return 0;
}

void close_audio(bool closePipeWire){
  if (!audio_stream) return;

  stop_pipewire(audio_stream, closePipeWire);
}

#ifdef AUDIO_STANDALONE
void main(void){
  start_pipewire();
  create_audio_listener(NULL, true, &audio_debug);
}
#endif

// gcc -shared -fPIC -o _builded/libaudio_listener.so audio_listener.c base.c $(pkg-config --cflags --libs libpipewire-0.3)
// gcc -DAUDIO_STANDALONE -fPIC -o ../_builded/alistener audio_listener.c base.c $(pkg-config --cflags --libs libpipewire-0.3)