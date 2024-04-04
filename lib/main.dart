import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 10,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    )),
                onPressed: () async {
                  debugPrint("button pressed");
                  int result = await heavyTaskIsolate();
                  debugPrint("result: $result");
                  debugPrint("button end");
                },
                child: const Text("Heavy Task with isolate"),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    )),
                onPressed: () {
                  heavyTask2();
                },
                child: const Text("Heavy Task without isolate"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void heavyTask2() {
    int a = 0;
    for (int i = 0; i < 999999999; i++) {
      a += i;
    }
  }
}

Future<int> heavyTaskIsolate() async {
  int result = 0;
  final Completer<void> completer = Completer<void>();
  final ReceivePort rp = ReceivePort();
  await Isolate.spawn(_heavyTask, rp.sendPort);
  rp.listen((dynamic data) {
    result = data;
    rp.close();
  }, onDone: () {
    completer.complete();
  });
  await completer.future;
  return result;
}

void _heavyTask(SendPort sp) {
  debugPrint("start");
  int a = 0;
  for (int i = 0; i < 999999999; i++) {
    a += i;
  }
  debugPrint("end");
  sp.send(a);
}
