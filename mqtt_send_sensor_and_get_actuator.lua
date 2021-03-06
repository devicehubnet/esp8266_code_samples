projectID        = "paste_project_id_here"
SENSOR_NAME1     = "paste_sensor_name_here"
SENSOR_NAME2     = "paste_sensor_name_here"
ACTUATOR_NAME    = "paste_actuator_name_here"
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

relay_pin = 1
sensor1_pin = 2
sensor2_pin = 3

gpio.mode(sensor1_pin, gpio.INT)
gpio.mode(sensor2_pin, gpio.INT)
gpio.mode(relay_pin, gpio.OUTPUT)
gpio.write(relay_pin, gpio.LOW)

function setRelay(state)
  if state == 1 then
    gpio.write(relay_pin, gpio.HIGH)
  else
    gpio.write(relay_pin, gpio.LOW)
  end
end

function mqtt_do()
if mqtt_state < 5 then
      mqtt_state = wifi.sta.status() --State: Waiting for wifi

    elseif mqtt_state == 5 then
          m = mqtt.Client(clientID, 120, userID, userPWD)
          mqtt_state = 10 -- State: initialised but not connected
          m:on("message",
          function(conn, topic, data)
               if data ~= nil then
                  local pack = cjson.decode(data)
                  if pack.state then
                    print(" Received Actuator 1 value "..pack.state.." !")
                    if (pack.state == 0 or pack.state == "0")  then
                      setRelay(0)    
                    elseif (pack.state == 1 or pack.state == "1") then
                      setRelay(1)
                    end
                  end
               end
          end)
    elseif mqtt_state == 10 then
          m:connect( serverIP , mqttport, 0,
          function(conn)
               print("Connected to MQTT:" .. serverIP .. ":" .. mqttport .." as " .. clientID )
               m:subscribe("/a/"..apiKey.."/p/"..projectID.."/d/"..deviceUUID.."/actuator/"..ACTUATOR_NAME.."/state",0,
               function(conn)
                    print("subscribed!")
                    mqtt_state = 20 -- Go to publish state
               end)
           end)

    elseif mqtt_state == 20 then
          t1 = math.random(0, 500) -- generate random number to simulate analog sensor, replace with your actual sensor

          m:publish("/a/"..apiKey.."/p/"..projectID.."/d/"..deviceUUID.."/sensor/"..SENSOR_NAME1.."" , "{\"value\": "..t1.."}", 0, 0,
          function(conn)
                -- Print confirmation of data published
                print(" Sent Sensor 1 value "..t1.." !")
                mqtt_state = 25 -- Go to publish state for second sensor
          end)
          tmr.delay(250)
 

    elseif mqtt_state == 25 then
          t2 = math.random(0, 1) -- generate random number to simulate digital sensor, replace with your actual sensor
          
          m:publish("/a/"..apiKey.."/p/"..projectID.."/d/"..deviceUUID.."/sensor/"..SENSOR_NAME2.."" , "{\"value\": "..t2.."}", 0, 0,
          function(conn)
                -- Print confirmation of data published
                print(" Sent Sensor 2 value "..t2.." !")
                mqtt_state = 20 -- Go to publish state for first sensor
          end)
          tmr.delay(250)
    end
    
end

tmr.alarm(0, 600, 1, function() mqtt_do() end) -- convert 10000 to dynamic variable

