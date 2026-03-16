#include "virtual_mic.h"
#include "audio_listener.h"
#include "base.h"

#ifdef NATIVE_STANDALONE
void main(void){
  start_pipewire();
  create_virtual_mic("native_mic", 48000, true);
  create_audio_listener(NULL, true, &audio_debug);

}
#endif


//gcc -DNATIVE_STANDALONE -fPIC -o ../_builded/native native_resource.c virtual_mic.c audio_listener.c base.c $(pkg-config --cflags --libs libpipewire-0.3) -lm