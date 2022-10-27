load_utility('AIT\AOCS\AOCS_RWA')
load_utility("Operations/FSW/FSW_CSP")
RWA = ModuleRWA.new

["RWAX","RWAY","RWAZXP","RWAZXM"].each do |rwa|

  RWA.set_wheel_torque_RWA(rwa,0.05)
  RWA.set_wheel_mode_RWA(rwa,"EXTERNAL")
  RWA.set_wheel_speed_RWA(rwa,1000)

end

["RWA_XP","RWA_XN","RWA_YP","RWA_YN"].each do |rwa|

    RWA.power_on_RWA(rwa)
    
end

RWA.actuator_ground_mode("GROUND")

[0,1,2,3].each do |rwa|

    RWA.get_RWA_mode_idle(rwa)
    RWA.get_RWA_mode_external(rwa)
    RWA.get_RWA_command_status(rwa)
    RWA.check_RWA_command_reject_count(rwa)
    RWA.get_RWA_command_accept_count(rwa)
    
end