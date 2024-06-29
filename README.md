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
2. Create a "keys.py" file with
3. It should say: "Pico Connected" in the bottom blue bar.
4. Enter the Command Prompt of VSCode and select "Upload Project to Pico"
5. Exit the Program(so it doesn't take control over the pico when you reconnect)
6. Plug the Pico out and in
7. observe the main.py running (the led will flash while connecting to the WIFI
