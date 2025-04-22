@echo off
setlocal

rem Create a temporary Python script
echo from serial.tools.list_ports import comports > "%TEMP%\find_esp_port.py"
echo import os >> "%TEMP%\find_esp_port.py"
echo def get_com_port(): >> "%TEMP%\find_esp_port.py"
echo     first_interface = None >> "%TEMP%\find_esp_port.py"
echo     for port in comports(): >> "%TEMP%\find_esp_port.py"
echo         if [port.vid, port.pid] == [0x303a, 0x1001]: >> "%TEMP%\find_esp_port.py"
echo             print("Found ESP32 USB serial / JTAG adapter at", port.device) >> "%TEMP%\find_esp_port.py"
echo             return port.device >> "%TEMP%\find_esp_port.py"
echo         if [port.vid, port.pid] == [0x0403, 0x6010]: >> "%TEMP%\find_esp_port.py"
echo             if first_interface == None: >> "%TEMP%\find_esp_port.py"
echo                 first_interface = port >> "%TEMP%\find_esp_port.py"
echo                 continue >> "%TEMP%\find_esp_port.py"
echo             return first_interface.device if (first_interface ^> port) else port.device >> "%TEMP%\find_esp_port.py"
echo port = get_com_port() >> "%TEMP%\find_esp_port.py"
echo if port: >> "%TEMP%\find_esp_port.py"
echo     print(f"Set IDF_PORT to {port}.") >> "%TEMP%\find_esp_port.py"
echo     print(f"SET IDF_PORT={port}") >> "%TEMP%\find_esp_port.py"
echo     print(f"SET ESPTOOL_PORT={port}") >> "%TEMP%\find_esp_port.py"

rem Check if pyserial is installed
python.exe -c "import serial.tools.list_ports" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Python package 'pyserial' not found. Installing...
    pip install pyserial
)

rem Run the Python script and capture its output
python.exe "%TEMP%\find_esp_port.py" > "%TEMP%\esp_port_output.txt"
type "%TEMP%\esp_port_output.txt"

rem Execute the SET commands from the Python script output
for /f "tokens=*" %%a in ('findstr /b "SET" "%TEMP%\esp_port_output.txt"') do (
    %%a
)

rem Clean up temporary files
del "%TEMP%\find_esp_port.py"
del "%TEMP%\esp_port_output.txt"

rem Display current environment variables to verify
echo.
echo Current environment variables:
echo IDF_PORT=%IDF_PORT%
echo ESPTOOL_PORT=%ESPTOOL_PORT%

endlocal & (
    set "IDF_PORT=%IDF_PORT%"
    set "ESPTOOL_PORT=%ESPTOOL_PORT%"
)
