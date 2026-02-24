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

bool initilized = false;
bool connectedToServer = false;

Future<void> initializeSRT() async {
  late InternetAddress ip;

  if(Platform.isAndroid){
    ip = InternetAddress.loopbackIPv4;
  }
  else{
    ip = await Configurations.address;
  }

  /// The SrtSocket set by default the options
  /// - Live Mode, and
  /// - Sender: true.
  /// 
  server = SrtSocket();
  clientAudio = SrtSocket();
  clientMic = SrtSocket();
  clientCam = SrtSocket();

  server.bind(ip, Configurations.port);
  server.listen(backlog: 3);

  initilized = true;

  audioHandle = await server.accept();
  micHandle = await server.accept();
  camHandle = await server.accept();

  startMicStream();

}