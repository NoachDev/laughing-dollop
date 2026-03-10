import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:laughing_dollop/native/bindings/base.dart';

typedef NativeListener = ffi.Void Function(
    ffi.Pointer<ffi.Uint8> data, ffi.Int size);

class AudioListener extends Base {
  static final _streamControl = StreamController<Uint8List>.broadcast();
  static late ffi.NativeCallable<NativeListener> nativeCallback;
  static bool audioInitalized = false;

  static final _create = native.lookupFunction<
          ffi.Int Function(ffi.Pointer<Utf8>, ffi.Bool,
              ffi.Pointer<ffi.NativeFunction<NativeListener>>),
          int Function(ffi.Pointer<Utf8> name, bool logs,
              ffi.Pointer<ffi.NativeFunction<NativeListener>> listener)>(
      "create_audio_listener");

  static Stream<Uint8List> get stream => _streamControl.stream;

  static void start() async {
    if (!audioInitalized) {
      audioInitalized = true;
      Base.startP();
      nativeCallback = ffi.NativeCallable<NativeListener>.listener(
          (ffi.Pointer<ffi.Uint8> data, int size) {
        _streamControl.sink.add(data.asTypedList(data.value));
      });

      _create("laughing_dollop_mic".toNativeUtf8(), false,
          nativeCallback.nativeFunction);
    }
  }

  static void close() {
    if (audioInitalized) {
      audioInitalized = false;
      Base.closeP();
      nativeCallback.close();
      _streamControl.sink.close();
    }
  }
}
