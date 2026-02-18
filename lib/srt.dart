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
  final ip = await Configurations.address;

  server = SrtSocket(options: SocketOptions.liveMode(sender: true));
  clientAudio = SrtSocket(options: SocketOptions.liveMode(sender: true));

  server.bind(ip, Configurations.port);
  server.listen();

  initilized = true;

  audioHandle = await server.accept();
  micHandle = await server.accept();
  camHandle = await server.accept();

}