import 'dart:ffi' as ffi;

final native = loadLibrary("lib_native_resources.so");
 
ffi.DynamicLibrary loadLibrary(String name) {
  try {
    return ffi.DynamicLibrary.open(name);
  } catch (e) {
    return ffi.DynamicLibrary.open("test/$name");
  }
}

abstract class Base{
  static final startP = native
      .lookupFunction<ffi.Void Function(), void Function()>("start_pipewire");

  static final closeP = native
      .lookupFunction<ffi.Void Function(), void Function()>("stop_pipewire");
}