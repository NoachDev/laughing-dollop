import 'dart:io';

import 'package:laughing_dollop/data.dart';
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

bool _serverInitilized = false;

Future<void> waitClient() async{
  if (!_serverInitilized) throw Exception("Server uninitailed");

  audioHandle = await server.accept;
  micHandle = await server.accept;
  camHandle = await server.accept;
  
  /// TODO : retrive the audio from client to server
  // epoll.register(audioHandle!, events: [EpollEventType.read]);
  // await for (final event in epoll.waitStream(stopOnTimeout: false)) {
  //   final data = await event.socket.recvStream;
  // }
}

Future<bool> get serverStatus async {
  if (!_serverInitilized){
    final InternetAddress ip = await Configurations.address;

    server.bind(ip, Configurations.port);
    server.listen(backlog: 3);

    _serverInitilized = true;

  }

  return _serverInitilized;

}

Future<void> connect(InternetAddress ip, int port) async {
  await clientAudio.connect(ip, port);
  await clientMic.connect(ip, port);
  mic.start();

  await clientCam.connect(ip, port);
  epoll.register(clientMic, events: [EpollEventType.read]);

  // AudioListener.start();

  // AudioListener.stream.listen((Uint8List data) {
  //   clientAudio.sendStream(data);
  // });

  await for (final event in epoll.waitStream(stopOnTimeout: false)) {
    final data = await event.socket.recvStream;
    mic.addData = data;
  }

}

Future<void> initializeSRT() async {

  epoll = SrtEpoll();

  /// using a long timout for connection issues.
  /// 
  /// The SocketOptions set by default the options
  /// - Live Mode
  /// - Sender: true.
  ///
  /// The [epoll.timeOutMs] is for events on Epoll
  /// 
  final clientOption = SocketOptions.liveMode()..connectTimeout = 1000;
  epoll.timeOutMs = 250;

  server = SrtSocket();
  clientAudio = SrtSocket(options: clientOption);
  clientMic = SrtSocket(options: clientOption);
  clientCam = SrtSocket(options: clientOption);

}
