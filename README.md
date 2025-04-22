# ESP32-Port-Finder

Reliably finds the correct COM port for UART programming of ESP32-series chips.
This assumes you are using an ESP-Prog programmer (FTDI FT2232) or the built-in Espressif USB peripheral.
Unlike Espressif's own tool, this does not require actually opening the port (which often triggers a hardware reset) to discover it.
I have only tested with the ESP32-S3. The script could trivially be extended to support the Silabs UART chip that ships with many ESP32s.

The original script (that I wrote) is `find_port.py`. I used Claude to generate the `.bat` and `.sh` files, which wrap the Python source for Unix and Windows systems (with Python installed).

It sets the `IDF_PORT` and `ESPTOOL_PORT` environment variables in the current shell. Subsequent calls to `idf.py` and `esptool.py` will start by using the discovered port instead of randomly querying each USB serial port attached to the computer. This behavior is especially annoying on macOS, where random Bluetooth devices connected years ago frequently enumerate garbage entries of the form `/dev/tty.XYZ`.
# Use

## Unix / macOS

`source find_port.sh`  
`esptool.py [esptool command]`  
or  
`idf.py [ESP-IDF command]`  

## Windows

(from a shell with access to ESP-IDF):  
`find_port.bat`  
`esptool.py [esptool command]`  
or  
`idf.py [ESP-IDF command]`   
