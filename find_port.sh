#!/bin/bash

# Create a temporary Python script
cat > /tmp/find_esp_port.py << 'EOF'
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
EOF

# Check if pyserial is installed
if ! python3 -c "import serial.tools.list_ports" &> /dev/null; then
    echo "Python package 'pyserial' not found. Installing..."
    pip install pyserial
fi

# Run the python script and capture its output
output=$(python3 /tmp/find_esp_port.py)
echo "$output"

# Extract and execute export commands
export_commands=$(echo "$output" | grep "^export" || echo "")
if [ -n "$export_commands" ]; then
    eval "$export_commands"
fi

# Clean up temporary file
rm /tmp/find_esp_port.py

# Print current environment variables to verify
echo "Current environment variables:"
echo "IDF_PORT=$IDF_PORT"
echo "ESPTOOL_PORT=$ESPTOOL_PORT"
