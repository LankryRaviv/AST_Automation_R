load_utility('AIT\AOCS\AOCS_GPS')
load_utility("Operations/FSW/FSW_CSP")
GPS = ModuleGPS.new

GPS.get_GPS_functional()
GPS.GPS_reset_timeout(1200)
GPS.GPS_reset()