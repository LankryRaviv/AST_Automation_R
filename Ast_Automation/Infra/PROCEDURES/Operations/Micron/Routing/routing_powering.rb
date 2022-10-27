# frozen_string_literal: true

# RoutingPowering
class RoutingPowering
  attr_reader :power_order, :power_stages

  def initialize(routing, options)
    @routing = routing

    @power_order = power_sequence(@routing, options[:rings_filter])
    @power_stages = power_sequence_to_stages(@power_order)
  end

  def power_sequence(routing, rings)
    # Identify source chain bases
    source_chains = routing.routes.compact.select { |route| route.backward.to_i.zero? }

    power_order = Array.new(Microns::MAX_MICRON_ID + 1) { nil }

    # Set as stage 1
    source_chains.each do |route|
      next if !rings.nil? && !(rings.include? routing.matrix.microns[route.micron_id].ring)

      power_order[route.micron_id] = {
        stage: 1,
        micron_id: route.micron_id,
        donor: 'PCDU',
        direction: nil
      }
      power_sequence_recursive(routing, route, rings, power_order, 1)
    end

    power_order.compact.sort_by { |data| data[:stage] }
  end

  def power_sequence_to_stages(power_order)
    power_stages = []
    stage = 1
    loop do
      filtered = power_order.select { |data| data[:stage] == stage }
      break unless filtered.length.positive?

      power_stages.append({
                            stage: stage,
                            microns: filtered
                          })

      stage += 1
    end

    power_stages
  end

  private

  def power_sequence_recursive(routing, route, rings, power_order, rabbit_hole)
    stage = power_order[route.micron_id][:stage]

    route.forward.to_i.each do |next_micron_id|
      next if !rings.nil? && !(rings.include? routing.matrix.microns[next_micron_id].ring)

      stage += 1
      power_order[next_micron_id] = {
        stage: stage,
        micron_id: next_micron_id,
        donor: route.micron_id,
        direction: to_s_dir(route.forward.direction(next_micron_id))
      }

      power_sequence_recursive(routing, routing.routes[next_micron_id], rings, power_order, rabbit_hole + 1)
    end
  end

  def to_s_dir(direction)
    "#{case direction
       when Direction::NORTH
         'NORTH'
       when Direction::EAST
         'EAST'
       when Direction::WEST
         'WEST'
       when Direction::SOUTH
         'SOUTH'
       else
         abort
       end}_CLOSED"
  end
end
