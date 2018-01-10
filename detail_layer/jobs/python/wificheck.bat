REM Restart Wireless Connection
REM Don’t restart if ping works.
ping -n 1 google.com
if %errorlevel% EQU 0 goto end
netsh wlan disconnect interface="Wi-Fi"
TIMEOUT 5
netsh wlan connect name=HOME
TIMEOUT 5
ping -n 1 google.com
if %errorlevel% EQU 0 goto end
netsh wlan disconnect interface="Wi-Fi"
TIMEOUT 5
netsh wlan connect name=HOMEG
TIMEOUT 5
ping -n 1 google.com
if %errorlevel% EQU 0 goto end
netsh wlan disconnect interface="Wi-Fi"
TIMEOUT 5
netsh wlan connect name=Garden
:end