# frozen_string_literal: true

require 'Operations/MICRON/Routing/constants'
require 'Operations/Micron/Routing/control_sat_route'

# RoutingMatrix
class RoutingMatrix
  attr_reader :routes, :matrix, :chain_max_length, :micron_chain_length, :hs_active_routes, :ls_active_routes,
              :control_sat

  def initialize(matrix)
    @matrix = matrix
    @routes = Array.new(Microns::MAX_MICRON_ID + 1)
    @chain_max_length = 0
    @ls_active_routes = Array.new(Microns::MAX_MICRON_ID + 1) { true }
    @hs_active_routes = Array.new(Microns::MAX_MICRON_ID + 1) { true }
  end

  def route(route)
    @routes[route.micron_id] = route
  end

  def update_control_sat(chains)
    @control_sat = ControlSatRoute.new(@routes, chains)
  end

  def apply_rings_filter(rings, chains, destination, reroute_hsl)
    @ls_active_routes = Array.new(Microns::MAX_MICRON_ID + 1) { false }
    @hs_active_routes = Array.new(Microns::MAX_MICRON_ID + 1) { false }

    @matrix.microns.compact.each do |micron|
      next if micron.micron_id.zero?
      next if micron.ring.nil?
      next if !rings.nil? && !(rings.include? micron.ring)

      # Identify all LSL dependant microns in rings
      path = determine_lsl_backward_route(micron.micron_id)

      if chains.nil? || (chains.include? path.last.chain_id)
        path.each do |path_route|
          @ls_active_routes[path_route.micron_id] = true
        end
      end

      path = destination.determine_lsl_backward_route(micron.micron_id)

      if chains.nil? || (chains.include? path.last.chain_id)
        path.each do |path_route|
          @ls_active_routes[path_route.micron_id] = true
        end
      end

      next unless reroute_hsl

      # Identify all HSL dependant microns in rings
      path = determine_hsl_backward_route(micron.micron_id)

      if chains.nil? || (chains.include? path.last.hsl[:chain_id])
        path.each do |path_route|
          @hs_active_routes[path_route.micron_id] = true
        end
      end

      path = destination.determine_hsl_backward_route(micron.micron_id)

      next unless chains.nil? || (chains.include? path.last.hsl[:chain_id])

      path.each do |path_route|
        @hs_active_routes[path_route.micron_id] = true
      end
    end
  end

  def apply_hs_rings_filter(rings, chains)
    @hs_active_routes = Array.new(Microns::MAX_MICRON_ID + 1) { false }

    @matrix.microns.compact.each do |micron|
      next if micron.micron_id.zero?
      next if micron.ring.nil?

      next if !rings.nil? && !(rings.include? micron.ring)

      # Identify all HSL dependant microns in rings
      path = determine_hsl_backward_route(micron.micron_id)

      next if !chains.nil? && !(chains.include? path.last.hsl[:chain_id])

      path.each do |path_route|
        @hs_active_routes[path_route.micron_id] = true
      end
    end

    @routes.compact.each do |route|
      next if route.micron_id.zero?
      next unless @hs_active_routes[route.micron_id]

      hsl_forward = route.hsl[:forward]
      active_routes = {
        north: hsl_forward.north ? @hs_active_routes[hsl_forward.north] : false,
        east: hsl_forward.east ? @hs_active_routes[hsl_forward.east] : false,
        west: hsl_forward.west ? @hs_active_routes[hsl_forward.west] : false,
        south: hsl_forward.south ? @hs_active_routes[hsl_forward.south] : false
      }
      hsl_forward.override(active_routes)
    end
  end

  def determine_lsl_backward_route(micron_id, rabbit_hole = 1)
    return [] if micron_id.nil?
    return [] if micron_id.negative?

    route = @routes[micron_id]

    return [route] if micron_id.zero?
    # Return if got to C/S
    return [route] if route.backward.to_i.zero?

    begin
      [route] + determine_lsl_backward_route(route.backward.to_i, rabbit_hole + 1)
    rescue SystemStackError
      puts "(#{rabbit_hole}) ERROR Micron ID #{micron_id}: #{route}"
      abort
    end
  end

  def determine_lsl_forward_route(micron_id, rabbit_hole = 1)
    return [] if micron_id.nil?
    return [] if micron_id.negative?

    forward_routes = @routes.compact.select { |dest| dest.forward.to_i.include? micron_id }

    if forward_routes.length > 1
      puts "ERROR #{forward_routes}"
      return []
    end

    route = forward_routes.first

    # TODO: Add C/S object and check
    return [@routes[micron_id]] if route.nil?

    begin
      [@routes[micron_id]] + determine_lsl_forward_route(route.micron_id, rabbit_hole + 1)
    rescue SystemStackError
      puts "(#{rabbit_hole}) ERROR Micron ID #{micron_id}: #{route}"
      abort
    end
  end

  def determine_hsl_backward_route(micron_id, rabbit_hole = 1)
    return [] if micron_id.nil?
    return [] if micron_id.negative?

    route = @routes[micron_id]

    if route.nil?
      puts "(#{rabbit_hole}) ERROR Micron ID #{micron_id} missing route"
      abort
    end

    return [route] if micron_id.zero?
    # Return if got to C/S
    return [route] if route.hsl[:backward].to_i.zero?

    begin
      [route] + determine_hsl_backward_route(route.hsl[:backward].to_i, rabbit_hole + 1)
    rescue SystemStackError
      puts "(#{rabbit_hole}) ERROR Micron ID #{micron_id}: #{route}"
      abort
    end
  end

  def determine_hsl_forward_route(micron_id, rabbit_hole = 1)
    return [] if micron_id.nil?
    return [] if micron_id.negative?

    forward_routes = @routes.compact.select { |dest| dest.hsl[:forward].to_i.include? micron_id }

    if forward_routes.length > 1
      puts "ERROR #{forward_routes}"
      return []
    end

    route = forward_routes.first

    # TODO: Add C/S object and check
    return [@routes[micron_id]] if route.nil?

    begin
      [@routes[micron_id]] + determine_hsl_forward_route(route.micron_id, rabbit_hole + 1)
    rescue SystemStackError
      puts "(#{rabbit_hole}) ERROR Micron ID #{micron_id}: #{route}"
      abort
    end
  end

  def determine_lsl_chain(micron_id)
    return nil if micron_id.nil?
    return nil if micron_id.negative?

    route = @routes[micron_id]

    # Return if got to C/S
    return route.chain_id if route.backward.to_i.zero?

    determine_lsl_chain(route.backward.to_i)
  end

  def determine_hsl_chain(micron_id)
    return nil if micron_id.nil?
    return nil if micron_id.negative?

    route = @routes[micron_id]

    # Return if got to C/S
    return route.hsl[:chain_id] if route.hsl[:backward].to_i.zero?

    determine_hsl_chain(route.hsl[:backward].to_i)
  end

  def verify_forward_routing
    valid_routes = @routes.compact

    # Verify only one forward points to a specific micron
    @matrix.microns.compact.map do |micron|
      # CS is always true
      next true if micron.micron_id.zero?

      micron_routes = valid_routes.count { |route| route.forward.to_i.include? micron.micron_id }
      # TODO: Count CS routing properly
      micron_routes += 1 unless @routes[micron.micron_id].chain_id.nil?

      micron_routes == 1
    end.all?
  end

  def verify_backward_routing
    # Verify each micron can reach CS
    @matrix.microns.compact.map do |micron|
      # CS is always true
      next true if micron.micron_id.zero?

      lsl_chain_id = determine_lsl_chain(micron.micron_id)

      next false if lsl_chain_id.nil?

      # TODO: Verify HSL
      lsl_chain_id.positive?
    end.all?
  end

  def update_max_chain_length(rings = nil)
    # Make sure to reset length
    @chain_max_length = 0

    @matrix.microns.each_with_index do |micron, id|
      next if micron.nil?
      next if id.zero?
      next if !rings.nil? && !(rings.include? micron.ring)

      route = determine_hsl_backward_route(id)
      route_length = route.length

      @chain_max_length = route_length if route_length > @chain_max_length
    end

    @routes.each do |route|
      next if route.nil?
      next if route.micron_id.zero?

      path = determine_hsl_backward_route(route.micron_id)

      route.update_location(@chain_max_length - path.length + 1)
    end
  end
end
