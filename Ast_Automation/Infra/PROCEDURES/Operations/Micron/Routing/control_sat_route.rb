# frozen_string_literal: true

require 'Operations/MICRON/Routing/constants'

module ControlSat
  YP = 0
  YM = 1
end

# ControlSatRoute
class ControlSatRoute
  attr_reader :chains, :dpc_yp, :dpc_ym, :uart_yp, :uart_ym, :active

  def initialize(routes, chains)
    # Identify which micron is active on which chain

    @chains = identify_lsl_chains(routes)
    @dpc_yp = chains[:dpc_yp]
    @dpc_ym = chains[:dpc_ym]
    @uart_yp = chains[:uart_yp]
    @uart_ym = chains[:uart_ym]

    @active = chains[:use_yp] ? ControlSat::YP : ControlSat::YM
  end

  def dpc(chain_id)
    if (1..8).include?(chain_id)
      case @active
      when ControlSat::YP
        dpc_id = @dpc_yp[chain_id]
      when ControlSat::YM
        dpc_id = @dpc_ym[chain_id]
      end
    end

    return '?' if dpc_id.nil?

    dpc_id
  end

  def uart(chain_id)
    if (1..8).include?(chain_id)
      case @active
      when ControlSat::YP
        uart_id = @uart_yp[chain_id]
      when ControlSat::YM
        uart_id = @uart_ym[chain_id]
      end
    end

    return '?' if uart_id.nil?

    uart_id
  end

  private

  def identify_lsl_chains(routes)
    chains = Array.new(Microns::MAX_CHAIN_ID + 1) { nil }

    routes.compact.select { |route| route.backward.to_i.zero? }.each do |route|
      chains[route.chain_id] = route.micron_id
    end

    chains
  end

  def identify_hsl_chains(routes)
    chains = Array.new(Microns::MAX_CHAIN_ID + 1) { nil }

    routes.compact.select { |route| route.hsl[:backward].to_i.zero? }.each do |route|
      chains[route.hsl[:chain_id]] = route.hsl[:micron_id]
    end

    chains
  end
end
