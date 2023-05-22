import board
import digitalio
import busio
import adafruit_pca9685
from adafruit_httpserver.server import HTTPServer
from adafruit_httpserver.mime_type import MIMEType
from adafruit_httpserver.response import HTTPResponse
from adafruit_httpserver.request import HTTPRequest
from adafruit_httpserver.methods import HTTPMethod
import os
import socketpool
import wifi
import json

wifi.radio.connect(os.getenv('wifiUser'), os.getenv('wifiPass'))
i2c = busio.I2C(board.SCL, board.SDA)
pwm = adafruit_pca9685.PCA9685(i2c)
outputDisablePin = digitalio.DigitalInOut(board.D6)

CHANNELS = 16

outputDisablePin.direction = digitalio.Direction.OUTPUT
outputDisablePin.value = False
pwm.frequency = 100

for i in range(CHANNELS):
    pwm.channels[i].duty_cycle = 0

lightStatus = [0] * CHANNELS

print(os.getenv('wifiUser'))
wifi.radio.connect(os.getenv('wifiUser'), os.getenv('wifiPass'))
pool = socketpool.SocketPool(wifi.radio)
server = HTTPServer(pool, '/static') # type: ignore

def setData(data):
    for field in data:
        if not 'cmd' in field:
            continue
        if not 'channel' in field:
            continue
        channel = CHANNELS - field['channel']
        if field['cmd'] == 'set':
            if not 'value' in field:
                continue
            lightStatus[channel] = field['value']
            pwm.channels[channel].duty_cycle = field['value']
        elif field['cmd'] == 'off':
            pwm.channels[channel].duty_cycle = 0
        elif field['cmd'] == 'on':
            pwm.channels[channel].duty_cycle = lightStatus[channel]
            
@server.route('/')
def index(req: HTTPRequest):
    with HTTPResponse(request=req, content_type=MIMEType.TYPE_TXT) as response:
        response.send('Hello World')
        
@server.route('/set', HTTPMethod.POST) # type: ignore
def setStatus(req: HTTPRequest):
    with HTTPResponse(request=req, content_type=MIMEType.TYPE_TXT) as response:
        try:
            data = json.loads(req.body.decode('utf-8'))
            print(data)
            setData(data)
            response.send('OK')
        except Exception as e:
            print(e)
            response.send('ERROR')
        
print('Server IP: ', wifi.radio.ipv4_address)
server.start(str(wifi.radio.ipv4_address), 80)
while True:
    try:
        server.poll()
    except OSError as e:
        print('Server error: ', e)
