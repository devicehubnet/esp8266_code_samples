# ESP8266
Sample codes for ESP8266 development boards for Internet of Things applications using DeviceHUB.net platform.

DeviceHub.net is an IoT platform that bridges the gap between hardware devices and mobile/web developers by providing a collection of straightforward APIs to both ends. The web platform, not only gathers data but makes sense of the data spewed out by billions of connected devices and helps people make smarter decisions by giving them the possibility to remote control the devices.

# Documentation
All sample codes are made using the programming language LUA.

We used NodeMCU 0.9.6-dev_20150704 float firmware, which has fully working MQTT. 
It can be downloaded from: https://github.com/nodemcu/nodemcu-firmware/releases/tag/0.9.6-dev_20150704
You can write it easily using the espTool here: https://github.com/themadinventor/esptool (Be sure to put GPIO0 to GND to be in bootloader mode when doing it)
Please use the init.lua file for all samples. It will help you upload code easier and avoid errors on the module. Be sure to change the sample name in it before uploading.
For upload, we used ESPlorer which can be downloaded from here: https://github.com/4refr0nt/ESPlorer

# Contributing
Ideas, bugs, tests and pull requests always welcome.
