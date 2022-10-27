# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate.rb')
load('Operations/MICRON/Routing/utils/csv_analyzer.rb')
load('Operations/MICRON/Routing/printing.rb')
load('Operations/MICRON/Routing/routing_options.rb')
load('Operations/MICRON/Routing/routing_operations.rb')
load('Operations/MICRON/Routing/routing_powering.rb')

# Routing
class Routing
  attr_reader :options, :delegate, :data, :algo, :powering

  def initialize(options, delegate)
    @options = options
    @delegate = delegate

    validations

    reload_and_reset
  end

  def reload_and_reset
    @data = CSVAnalyzer.new(options[:yp], options[:reroute_lsl], options[:reroute_hsl], options[:secondary])

    @powering = RoutingPowering.new(@data.source, options)

    @algo = if @options[:reverse]
              RoutingOperations.new(@delegate, @data.matrix, @data.destination, @data.source)
            else
              RoutingOperations.new(@delegate, @data.matrix, @data.source, @data.destination)
            end

    @algo.filter(@options)
  end

  def reroute
    start_time = Time.now
    @algo.reroute(@options[:chains_filter])
    puts format('Reroute logic runtime: %<time>0.3f', time: Time.now - start_time)

    true
  rescue StandardError => e
    puts format('ERROR Reroute logic FAILED runtime: %<time>0.3f', time: Time.now - start_time)
    puts e
    false
  end

  def reroute_default
    start_time = Time.now
    @algo.reroute_default(@options[:chains_filter])
    puts format('Reroute default logic runtime: %<time>0.3f', time: Time.now - start_time)

    true
  rescue StandardError => e
    puts format('ERROR Reroute default logic FAILED runtime: %<time>0.3f', time: Time.now - start_time)
    puts e
    false
  end

  def power_stages
    @powering.power_stages
  end

  def microns(rings = nil)
    @data.matrix.microns.compact.map do |micron|
      next if micron.nil?
      next if micron.micron_id.zero?
      next if !rings.nil? && !(rings.include? micron.ring)

      micron.micron_id
    end.compact
  end

  private

  def validations
    unless @delegate.is_a? RoutingOperationsDelegate
      puts "ERROR: Invalid delegate #{@delegate.class}"
      abort
    end

    if @options[:yp] == @options[:ym]
      puts 'ERROR: YM or YP needs to be selected'
      abort
    end

    if @options[:rings_filter].nil?
      puts 'INFO: Reroute and validation is done on all Rings'
    else
      puts "WARNING: Reroute and validation is limited to Rings: #{@options[:rings_filter].join(',')}"
    end

    puts 'WARNING: Low Speed Reroute Disabled' unless @options[:reroute_lsl]
    puts 'WARNING: High Speed Reroute Disabled' unless @options[:reroute_hsl]
    puts 'WARNING: Reverse reroute' if @options[:reverse]
    puts 'NOTICE: DPC is YP' if @options[:yp]
    puts 'NOTICE: DPC is YM' if @options[:ym]
  end
end
