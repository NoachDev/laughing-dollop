native=../lib/native/
build=${native}/_builded/

mkdir -p ${build}

gcc -shared -fPIC -o ${build}lib_native_resources.so ${native}linux/audio_listener.c ${native}linux/base.c $(pkg-config --cflags --libs libpipewire-0.3)
gcc -DAUDIO_STANDALONE -fPIC -o ${build}alistener ${native}linux/audio_listener.c ${native}linux/base.c $(pkg-config --cflags --libs libpipewire-0.3)

${build}alistener