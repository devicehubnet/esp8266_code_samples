--[=====[ 

DeviceHUB.net sample code for sending analog sensor with ESP8266.

In this example the sensor is simulated.

created 3 June 2015
by Alexandru Gheorghe

--]=====]


AN_SENSOR_NAME  = "paste_your_SENSOR_NAME_here"
PROJECT_ID      = "paste_your_PROJECT_ID_here"
API_KEY         = "paste_your_API_KEY_here"
DEVICE_UUID     = "paste_your_DEVICE_UUID_here"

serverIP   = "104.155.7.31" -- mqtt.devicehub.net IP
mqttport   = 1883           -- MQTT port (default 1883)
userID     = ""             -- no username for authentication is needed
userPWD    = ""             -- no user password is needed
clientID   = "ESP8266"      -- Device ID
mqtt_state = 0              -- State control

wifiName = "paste_your_SSID_here"
wifiPass = "paste_your_SSID_password_here"

wifi.setmode(wifi.STATION)
wifi.sta.config(wifiName, wifiPass)
wifi.sta.connect()

function mqtt_do()     
     if mqtt_state < 5 then
          -- State: Waiting for wifi
          mqtt_state = wifi.sta.status() 

     elseif mqtt_state == 5 then
     m = mqtt.Client(clientID, 120, userID, userPWD)
          m:connect( serverIP , mqttport, 0,
          function(conn)
               print("Connected to MQTT:" .. serverIP .. ":" .. mqttport .." as " .. clientID )
               -- Go to publish state
               mqtt_state = 20               
          end)

     elseif mqtt_state == 20 then
          -- Publishing...
          mqtt_state = 25 
         
          -- simulation for analog sensor
          analog_sensor = 324
          
          m:publish("/a/"..API_KEY.."/p/"..PROJECT_ID.."/d/"..DEVICE_UUID.."/sensor/"..AN_SENSOR_NAME, 
            "{\"value\": "..analog_sensor.."}", 0, 0,
          function(conn)
              -- Print confirmation of data published
              print(" Sent messeage "..analog_sensor.." published!")
              -- Finished publishing - go back to publish state.
              mqtt_state = 20  
          end)
     else print("Publishing..."..mqtt_state)
          -- takes us gradually back to publish state to retry
          mqtt_state = mqtt_state - 1  
     end

end

-- publishing new value every 5 seconds
tmr.alarm(0, 5000, 1, function() mqtt_do() end) 
