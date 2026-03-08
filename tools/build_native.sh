native=../lib/native/
linux=../linux/
tests=../tests/
build=${native}/_builded/

mkdir -p ${build}

gcc -shared -fPIC -o ${build}lib_native_resources.so ${native}linux/virtual_mic.c ${native}linux/base.c ${build}linux/audio_listener.c $(pkg-config --cflags --libs libpipewire-0.3)

cp -f ${build}lib_native_resources.so ${linux}
cp -f ${build}lib_native_resources.so ${tests}

rm ${build}lib_native_resources.so
