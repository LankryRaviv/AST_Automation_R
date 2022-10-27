load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/CPBF/CPBF_MODULE.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')
#load_utility('Operations/Micron/turn_on_off_CPBF.rb')

$RUN_ID = "1234567891011150" #Tzvi Test rerouting ring A only



def off_ring_A(board = "MIC_LSL")
    
	puts "***********power of To ring_A *********************"

	retPowerOff = power_off_ring("A",$RUN_ID)
	
end

# read register function
$c = ModuleCPBF.new
def read_micron_reg(micron_id, regaddr)
    rw_flag = 0 # read
    data = 0x0  # Ignored if rw_flag = 0
    timeout = 100
    recv = $c.cpbf_micron_rw_reg_cmd(micron_id, rw_flag, regaddr, data, timeout)[0]
    data = recv["CPBF_REG_DATA"]
    puts("[DEBUG] MICRON REG #{regaddr}, DATA: #{data}")
    return data
end

def dec2hex(number)

    number.to_s(16)

end
