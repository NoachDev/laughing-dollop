import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:laughing_dollop/srt.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final _formKey = GlobalKey<FormState>();
  late InternetAddress ip;
  late int port;

  void connectToServer() {
    try {
      clientSocket.connect(ip, port);
      // handle successful connection
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onSurface,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: FractionallySizedBox(
              heightFactor: 0.75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset("assets/cat_2.png"),
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Ip addres : ",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[0-9.a-z:]"))
                          ],
                          validator: (elm) {
                            try {
                              InternetAddress.tryParse(elm!)!.address;
                              return null;
                            } catch (e) {
                              return "Please enter a Ipv4 or Ipv6";
                            }
                          },
                          onSaved: (value) {
                            ip = InternetAddress(value!);
                          },
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "port : ",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 330,
                        child: TextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface),
                            validator: FormBuilderValidators.portNumber(
                                errorText:
                                    "Please eneter a valid port number")),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tried to connect')),
                          );
                          _formKey.currentState!.save();
                          connectToServer();
                        }
                      },
                      child: const Text("Connect")),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
