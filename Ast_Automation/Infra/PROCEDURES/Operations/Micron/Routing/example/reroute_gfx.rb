# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate_graphics.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/printing.rb')
load('Operations/MICRON/Routing/routing.rb')

options = RoutingOptions.new.options

delegate = RoutingOperationsDelegateGraphics.new(options[:print_gfx], false, options[:print_debug],
                                                 options[:generate_code], options[:gfx_delay])

routing = Routing.new(options, delegate)

Printing.print_routes(routing.data.source, options[:rings_filter]) if options[:print_routes]

puts "#{'#' * 10} Code Start #{'#' * 10}" if options[:generate_code]
routing.reroute
if options[:print_return]
  puts "#{'#' * 10} Reroute to Default #{'#' * 10}" if options[:generate_code]
  routing.reroute_default
end
puts "#{'#' * 10} Code End #{'#' * 10}" if options[:generate_code]

Printing.print_routes(routing.data.source, options[:rings_filter]) if options[:print_routes]
Printing.print_cosmos_routing(routing.data.source, options[:rings_filter]) if options[:print_routing_summary]
