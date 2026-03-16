#ifndef VM
#define VM
#include <stdint.h>
#include "base.h"
#include <spa/param/audio/format-utils.h>
#include <spa/utils/ringbuffer.h>

#define BUFFER_SIZE (16*1024)

struct mic_config {
  struct spa_ringbuffer ring;
  struct spa_source *refill_event;

  int16_t buffer[BUFFER_SIZE * CHANNELS];
};

int create_virtual_mic(const char *name, uint32_t rate, bool debug);
int add_data(int16_t *frames_buf, size_t frames_count, bool perishable);
void close_mic(bool closePipeWire);

#endif // VM