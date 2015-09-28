projectID        = "paste_project_id_here"
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
    end
    
end

tmr.alarm(0, 600, 1, function() mqtt_do() end) -- convert 10000 to dynamic variable
