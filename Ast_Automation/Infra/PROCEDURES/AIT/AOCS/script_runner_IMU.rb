load_utility('AIT\AOCS\AOCS_IMU')
load_utility("Operations/FSW/FSW_CSP")
IMU = ModuleIMU.new

IMU.get_IMU_mode()
IMU.get_IMU_status()
IMU.get_IMU_measurements()
IMU.IMU_reset()
IMU.get_IMU_EXTENDED_ERROR()
IMU.IMU_SERVICE_MODE()
IMU.IMU_NORMAL_MODE()