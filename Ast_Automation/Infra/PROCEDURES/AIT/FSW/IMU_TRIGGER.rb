while true

cmd_no_hazardous_check("BW3 APC_YP-APC_LVC_OUTPUT_SINGLE with OUTPUT_CHANNEL IMU, OUTPUT_CHANNEL IMU, DELAY 0, DELAY 0, STATE_ONOFF OFF, STATE_ONOFF OFF")

wait(20)

cmd_no_hazardous_check("BW3 APC_YP-APC_LVC_OUTPUT_SINGLE with OUTPUT_CHANNEL IMU, OUTPUT_CHANNEL IMU, DELAY 0, DELAY 0, STATE_ONOFF OFF, STATE_ONOFF ON")

wait(20)

end