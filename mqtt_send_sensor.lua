projectID        = "paste_project_id_here"
SENSOR_NAME      = "paste_sensor_name_here"
apiKey           = "paste_api_key_here"
deviceUUID       = "paste_device_id_here"

serverIP   = "mqtt.devicehub.net" -- mqtt.devicehub.net IP
mqttport   = 1883                 -- MQTT port (default 1883)
userID     = ""                   -- username for authentication if required
userPWD    = ""                   -- user password if needed for security
clientID   = "ESP1"               -- Device ID
mqtt_state = 0                    -- State control

wifiName = "wifissid"
wifiPass = "wifipass"

wifi.setmode(wifi.STATION)
wifi.sta.config(wifiName, wifiPass)
wifi.sta.connect()

sensor_pin = 2
gpio.mode(sensor_pin, gpio.INT)

function mqtt_do()
if mqtt_state < 5 then
      mqtt_state = wifi.sta.status() --State: Waiting for wifi

    elseif mqtt_state == 5 then
          m = mqtt.Client(clientID, 120, userID, userPWD)
          mqtt_state = 10 -- State: initialised but not connected
          
    elseif mqtt_state == 10 then
          m:connect( serverIP , mqttport, 0,
          function(conn)
               print("Connected to MQTT:" .. serverIP .. ":" .. mqttport .." as " .. clientID )
               mqtt_state = 20 -- Go to publish state
          end)

    elseif mqtt_state == 20 then
          t1 = math.random(0, 500) -- generate random number to simulate analog sensor, replace with your actual sensor

          m:publish("/a/"..apiKey.."/p/"..projectID.."/d/"..deviceUUID.."/sensor/"..SENSOR_NAME.."" , "{\"value\": "..t1.."}", 0, 0,
          function(conn)
                -- Print confirmation of data published
                print(" Sent Sensor value "..t1.." !")
                mqtt_state = 20 -- Go to publish state
          end)
          tmr.delay(250)
    end
    
end

tmr.alarm(0, 600, 1, function() mqtt_do() end) -- convert 10000 to dynamic variable
