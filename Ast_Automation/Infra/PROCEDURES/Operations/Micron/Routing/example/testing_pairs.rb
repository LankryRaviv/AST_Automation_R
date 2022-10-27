# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate_graphics.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/printing.rb')
load('Operations/MICRON/Routing/routing.rb')

options = RoutingOptions.new.options

delegate = RoutingOperationsDelegateGraphics.new(options[:print_gfx], false, options[:print_debug],
                                                 options[:generate_code], options[:gfx_delay])
routing = Routing.new(options, delegate)

def to_i_dir(direction)
  case direction
  when 'N', Direction::NORTH
    '2'
  when 'E', Direction::EAST
    '1'
  when 'W', Direction::WEST
    '0'
  when 'S', Direction::SOUTH
    '3'
  else
    '?'
  end
end

def prbs_pairs_recursive(routing, route, rings)
  data = []

  route.hsl[:forward].to_i.map do |next_micron_id|
    unless rings.nil?
      next unless rings.include? routing.matrix.microns[route.micron_id].ring
      next unless rings.include? routing.matrix.microns[next_micron_id].ring
    end

    data.append({
                  micron1: route.micron_id,
                  micron1_dir: to_i_dir(route.hsl[:forward].direction(next_micron_id)),
                  micron2: next_micron_id,
                  micron2_dir: to_i_dir(route.hsl[:backward].to_s)
                })

    data.append(prbs_pairs_recursive(routing, routing.routes[next_micron_id], rings))
  end.compact.flatten
end

def prbs_pairs(routing, rings)
  # Identify source chain bases
  source_chains = routing.routes.compact.select { |route| route.backward.to_i.zero? }

  source_chains.map do |route|
    # Skin ring
    next if !rings.nil? && !(rings.include? routing.matrix.microns[route.micron_id].ring)

    prbs_pairs_recursive(routing, route, rings)
  end.compact.flatten
end

pairs = prbs_pairs(routing.data.source, options[:rings_filter])
pairs.uniq.sort_by { |data| data[:micron1] }.each_with_index do |pair, index|
  puts [(index + 1).to_s, "#{pair[:micron1]} #{pair[:micron1_prbs]} #{pair[:micron1_dir]}",
        '---',
        "#{pair[:micron2]} #{pair[:micron2_prbs]} #{pair[:micron2_dir]}"].join(' ')
end
