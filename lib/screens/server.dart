import 'package:flutter/material.dart';
import 'package:laughing_dollop/data.dart';
import 'package:laughing_dollop/util.dart';
import 'package:laughing_dollop/widgets/info_server.dart';
import 'package:permission_handler/permission_handler.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snackbar = ScaffoldMessenger.of(context).showSnackBar;

    status.then((value) {
      // audio - [0] , video - [1]
      if (!value[0] || !value[1]) {
        snackbar(
          SnackBar(
            content: Text(
                'Without the, ${!value[0] ? "microphone" : !value[1] ? "and" : ""} ${!value[1] ? "camera" : ""}, permitions the server can`t send the data'),
            duration: Duration(hours: 1),
            action: SnackBarAction(
                label: "Open Settings",
                onPressed: () async => await openAppSettings()),
          ),
        );
      }
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 1100) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.vertical,
                  spacing: Configurations.spacing,
                  children: const [
                    ConfigInfo(),
                    Devices(),
                  ],
                ),
                const Spacer(),
                const CatImage(),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, top: 60),
          child: ListView(
              // padding: EdgeInsets.all(10),
              children: [
                const ConfigInfo(min: true),
                SizedBox(
                  height: Configurations.spacing,
                ),
                const Devices(),
                const CatImage(),
              ]),
        );
      },
    );
  }
}

class CardServer extends StatefulWidget {
  const CardServer({super.key});

  @override
  State<StatefulWidget> createState() => _CardServerState();
}

class _CardServerState extends State<CardServer> {
  bool colorT = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: const Text(
          'For now, the devices will not appear.',
          style: TextStyle(),
        ),
        // trailing : Icon(Icons.more_vert),
        trailing: IconButton(
            onPressed: () {
              setState(() {
                colorT = !colorT;
              });
            },
            icon: Icon(
              Icons.done,
              color: colorT
                  ? Colors.red
                  : const Color.fromARGB(255, 149, 189, 254),
            )),
      ),
    );
  }
}

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  final devices = const <Widget>[CardServer()];

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
              image: AssetImage("assets/noise_image_1.png"),
              fit: BoxFit.none,
              opacity: 0.02,
              repeat: ImageRepeat.repeat),
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(7),
          color: Colors.white.withAlpha(20),
        ),
        width: 400,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            // direction: Axis.vertical,
            // alignment: WrapAlignment.center,
            children: [
              Text(
                "Devices",
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
              ),
              const SizedBox(
                height: 25,
              ),
              ...devices
            ],
          ),
        ));
  }
}

class CatImage extends StatelessWidget {
  const CatImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 350,
        minHeight: 100,
      ),
      child: Image.asset("assets/cat_4.png"),
    );
  }
}
