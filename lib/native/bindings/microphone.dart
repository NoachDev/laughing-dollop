import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

ffi.DynamicLibrary get micDylb {
  try {
    return ffi.DynamicLibrary.open("libvirtual_mic.so");
  } catch (e) {
    return ffi.DynamicLibrary.open("tests/libvirtual_mic.so");
  }
}

class Microphone {
  static final _start = micDylb
      .lookupFunction<ffi.Void Function(), void Function()>("start_pipewire");

  static final _mic = micDylb.lookupFunction<
      ffi.Int Function(ffi.Pointer<Utf8>, ffi.Bool),
      int Function(ffi.Pointer<Utf8> name, bool logs)>("create_virtual_mic");

  static final write = micDylb.lookupFunction<
      ffi.IntPtr Function(ffi.Pointer<ffi.Int16>, ffi.UintPtr),
      int Function(
          ffi.Pointer<ffi.Int16> framesBuf, int framesCount)>("wirite_frames");

  static final _close = micDylb
      .lookupFunction<ffi.Void Function(), void Function()>("stop_pipewire");

  static bool micRInitalized = false;

  static void start() {
    if (!micRInitalized) {
      _start();
      micRInitalized = true;
      _mic("laughing_dollop_mic".toNativeUtf8(), false);
    }
  }

  static void close() {
    if (micRInitalized) {
      micRInitalized = false;
      _close();
    }
  }
}
