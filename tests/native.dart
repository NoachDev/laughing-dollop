import 'dart:io';
import 'dart:typed_data';

import 'package:laughing_dollop/native/bindings/microphone.dart';
import 'package:wav/wav.dart';

void main() async {
  /// helper
  ///
  final wav = await Wav.readFile("tests/sound.wav");

  /// the raw pcm16 data in a Uint8List format
  ///
  final data = await readWavPcm("tests/sound.wav");

  final duration = Duration(milliseconds: 20);

  /// buffer of samples
  ///
  /// num of samples to directely write on mic
  final block = wav.samplesPerSecond / 1000 * duration.inMilliseconds;
  final bytePerBlock = block.truncate() * 2; // pcm16 -> 16 bits per sample = 2 bytes

  final split = data.lengthInBytes ~/ bytePerBlock;

  final mic = Microphone();

  /// start the microphone.
  ///
  /// 48000 of sample rate
  /// 2 chanels
  ///
  mic.start(wav.samplesPerSecond);

  print(bytePerBlock);
  print(split);

  print("start the recorder");
  await Future.delayed(Duration(seconds: 1));

  for (int i = 0; i < split; i++) {
    mic.addData = data.sublist(i * bytePerBlock, (i + 1) * bytePerBlock);
  }

  while (true) {
    await Future.delayed(Duration(seconds: 1));
  }


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
