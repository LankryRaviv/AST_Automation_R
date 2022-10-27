# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')

options = RoutingOptions.lsl_reroute_yp
options[:rings_filter] = ['A']

board = 'MIC_LSL'

powering = ModuleMicronRapidPower.new(board, options)

#ret_power = powering.power_up('PS2', 'TEST', nil)
#puts "POWER ON - #{ret_power}"
powering.power_down('TEST',nil)
