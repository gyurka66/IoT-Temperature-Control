import socket
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

IP_ADDRESS = "192.168.1.5"
OUTSIDE_PORT = 12341
INSIDE_PORT = 12342
HTTP_PORT = 12343
global g_outside_temperature
global g_inside_temperature
g_outside_temperature = 0
g_inside_temperature = 0

def listenForTemp(socket: socket.socket):
    try:
        data, addr = socket.recvfrom(1024)
        return int.from_bytes(data, 'big')
    except:
        return 0
    
def outside_thread_controller(socket: socket.socket):
    global g_outside_temperature
    while True:
        temp = listenForTemp(socket)
        g_outside_temperature = temp

def inside_thread_controller(socket: socket.socket):
    global g_inside_temperature
    while True:
        temp = listenForTemp(socket)
        g_inside_temperature = temp

def http_thread_controller(socket: HTTPServer):
    socket.serve_forever()

class TemperatureHTTPController(BaseHTTPRequestHandler):
    def do_GET(self):
        print("got a GET")
        global g_outside_temperature
        global g_inside_temperature
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(bytes(str(g_inside_temperature) + "," + str(g_outside_temperature), encoding="utf-8"))
        print("wrote everything")


outside_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
outside_socket.bind(('', OUTSIDE_PORT))
inside_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
inside_socket.bind(('', INSIDE_PORT))
http_socket = HTTPServer(('', HTTP_PORT), TemperatureHTTPController)

outside_thread = threading.Thread(target= outside_thread_controller, args= [outside_socket])
inside_thread = threading.Thread(target= inside_thread_controller, args= [inside_socket])
http_thread = threading.Thread(target= http_thread_controller, args= [http_socket])

outside_thread.start()
inside_thread.start()
http_thread.start()

while True:
    print("inside: ", g_inside_temperature)
    print("outside: ", g_outside_temperature)
    time.sleep(2)