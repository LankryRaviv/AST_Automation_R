# frozen_string_literal: true

load('Operations/MICRON/Routing/printing.rb')
load('Operations/MICRON/Routing/routing_operations_delegate.rb')

# rubocop:disable Lint/SuppressedException
begin
  require 'colorize'
rescue LoadError
end
# rubocop:enable Lint/SuppressedException

# RoutingOperationsDelegateGraphics
class RoutingOperationsDelegateGraphics < RoutingOperationsDelegate
  attr_reader :print_gfx, :print_gfx_backward, :print_debug, :generate_code

  def initialize(print_gfx, print_gfx_backward, print_debug, generate_code, gfx_delay)
    @generate_code = generate_code
    super(generate_code ? '# ' : '')
    @print_gfx = print_gfx
    @print_gfx_delay = gfx_delay
    @print_gfx_backward = print_gfx_backward
    @print_debug = print_debug

    # Override if colorize not found
    @print_gfx = false unless defined?(''.colorize)
    @print_gfx_backward = false unless defined?(''.colorize)
  end

  def reroute_enable_forward(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('LS-E', cur_route)
    true
  end

  def reroute_disable_forward(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('LS-D', cur_route)
    true
  end

  def reroute_backward(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('LS-B', cur_route)
    true
  end

  def reroute_hsl(_dest_micron_id, cur_route, _new_route)
    puts format_cosmos_route('HS', cur_route)
    true
  end

  def reroute_default(dest_micron_id)
    puts format_cosmos_route_default(dest_micron_id)
    true
  end

  def reroute_dpc_disable_chain(_dest_micron_id, chain_id, dpc, uart)
    puts format_cosmos_dpc(chain_id, dpc, uart, false)
    true
  end

  def reroute_dpc_enable_chain(_dest_micron_id, chain_id, dpc, uart)
    puts format_cosmos_dpc(chain_id, dpc, uart, true)
    true
  end

  def print_reroute_map(matrix, source, forward, backward)
    Printing.print_reroute(matrix, [forward], [backward], nil) if @print_gfx
    sleep(@print_gfx_delay) unless @print_gfx_delay.zero?

    return unless @print_gfx_backward

    backward_route = source.determine_lsl_backward_route(backward.micron_id)
    Printing.print_route_backward(matrix, backward_route, nil)
  end

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

  def print_location(rabbit_hole, micron_id, source, dest)
    super if @print_debug
  end

  private

  def format_cosmos_route(type, route)
    lsl_routing = route.forward.bitmask | route.backward.bitmask
    hsl_routing = route.hsl[:forward].bitmask | route.hsl[:backward].bitmask
    time_tag_delay = route.time_tag_delay
    whole_frame_delay = route.whole_frame_delay

    out = [["#{@print_prefix}SET_ROUTING: ",
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

    if @generate_code
      board = '\'MIC_LSL\''
      chain_id = 0

      params = [board,
                route.micron_id,
                chain_id,
                lsl_routing,
                hsl_routing,
                whole_frame_delay,
                time_tag_delay].join(', ')
      out.append("puts micron.set_micron_routing_param(#{params})")
    end

    out
  end

  def format_cosmos_route_default(dest_micron_id)
    out = [["#{@print_prefix}SET_ROUTING_DEFAULT: ",
            "MicronID #{dest_micron_id.to_s.ljust(3)}"].join(' ')]

    if @generate_code
      board = '\'MIC_LSL\''

      params = [board,
                dest_micron_id].join(', ')
      out.append("puts micron.set_micron_default_routing_param(#{params})")
    end

    out
  end

  def format_cosmos_dpc(chain, dpc, uart, enable)
    out = [["#{@print_prefix}UART_CONTROL: ",
            "Chain #{chain}",
            "DPC: #{dpc}",
            "UART: #{uart}",
            "Control #{enable}"].join(' ')]

    if @generate_code
      params = ["'DPC_#{dpc}'",
                "'UART#{uart}'",
                "'#{enable ? 'ON' : 'OFF'}'"].join(', ')

      out.append("puts dpc.set_micron_uart(#{params})")
    end

    out
  end
end
