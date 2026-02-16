import 'package:laughing_dollop/util.dart';
import 'package:srt_dart/srt_dart.dart';
import 'package:srt_flutter_libs/main.dart';

late final SrtSocket cHandle;
late final SrtSocket server;
late final SrtSocket clientSocket;

Future<void> initilizeSRT() async {
  initializeSrtFlutter();

  final ip = await Configurations.address;

  server = SrtSocket(options: SocketOptions.liveMode(sender: true));
  clientSocket = SrtSocket(options: SocketOptions.liveMode(sender: true));
  server.bind(ip, Configurations.port);
  server.listen();
  server.accept();

}