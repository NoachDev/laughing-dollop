#include "base.h"
#include <pipewire/pipewire.h>

bool initiailized = false;
uint32_t CHANNELS = 2;
struct spa_hook stream_listener;
struct pw_main_loop *loop;
struct pw_context *context;
struct pw_core *core;
struct pw_registry *registry;
struct pw_thread_loop *thread_loop = NULL;

void start_pipewire(void){
  if (initiailized) return;
  
  pw_init(NULL, NULL); /// start the pipewire.
  initiailized = true;

  loop = pw_main_loop_new(NULL); /// the main function for blok the process
  context = pw_context_new(pw_main_loop_get_loop(loop), NULL, 0);
  core = pw_context_connect(context, NULL, 0);
  registry = pw_core_get_registry(core, PW_VERSION_REGISTRY, 0);
}

void stop_pipewire(struct pw_stream *stream, bool close){
  if (!initiailized) return;

  if (thread_loop){
    pw_thread_loop_stop(thread_loop);
    pw_thread_loop_destroy(thread_loop);
  }

  pw_stream_destroy(stream);
  pw_main_loop_destroy(loop);
  pw_context_destroy(context);
  pw_core_disconnect(core);

  if(close){
    pw_deinit();
    initiailized = false;
  }

}

// Stream callbacks
void stream_state_changed(void *data, enum pw_stream_state old, enum pw_stream_state state, const char *error){
  fprintf(stderr, "stream state: %s\n", pw_stream_state_as_string(state));

  if (state == PW_STREAM_STATE_ERROR)
      fprintf(stderr, "stream error: %s\n", error);
}