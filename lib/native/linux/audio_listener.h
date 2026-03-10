#ifndef AL
#define AL
#include <stdint.h>
#include <stdbool.h>

void audio_debug(uint8_t *data, int size);
void on_process_audio(void *data);
int create_audio_listener(char *name, bool debug, void (*listener)(uint8_t *data, int size));
void close_audio(bool closePipeWire);

#endif // AL