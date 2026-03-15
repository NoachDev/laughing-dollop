#ifndef VM
#define VM
#include <stdint.h>
#include <spa/param/audio/format-utils.h>

struct mic_config {
  uint32_t RATE;
  const char *NAME;
  void (*listener)(void *data);
};

int write_frames(int16_t *frames_buf, size_t frames_count);
int create_virtual_mic(struct mic_config *mic, bool debug);
void close_mic(bool closePipeWire);

#endif // VM