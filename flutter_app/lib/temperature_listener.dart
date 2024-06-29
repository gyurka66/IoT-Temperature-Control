import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

final Uri iotGatewayUrl = Uri.http('192.168.1.5:12343');

// This will be running on a separate thread
Future<void> temperatureListener(SendPort sendPort) async {
  print("listenerthreadrunning");
  while (true) {
    var client = http.Client();
    try {
      while(true) { // We try to use the same client connection as long as possible
        sleep(const Duration(seconds: 5)); //wait 5 secs between queries
        var response = await client.get(iotGatewayUrl);
        // Response format -> "[inside temperature in decicelsius],[outside temperatuer in decicelsius]"
        sendPort.send(response.body);
      }
    }
    finally {
      client.close(); // if a message failed close the client and loop back to make a new one
    }
  }
}