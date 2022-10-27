# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate.rb')

# rubocop:disable Metrics/ClassLength

# RoutingMatrix
class RoutingOperations
  attr_reader :delegate, :matrix, :source, :destination

  def initialize(delegate, matrix, routes_source, routes_dest)
    raise NoMethodError, 'ERROR Missing delegates' unless delegate.is_a? RoutingOperationsDelegate

    @delegate = delegate
    @matrix = matrix
    @source = routes_source
    @destination = routes_dest

    calculate_reroute_default
  end

  def filter(options)
    rings_filter = options[:rings_filter]
    chains_filter = options[:chains_filter]

    return if rings_filter.nil? && chains_filter.nil?

    hsl_reroute = options[:reroute_hsl]
    rings_max_chain_length = options[:rings_chain_length]

    if hsl_reroute
      # Recalculate max chain length
      @destination.update_max_chain_length(rings_max_chain_length ? rings_filter : nil)
      @destination.apply_hs_rings_filter(rings_filter, chains_filter)
    end
    @source.apply_rings_filter(rings_filter, chains_filter, @destination, hsl_reroute)

    calculate_reroute_default
  end

  def reroute(chains_filter = nil)
    disable_unused_dpc_chains

    logic_verify_all_routes

    # Identify destination chain bases
    dest_chains = @destination.routes.compact.select { |route| route.backward.to_i.zero? }

    dest_chains.each do |route|
      unless chains_filter.nil?
        lsl_filter = chains_filter.include? route.chain_id
        hsl_filter = chains_filter.include? route.hsl[:chain_id]
        next unless lsl_filter || hsl_filter
      end

      # Down the rabbit hole
      reroute_recursive(route.micron_id, 1)
    end
  end

  def reroute_default(chains_filter = nil)
    disable_unused_dpc_chains

    @default_source_chains.each do |micron|
      unless chains_filter.nil?
        lsl_route = @source.determine_lsl_backward_route(micron[:micron_id]).last
        hsl_route = @source.determine_hsl_backward_route(micron[:micron_id]).last

        lsl_filter = chains_filter.include? lsl_route.chain_id
        hsl_filter = chains_filter.include? hsl_route.hsl[:chain_id]

        next unless lsl_filter || hsl_filter
      end

      unless micron[:chain_id].nil?
        @delegate.reroute_dpc_enable_chain(micron[:micron_id], micron[:chain_id], micron[:dpc], micron[:uart])
      end

      @delegate.reroute_default(micron[:micron_id])
    end
  end

  private

  def disable_unused_dpc_chains
    @delegate.reroute_dpc_disable_chain(93, 3, @destination.control_sat.dpc(3),
                                        @destination.control_sat.uart(3))
    @delegate.reroute_dpc_disable_chain(120, 5, @source.control_sat.dpc(5),
                                        @source.control_sat.uart(5))
  end

  def calculate_reroute_default
    # Identify source chain bases
    source_chains = @source.routes.compact.select { |route| route.backward.to_i.zero? }

    @default_source_chains = source_chains.map do |route|
      # Down the rabbit hole
      calculate_reroute_default_recursive(route, 1)
    end.compact.flatten
  end

  # rubocop:disable Metrics/AbcSize
  def reroute_recursive(micron_id, rabbit_hole)
    return unless @source.ls_active_routes[micron_id] || @source.hs_active_routes[micron_id]

    source_route = @source.routes[micron_id]
    dest_route = @destination.routes[micron_id]

    unless source_route.location == dest_route.location
      @delegate.print_location(rabbit_hole, micron_id, source_route, dest_route)
    end

    unless dest_route.forward == source_route.forward
      @delegate.print_forward_debug(rabbit_hole, micron_id, source_route, dest_route)
    end

    # routes_to_add = dest_route.forward.to_i - source_route.forward.to_i
    # routes_to_remove = source_route.forward.to_i - dest_route.forward.to_i
    # Make sure power is PS2 in current
    # verify_power_route(micron_id) unless routes_to_add.length.zero? && routes_to_remove.length.zero?

    # Add new forward paths
    routes_to_add = dest_route.forward.to_i - source_route.forward.to_i
    routes_to_add.each do |dest_micron_id|
      next unless @source.ls_active_routes[dest_micron_id] || @source.hs_active_routes[dest_micron_id]

      process_add_forward_path(micron_id, dest_micron_id, source_route, dest_route, rabbit_hole)
    end

    # Remove old forward paths
    routes_to_remove = source_route.forward.to_i - dest_route.forward.to_i
    routes_to_remove.each do |dest_micron_id|
      next unless @source.ls_active_routes[dest_micron_id] || @source.hs_active_routes[dest_micron_id]

      process_del_forward_path(micron_id, dest_micron_id, source_route, dest_route, rabbit_hole)
    end

    process_hsl(source_route, dest_route)

    # No routing change is needed
    routes_same = dest_route.forward.to_i & source_route.forward.to_i
    routes_same.each do |dest_micron_id|
      next unless @source.ls_active_routes[dest_micron_id] || @source.hs_active_routes[dest_micron_id]

      reroute_recursive(dest_micron_id, rabbit_hole + 1)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def logic_verify_all_routes
    @matrix.microns.each_with_index do |micron, id|
      next if micron.nil?
      next if id.zero?

      # Verify we have a forward route
      route = @source.determine_lsl_forward_route(id)
      last_micron = @matrix.microns[route.last.micron_id]

      raise StandardError, "ERROR Forward Chain #{id}" if route.last.chain_id.nil?
      raise StandardError, "ERROR Forward Micron #{id}" if last_micron.nil?

      # Verify we have a backward route
      route = @source.determine_lsl_backward_route(id)
      last_micron = @matrix.microns[route.last.micron_id]
      raise StandardError, "ERROR Backward Chain #{id}" if route.last.chain_id.nil?
      raise StandardError, "ERROR Backward Micron #{id}" if last_micron.nil?
    end
  rescue StandardError => e
    puts e
    abort
  end

  # rubocop:disable Metrics/AbcSize
  def process_add_forward_path(micron_id, dest_micron_id, source_route, dest_route, rabbit_hole)
    @delegate.print_add_debug(rabbit_hole, micron_id, dest_micron_id)

    # New foward paths might be redundant. Locate the current forward path for dest_micron_id
    route = @source.routes.compact.detect { |dest| dest.forward.to_i.include? dest_micron_id }

    dest_source_route = @source.routes[dest_micron_id]

    if route.nil?
      chain_index = @source.control_sat.chains.index(dest_micron_id)

      # If no new forward route found
      raise StandardError, "ERROR No route #{dest_micron_id} (ADD)" if chain_index.nil?

      @delegate.reroute_dpc_disable_chain(dest_micron_id, chain_index, @destination.control_sat.dpc(chain_index),
                                          @destination.control_sat.uart(chain_index))

    else
      # Handle the discovered redundant forward route found
      @delegate.print_forward_debug(rabbit_hole, route.micron_id, route, @destination.routes[route.micron_id])

      @delegate.print_reroute_map(@matrix, @source, route, dest_source_route)
      @delegate.print_add_disable_debug(rabbit_hole, route.micron_id, dest_micron_id)
      route.reroute_disable_forward(@delegate, dest_micron_id, dest_source_route)
      @delegate.print_reroute_map(@matrix, @source, route, dest_source_route)
    end

    # Enable the new forward
    @delegate.print_reroute_map(@matrix, @source, source_route, dest_source_route)
    @delegate.print_add_enable_debug(rabbit_hole, micron_id, dest_micron_id)
    source_route.reroute_enable_forward(@delegate, dest_micron_id, dest_route)
    @delegate.print_backward_debug(rabbit_hole, dest_micron_id, dest_source_route, @destination.routes[dest_micron_id])
    dest_source_route.reroute_backward(@delegate, @destination.routes[dest_micron_id])
    @delegate.print_reroute_map(@matrix, @source, source_route, dest_source_route)

    logic_verify_all_routes
    reroute_recursive(dest_micron_id, rabbit_hole + 1)
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def process_del_forward_path(micron_id, dest_micron_id, source_route, _dest_route, rabbit_hole)
    @delegate.print_remove_debug(rabbit_hole, micron_id, dest_micron_id)

    # Make sure new foward paths are set, by finding the new forward path for dest_micron_id
    next_route = @destination.routes.compact.detect { |dest| dest.forward.to_i.include? dest_micron_id }

    if next_route.nil?

      chain_index = @destination.control_sat.chains.index(dest_micron_id)

      # If no new forward route found
      raise StandardError, "ERROR No route #{dest_micron_id} (DEL)" if chain_index.nil?

      @delegate.reroute_dpc_enable_chain(dest_micron_id, chain_index, @destination.control_sat.dpc(chain_index),
                                         @destination.control_sat.uart(chain_index))
    else
      route = @source.routes[next_route.micron_id]
      dest_source_route = @source.routes[dest_micron_id]

      # Reroute
      @delegate.print_forward_debug(rabbit_hole, route.micron_id, route, @destination.routes[route.micron_id])

      @delegate.print_reroute_map(@matrix, @source, source_route, dest_source_route)
      @delegate.print_remove_disable_debug(rabbit_hole, micron_id, dest_micron_id)
      source_route.reroute_disable_forward(@delegate, dest_micron_id, dest_source_route)
      @delegate.print_reroute_map(@matrix, @source, source_route, dest_source_route)

      # Enable the new forward
      @delegate.print_reroute_map(@matrix, @source, route, dest_source_route)
      @delegate.print_remove_enable_debug(rabbit_hole, route.micron_id, dest_micron_id)
      route.reroute_enable_forward(@delegate, dest_micron_id, next_route)
      @delegate.print_backward_debug(rabbit_hole, dest_micron_id, dest_source_route,
                                     @destination.routes[dest_micron_id])
      dest_source_route.reroute_backward(@delegate, @destination.routes[dest_micron_id])
      @delegate.print_reroute_map(@matrix, @source, route, dest_source_route)
    end

    logic_verify_all_routes
    reroute_recursive(dest_micron_id, rabbit_hole + 1)
  end
  # rubocop:enable Metrics/AbcSize

  def process_hsl(source_route, dest_route)
    source = source_route.hsl
    dest = dest_route.hsl

    # puts "#{source[:micron_id]} forward" unless source[:forward] == dest[:forward]
    # puts "#{source[:micron_id]} backward" unless source[:backward] == dest[:backward]
    # puts "#{source[:micron_id]} chain_id" unless source[:chain_id] == dest[:chain_id]
    # puts "#{source[:micron_id]} location" unless source_route.location == dest_route.location

    # Check if HSL reroute is needed
    unless source[:forward] == dest[:forward] &&
           source[:backward] == dest[:backward] &&
           source[:chain_id] == dest[:chain_id] &&
           source_route.location == dest_route.location

      source_route.reroute_hsl(@delegate, dest_route)
    end
  end

  def verify_power_route(micron_id)
    route_path = @source.determine_lsl_forward_route(micron_id).reverse

    route_path.each_with_index do |route, index|
      case route.power.power_mode
      when PowerMode::PS1
        if index.zero? # C/S
          puts 'DO CS'
        else
          route_path[index - 1].power.share_enable(route)
        end

        route.power.power_mode_set(PowerMode::PS2)

        if index.zero? # C/S
          puts 'DF CS'
        else
          route_path[index - 1].power.share_disable(route)
        end

      when PowerMode::PS2, PowerMode::OPERATIONAL, PowerMode::REDUCED
        # All good!
      else
        raise StandardError, "ERROR Invalid PowerMode #{micron_id} #{route.power.power_mode}"
      end
    end
  end

  def calculate_reroute_default_recursive(route, rabbit_hole)
    micron_id = route.micron_id

    return [] unless @source.ls_active_routes[micron_id] || @source.hs_active_routes[micron_id]

    chain_id = route.chain_id

    data = { micron_id: micron_id, chain_id: chain_id }

    unless chain_id.nil?
      data = data.merge({ dpc: @source.control_sat.dpc(chain_id),
                          uart: @source.control_sat.uart(chain_id) })
    end

    [data] + route.forward.to_i.map do |dest_micron_id|
      calculate_reroute_default_recursive(@source.routes[dest_micron_id], rabbit_hole + 1)
    end
  end
end

# rubocop:enable Metrics/ClassLength
