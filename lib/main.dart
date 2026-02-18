import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laughing_dollop/data.dart';
import 'package:laughing_dollop/screens/client.dart';
import 'package:laughing_dollop/screens/config.dart';
import 'package:laughing_dollop/screens/server.dart';
import 'package:laughing_dollop/srt.dart';
import 'package:srt_flutter_libs/main.dart';

/// Dart entry point
/// 
/// Start the Flutter SDK with the bindings ensure initialized. This is needed for configure a lot of propieties,
/// 
/// Call the [SystemChrome] to set the orientation for landscape ( horizontal on mobile devices ),
/// 
/// And, initialize the core of Srt with [initializeSrtFlutter] and create the sockets ( server, client , ... ) with [initializeSRT]
/// 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  initializeSrtFlutter();
  initializeSRT();

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 108, 104, 185),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The Background of application
/// 
/// Creating a navigation bar in left side with [NavigationRail], and control them with [pageIndex]
/// 
class _MyHomePageState extends State<MyHomePage> {
  int pageIndex = 1;
  late Widget page;

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (pageIndex) {
      case 0:
        page = const ServerPage();

      case 1:
        page = const ClientPage();

      default:
        page = const ConfigPage();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            backgroundColor: const Color.fromARGB(255, 177, 179, 200),
            selectedIndex: pageIndex,
            extended: false,
            selectedLabelTextStyle: const TextStyle(
              color: Colors.white,
            ),
            onDestinationSelected: (value) => setState(() {
              pageIndex = value;
            }),
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text("server")),
              NavigationRailDestination(
                  icon: Icon(Icons.coffee), label: Text("client")),
              NavigationRailDestination(
                  icon: Icon(Icons.settings), label: Text("config")),
            ],
          )),
          Expanded(child: page)
        ],
      ),
    );
  }
}

