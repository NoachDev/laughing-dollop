import 'dart:ffi';
import 'dart:typed_data';

import 'package:laughing_dollop/native/bindings/audio_listener.dart';
import 'package:laughing_dollop/native/bindings/microphone.dart';

void main() async{
  // Microphone.start();
  AudioListener.start();

  await for (final data in AudioListener.stream){
    print(data);
  }
}
