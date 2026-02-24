import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:laughing_dollop/native/bindings/microphone.dart';
import 'package:laughing_dollop/srt.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

final record = AudioRecorder();

Future<List<bool>> get status async {
  if (Platform.isLinux) return [true, true];
  final mic = await Permission.microphone.request();
  final cam = await Permission.camera.request();
  return [mic.isGranted, cam.isGranted];
}

void disposeMicRecv() {
  if (micRInitalized) {
    final close = micDylb
        .lookupFunction<ffi.Void Function(), void Function()>("stop_pipewire");
    close();
    micRInitalized = false;
  }
}

Future<void> startMicRecv() async {
  if (!micRInitalized) {
    start();

    mic("laughing_dollop_mic".toNativeUtf8(), false);
    micRInitalized = true;

    await clientAudio.waitStream(onReceive: (data) {
      // final bd = ByteData.sublistView(data);
      final buf = calloc<ffi.Int16>(data.length);

      for (var i = 0; i < data.length; i++) {
        buf[i] = data[i];
      }

      write(buf, data.length);

      calloc.free(buf);
    });
  }
}

Future<void> startMicStream() async {
  final stream = await record
      .startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));

  stream.listen((data) {
    bool isNull = data.every((elm) => elm == 0);
    // final newData = "hello how are you ? Im fine you too? Yes".codeUnits;
    if (!isNull) {
      audioHandle?.sendStream(Uint8List.fromList(data), chunked: true);
    }
  });
}
