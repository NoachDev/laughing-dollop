#define _GNU_SOURCE
#include "virtual_mic.h"
#include "base.h"
#include <pipewire/pipewire.h>
#include <spa/param/audio/format-utils.h>
#include <spa/param/audio/raw.h>
#include <spa/param/props.h>
#include <spa/pod/builder.h>
#include <spa/utils/string.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

static struct pw_stream *mic_stream = NULL;
// static struct PipeWireFunctions data;

uint32_t RATE = 48000;
static const char *NODE_MIC_NAME = "virtual_mic_from_c";
static double phase = 0.0;

struct spa_pod *make_audio_format(struct spa_pod_builder *builder){
  return spa_format_audio_raw_build(
    builder, SPA_PARAM_EnumFormat,
    &SPA_AUDIO_INFO_RAW_INIT(
      .format = SPA_AUDIO_FORMAT_S16_LE,
      .rate = RATE,
      .channels = CHANNELS
    )
  );
}

/// @brief Send data to microphone, only call after [create_virtual_mic]
/// @param frames_buf 
/// @param frames_count 
/// @return 
int write_frames(int16_t *frames_buf, size_t frames_count){
  if (!mic_stream) return -1;
  
  struct pw_buffer *b = pw_stream_dequeue_buffer(mic_stream);
  struct spa_buffer *buf;
  int16_t *dst;
  
  buf = b->buffer;
  
  if (b == NULL){
    pw_log_warn("out of buffers: %m");
    return -1;
  }
  
  size_t stride = CHANNELS * sizeof(int16_t);
  dst = buf->datas[0].data;

  if (dst == NULL) return -1;

  memcpy(dst, frames_buf, frames_count * stride);
  
  buf->datas[0].chunk->offset = 0;
  buf->datas[0].chunk->stride = stride;
  buf->datas[0].chunk->size = frames_count * stride;
  
  pw_stream_queue_buffer(mic_stream, b);

  return 0;

}

/// Send a sin wave to microphone, debug only
///
/// for see the sin wave open an recorder.
void on_process_mic(void *data) {
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

  write_frames(buf, block);
  free(buf);
  
}

// Crete one virtual mic
int create_virtual_mic(char *name, bool debug){
  if (mic_stream) return 0; // already created

  struct pw_properties *props = pw_properties_new(
    PW_KEY_NODE_NAME, "virtual-microphone",
    PW_KEY_MEDIA_CLASS, "Audio/Source",
    PW_KEY_MEDIA_ROLE, "virtual",
    NULL
  );

  mic_stream = pw_stream_new(core, name ? name : NODE_MIC_NAME, props); /// The chanel for wirite in microphone

  if (!mic_stream) return -1;

  if (debug){ /// Enable debug funtions and logs
    static struct pw_stream_events events = { PW_VERSION_STREAM_EVENTS };
    events.state_changed = stream_state_changed; 
    events.process = on_process_mic; 

    pw_stream_add_listener(mic_stream, &stream_listener, &events, NULL); 
  }

  uint8_t buffer[1024];
  struct spa_pod_builder builder = SPA_POD_BUILDER_INIT(buffer, sizeof(buffer));
  const struct spa_pod *params[1];
  params[0] = make_audio_format(&builder);

  int res = pw_stream_connect(
    mic_stream,
    PW_DIRECTION_OUTPUT, /// we provide a source: other apps read from our output
    PW_ID_ANY,
    PW_STREAM_FLAG_AUTOCONNECT | PW_STREAM_FLAG_MAP_BUFFERS | PW_STREAM_FLAG_RT_PROCESS,
    params,
    1
  );

  if (res < 0){
    return -1;
  }
  
  if(!thread_loop){
    if (debug){
      pw_main_loop_run(loop); /// block the process, until pw_main_loop_quit() 
    }
    else{
      thread_loop = pw_thread_loop_new_full(pw_main_loop_get_loop(loop), "mic_thread", NULL);
      pw_thread_loop_start(thread_loop);
    }
  }


  return 0;
  
}

void close_mic(bool closePipeWire){
  if (!mic_stream) return;

  stop_pipewire(mic_stream, closePipeWire);
} 

#ifdef VMIC_STANDALONE
void main(void){
  start_pipewire();
  create_virtual_mic(NULL, true); // allowed logs
}
#endif
// mkdir _builded &&
// gcc -shared -fPIC -o _builded/libvirtual_mic.so virtual_mic.c base.c $(pkg-config --cflags --libs libpipewire-0.3)
// gcc -Wall -DVMIC_STANDALONE -fPIC -o ../_builded/mic virtual_mic.c base.c $(pkg-config --cflags --libs libpipewire-0.3) -lm