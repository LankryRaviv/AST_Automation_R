# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/routing.rb')
load('Operations/MICRON/MICRON_MODULE.rb')

options = RoutingOptions.hsl_reroute_ym
options[:rings_filter] = %w[A B C D]
options[:rings_chain_length] = true # Calculate maximum chain length according to ring
delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
routing = Routing.new(options, delegate)

routing.reroute

# routing.reroute_default
# micron_module = MICRON_MODULE.new
# puts micron.set_micron_routing_param('MIC_LSL', 109, 0, 34, 68, 81, 33)
# puts micron.set_micron_routing_param('MIC_LSL', 122, 0, 34, 144, 81, 33)
# puts micron.set_micron_routing_param('MIC_LSL', 123, 0, 34, 135, 76, 31)
