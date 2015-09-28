function startup()
    print('in startup')
    dofile('mqtt_send_sensor_and_get_actuator')
    end

tmr.alarm(0,5000,0,startup)

