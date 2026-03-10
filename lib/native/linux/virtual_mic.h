#ifndef VM
#define VM
#include <stdint.h>
#include <spa/param/audio/format-utils.h>

struct spa_pod *make_audio_format(struct spa_pod_builder *builder);
int write_frames(int16_t *frames_buf, size_t frames_count);
void on_process_mic(void *data);
int create_virtual_mic(char *name, bool debug);
void close_mic(bool closePipeWire);

#endif // VM