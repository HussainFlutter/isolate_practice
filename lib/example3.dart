import 'dart:isolate';

import 'package:flutter/material.dart';

//Isolate with parameter which is kept alive and not spawned everytime you call the function
class Example3 extends StatefulWidget {
  const Example3({super.key});

  @override
  State<Example3> createState() => _Example3State();
}

class _Example3State extends State<Example3> {
  final messageController = TextEditingController();
  String communicatorResponse = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: messageController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              communicatorResponse,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  )),
              onPressed: () async {
                final communicatorIsolate = await CommunicatorIsolate.create();
                final response = await communicatorIsolate.communicate(
                  messageController.text,
                );
                messageController.clear();
                setState(() {
                  communicatorResponse = response;
                });
              },
              child: const Text("Ask"),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunicatorIsolate {
  final ReceivePort rp;
  final SendPort sp;
  final ReceivePort communicatorRp;

  const CommunicatorIsolate({
    required this.rp,
    required this.sp,
    required this.communicatorRp,
  });

  static Future<CommunicatorIsolate> create() async {
    // We spawn the isolate
    final ReceivePort receivePort = ReceivePort();
    // Getting receivePort of the _communicator function
    final ReceivePort communicatorRp =
        await Isolate.spawn(_communicator, receivePort.sendPort)
            .asStream()
            .cast<ReceivePort>()
            .take(1)
            .first;
    // Making a instance of our class
    return CommunicatorIsolate(
      rp: receivePort,
      sp: receivePort.sendPort,
      communicatorRp: communicatorRp,
    );
  }

  Future<String> communicate(String message) async {
    // Sending the message to the isolate
    communicatorRp.sendPort.send(message);
    // Getting the response
    final resultMessage = communicatorRp.first;
    // Returning the result
    return resultMessage as String;
  }
}

void _communicator(SendPort sp) async {
  final ReceivePort rp = ReceivePort();
  // Sending receivePort to the isolate.spawn()
  sp.send(rp);
  final broadCastStream = rp.asBroadcastStream();
  // Getting the message
  final messageReceived = await broadCastStream.first as String;
  //Searching for the message in the response
  for (final message in response.keys) {
    if (message.trim().toLowerCase() == messageReceived.trim().toLowerCase()) {
      //Sending the message if found
      rp.sendPort.send(message);
      break;
    }
  }
  // When no response is found
  rp.sendPort.send("I have no response to that");
}

const response = {
  "": "Say Something",
  "Hi": "Hello how can i help you",
  "How are you": "Fine , how are you?",
  "Good": "Nice to hear that",
};
