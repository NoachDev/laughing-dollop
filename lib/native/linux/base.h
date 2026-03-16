#ifndef BASE_H
#define BASE_H
#include <stddef.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pipewire/pipewire.h>

#define CHANNELS  2

// Configuartions
extern uint32_t RATE;

// PipeWiere base functions
extern struct spa_hook stream_listener;
extern struct pw_thread_loop *thread_loop;
extern struct pw_main_loop *loop;
extern struct pw_context *context;
extern struct pw_core *core;
extern struct pw_registry *registry;

void start_pipewire(void);
void stop_pipewire(struct pw_stream *stream, bool close);
void stream_state_changed(void *data, enum pw_stream_state old, enum pw_stream_state state, const char *error);

#endif // BASE_H