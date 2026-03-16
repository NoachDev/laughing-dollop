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
#include <spa/utils/ringbuffer.h>
#include <sys/time.h>

static struct pw_stream *mic_stream = NULL;
static struct mic_config mic = {};

size_t stride = CHANNELS * sizeof(int16_t);

static double phase = 0.0;

static struct spa_pod *make_audio_format(struct spa_pod_builder *builder, uint32_t rate){
  return spa_format_audio_raw_build(
    builder, SPA_PARAM_EnumFormat,
    &SPA_AUDIO_INFO_RAW_INIT(
      .format = SPA_AUDIO_FORMAT_S16_LE,
      .rate = rate,
      .channels = CHANNELS
    )
  );
}

/// @brief Add data to be writed on microphone
///
/// @param frame_buf the raw pcm16 data
/// @param sample_count num of samples per chanel
/// @param perishable set the data as perishable.
/// When the mic is unavailable the perishable data is losted ( The add_data return without write on buffer ).
/// @return 
int add_data(int16_t *frame_buf, size_t sample_count, bool perishable){
  if (!mic_stream) return -1;
  
  
  uint32_t w_index, avail, filled;

  while (sample_count > 0) {

    while (true){
      filled = spa_ringbuffer_get_write_index(&mic.ring, &w_index);
    
      avail = BUFFER_SIZE - filled;

      if (avail > 0)
        break;

      if (perishable){
        enum pw_stream_state state = pw_stream_get_state(mic_stream, NULL);

        if (state != PW_STREAM_STATE_STREAMING){
          return -1;
        }

      }
  
    }

    if (avail > sample_count){
      avail = sample_count;
    }

    spa_ringbuffer_write_data(&mic.ring,
      mic.buffer, BUFFER_SIZE * stride,
      (w_index % BUFFER_SIZE) * stride,
      frame_buf, avail * stride);

    spa_ringbuffer_write_update(&mic.ring, w_index + avail);

    sample_count -= avail;

  }

  return sample_count;
}

static void on_process(void *data){
  if (!mic_stream) return;

  struct mic_config * mic = data;
  
  struct pw_buffer *b = pw_stream_dequeue_buffer(mic_stream);
  
  if (b == NULL){
    pw_log_warn("out of buffers: %m");
    return;
  }
  
  int32_t avail;
  uint32_t index;

  avail = spa_ringbuffer_get_read_index(&mic->ring, &index);

  if (avail < 0){
    return;
  }

  struct spa_buffer *buf;
  int16_t *dst;
  
  buf = b->buffer;
  dst = buf->datas[0].data;
  
  if (dst == NULL) return;

  int32_t n_frames = buf->datas[0].maxsize / stride;
  
  int32_t frames_count = SPA_MIN(avail, n_frames);
  
  spa_ringbuffer_read_data(&mic->ring,
    mic->buffer, BUFFER_SIZE * stride,
    (index % BUFFER_SIZE) * stride,
    dst,
    frames_count * stride
  );

  spa_ringbuffer_read_update(&mic->ring, index + frames_count);
  
  buf->datas[0].chunk->offset = 0;
  buf->datas[0].chunk->stride = stride;
  buf->datas[0].chunk->size = frames_count * stride;
  
  pw_stream_queue_buffer(mic_stream, b);

}

// Crete one virtual mic
int create_virtual_mic(const char *name, uint32_t rate, bool debug){
  if (mic_stream) return 0; // already created

  struct pw_properties *props = pw_properties_new(
    PW_KEY_NODE_NAME, "virtual-microphone",
    PW_KEY_MEDIA_CLASS, "Audio/Source",
    PW_KEY_MEDIA_ROLE, "virtual",
    NULL
  );

  mic_stream = pw_stream_new(core, name, props); /// The chanel for write in microphone

  if (!mic_stream) return -1; /// error on create the stream
  
  spa_ringbuffer_init(&mic.ring); /// create / initilize the ring buffer

  static struct pw_stream_events events = { PW_VERSION_STREAM_EVENTS };
  
  if (debug){
    events.state_changed = stream_state_changed; /// Enable logs
  }
  
  events.process = on_process; 

  pw_stream_add_listener(mic_stream, &stream_listener, &events, &mic); 

  uint8_t buffer[1024];
  struct spa_pod_builder builder = SPA_POD_BUILDER_INIT(buffer, sizeof(buffer));
  const struct spa_pod *params[1];
  params[0] = make_audio_format(&builder, rate);

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
    // thread_loop = pw_thread_loop_new_full(pw_main_loop_get_loop(loop), "mic_thread", NULL);
    // pw_thread_loop_start(thread_loop);
  }

  return 0;
  
}

void close_mic(bool closePipeWire){
  if (!mic_stream) return;

  stop_pipewire(mic_stream, closePipeWire);
} 

#ifdef VMIC_STANDALONE

/// Send a sin wave to microphone, debug only
///
/// for see the sin wave open an recorder.
///
/// on left side, a normal sin wave
/// on right chanel the inverse value of in left.
///
static void on_debug() {
  while (true){
    const size_t block = 256;
    double inc = 2*M_PI / 48000;
  
    if (phase > 2*M_PI){
      phase = 0.0;
    }
  
    int16_t *buf = malloc(sizeof(int16_t) * block);
  
    for (size_t i = 0; i < block; i += 2) {
      int16_t l = (int16_t)(sin(phase) * 32767.0);
      int16_t r = (int16_t)(sin(phase + M_PI) * 32767.0);
      buf[i] = l; // left chanel
      buf[i+1] = r; // right chanel
      phase += inc;
    }
  
    add_data(buf, block/2, false);
    
    free(buf);
  }

}

void main(void){
  start_pipewire();
  create_virtual_mic("virtual_mic_from_c", 48000, true); // allowed logs
  on_debug(&mic);
}
#endif
// mkdir _builded &&
// gcc -shared -fPIC -o _builded/libvirtual_mic.so virtual_mic.c base.c $(pkg-config --cflags --libs libpipewire-0.3)
// gcc -Wall -DVMIC_STANDALONE -fPIC -o ../_builded/mic virtual_mic.c base.c $(pkg-config --cflags --libs libpipewire-0.3) -lm