from serial.tools.list_ports import comports
import os
def get_com_port():
    first_interface = None
    for port in comports():
        if [port.vid, port.pid] == [0x303a, 0x1001]:
            print("Found ESP32 USB serial / JTAG adapter at", port.device)
            return port.device
        if [port.vid, port.pid] == [0x0403, 0x6010]:
            if first_interface == None:
                first_interface = port
                continue
            return first_interface.device if (first_interface > port) else port.device
port = get_com_port()
if port:
    print(f"Set IDF_PORT to {port}.")
    print(f"export IDF_PORT={port}")
    print(f"export ESPTOOL_PORT={port}")
