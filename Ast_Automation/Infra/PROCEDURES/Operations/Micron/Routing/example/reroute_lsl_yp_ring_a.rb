# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate_cosmos_lsl.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/routing.rb')

options = RoutingOptions.lsl_reroute_yp
options[:rings_filter] = ['A']

delegate = RoutingOperationsDelegateCosmosLSL.new(options[:print_debug])
routing = Routing.new(options, delegate)

routing.reroute

# routing.reroute_default
