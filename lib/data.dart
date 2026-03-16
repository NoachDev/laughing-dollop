import 'dart:async';
import 'dart:typed_data';
import 'package:laughing_dollop/native/bindings/microphone.dart';
import 'package:laughing_dollop/srt.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

final record = AudioRecorder();
final mic = Microphone();

bool ms = false;

const int sampleRate = 48000;
const int numChannels = 2;

bool micState = false;
bool camState = false;

Future<bool> get newMicState async {
  final mic = await Permission.microphone.request();
  return mic.isGranted;
}

Future<bool> get newCamState async {
  final cam = await Permission.camera.request();
  return cam.isGranted;
}

Future<void> startMicStream() async {
  final streamR = await record.startStream(const RecordConfig(
      bitRate: 1536000,
      encoder: AudioEncoder.pcm16bits,
      sampleRate: sampleRate,
      numChannels: numChannels,
      noiseSuppress: false,
      echoCancel: false));

  streamR.listen((data) async {
    bool isNull = data.every((elm) => elm == 0);

    if (!isNull) {
      micHandle?.sendStream(Uint8List.fromList(data), chunked: true);
    }
  });
}