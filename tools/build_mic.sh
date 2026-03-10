native=../lib/native/
build=${native}/_builded/

mkdir -p ${build}

gcc -shared -fPIC -o ${build}libvirtual_mic.so ${native}linux/virtual_mic.c ${native}linux/base.c $(pkg-config --cflags --libs libpipewire-0.3)
gcc -DVMIC_STANDALONE -fPIC -o ${build}mic ${native}linux/virtual_mic.c ${native}linux/base.c $(pkg-config --cflags --libs libpipewire-0.3) -lm &&

${build}mic