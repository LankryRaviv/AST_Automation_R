
load_utility 'Operations/Micron/MICRON_POWER_SHARE.rb'
@pwr_share = ModuleMicronPower.new

@pwr_share.set_individual_micron_power_share_switch("APC_YM", "POWER_SHARE_MICRON_104", "ON", TRUE)



