#RUN this code on raspberry pi etc to communicate with Robo over HTTP
#Example = http://192.168.1.14:1234/command/C:75:3000,35:3000,125:3000,70:3000,80:0,0:3000,
import serial
from datetime import datetime
import time

def connect_to_serial_port(port_name, baud_rate):
    try:
        ser = serial.Serial(port=port_name, baudrate=baud_rate, timeout=1)
        print(f"Connected to {port_name} at {baud_rate} baud.")
        return ser
    except serial.SerialException as e:
        print(f"Failed to connect to {port_name}: {e}")
        return None


def send_message(serial_port, message):
    try:
        message = message.encode('utf-8')  # Convert the message to bytes
        serial_port.write(message)         # Send the message
        print(f"Sent message: {message.decode('utf-8')}")
    except serial.SerialException as e:
        print(f"Failed to send message: {e}")

def read_message():
    try:
        message = None
        time.sleep(0.010)
        print("ser.in_waiting=",ser.in_waiting)
        if ser.in_waiting>0:
            message = ""
        while ser.in_waiting > 0:
            time.sleep(0.002)
            msg = ser.readline()
            msg = msg.decode()
            msg = msg.strip()
            message += msg
        return message
    except Exception as e:
        return str(e)

ser = connect_to_serial_port("/dev/ttyACM0",115200)
# send_message(ser,"C:75:3000,35:3000,125:3000,70:3000,80:0,0:3000, ")

from flask import Flask
app = Flask(__name__)

def exec_custom_string(custom_string):
    # You should add security measures here to prevent arbitrary code execution.
    # For simplicity, this example directly passes the custom_string to exec().
    try:
        send_message(ser, custom_string+" ")
        roboResponse = read_message()
        print("roboResponse",roboResponse)
        if roboResponse == None:
            return "No response from Robo"
        else:
            return roboResponse
    except Exception as e:
        return f"Error executing command: {str(e)}"

@app.route('/command/<path:custom_string>')
def execute_command(custom_string):
    result = exec_custom_string(custom_string)
    response = str(datetime.now()) + "<br>" + custom_string + "<br>" + result
    return response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=1234)
