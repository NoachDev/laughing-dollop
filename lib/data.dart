import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
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

Future<void> startMicStream() async {
  final stream = await record
      .startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));

  stream.listen((data) {
    bool isNull = data.every((elm) => elm == 0);
    if (!isNull) {}
    micHandle?.sendStream(Uint8List.fromList(data), chunked: true);
  });
}
