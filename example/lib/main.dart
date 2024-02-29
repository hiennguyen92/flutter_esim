import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_esim/flutter_esim.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSupportESim = false;
  final _flutterEsimPlugin = FlutterEsim();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _flutterEsimPlugin.onEvent.listen((event) {
      print(event);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    bool isSupportESim;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      isSupportESim = await _flutterEsimPlugin.isSupportESim();
    } on PlatformException {
      isSupportESim = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _isSupportESim = isSupportESim;
    });
  }

  Future<void> installEsim() async {
    await _flutterEsimPlugin.installEsimProfile("LPA:1\$lpa.airalo.com\$TEST");
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('isSupportESim: $_isSupportESim\n'),
              ElevatedButton(
                onPressed: () {
                  installEsim();
                },
                child: const Text('Install eSim'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
