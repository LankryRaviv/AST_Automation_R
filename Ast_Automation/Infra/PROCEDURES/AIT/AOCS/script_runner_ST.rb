load_utility('AIT\AOCS\AOCS_ST')
load_utility("Operations/FSW/FSW_CSP")
ST = ModuleST.new

[0,1].each do |st_id|
  
  ST.get_ST_mode(st_id)
  ST.power_on_ST(st_id)
  ST.AP_CHECK_ST(st_id)
  ST.AP_DUMP_ST(st_id)
  
end
