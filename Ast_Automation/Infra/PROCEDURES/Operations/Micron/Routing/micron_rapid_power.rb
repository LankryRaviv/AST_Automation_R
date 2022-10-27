# frozen_string_literal: true

load('Operations/MICRON/Routing/routing_operations_delegate_graphics.rb')
load('Operations/MICRON/Routing/routing.rb')

load('Operations/Micron/MICRON_MODULE.rb')
#load('Operations/Micron/TrajectoryControlFunctions.rb')
load('Operations/Micron/MICRON_POWER_SHARE.rb')
load('Operations/MICRON/MICRON_SoC.rb')
load('Operations/MICRON/MICRON_CSP.rb')
load('Operations/MICRON/HandleRouting.rb')
load('Operations/MICRON/MICRON_BATT_THERMAL.rb')

# ModuleMicronRapidPower
class ModuleMicronRapidPower
  def initialize(board, options)
    @pwr_share = ModuleMicronPower.new
    @micron = MICRON_MODULE.new
    @apc = options[:yp] ? 'APC_YP' : 'APC_YM'
    @board = board

    delegate = RoutingOperationsDelegateGraphics.new(options[:print_gfx], false, options[:print_debug],
                                                     options[:generate_code], options[:gfx_delay])

    routing = Routing.new(options, delegate)
    @power_stages = routing.power_stages
  end

  def power_up(power_mode, run_id, out_file, safety = true, with_pcdu = true)
    puts "#{'#' * 5} Power Up #{@power_stages.length} stages"

    total_start_time = Time.now
    @power_stages.each do |stage|
      puts "#{'#' * 5} Power Up Stage #{stage[:stage]} #{'#' * 5} (#{stage[:microns].length} Microns)"

      stage_start_time = Time.now
      result = power_up_stage(stage[:microns], power_mode, run_id, out_file, safety, with_pcdu)
      puts format('Power Up Stage %<stage>d runtime: %<time>0.3f', stage: stage[:stage],
                                                                  time: Time.now - stage_start_time)

      return false unless result
    end
    puts format('Power Up runtime: %<time>0.3f', time: Time.now - total_start_time)
    return true
  end

  def power_down(run_id, out_file, with_pcdu = true)
    puts "#{'#' * 5} Power Down #{@power_stages.length} stages"
    all_microns_down = true
    total_start_time = Time.now
    @power_stages.reverse.each do |stage|
      puts "#{'#' * 5} Power Down Stage #{stage[:stage]} #{'#' * 5} (#{stage[:microns].length} Microns)"

      stage_start_time = Time.now
      ret_power_down = power_down_stage(stage[:microns], run_id, out_file, with_pcdu)
      puts format('Power Down Stage %<stage>d runtime: %<time>0.3f', stage: stage[:stage], time: Time.now - stage_start_time)
      all_microns_down = all_microns_down & ret_power_down
    end
    puts format('Power Down runtime: %<time>0.3f', time: Time.now - total_start_time)
    return all_microns_down
  end

  private

  def power_up_stage(stage, power_mode, run_id, out_file, safety, with_pcdu)
    microns = stage.map do |micron|
      micron[:micron_id]
    end

    process_donors = Array.new(microns.length) { true }
    process_power = Array.new(microns.length) { true }

    return false unless power_on_donors(stage, process_donors, with_pcdu)

    # Send pings
    # NOTICE: If one ping does not return true, return false.
    return false unless ping_microns(microns, process_donors, out_file, run_id)

    # Move to PS2
    return false unless configure_power_mode(microns, process_power, power_mode, run_id, out_file)

    # INFO: Wait 5 seconds after the power mode changed
    sleep(5) if process_power.any?

    # Verify to PS2
    return false unless verify_power_mode(microns, process_power, power_mode, run_id, out_file)

    # power off donors
    return false unless power_off_donors(stage, process_donors, with_pcdu)

    if(safety)
      # Battery check soc
      # NOTICE: if one micron does not report battery OK, return false
      return false unless verify_battries(microns, run_id, out_file)

      # Check Battery temerature
      return false unless verify_battries_temperature(microns, run_id, out_file)

      # Default routing check
      return false unless verify_micron_routing(microns, run_id, out_file)

      # SW version check
      verify_micron_software_version(microns, run_id, out_file)
    end

    return true
  end

  def power_down_stage(stage, run_id, out_file, with_pcdu)
    microns = stage.map do |micron|
      micron[:micron_id]
    end
    after_reboot = true
    process_donors = Array.new(microns.length) { true }

    # verify_battries(microns, run_id, out_file)

    power_off_donors(stage, process_donors, with_pcdu)

    reboot_microns(microns)

    sleep(5) if process_donors.any?

    !ping_microns(microns, process_donors, out_file, run_id, 3, 0.2, after_reboot)
  end

  # This function change the modes to: PS2\Reduce\Operational
  def change_micron_power_mode(micron_id, mode)
    mode = mode.to_s.upcase.strip
    result = @micron.set_system_power_mode(@board, micron_id, mode, true, false, 0.1)[0]

    unless result['MIC_SYSTEM_RESULT_CODE'] == 'SYSTEM_OK'
      puts "Micron Set Power mode was not set correctly.  Result is #{result['MIC_SYSTEM_RESULT_CODE']}"
      return false
    end

    true
  end

  def verify_micron_power_mode(micron_id, mode, run_id, out_file, is_configuration_check = false, process = false)
    mode = mode.to_s.upcase.strip
    time = Time.new
    result = @micron.get_system_power_mode(@board, micron_id, true, false, 0.5)
    power_mode_status = "PS1"
    if result != []
      result = result[0]
      power_mode_status = result['MIC_CURRENT_SYSTEM_POWER_MODE']
    end
    if !is_configuration_check
      if out_file != nil
        write_to_log_file(run_id, time, "SET_POWER_MODE_#{mode.to_s.upcase}_MICRON_#{get_micron_id_filterd(micron_id)}",
        "TRUE", "TRUE", (power_mode_status == mode), "BOOLEAN", ((power_mode_status == mode) ? "PASS": "FAIL"), "BW3_COMP_SAFETY", out_file)
      end
    end

    unless power_mode_status == mode
      puts "ERROR Get POWER_MODE of #{mode} for #{micron_id}: result is #{power_mode_status}"
      return false
    end

    puts "CURRENT_SYSTEM_POWER_MODE is #{power_mode_status} - MICRON_ID = #{micron_id}"
    true
  end

  def power_on_donors(microns, process, with_pcdu)
    start_time = Time.now
    timeout = 5
    result = Array.new(microns.length) { false }
    first_run = true

    while !result.all? && timeout.positive?
      microns.each_with_index do |micron, i|
        next if result[i]

        # Check if ping
        if @micron.ping_micron(@board, micron[:micron_id], false, false, 0.1, 1)
          process[i] = false if first_run
          result[i] = true
          next
        end

        if micron[:donor] == 'PCDU'
          if with_pcdu
            puts @pwr_share.set_individual_micron_power_share_switch(@apc, "POWER_SHARE_MICRON_#{micron[:micron_id]}",
                                                                   'ON', true)
          end
          result[i] = true
        else
          puts @micron.set_power_sharing(@board, "MICRON_#{micron[:donor]}", micron[:direction], 'DONOR',
                                         converted = false, raw = false, wait_check_timeout = 1)
        end
      end

      first_run = false if first_run

      sleep(8) if process.any?

      microns.each_with_index do |micron, i|
        next unless process[i]

        next if micron[:donor] == 'PCDU'
        share_mode = "NA"
        power_result = @micron.get_power_sharing(@board, "MICRON_#{micron[:donor]}", nil, nil, converted = true, raw = false, wait_check_timeout = 1)
        if power_result != []
          power_result = power_result[0]
          share_mode = power_result['MIC_SHARE_MODE']
        end
        result[i] = share_mode == 'DONOR'
        puts power_result unless result[i]
      end

      timeout -= 1
    end

    puts format('power_on_donors: %<time>0.3f', time: Time.now - start_time)

    true
  end

  def power_off_donors(microns, process, with_pcdu)
    start_time = Time.now
    microns.each_with_index do |micron, i|
      next unless process[i]

      if micron[:donor] == 'PCDU'
        if with_pcdu
          puts @pwr_share.set_individual_micron_power_share_switch(@apc, "POWER_SHARE_MICRON_#{micron[:micron_id]}",
                                                                 'OFF', true)
        end
      else
        puts @micron.set_power_sharing(@board, "MICRON_#{micron[:donor]}", 'ALL_DISCONNECTED', 'DISABLED', converted = false, raw = false,
                                       wait_check_timeout = 1)
      end
    end

    puts format('power_off_donors: %<time>0.3f', time: Time.now - start_time)

    true
  end

  def ping_microns(microns, process, out_file, run_id, timeout = 5, delay = 2, after_reboot = false)
    start_time = Time.now
    result = Array.new(microns.length) { false }

    while !result.all? && timeout.positive?
      microns.each_with_index do |micron_id, i|
        time = Time.new
        next if result[i]

        unless process[i]
          result[i] = true
          if out_file != nil
            write_to_log_file(run_id, time, "PING_MICRON_#{get_micron_id_filterd(micron_id)}",
            "TRUE", "TRUE", result[i],"BOOLEAN", (result[i] == true ? "PASS": "FAIL"), "BW3_COMP_SAFETY", out_file)
          end
          next
        end
        
        result[i] =
          @micron.ping_micron(@board, micron_id, false, false, 0.1, 1)

        if after_reboot == false
          if out_file != nil
            write_to_log_file(run_id, time, "PING_MICRON_#{get_micron_id_filterd(micron_id)}",
            "TRUE", "TRUE", result[i],"BOOLEAN", (result[i] == true ? "PASS": "FAIL"), "BW3_COMP_SAFETY", out_file)
          end
        end
 
        if after_reboot && timeout == 1
          res_reboot = !result[i]
          pass_fail_criteria = (res_reboot == true ? "PASS": "FAIL")
          if out_file != nil
            write_to_log_file(run_id, time, "REBOOT_MICRON_#{get_micron_id_filterd(micron_id)}",
            "TRUE", "TRUE", res_reboot,"BOOLEAN", pass_fail_criteria, "BW3_COMP_SAFETY", out_file)
          end
        end
          
      end

      next if result.all?

      timeout -= 1
      sleep(delay)
    end

    puts format('ping_microns: %<time>0.3f', time: Time.now - start_time)

    # NOTICE: If one ping does not return true, return false.
    result.all?
  end

  def configure_power_mode(microns, process, power_mode, run_id, out_file)
    start_time = Time.now
    timeout = 5
    result = Array.new(microns.length) { false }
    while !result.all? && timeout.positive?
      microns.each_with_index do |micron_id, i|
        next if result[i]

        if process[i] && verify_micron_power_mode(micron_id, power_mode, run_id, out_file, true)
          process[i] = false
          result[i] = true
          next
        end

        result[i] = change_micron_power_mode(micron_id, power_mode)
      end

      next if result.all?

      timeout -= 1
    end

    puts format('configure_power_mode: %<time>0.3f', time: Time.now - start_time)

    # NOTICE: if one micron does not switch to mode, return false.
    result.all?
  end

  def verify_power_mode(microns, process, mode, run_id, out_file)
    start_time = Time.now
    timeout = 5
    result = Array.new(microns.length) { false }
    while !result.all? && timeout.positive?
      microns.each_with_index do |micron_id, i|
        next if result[i]

        unless process[i]
          result[i] = true
          #next
        end

        result[i] = verify_micron_power_mode(micron_id, mode, run_id, out_file,false)
        next if result[i]

        change_micron_power_mode(micron_id, mode)

        timeout -= 1
      end
    end

    puts format('verify_power_mode: %<time>0.3f', time: Time.now - start_time)

    # NOTICE: if one micron does not switch to mode, return false.
    result.all?
  end

  def verify_battries(microns, run_id, out_file)
    start_time = Time.now
    timeout = 5
    result = Array.new(microns.length) { false }
    while !result.all? && timeout.positive?
      microns.each_with_index do |micron_id, i|
        next if result[i]

        result[i] = check_batteries_soc(micron_id, out_file, run_id)
      end

      next if result.all?

      timeout -= 1
    end

    puts format('verify_battries: %<time>0.3f', time: Time.now - start_time)

    # NOTICE: if one micron does not report battery OK, return false
    result.all?
  end

  def verify_battries_temperature(microns, run_id, out_file)
    start_time = Time.now
    timeout = 5
    result = Array.new(microns.length) { false }
    while !result.all? && timeout.positive?
      microns.each_with_index do |micron_id, i|
        next if result[i]

        result[i] = check_batteries_temperature(micron_id, out_file, run_id)
      end

      next if result.all?

      timeout -= 1
    end

    puts format('verify_battries_temperature: %<time>0.3f', time: Time.now - start_time)

    # NOTICE: if one micron does not report battery OK, return false
    result.all?
  end

  def verify_micron_routing(microns, run_id, out_file)
    start_time = Time.now
    timeout = 5
    result = Array.new(microns.length) { false }
    while !result.all? && timeout.positive?
      microns.each_with_index do |micron_id, i|
        next if result[i]

        # INFO ping_pass true as we tested before we have communication to the micron
        result[i] = get_micron_default_routing("MICRON_#{micron_id}", out_file, run_id, true)
      end

      next if result.all?

      timeout -= 1
    end

    puts format('verify_micron_routing: %<time>0.3f', time: Time.now - start_time)

    # NOTICE: if one micron does not report battery OK, return false
    result.all?
  end

  def verify_micron_software_version(microns, run_id, out_file)
    start_time = Time.now

      microns.each_with_index do |micron_id, i|
        verify_sw_version(micron_id, out_file, run_id)
      end
    puts format('verify_micron_software_version: %<time>0.3f', time: Time.now - start_time)
  end

  def reboot_microns(microns)
    start_time = Time.now

    microns.each do |micron_id|
      @micron.sys_reboot(@board, micron_id, false, false, wait_check_timeout = 0.1)
    end

    puts format('reboot_microns: %<time>0.3f', time: Time.now - start_time)

    true
  end
end
