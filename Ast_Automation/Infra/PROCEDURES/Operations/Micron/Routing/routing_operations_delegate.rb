# frozen_string_literal: true

# RoutingOperationsDelegate
class RoutingOperationsDelegate
  attr_reader :print_prefix

  def initialize(print_prefix = '')
    @print_prefix = print_prefix
  end

  def reroute_enable_forward(_dest_micron_id, _cur_route, _new_route)
    raise NoMethodError
  end

  def reroute_disable_forward(_dest_micron_id, _cur_route, _new_route)
    raise NoMethodError
  end

  def reroute_backward(_dest_micron_id, _cur_route, _new_route)
    raise NoMethodError
  end

  def reroute_hsl(_dest_micron_id, _cur_route, _new_route)
    raise NoMethodError
  end

  def reroute_default(_dest_micron_id)
    raise NoMethodError
  end

  def reroute_dpc_disable_chain(_chain_id)
    raise NoMethodError
  end

  def reroute_dpc_enable_chain(_chain_id)
    raise NoMethodError
  end

  def print_reroute_map(_matrix, _source, _forward, _backward)
    raise NoMethodError
  end

  def print_forward_debug(rabbit_hole, micron_id, source, dest)
    rabbit_hole = rabbit_hole.to_s.ljust(2)
    micron_id = micron_id.to_s.ljust(3)

    puts "#{@print_prefix}(#{rabbit_hole}) MicronID #{micron_id} F: #{source.forward} -> #{dest.forward}"
  end

  def print_backward_debug(rabbit_hole, micron_id, source, dest)
    rabbit_hole = rabbit_hole.to_s.ljust(2)
    micron_id = micron_id.to_s.ljust(3)

    puts "#{@print_prefix}(#{rabbit_hole}) MicronID #{micron_id} B: #{source.backward} -> #{dest.backward}"
  end

  def print_add_debug(rabbit_hole, micron_id, dest_micron_id, prefix = '')
    rabbit_hole = rabbit_hole.to_s.ljust(2)
    micron_id = micron_id.to_s.ljust(3)

    puts "#{@print_prefix}(#{rabbit_hole}) MicronID #{micron_id} A #{prefix} #{dest_micron_id}"
  end

  def print_add_enable_debug(rabbit_hole, micron_id, dest_micron_id)
    print_add_debug(rabbit_hole, micron_id, dest_micron_id, 'Enable')
  end

  def print_add_disable_debug(rabbit_hole, micron_id, dest_micron_id)
    print_add_debug(rabbit_hole, micron_id, dest_micron_id, 'Disable')
  end

  def print_remove_debug(rabbit_hole, micron_id, dest_micron_id, prefix = '')
    rabbit_hole = rabbit_hole.to_s.ljust(2)
    micron_id = micron_id.to_s.ljust(3)

    puts "#{@print_prefix}(#{rabbit_hole}) MicronID #{micron_id} D #{prefix} #{dest_micron_id}"
  end

  def print_remove_enable_debug(rabbit_hole, micron_id, dest_micron_id)
    print_remove_debug(rabbit_hole, micron_id, dest_micron_id, 'Enable')
  end

  def print_remove_disable_debug(rabbit_hole, micron_id, dest_micron_id)
    print_remove_debug(rabbit_hole, micron_id, dest_micron_id, 'Enable')
  end

  def print_location(rabbit_hole, micron_id, source, dest)
    source_location = source.location
    dest_location = dest.location

    time_tag_delay = dest.time_tag_delay
    whole_frame_delay = dest.whole_frame_delay

    puts ["#{@print_prefix}(#{rabbit_hole})",
          "MicronID #{micron_id}",
          "Location #{source_location} -> #{dest_location}",
          "(WFD #{whole_frame_delay}",
          "TTD #{time_tag_delay})"].join(' ')
  end
end
