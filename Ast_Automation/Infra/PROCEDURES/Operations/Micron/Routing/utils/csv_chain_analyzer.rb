# frozen_string_literal: true

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
