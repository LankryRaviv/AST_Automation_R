# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/micron_rapid_power.rb')

options = RoutingOptions.lsl_reroute_ym
options[:rings_filter] = %w[A B C D]

board = 'MIC_LSL'

powering = ModuleMicronRapidPower.new(board, options)

powering.power_up('PS2', 'TEST')

# powering.power_down('TEST')
