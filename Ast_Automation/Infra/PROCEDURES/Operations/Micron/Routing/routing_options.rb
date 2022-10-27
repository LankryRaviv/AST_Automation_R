# frozen_string_literal: true

require 'optparse'

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/AbcSize

# RoutingOptions
class RoutingOptions
  attr_reader :options

  def self.reroute_yp
    options = RoutingOptions.new(process_options: false).options
    options[:yp] = true

    options
  end

  def self.reroute_ym
    options = RoutingOptions.new(process_options: false).options
    options[:ym] = true

    options
  end

  def self.reroute_lsl
    options = RoutingOptions.new(process_options: false).options
    options[:reroute_hsl] = false

    options
  end

  def self.reroute_hsl
    options = RoutingOptions.new(process_options: false).options
    options[:reroute_lsl] = false

    options
  end

  def self.lsl_reroute_yp
    options = reroute_lsl
    options[:yp] = true

    options
  end

  def self.lsl_reroute_ym
    options = reroute_lsl
    options[:ym] = true

    options
  end

  def self.hsl_reroute_yp
    options = reroute_hsl
    options[:yp] = true

    options
  end

  def self.hsl_reroute_ym
    options = reroute_hsl
    options[:ym] = true

    options
  end

  def initialize(process_options: true)
    @options = {
      secondary: 'SecondaryRouting',
      reverse: false,
      print_gfx: false,
      gfx_delay: 0,
      print_gfx_backward: false,
      print_debug: true,
      print_routes: false,
      print_return: false,
      rings_filter: nil,
      chains_filter: nil,
      reroute_lsl: true,
      reroute_hsl: true,
      generate_code: false,
      print_routing_summary: false,
      rings_chain_length: false,
      yp: false,
      ym: false
    }

    return unless process_options

    OptionParser.new do |parser|
      parser.banner = 'Usage: analyze_csv_cosmos.rb [options]'

      parser.on('-v', '--[no-]verbose', 'Run verbosely') do |flag|
        options[:print_gfx] = flag
        options[:print_debug] = flag
      end

      parser.on('-d', '--[no-]debug', 'Print debug') do |flag|
        options[:print_debug] = flag
      end

      parser.on('-g', '--[no-]gfx', 'Print Graphics') do |flag|
        options[:print_gfx] = flag
      end

      parser.on('-r', '--routes', 'Print Routes') do |flag|
        options[:print_routes] = flag
      end

      parser.on('--summary', 'Print COSMOS summary') do |flag|
        options[:print_routing_summary] = flag
      end

      parser.on('--return', 'Print Return to Default') do |flag|
        options[:print_return] = flag
      end

      parser.on('-c', '--code', 'Generate Code') do |flag|
        options[:generate_code] = flag
      end

      parser.on('--rings=RINGS', 'Filter rings') do |rings|
        options[:rings_filter] = rings.upcase.split(',')
      end

      parser.on('--chains=CHAINS', 'Filter chains') do |chains|
        options[:chains_filter] = chains.upcase.split(',').map(&:to_i)
      end

      parser.on('--chain-rings', 'Chain maximum length based on rings') do |flag|
        options[:rings_chain_length] = flag
      end

      parser.on('--reverse', 'Route in reverse') do |flag|
        options[:reverse] = flag
      end

      parser.on('--yp', 'Use DPC YP') do |flag|
        options[:ym] = !flag
        options[:yp] = flag
      end

      parser.on('--ym', 'Use DPC YM') do |flag|
        options[:ym] = flag
        options[:yp] = !flag
      end

      parser.on('--gfx-delay=DELAY', 'Graphics delay in ms') do |gfx_delay|
        options[:gfx_delay] = gfx_delay.to_i / 1000.0
      end

      parser.on('-s', '--secondary=FILENAME', String, 'Secondary routing') do |filename|
        options[:secondary] = filename
      end

      parser.on('-l', '--[no-]lsl', 'Enable LSL Reroute') do |flag|
        options[:reroute_lsl] = flag
      end

      parser.on('-h', '--[no-]hsl', 'Enable HSL Reroute') do |flag|
        options[:reroute_hsl] = flag
      end
    end.parse!

    return unless options[:yp] == options[:ym]

    puts 'ERROR: YM or YP needs to be selected'
    abort
  end
end

# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/BlockLength
# rubocop:enable Metrics/AbcSize
