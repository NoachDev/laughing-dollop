import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:laughing_dollop/native/bindings/base.dart';

class Microphone extends Base{
  static final _mic = native.lookupFunction<
      ffi.Int Function(ffi.Pointer<Utf8>, ffi.Bool),
      int Function(ffi.Pointer<Utf8> name, bool logs)>("create_virtual_mic");

  static final write = native.lookupFunction<
      ffi.IntPtr Function(ffi.Pointer<ffi.Int16>, ffi.UintPtr),
      int Function(
          ffi.Pointer<ffi.Int16> framesBuf, int framesCount)>("wirite_frames");

  static bool micRInitalized = false;

  static void start() {
    if (!micRInitalized) {
      Base.startP();
      micRInitalized = true;
      _mic("laughing_dollop_mic".toNativeUtf8(), false);
    }
  }

  static void close() {
    if (micRInitalized) {
      micRInitalized = false;
      Base.closeP();
    }
  }
}
