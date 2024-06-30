import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'notification_controller.py.dart';
import 'temperature_listener.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic texts',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Watcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Temperature Monitor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _insideTemperature = -1;
  double _outsideTemperature = -1;
  bool insideMoreWarm = false;
  String _recommendedAction = "Waiting for Data Connection...";

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );

    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    startTemperatureListener();
    print("testifasync");

  }

  void startTemperatureListener() async {
    // Create a receive port to receive messages from the isolate
    ReceivePort receivePort = ReceivePort();

    // Spawn the isolate
    await Isolate.spawn(temperatureListener, receivePort.sendPort);

    // Listen for messages from the isolate
    receivePort.listen((message) {
      // Response format -> "[inside temperature in decicelsius],[outside temperatuer in decicelsius]"
      print("Received message from isolate: $message");
      if (message is String) { // Should always be true, but just in case
        String messageStr = message as String;
        var splitted = messageStr.split(",");
        setState(() {
          _insideTemperature = int.parse(splitted[0])/10; // Divide by ten to convert back to full Celsius
          _outsideTemperature = int.parse(splitted[1])/10;
          if(_insideTemperature > _outsideTemperature) {
            _recommendedAction = "Open the windows!";
          }
          else {
            _recommendedAction = "Close the windows!";
          }
        });
        if(_insideTemperature < _outsideTemperature && insideMoreWarm || _insideTemperature > _outsideTemperature && !insideMoreWarm) { //Ie status changed
          // Create the notifications!
          AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: 10,
                channelKey: 'basic_channel',
                actionType: ActionType.Default,
                title: 'Recommended Action:',
                body: _recommendedAction,
              )
          );
          insideMoreWarm = ! insideMoreWarm;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Inside Temperature:',
            ),
            Text(
              '$_insideTemperature',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Outside Temperature:',
            ),
            Text(
              '$_outsideTemperature',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _recommendedAction,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
