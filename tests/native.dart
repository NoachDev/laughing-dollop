import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:laughing_dollop/native/bindings/audio_listener.dart';
import 'package:laughing_dollop/native/bindings/microphone.dart';
import 'package:wav/wav.dart';

void main() async {
  // /// helper
  // ///
  // final wav = await Wav.readFile("tests/sound.wav");

  // /// the raw pcm16 data in a Uint8List format
  // ///
  // final data = await readWavPcm("tests/sound.wav");

  // final duration = Duration(milliseconds: 20);

  // /// buffer of samples
  // ///
  // /// num of samples to directely write on mic
  // final block = wav.samplesPerSecond / 1000 * duration.inMilliseconds;
  // final bytePerBlock =
  //     block.truncate() * 2; // pcm16 -> 16 bits per sample = 2 bytes

  // final split = data.lengthInBytes ~/ bytePerBlock;

  /// start the microphone.
  ///
  /// 48000 of sample rate
  /// 2 chanels
  ///
  final mic = Microphone();
  mic.start();
  // mic.start(wav.samplesPerSecond);

  // print(bytePerBlock);
  // print(split);

  await Future.delayed(Duration(seconds: 1));

  print("start w");

  double phase = 0;
  final double inc = 2 * pi / 48000;
  final List<int> send = [];

  for (var i = 0; i < 1000; i++) {
    // final send = data.sublist(i * bytePerBlock, (i + 1) * bytePerBlock);
    final send =
        List<int>.generate(256, (j) => (sin(phase += inc) * 32767).truncate());
    Int16List samples16 = Int16List.fromList(send);

    mic.addData = samples16.buffer.asUint8List();
  }

  while (mic.queueLength > 0) {
    await Future.delayed(Duration(seconds: 3));
    print("loop");
    print(mic.queueLength);
  }
  print("finished");
  

}

Future<Uint8List> readWavPcm(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  final buffer = bytes.buffer;
  final view = ByteData.view(buffer);

  int offset = 0;

  // Check RIFF header
  if (bytes.length < 12) throw FormatException('Not a valid WAV (too small).');
  final riff = String.fromCharCodes(bytes.sublist(0, 4));
  final wave = String.fromCharCodes(bytes.sublist(8, 12));
  if (riff != 'RIFF' || wave != 'WAVE')
    throw FormatException('Not a RIFF/WAVE file.');

  offset = 12;

  while (offset + 8 <= bytes.length) {
    final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final chunkSize = view.getUint32(offset + 4, Endian.little);
    final dataStart = offset + 8;

    if (id == 'data') {
      if (dataStart + chunkSize > bytes.length)
        throw FormatException('Truncated data chunk.');
      return bytes.sublist(dataStart, dataStart + chunkSize);
    }

    // Move to next chunk. Chunks are padded to even length.
    var advance = 8 + chunkSize;
    if (chunkSize % 2 == 1) advance += 1;
    offset += advance;
  }

  throw FormatException('No data chunk found in WAV file.');
}
