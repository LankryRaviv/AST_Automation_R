# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate_graphics.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/printing.rb')
load('Operations/MICRON/Routing/routing.rb')

options = RoutingOptions.new.options

delegate = RoutingOperationsDelegateGraphics.new(options[:print_gfx], false, options[:print_debug],
                                                 options[:generate_code], options[:gfx_delay])

routing = Routing.new(options, delegate)

microns = routing.microns(options[:rings_filter])
microns = "[#{microns.join(', ')}]" if options[:generate_code]

puts microns
