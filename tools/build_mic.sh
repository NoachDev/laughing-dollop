native=../lib/native/
linux=../linux/
tests=../tests/

gcc -shared -fPIC -o ${native}libvirtual_mic.so ${native}virtual_mic.c $(pkg-config --cflags --libs libpipewire-0.3)

cp -f ${native}libvirtual_mic.so ${linux}
cp -f ${native}libvirtual_mic.so ${tests}

rm ${native}libvirtual_mic.so