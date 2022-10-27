# frozen_string_literal: true

# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate_graphics.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/printing.rb')
load('Operations/MICRON/Routing/routing.rb')

options = RoutingOptions.new.options

delegate = RoutingOperationsDelegateGraphics.new(options[:print_gfx], false, options[:print_debug],
                                                 options[:generate_code], options[:gfx_delay])

routing = Routing.new(options, delegate)

def print_stages(power_stages)
  power_stages.each do |stage|
    puts "#{'#' * 5} Stage #{stage[:stage]} #{'#' * 5} (#{stage[:microns].length} Microns)"
    puts stage[:microns]
  end

  power_stages.reverse.each do |stage|
    puts "#{'#' * 5} Stage #{stage[:stage]} #{'#' * 5} (#{stage[:microns].length} Microns)"
    puts stage[:microns]
  end
end

print_stages(routing.power_stages)
