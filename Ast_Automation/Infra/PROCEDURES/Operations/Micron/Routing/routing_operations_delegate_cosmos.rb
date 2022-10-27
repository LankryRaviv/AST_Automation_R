# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate.rb')
load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/FSW/FSW_DPC.rb')

# RoutingOperationsCosmos
class RoutingOperationsDelegateCosmos < RoutingOperationsDelegate
  def initialize(board, print_debug)
    super()
    @board = board
    @print_debug = print_debug
    @micron_module = MICRON_MODULE.new
    @dpc = ModuleDPC.new
  end

  def reroute_enable_forward(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('LS-E', cur_route)

    routing_set(cur_route)
  end

  def reroute_disable_forward(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('LS-D', cur_route)

    routing_set(cur_route)
  end

  def reroute_backward(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('LS-B', cur_route)

    routing_set(cur_route)
  end

  def reroute_hsl(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('HS', cur_route)

    routing_set(cur_route)
  end

  def reroute_default(dest_micron_id)
    puts format_cosmos_route_default(dest_micron_id)

    routing_set_default(dest_micron_id)
  end

  def reroute_dpc_disable_chain(_dest_micron_id, chain_id, dpc, uart)
    puts format_cosmos_dpc(chain_id, dpc, uart, false)

    dpc_set(dpc, uart, false)
  end

  def reroute_dpc_enable_chain(_dest_micron_id, chain_id, dpc, uart)
    puts format_cosmos_dpc(chain_id, dpc, uart, true)

    dpc_set(dpc, uart, true)
  end

  def print_reroute_map(_matrix, _source, _forward, _backward); end

  def print_forward_debug(rabbit_hole, micron_id, source, dest)
    super if @print_debug
  end

  def print_backward_debug(rabbit_hole, micron_id, source, dest)
    super if @print_debug
  end

  def print_add_debug(rabbit_hole, micron_id, dest_micron_id, prefix = '')
    super if @print_debug
  end

  def print_remove_debug(rabbit_hole, micron_id, dest_micron_id, prefix = '')
    super if @print_debug
  end

  protected

  def routing_get(cur_route)
    micron_id = cur_route.micron_id

    route = @micron_module.get_micron_default_routing(@board, micron_id)
    return nil if route.length.zero?

    route = route.first
    return nil unless route['MICRON_ID'] == micron_id

    lsl_routing = cur_route.forward.bitmask | cur_route.backward.bitmask
    hsl_routing = cur_route.hsl[:forward].bitmask | cur_route.hsl[:backward].bitmask
    time_tag_delay = cur_route.time_tag_delay
    whole_frame_delay = cur_route.whole_frame_delay

    puts "ERROR: #{micron_id} LSL #{lsl_routing} != #{route['ROUTING_LS']}" unless lsl_routing == route['ROUTING_LS']
    puts "ERROR: #{micron_id} HSL #{hsl_routing} != #{route['ROUTING_HS']}" unless hsl_routing == route['ROUTING_HS']
    unless whole_frame_delay == route['WHOLE_FRAME_DELAY']
      puts "ERROR: #{micron_id} WFD #{whole_frame_delay} != #{route['WHOLE_FRAME_DELAY']}"
    end
    unless time_tag_delay == route['TIME_TAG_DELAY']
      puts "ERROR: #{micron_id} TTD #{time_tag_delay} != #{route['TIME_TAG_DELAY']}"
    end

    route
  end

  def routing_set(cur_route)
    micron_id = cur_route.micron_id
    lsl_routing = cur_route.forward.bitmask | cur_route.backward.bitmask
    hsl_routing = cur_route.hsl[:forward].bitmask | cur_route.hsl[:backward].bitmask
    time_tag_delay = cur_route.time_tag_delay
    whole_frame_delay = cur_route.whole_frame_delay

    result = @micron_module.set_micron_routing_param(@board, micron_id, 0, lsl_routing, hsl_routing,
                                                     whole_frame_delay, time_tag_delay)

    return false if result.length.zero?

    result = result.first
    return false unless result['MICRON_ID'] == micron_id
    return false unless result['MIC_ERROR_CODE'].zero?

    true
  end

  def routing_set_default(micron_id)
    result = @micron_module.set_micron_default_routing_param(@board, micron_id)

    return false if result.length.zero?

    result = result.first
    return false unless result['MICRON_ID'] == micron_id
    return false unless result['MIC_ERROR_CODE'].zero?

    true
  end

  def dpc_set(dpc, uart, enable)
    @dpc.set_micron_uart("DPC_#{dpc}", "UART#{uart}", enable ? 'ON' : 'OFF')

    true
  end

  def format_cosmos_dpc(chain, dpc, uart, enable)
    [["#{@print_prefix}UART_CONTROL: ",
      "Chain #{chain}",
      "DPC: #{dpc}",
      "UART: #{uart}",
      "Control #{enable}"].join(' ')]
  end

  def format_cosmos_route(type, route)
    lsl_routing = route.forward.bitmask | route.backward.bitmask
    hsl_routing = route.hsl[:forward].bitmask | route.hsl[:backward].bitmask
    time_tag_delay = route.time_tag_delay
    whole_frame_delay = route.whole_frame_delay

    [["#{@print_prefix}SET_ROUTING: ",
      "MicronID #{route.micron_id.to_s.ljust(3)}",
      'LSL',
      lsl_routing.to_s.ljust(3).to_s,
      "(#{format('%<routing>08b', routing: lsl_routing)})",
      'HSL',
      hsl_routing.to_s.ljust(3).to_s,
      "(#{format('%<routing>08b', routing: hsl_routing)})",
      "WFD #{whole_frame_delay.to_s.ljust(3)}",
      "TTD #{time_tag_delay.to_s.ljust(3)}",
      "[#{type}]",
      "(Location #{route.location.to_s.ljust(2)})"].join(' ')]
  end

  def format_cosmos_route_default(dest_micron_id)
    [["#{@print_prefix}SET_ROUTING_DEFAULT: ",
      "MicronID #{dest_micron_id.to_s.ljust(3)}"].join(' ')]
  end
end
