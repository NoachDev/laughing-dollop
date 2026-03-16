import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:laughing_dollop/native/bindings/base.dart';

final _micNative = native.lookupFunction<
    ffi.Int Function(ffi.Pointer<Utf8>, ffi.Int, ffi.Bool),
    int Function(ffi.Pointer<Utf8> mic, int rate, bool logs)>("create_virtual_mic");

final _writeNative = native.lookupFunction<
    ffi.Int Function(ffi.Pointer<ffi.Int16>, ffi.UintPtr, ffi.Bool),
    int Function(
        ffi.Pointer<ffi.Int16> framesBuf, int framesCount, bool perishable)>("add_data");

typedef NativeListener = ffi.Void Function(ffi.Pointer<ffi.Void> data);


class Microphone extends Base {
  bool micRInitalized = false;

  /// add data to be writed on microphone
  set addData(Uint8List frame) {
    ByteData byteData = frame.buffer.asByteData();
    final int16lenght = byteData.lengthInBytes ~/ 2;

    final samples = calloc<ffi.Int16>(int16lenght);

    /// copy the frame to the native farame buffer
    for (int i = 0; i < int16lenght; i ++) {
      /// transform / get the data in a int16 format
      int sample = byteData.getInt16(i*2, Endian.little); 
      /// copy the sample to the frame buffer
      samples[i] = sample;
    }

    /// call the native function to write the data on ring buffer
    _writeNative(samples, int16lenght ~/2, true);
  }

  Microphone();

  /// Start the mic
  /// 
  /// [rate] num of sample per second 
  /// [name] the name to be appear on devices
  /// 
  void start([int rate = 48000, String name = "laughing-dollop_mic"]) {
    /// start the pipewire
    Base.startP();
    /// signaling of the mic is ready
    micRInitalized = true;
    /// creating the mic
    _micNative(name.toNativeUtf8(), rate, false);

  }

  void close() {
    if (micRInitalized) {
      Base.closeP();
      micRInitalized = false;
    }
  }
}
