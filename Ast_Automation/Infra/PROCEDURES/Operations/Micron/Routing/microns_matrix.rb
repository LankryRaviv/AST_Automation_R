# frozen_string_literal: true

load('Operations/MICRON/Routing/micron.rb')
require 'Operations/MICRON/Routing/constants'

# MicronsMatrix
class MicronsMatrix
  attr_reader :matrix, :microns, :map

  def initialize
    @matrix = Array.new(Microns::MAX_MICRON_ID + 1) { Array.new(Microns::MAX_MICRON_ID + 1) { false } }
    @microns = Array.new(Microns::MAX_MICRON_ID + 1)
    @map = Array.new(Microns::MICRON_ARRAY_SIZE) { Array.new(Microns::MICRON_ARRAY_SIZE) }
  end

  def initialize_copy(orig)
    super
    @microns = Array.new(Microns::MAX_MICRON_ID + 1)
  end

  def set_matrix(row, col, value)
    row = 0 if row == 'CS'
    col = 0 if col == 'CS'

    @matrix[row.to_i][col.to_i] = !value.to_i.zero?
  end

  def get_matrix(row, col)
    row = 0 if row == 'CS'
    col = 0 if col == 'CS'

    @matrix[row.to_i][col.to_i]
  end

  def micron(micron)
    @microns[micron.micron_id] = micron
  end

  def micron_location(micron_id, row, col, ring)
    micron_id = Microns::CS_MICRON_ID if micron_id == 'CS'

    @microns[micron_id] = Micron.new(micron_id, row, col, ring) if @microns[micron_id].nil?

    @map[row][col] = @microns[micron_id]
    @map[row][col] = micron_id if @map[row][col].nil?
  end

  def map_connections
    @microns.each do |micron|
      micron&.map_connections(@matrix, @map)
    end
  end
end
