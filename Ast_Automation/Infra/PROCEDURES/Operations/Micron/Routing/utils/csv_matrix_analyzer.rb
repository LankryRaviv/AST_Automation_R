# frozen_string_literal: true

require 'Operations/MICRON/Routing/compass'
load('Operations/MICRON/Routing/microns_matrix.rb')
require 'Operations/MICRON/Routing/constants'

# CSVMatrixAnalyzer
class CSVMatrixAnalyzer
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
