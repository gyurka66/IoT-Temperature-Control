# IoT Temperature Monitoring System Tutorial
Nyári György Balázs (gn222gs)
## Overview
This project shows how you can set up a simple temperature monitoring system with multiple different sensors in different locations using Raspberry Pi Picos and TMP36 temperature sensors.
The project can be installed in about an hour if using the code in this repository, writing your own code would probably take around 5 to 10 hours depending on your level of expertise.
## Material Requirements
| 2x Raspberry Pi Pico WH          | ![alt text](https://malnapc.cdn.shoprenter.hu/custom/malnapc/image/cache/w640h480wt1q100/images/Raspberry/55338.jpg.webp?lastmod=1719487244.1716746513) |
|----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2x TMP36 temperature sensor      | ![pico](https://malnapc.cdn.shoprenter.hu/custom/malnapc/image/cache/w640h480wt1q100/images/TMP36GZ.jpg.webp?lastmod=1718966503.1716746513)                          |
| 6x Cables                        | ![alt text](https://malnapc.cdn.shoprenter.hu/custom/malnapc/image/cache/w370h315q100/images/A758_Premium_jumper_150mm_papa_papa.jpg.webp?lastmod=1719106605.1716746513)       |
| 2x Breadboards                   | ![alt text](https://malnapc.cdn.shoprenter.hu/custom/malnapc/image/cache/w640h480wt1q100/images/31971.jpg.webp?lastmod=1719395420.1716746513)                                  |
| 1x Computer (for running server) |                                                                                                                                                                               |
I've decided to work with the TMP36 sensors and RPI picos Mainly for their low price. Technically I could have gone even cheaper, but I plan on reusing the Picos for different projects when it's a bit less warm, since they are very versatile.
All components have been bought from malnapc.hu. I paid 9500 HUF (273 SEK) for the required components (besides the PC) and had a lot of cables left over.

## Objective
Since it's the summer and I live in a house with no AC, efficient management of the temperature inside is extremely important if one wishes to have a good time. The idea is to measure the inside and outside temperature to help decide when to open the windows/doors and when to close them. A phone app will send notifications when it is time to close/open the window, we will also be able to see the current temperatures in the same application.
This project helps with understanding how to read analog sensor data, how to send readings to a central IoT gateway from multiple microcontroller-sensor combos using UDO and how to access this data from the outside using HTTP.

## Software Requirements
The following software will be used to develop the system:
- Visual Studio Code: https://code.visualstudio.com/
-- With the MicroPico plugin installed: https://marketplace.visualstudio.com/items?itemName=paulober.pico-w-go (Pymakr works too)
- Android Studio (for developing the flutter client app)

## Setting up the Picos
The Picos will need to be flashed with a Micropython image before we can start development on them.
To flash an RPI Pico W:
1. Hold down the BOOTSEL button (white button on top) on the Pico
2. Plug the Pico into your PC with a microUSB cable
3. Release the BOOTSEL button
4. A flash drive should now appear
5. Download the newest firmware from: https://micropython.org/download/RPI_PICO_W/
6. Copy the uf2 file onto the flash drive
7. The drive should dissapear
8. Plug the pico out and in WITHOUT holding down the BOOTSEL
9. The Pico is now ready to use.

## Uploading code to the Picos
1. Open the client folder in VSCode
2. Create a "keys.py" file with variables WIFI_SSID and WIFI_PASS which contain the SSID and the password of the WIFI to use.
3. Connect the Pico to the computer
4. It should say: "Pico Connected" in the bottom blue bar in VSC.
5. Enter the Command Prompt of VSCode and select "Upload Project to Pico"
6. Exit the Program(so it doesn't take control over the pico when you reconnect)
7. Plug the Pico out and in
8. observe the main.py running (the led will flash while connecting to the WIFI

## Circuitry
We will be assembling two circuits, one for each Pico, but both circuits are exactly the same, so I'll describe it only once

The TMP36 chip has a nominal power draw of 50 microamperes on 3.3V, this is pretty much negligible. The Pico itself draws about 65mA according to Multimeter.

## Platform
We will use a local server to receive the data from the Picos, as explained earlier this server is written in Python and is fairly basic. It stores the temperature values it receives and offers them up on a simple HTTP API.
I've decided the use a local installation because my use case does not need the complex analyisis tools that online IoT platforms offer.

## Networking
Both the Picos and the server communicate on the LAN using WiFi(802.11n), though there is nothing stopping the server from using ethernet instead.
On the transport layer, the Picos send their data through UDP, literally just sending a byte representation of their readings. There is also an application layer protocol in use, HTTP, for communicating with the flutter client. As you might know HTTP build upon TCP.
The sensors send their data every 10 seconds, this is pretty easy to change in the code however and I might change it to a lower sending rate to save on traffic.

I'm using just UDP because the only thing I'm sending is a number that generally takes only 2 bytes to store, so there is no need for anything more complicated. Also it's no big deal if one transmission gets lost, due to the non-checking nature of UDP, since this is not a time or correctness critical application. As for using HTTP for the communication with the app, I'm using it because the Flutter http package is very easy to use.

## Presentation
From the user side, the application will look   like this:
image here

The data here gets updated every minute, a notification is sent if the outside temperature rises above the inside or the other way around.

## Code Snippets:
Pico collecting the temperature reading:
~~~
while True:
    readings_total = 0
    for i in range(100): #we make 100 readings over ten seconds
        readings_total += converter.read_u16()
        sleep(0.1) #wait one-tenth of a second
    average_reading = readings_total/100 # we get the average reading of the last 10 seconds, to cover for fluctuation
    millivolts = average_reading * 3300 / 65535 # convert it into millivolts
    temp = (millivolts-500)/10 # convert the millivolts into Celsius, as given by the TMP36 datasheet
    temp = temp * 10 # convert the temperature into centi Celsius, since integers are much easier to send in byte form then floats
    temp = round(temp) # we will have a centi celsius precision, this gives an int from our previous float
    print("millivolts:",millivolts,"temp:",temp)
    b_temp = temp.to_bytes(2, "big") #convert to 2 bytes, big-endian
    # Change the port depending on where you are going to place the device
    socket.sendto(b_temp, (IP_ADDRESS, OUTSIDE_PORT))
~~~

Server listening for and saving temperature values:
~~~
def listenForTemp(socket: socket.socket):
    try:
        data, addr = socket.recvfrom(1024) # receive UDP
        return int.from_bytes(data, 'big')
    except:
        return 0
    
def outside_thread_controller(socket: socket.socket): # is going to run in a separate thread from main
    global g_outside_temperature #gloval variable
    while True:
        temp = listenForTemp(socket)
        g_outside_temperature = temp
~~~

Server listening for HTTP requests:
~~~
def http_thread_controller(socket: HTTPServer):
    socket.serve_forever()

class TemperatureHTTPController(BaseHTTPRequestHandler):
    def do_GET(self):
        print("got a GET")
        global g_outside_temperature
        global g_inside_temperature
        self.send_response(200) # OK response
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(bytes(str(g_inside_temperature) + "," + str(g_outside_temperature), encoding="utf-8")) # we encode the temperatures as text, with comma separation.
        print("wrote everything")
~~~

Flutter App, querying the server for temperature values:
~~~
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
        sleep(const Duration(seconds: 60)); //wait 60 secs between queries
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
~~~

# Final Overview
I thought the project went well, I've tried to keep everything minimalistic and clean as possible.
Some pics of the finished project here:
