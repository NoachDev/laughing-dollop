import 'dart:collection';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:laughing_dollop/native/bindings/base.dart';

final _mic = native.lookupFunction<
    ffi.Int Function(ffi.Pointer<_MicConfig>, ffi.Bool),
    int Function(ffi.Pointer<_MicConfig> mic, bool logs)>("create_virtual_mic");

final _writeNative = native.lookupFunction<
    ffi.IntPtr Function(ffi.Pointer<ffi.Int16>, ffi.UintPtr),
    int Function(
        ffi.Pointer<ffi.Int16> framesBuf, int framesCount)>("write_frames");

typedef NativeListener = ffi.Void Function(ffi.Pointer<ffi.Void> data);

/// the configuartion of the mic
/// 
/// [rate] num of sample per second 
/// [name] the name to be appear on devices
/// [listener] a intern callbeck
/// 
final class _MicConfig extends ffi.Struct {
  @ffi.Uint32()
  external int rate;

  external ffi.Pointer<Utf8> name;

  external ffi.Pointer<ffi.NativeFunction<NativeListener>> listener;
}

class Microphone extends Base {
  bool micRInitalized = false;
  final _queue = Queue<List<int>>();
  late ffi.NativeCallable<NativeListener> listener;

  /// add data to be writed on microphone
  set addData(Uint8List frame) {
    ByteData byteData = frame.buffer.asByteData();

    final samples = <int>[];
    for (int i = 0; i < byteData.lengthInBytes; i += 2) {
      int sample = byteData.getInt16(i, Endian.little); 
      samples.add(sample);
    }

    _queue.add(samples);
  }

  int get queueLength => _queue.length;

  Microphone();

  /// on avaliable, write on microphone
  /// 
  void _onProcess(ffi.Pointer<ffi.Void> data) {
    if (_queue.isNotEmpty) {
      _write(_queue.removeFirst());
    }
  }

  // void _write(Int16List frame) {
  void _write(List<int> frame) {
    if (!micRInitalized) throw Exception("Microphone not initialized");

    final buf = calloc<ffi.Int16>(frame.length);

    try {
      
      /// copy the bytes to buffer
      for (var i = 0; i < frame.length; i++) {
        buf[i] = frame[i];
      }

      _writeNative(buf, frame.length ~/ 2);
    } finally {
      calloc.free(buf);
    }
  }

  void start([int rate = 48000]) {
    /// start the pipewire
    Base.startP();
    /// signaling of the mic is ready
    micRInitalized = true;

    /// the callback to write the data of queue on microphone
    listener = ffi.NativeCallable<NativeListener>.listener(_onProcess);
    
    /// alocate the _MicConfig on heap
    /// and configure the intern fields
    /// 
    final mic = calloc<_MicConfig>();
    mic.ref.name = "laughing_dollop_mic".toNativeUtf8();
    mic.ref.rate = rate;
    mic.ref.listener = listener.nativeFunction;

    _mic(mic, false);


    /// free the _MicConfig on fineshed the creation of mic
    ///  
    calloc.free(mic);
  }

  void close() {
    if (micRInitalized) {
      micRInitalized = false;
      listener.close();
      Base.closeP();
    }
  }
}
