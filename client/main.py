import machine
import wificonnector
import socket
from time import sleep
from machine import Pin

IP_ADDRESS = "192.168.1.5" # IP of the gateway
OUTSIDE_PORT = 12341
INSIDE_PORT = 12342

sleep(1) # just wait a sec to give the pico time to initialize everything

converter = machine.ADC(26) # start listening on the analog to digital converter

ip = wificonnector.connect() # we connect to the wifi set in keys.py
if (ip != "0.0.0.0"): # if we have an actual IP that means we are connected
    led = Pin("LED", Pin.OUT)    # turn on the onboard led to signal status
    led.on()
socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

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
    b_temp = temp.to_bytes(2, "big")
    # Change the port depending on where you are going to place the device
    socket.sendto(b_temp, (IP_ADDRESS, OUTSIDE_PORT))
