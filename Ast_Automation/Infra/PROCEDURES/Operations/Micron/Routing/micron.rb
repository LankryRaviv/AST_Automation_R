# frozen_string_literal: true

# Micron
class Micron
  attr_reader :micron_id, :pos_row, :pos_col, :connections, :power_donation, :ring

  def initialize(micron_id, pos_row, pos_col, ring)
    @micron_id = micron_id
    @pos_row = pos_row
    @pos_col = pos_col
    @ring = ring

    @connections = MatrixCompass.new(micron_id.zero?)
  end

  def to_s
    micron_id = @micron_id.zero? ? 'CS' : @micron_id
    "#{micron_id.to_s.ljust(3)} | #{@connections}"
  end

  def map_connections(matrix, map)
    return if @micron_id.zero?

    @connections.map_connections(
      north: neighbor(matrix, map, @pos_row - 1, @pos_col),
      east: neighbor(matrix, map, @pos_row, @pos_col + 1),
      west: neighbor(matrix, map, @pos_row, @pos_col - 1),
      south: neighbor(matrix, map, @pos_row + 1, @pos_col)
    )
  end

  private

  def neighbor(matrix, map, row, col)
    neighbor = begin
      map[row][col]
    rescue StandardError
      nil
    end

    return neighbor if neighbor.nil?

    matrix[@micron_id][neighbor.micron_id] ? neighbor : nil
  end
end
