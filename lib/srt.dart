import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:laughing_dollop/data.dart';
import 'package:laughing_dollop/native/bindings/audio_listener.dart';
import 'package:laughing_dollop/native/bindings/microphone.dart';
import 'package:laughing_dollop/util.dart';
import 'package:srt_dart/srt_dart.dart';

SrtSocket? audioHandle;
SrtSocket? micHandle;
SrtSocket? camHandle;

late final SrtSocket server;
late final SrtSocket clientAudio;
late final SrtSocket clientCam;
late final SrtSocket clientMic;
late final SrtEpoll epoll;

bool serverInitilized = false;

Future<void> initServer() async {
  if (serverInitilized) return;

  late InternetAddress ip;

  if (Platform.isAndroid) {
    ip = InternetAddress.loopbackIPv4;
  } else {
    ip = await Configurations.address;
  }


  server.bind(ip, Configurations.port);
  server.listen(backlog: 3);

  serverInitilized = true;

  audioHandle = await server.accept;
  micHandle = await server.accept;
  camHandle = await server.accept;

  startMicStream();

}

Future<void> connect(InternetAddress ip, int port) async {
  clientAudio.connect(ip, port);
  clientMic.connect(ip, port);
  Microphone.start();

  /// server accept wating ...
  /// certfing of audio and mic already connected in your handles
  await Future.delayed(Duration(microseconds: 10));
  clientCam.connect(ip, port);

  epoll.register(clientMic, events: [EpollEventType.read]);

}

Future<void> initializeSRT() async {
  /// The SrtSocket set by default the options
  /// - Live Mode, and
  /// - Sender: true.
  ///
  server = SrtSocket();
  clientAudio = SrtSocket();
  clientMic = SrtSocket();
  clientCam = SrtSocket();
  epoll = SrtEpoll();
  epoll.timeOutMs = 1000;

  await for( final event in epoll.waitStream(stopOnTimeout: false)){
    final data = await event.socket.recvStream;
    final buf = calloc<ffi.Int16>(data.length);

    for (var i = 0; i < data.length; i++) {
      buf[i] = data[i];
    }

    Microphone.write(buf, data.length);

    calloc.free(buf);
  }

}
