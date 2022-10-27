# frozen_string_literal: true

require 'Operations/MICRON/Routing/compass'
require 'Operations/MICRON/Routing/microns_matrix'
require 'Operations/MICRON/Routing/micron_route'
require 'Operations/MICRON/Routing/constants'
require 'Operations/MICRON/Routing/micron'
require 'Operations/MICRON/Routing/routing_matrix'

# CSVChainAnalyzer
class CSVChainAnalyzer
  attr_reader :chains

  def initialize(csv_chains, use_yp)
    process(csv_chains)

    @chains = {
      dpc_yp: @dpc_yp,
      uart_yp: @uart_yp,
      dpc_ym: @dpc_ym,
      uart_ym: @uart_ym,
      use_yp: use_yp
    }
  end

  private

  def process(csv_chains)
    puts 'Reading: Chains'

    @dpc_yp = Array.new(Microns::MAX_CHAIN_ID + 1) { nil }
    @uart_yp = Array.new(Microns::MAX_CHAIN_ID + 1) { nil }
    @dpc_ym = Array.new(Microns::MAX_CHAIN_ID + 1) { nil }
    @uart_ym = Array.new(Microns::MAX_CHAIN_ID + 1) { nil }

    csv_chains.each do |row|
      process_row(row) unless row.nil?
    end
  end

  def process_row(row)
    return if row[0].nil?

    chain_id = row[0].to_i
    return unless chain_id.positive?

    @dpc_yp[chain_id] = row[1].to_i
    @uart_yp[chain_id] = row[2].to_i
    # INFO: TBD Column 3
    @dpc_ym[chain_id] = row[4].to_i
    @uart_ym[chain_id] = row[5].to_i
    # INFO: TBD Column 6
  end
end

# CSVMatrixAnalyer
class CSVMatrixAnalyer
  attr_reader :matrix

  def initialize(_csv_matrix_lsl, csv_matrix_hsl, csv_map, csv_rings)
    @rings = Array.new(Microns::MAX_MICRON_ID + 1)
    @matrix = MicronsMatrix.new
    @matrix_hsl = MicronsMatrix.new
    @map_micron = Array.new(Microns::MAX_MICRON_ID + 1)

    process_rings(csv_rings)
    # TODO: Separate LSL and HSL
    process_matrix(csv_matrix_hsl)
    process_map(csv_map)

    @matrix.map_connections
  end

  private

  def process_map(csv_map)
    puts 'Reading: Map'

    csv_map.each_with_index do |row, row_index|
      row.each_with_index do |cell, col_index|
        next if cell.nil?

        micron_id = verify_micron_id(cell)

        @matrix.micron_location(micron_id, row_index, col_index, @rings[cell.to_i])
      end
    end
  end

  def process_matrix(csv_matrix)
    puts 'Reading: Matrix'

    csv_matrix.each_with_index do |row, index|
      if index.zero?
        process_top_row(row)
        next
      end

      process_row(row)
    end
  end

  def process_top_row(row)
    row.each_with_index do |cell, index|
      next if index.zero?

      micron_id = verify_micron_id(cell)

      @map_micron[index] = micron_id
    end
  end

  def process_row(row)
    micron_id = verify_micron_id(row[0])

    row.each_with_index do |cell, index|
      next if index.zero?

      process_cell(cell, micron_id, index)
    end
  end

  def process_cell(cell, cell_micron_id, row_index)
    row_micron_id = @map_micron[row_index]
    @matrix.set_matrix(row_micron_id, cell_micron_id, cell)
  end

  def verify_micron_id(micron_id)
    return micron_id.to_i if micron_id.to_i.positive?
    return micron_id.upcase if micron_id.upcase == 'CS'

    puts "ERROR #{micron_id}"
  end

  def process_rings(csv_rings)
    puts 'Reading: Rings'

    csv_rings.each do |row|
      next if row[0].nil?

      micron_id = row[0].to_i
      next unless micron_id.positive?

      ring = row[1]
      next if ring.nil?

      ring = ring.upcase

      @rings[micron_id] = ring if [*'A'..'F'].include? ring
    end
  end
end

# CSVRoutingAnalyer
class CSVRoutingAnalyer
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
