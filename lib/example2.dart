import 'dart:isolate';

import 'package:flutter/material.dart';

//Isolate with parameters

class Example2 extends StatefulWidget {
  const Example2({super.key});

  @override
  State<Example2> createState() => _Example2State();
}

class _Example2State extends State<Example2> {
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
                final result = await communicate(messageController.text);
                messageController.clear();
                setState(() {
                  communicatorResponse = result;
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

Future<String> communicate(String message) async {
  final ReceivePort rp = ReceivePort();
  await Isolate.spawn(
      _communicator, rp.sendPort); // Goes to _communicator function

  final broadCastStream = rp
      .asBroadcastStream(); // After it comes back we assign it as a broadCastStream

  final SendPort response = await broadCastStream
      .first; // We fetch the SendPort || this send port is sent by the _communicator function

  // Now we pass the user's message to the _communicator function
  // -> this will go to the _communicator function again and continue from the line after sp.send()
  response.send(message);

  // After we receive the response we return it
  return await broadCastStream
      .takeWhile((element) => element is String)
      .take(1)
      .first;
}

void _communicator(SendPort sp) async {
  final ReceivePort rp = ReceivePort();
  sp.send(rp.sendPort); // Now we send the sendPort of this function
  // to our caller so that he can send the (message) parameter to this isolate / function

  //Now when we receive a message from our caller, we can send the response back to our caller
  await rp.first.then((result) {
    // Over here if we find the response we give it back else we return "I have no response to that"
    final message = result as String;
    for (final response2 in response.entries) {
      if (response2.key.trim().toLowerCase() == message.trim().toLowerCase()) {
        sp.send(
          response2.value,
        ); // Sending response to caller
        continue;
      }
    }
    // Sending response to caller
    sp.send("I have no response to that");
  });
}

const response = {
  "": "Say Something",
  "Hi": "Hello how can i help you",
  "How are you": "Fine , how are you?",
  "Good": "Nice to hear that",
};
