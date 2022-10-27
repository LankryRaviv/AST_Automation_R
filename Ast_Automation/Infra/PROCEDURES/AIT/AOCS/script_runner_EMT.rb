load_utility('AIT\AOCS\AOCS_EMT')
load_utility("Operations/FSW/FSW_CSP")
EMT = ModuleEMT.new
["X", "Y", "ZXP", "ZXM"].each do |emt_num|
  
  EMT.on_EMT_positive(emt_num)
  EMT.on_EMT_negative(emt_num)
  EMT.EMT_off(emt_num)
  
end