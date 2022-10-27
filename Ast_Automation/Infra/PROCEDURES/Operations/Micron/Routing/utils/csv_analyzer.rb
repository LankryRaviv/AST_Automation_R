# frozen_string_literal: true

require 'csv'
load('Operations/MICRON/Routing/utils/csv_routing_analyzer.rb')
load('Operations/MICRON/Routing/utils/csv_matrix_analyzer.rb')
load('Operations/MICRON/Routing/utils/csv_chain_analyzer.rb')

# CSVAnalyzer
class CSVAnalyzer
  attr_reader :matrix, :chain, :source, :destination

  def initialize(use_yp, reroute_lsl, reroute_hsl, secondary)
    @basepath = $LOAD_PATH.detect { |path| path.include? 'PROCEDURES' }

    @matrix = build_matrix
    @chains = build_chains(use_yp)
    @source = build_source
    @destination = build_destination(reroute_lsl, reroute_hsl, secondary)
  end

  private

  def build_matrix
    matrix_lsl = CSV.read(File.expand_path('Operations/Routing/MatrixLSL.csv', @basepath), 'r')
    matrix_hsl = CSV.read(File.expand_path('Operations/Routing/MatrixHSL.csv', @basepath), 'r')
    map = CSV.read(File.expand_path('Operations/Routing/Map.csv', @basepath), 'r')
    rings = CSV.read(File.expand_path('Operations/Routing/Rings.csv', @basepath), 'r')

    CSVMatrixAnalyzer.new(matrix_lsl, matrix_hsl, map, rings).matrix
  end

  def build_chains(use_yp)
    chains = CSV.read(File.expand_path('Operations/Routing/Chains.csv', @basepath), 'r')

    CSVChainAnalyzer.new(chains, use_yp).chains
  end

  def build_source
    routing_lsl = CSV.read(File.expand_path('Operations/Routing/LSLDefaultRouting.csv', @basepath), 'r')
    routing_hsl = CSV.read(File.expand_path('Operations/Routing/HSLDefaultRouting.csv', @basepath), 'r')

    CSVRoutingAnalyzer.new(routing_lsl, routing_hsl, @matrix, @chains, 'Default Routing Table').routing
  end

  def build_destination(reroute_lsl, reroute_hsl, secondary)
    filename = "Operations/Routing/LSL#{reroute_lsl ? secondary : 'DefaultRouting'}.csv"
    routing_lsl = CSV.read(File.expand_path(filename, @basepath), 'r')
    filename = "Operations/Routing/HSL#{reroute_hsl ? secondary : 'DefaultRouting'}.csv"
    routing_hsl = CSV.read(File.expand_path(filename, @basepath), 'r')

    CSVRoutingAnalyzer.new(routing_lsl, routing_hsl, @matrix, @chains, "#{secondary} Table").routing
  end
end
