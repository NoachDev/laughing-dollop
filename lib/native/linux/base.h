#ifndef BASE_H
#define BASE_H
#include <stddef.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pipewire/pipewire.h>

// Configuartions
extern uint32_t RATE;
extern uint32_t CHANNELS;
extern const char *NODE_MIC_NAME;
extern const char *NODE_AUDIO_NAME;
extern bool initiailized;

// PipeWiere base functions
extern struct pw_main_loop *loop;
extern struct pw_context *context;
extern struct pw_core *core;
extern struct pw_stream *mic_stream;
extern struct pw_stream *audio_stream;
extern struct spa_hook stream_listener;
extern struct pw_registry *registry;
extern struct pw_thread_loop *thread_loop;

void start_pipewire(void);
void stop_pipewire(void);
void stream_state_changed(void *data, enum pw_stream_state old, enum pw_stream_state state, const char *error);

#endif // BASE_H