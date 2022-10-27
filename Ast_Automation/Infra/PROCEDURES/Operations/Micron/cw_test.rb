load('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')
load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
load('Operations/MICRON/Routing/routing.rb')
load('Operations/MICRON/MICRON_MODULE.rb')
load('Operations/FSW/FSW_DPC.rb')
# Config ring

apc = 'APC_YP'
run_id = ''
low_limit_battery = 90
ll_pd = 0
hl_pd = 2
ll_after_dsa = 0
hl_after_dsa = 2
ll_dbm = 0
hl_dbm = 23

# options = RoutingOptions.lsl_reroute_ym
# options[:rings_filter] = ['A']

# powering = ModuleMicronRapidPower.new("MIC_LSL", options)

# Move to PS2 - selected ring
# powering.power_up('PS2','TEST')

# internal setup
ring = 'A'
# microns_list = get_specific_ring(ring)

# Move to PS2 - selected ring
# moved_to_ps2 = power_on_ring_to_ps2(ring, apc,run_id , true)
microns_list = [93, 78]
# Config micron fpga to cw
config_fpga(microns_list)
sleep 5
# Move to operational mode
moved_to_operational = move_ring_to_mode_and_validate(ring, 'OPERATIONAL', run_id, false, microns_list, nil)
# sleep 10
# Check SOC & FPGA temperature
# soc_result = verify_battries(microns_list, run_id, nil, low_limit_battery)
# bat_temp = verify_battries_temperature(microns_list, run_id, nil)
# fpga_temperature_result = fpga_temperature(microns_list, nil, run_id)

# if !fpga_temperature_result
#    return false
# end
# Config cpbf cw
config_cpbf = configure_cpbf_read_pd(microns_list, run_id, nil, ll_pd, hl_pd)

# Set DSA value
set_dsa_res = set_dsa_read_pd(microns_list, run_id, nil, ll_after_dsa, hl_after_dsa, ll_dbm, hl_dbm)

# soc_result = verify_battries(microns_list, run_id, nil, low_limit_battery)
fpga_temperature_result = fpga_temperature(microns_list, nil, run_id)

# powering.power_down('TEST')
