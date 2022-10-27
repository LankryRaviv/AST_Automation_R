# frozen_string_literal: true

# MicronRoute
class MicronRoute
  attr_reader :micron_id, :backward, :forward, :power, :chain_id, :hsl, :location

  def initialize(micron_id, lsl, hsl)
    @micron_id = micron_id
    @backward = lsl[:backward]
    @forward = lsl[:forward]
    @power = lsl[:power]
    @chain_id = lsl[:chain_id]
    @hsl = hsl
  end

  def to_s
    compass = "#{@backward} #{@backward.to_i.to_s.ljust(3)} | #{@forward}"
    "#{@micron_id.to_s.ljust(3)} | #{compass} | #{@chain_id.to_s.ljust(3)}"
  end

  def reroute_enable_forward(delegate, dest_micron_id, new_route)
    abort unless delegate.is_a? RoutingOperationsDelegate

    # LSL
    @forward.reroute_enable(dest_micron_id, new_route.forward)
    # HSL
    @hsl[:forward] = new_route.hsl[:forward].clone
    @hsl[:backward] = new_route.hsl[:backward].clone
    @hsl[:chain_id] = new_route.hsl[:chain_id]

    return if delegate.reroute_enable_forward(dest_micron_id, self, new_route)

    # TODO: Log error
    puts "ERROR #{@micron_id} reroute_enable_forward failed #{dest_micron_id}"
    abort
  end

  def reroute_disable_forward(delegate, dest_micron_id, _new_route)
    abort unless delegate.is_a? RoutingOperationsDelegate

    # LSL
    @forward.reroute_disable(dest_micron_id)

    return if delegate.reroute_disable_forward(dest_micron_id, self, nil)

    # TODO: Log error
    puts "ERROR #{@micron_id} reroute_disable_forward failed #{dest_micron_id}"
    abort
  end

  def reroute_backward(delegate, new_route)
    abort unless delegate.is_a? RoutingOperationsDelegate

    # LSL
    @chain_id = new_route.chain_id
    @backward = new_route.backward.clone
    # HSL
    @hsl[:forward] = new_route.hsl[:forward].clone
    @hsl[:backward] = new_route.hsl[:backward].clone
    @hsl[:chain_id] = new_route.hsl[:chain_id]

    return if delegate.reroute_backward(@micron_id, self, nil)

    # TODO: Log error
    puts "ERROR #{@micron_id} reroute_backward failed"
    abort
  end

  def reroute_hsl(delegate, new_route)
    abort unless delegate.is_a? RoutingOperationsDelegate

    # HSL
    @hsl[:forward] = new_route.hsl[:forward].clone
    @hsl[:backward] = new_route.hsl[:backward].clone
    @hsl[:chain_id] = new_route.hsl[:chain_id]
    @location = new_route.location

    return if delegate.reroute_hsl(@micron_id, self, nil)

    # TODO: Log error
    puts "ERROR #{@micron_id} reroute_hsl failed"
    abort
  end

  def update_location(new_location)
    old_location = @location
    @location = new_location

    (old_location != new_location)
  end

  def time_tag_delay
    (@location * 2) - 1
  end

  def whole_frame_delay
    (@location * 5) - 4
  end

  def ==(other)
    return false if other.nil?

    return false unless @micron_id == other.micron_id
    return false unless @backward == other.backward
    return false unless @forward == other.forward
    return false unless @chain_id == other.chain_id

    true
  end
end
