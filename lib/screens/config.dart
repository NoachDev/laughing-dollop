
import 'package:flutter/material.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onSurface,
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Row(
          children: [
            Stack(
              // mainAxisAlignment: MainAxisAlignment.center,
              alignment: Alignment.center,
              children: [
                FractionallySizedBox(
                  heightFactor: 0.65,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset("assets/cat_lamen.png"),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 60, right: 30),
                children: const [
                  Center(
                      child: Text(
                    "Configurations",
                    style: TextStyle(color: Colors.white),
                  )),
                  Divider()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}