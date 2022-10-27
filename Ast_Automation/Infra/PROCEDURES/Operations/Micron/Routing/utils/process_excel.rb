# frozen_string_literal: true

require 'rubyXL'
require 'csv'
require 'Operations/MICRON/Routing/printing'
require 'Operations/MICRON/Routing/csv_analyzer'

adjacency = RubyXL::Parser.parse(File.expand_path('../docs/AdjacencyMatrix.xlsx', __dir__))
routing = RubyXL::Parser.parse(File.expand_path('../docs/RoutingPaths.xlsx', __dir__))

basepath = $LOAD_PATH.detect { |path| path.include? 'PROCEDURES' }

def process_worksheet(worksheet, filename)
  puts "Processing: #{worksheet.sheet_name}"
  csv = CSV.open(filename, 'w')
  worksheet.each do |row|
    csv << row.cells.map { |cell| cell.nil? ? nil : cell.value }
  end
  csv.close
end

process_worksheet(adjacency['Matrix'], File.expand_path('Operations/Routing/Matrix.csv', basepath))
process_worksheet(adjacency['MatrixLSL'], File.expand_path('Operations/Routing/MatrixLSL.csv', basepath))
process_worksheet(adjacency['MatrixHSL'], File.expand_path('Operations/Routing/MatrixHSL.csv', basepath))
process_worksheet(adjacency['Chains'], File.expand_path('Operations/Routing/Chains.csv', basepath))

process_worksheet(adjacency['Map'], File.expand_path('Operations/Routing/Map.csv', basepath))
process_worksheet(adjacency['Rings'], File.expand_path('Operations/Routing/Rings.csv', basepath))

process_worksheet(routing['LSL Default Routing'],
                  File.expand_path('Operations/Routing/LSLDefaultRouting.csv', basepath))
process_worksheet(routing['LSL Secondary Routing'],
                  File.expand_path('Operations/Routing/LSLSecondaryRouting.csv', basepath))

process_worksheet(routing['HSL Default Routing'],
                  File.expand_path('Operations/Routing/HSLDefaultRouting.csv', basepath))
process_worksheet(routing['HSL Secondary Routing'],
                  File.expand_path('Operations/Routing/HSLSecondaryRouting.csv', basepath))

adjacency_matrix_lsl = CSV.read(File.expand_path('Operations/Routing/MatrixLSL.csv', basepath), 'r')
adjacency_matrix_hsl = CSV.read(File.expand_path('Operations/Routing/MatrixHSL.csv', basepath), 'r')
adjacency_map = CSV.read(File.expand_path('Operations/Routing/Map.csv', basepath), 'r')
adjacency_rings = CSV.read(File.expand_path('Operations/Routing/Rings.csv', basepath), 'r')

matrix = CSVMatrixAnalyer.new(adjacency_matrix_lsl, adjacency_matrix_hsl, adjacency_map, adjacency_rings).matrix
Printing.print_micron_rings(matrix)
