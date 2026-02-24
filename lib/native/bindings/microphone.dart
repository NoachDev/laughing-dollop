import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

ffi.DynamicLibrary get micDylb {
  try {
    return ffi.DynamicLibrary.open("libvirtual_mic.so");
  }
  catch (e){
    return ffi.DynamicLibrary.open("tests/libvirtual_mic.so");
  }
}

final start = micDylb
    .lookupFunction<ffi.Void Function(), void Function()>("start_pipewire");

final mic = micDylb.lookupFunction<
    ffi.Int Function(ffi.Pointer<Utf8>, ffi.Bool),
    int Function(ffi.Pointer<Utf8> name, bool logs)>("create_virtual_mic");

final write = micDylb.lookupFunction<
    ffi.IntPtr Function(ffi.Pointer<ffi.Int16>, ffi.UintPtr),
    int Function(
        ffi.Pointer<ffi.Int16> framesBuf, int framesCount)>("wirite_frames");

bool micRInitalized = false;