# frozen_string_literal: true

require 'Operations/MICRON/Routing/compass'
require 'Operations/MICRON/Routing/micron'
require 'Operations/MICRON/Routing/micron_route'
require 'Operations/MICRON/Routing/routing_matrix'

# CSVRoutingAnalyzer
class CSVRoutingAnalyzer
  attr_reader :routing

  def initialize(routing_csv_lsl, routing_csv_hsl, matrix, chains, name)
    @routing = RoutingMatrix.new(matrix)
    process(routing_csv_lsl, routing_csv_hsl, matrix, name)

    @routing.update_max_chain_length
    @routing.update_control_sat(chains)
  end

  private

  def process(routing_csv_lsl, routing_csv_hsl, matrix, name)
    puts "Reading: #{name}"

    routing_csv_lsl.each_with_index do |row, row_index|
      process_row(row, routing_csv_hsl[row_index], matrix) unless row.nil?
    end
  end

  def process_row(row_lsl, row_hsl, matrix)
    # Process only microns
    micron_id = verify_micron_id(row_lsl, row_hsl)
    return if micron_id.nil?

    micron = matrix.microns[micron_id]

    if micron.nil?
      puts "ERROR: #{micron_id.to_s.ljust(3)} Micron missing"
      return
    end

    process_route(micron, row_lsl, row_hsl)

    # Verify connections
    connections = Compass.new(row_lsl[1])

    return if micron.connections == connections

    puts "WARN: #{micron_id.to_s.ljust(3)} #{micron.connections} != #{connections}"
  end

  def verify_micron_id(row_lsl, row_hsl)
    return nil if row_lsl[0].nil?

    micron_id_lsl = row_lsl[0].to_i
    return nil unless micron_id_lsl.positive?

    if row_hsl[0].nil?
      puts "ERROR: #{micron_id_lsl.to_s.ljust(3)} HSL missing"
      return nil
    end

    micron_id_hsl = row_hsl[0].to_i
    unless micron_id_lsl == micron_id_hsl
      puts "ERROR: #{micron_id_lsl.to_s.ljust(3)} != #{micron_id_hsl.to_s.ljust(3)}"
      return nil
    end

    micron_id_lsl
  end

  def process_route(micron, row_lsl, row_hsl)
    lsl = {
      power: PowerCompass.new(row_lsl[1], micron),
      backward: LSBackwardCompass.new(row_lsl[2], micron),
      forward: LSForwardCompass.new(row_lsl[3], micron)
    }
    lsl[:chain_id] = row_lsl[6].to_i if lsl[:backward].to_i.zero?

    hsl = {
      backward: HSBackwardCompass.new(row_hsl[2], micron),
      forward: HSForwardCompass.new(row_hsl[3], micron)
    }
    hsl[:chain_id] = row_hsl[6].to_i if hsl[:backward].to_i.zero?

    # TODO: Compare LSL and HSL Power

    @routing.route(MicronRoute.new(micron.micron_id, lsl, hsl))
  end
end
