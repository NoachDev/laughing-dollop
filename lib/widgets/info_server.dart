import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laughing_dollop/util.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// The [ConfigInfo] widget is a widget that shows the ip and port of the server
/// 
/// [min] is the parametor to set location of the ip, if [min] is true,
/// the ip will be shown in the right of the button of copy,
/// otherwise, the ip will be shown in the button of copy
class ConfigInfo extends StatefulWidget {
  final bool min;

  const ConfigInfo({super.key, this.min = false});

  @override
  State<StatefulWidget> createState() => _ConfigInfoState();
}

class _ConfigInfoState extends State<ConfigInfo> {
  final info = NetworkInfo();

  String? ipName;

  Widget get ipWidget => ipName == null
      ? const CircularProgressIndicator()
      : Text(
          ipName!,
          style: const TextStyle(color: Colors.white),
        );

  @override
  void initState() {
    super.initState();
    Configurations.address.then((ip) => setState(() => ipName = ip.address));

  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.vertical,
      spacing: Configurations.spacing,
      children: [
        Wrap(
          spacing: Configurations.spacing,
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage("assets/noise_image_1.png"),
                      fit: BoxFit.contain,
                      opacity: 0.02,
                      repeat: ImageRepeat.repeat),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white.withAlpha(20),
                ),
                width: 350,
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Material(
                  type: MaterialType.transparency,
                  borderOnForeground: false,
                  borderRadius: BorderRadius.circular(7),
                  child: InkWell(
                      splashColor: const Color.fromARGB(255, 149, 189, 254)
                          .withAlpha(100),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: ipName!));

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content:
                              Text(" The Ip has copied into your clip board"),
                          duration: Durations.medium2,
                        ));
                      },
                      child: Center(
                          child: widget.min
                              ? ipWidget
                              : const Text(
                                  "ip addres",
                                  style: TextStyle(color: Colors.white),
                                ))),
                )),
            if (!widget.min) ipWidget
          ],
        ),
        Wrap(
          spacing: Configurations.spacing,
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/noise_image_1.png"),
                    fit: BoxFit.none,
                    opacity: 0.02,
                  ),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white.withAlpha(20),
                ),
                width: 70,
                height: 40,
                clipBehavior: Clip.hardEdge,
                child: Material(
                  type: MaterialType.transparency,
                  borderRadius: BorderRadius.circular(7),
                  child: InkWell(
                      splashColor: const Color.fromARGB(255, 149, 189, 254)
                          .withAlpha(150),
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: Configurations.port.toString()));

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    " The port has copied into your clip board"),
                                duration: Durations.medium2));
                      },
                      child: const Center(
                          child: Text(
                        "port",
                        style: TextStyle(color: Colors.white),
                      ))),
                )),
            Text(
              Configurations.port.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
