native=../lib/native/
build=${native}/_builded/

mkdir -p ${build}

gcc -shared -fPIC -o ${build}lib_native_resources.so ${native}audio_listener.c ${native}/base.c $(pkg-config --cflags --libs libpipewire-0.3)
gcc -DAUDIO_STANDALONE -fPIC -o ${build}/alistener audio_listener.c base.c $(pkg-config --cflags --libs libpipewire-0.3)

${build}alistener