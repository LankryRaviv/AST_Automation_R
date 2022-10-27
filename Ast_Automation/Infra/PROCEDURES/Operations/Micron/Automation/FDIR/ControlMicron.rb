load_utility('Operations/MICRON/MICRON_MODULE.rb')
load_utility('Operations/Micron/ChangeMode.rb')
load('Operations/Micron/MICRON_Firmware_Update.rb')
load('Operations/Micron/MICRON_FPGA_Update.rb')
load_utility('Operations/Micron/TrajectoryControlFunctions.rb')

require 'json'

class ControlMicron

#MIC_get_power_mode
#MIC_set_power_mode

    def initialize
        @micron = MICRON_MODULE.new
        @board = "MIC_LSL"
        @path_json = 'C:/Cosmos/ATE/result.json'
		@diction = {}
    end

    def write_to_json(dictionary)
        File.open(@path_json, "w") do |f|
            f.write(dictionary.to_json)
        end
    end
	
	def get_power_mode(micron_id)
		current_power_mode = @micron.get_system_power_mode(@board, micron_id, true, false)
		return nil unless !current_power_mode[0]["MIC_CURRENT_SYSTEM_POWER_MODE"].nil? 
		@diction["MIC_CURRENT_SYSTEM_POWER_MODE"] = current_power_mode[0]["MIC_CURRENT_SYSTEM_POWER_MODE"]
		write_to_json(@diction)
        return @diction
	end
	
	def set_power_mode(micron_id, mode)
		if !change_mode(micron_id,mode)
			return nil
		end
		@diction["MIC_SET_SYS_PWR_MODE_RES"] = mode
		write_to_json(@diction)
        return @diction
	end	
	
	def ping(micron_id)
		if !@micron.ping_micron(@board, micron_id)
			@diction["PING"]="False"
			write_to_json(@diction)
			return nil
		end
		@diction["PING"] = "True"
		write_to_json(@diction)
		return @diction
	end
	
	def power_off_micron(micron_id)
		@micron.sys_reboot(@board, micron_id)
		sleep 5
		ret = @micron.ping_micron(@board, micron_id)
		if !ret
			@diction["POWER_OFF"] = "True"
		else
			@diction["POWER_OFF"] = "False"
		end
		write_to_json(@diction)
	end
	
	def reboot(micron_id)
		@micron.sys_reboot(@board, micron_id)
		sleep(10)
		current_power_mode_dict =self.get_power_mode(micron_id)
		if current_power_mode_dict.nil?
			@diction["MIC_CSP_REBOOT"] = "False"
			write_to_json(@diction)
			return nil
		end
		current_power_mode = current_power_mode_dict["MIC_CURRENT_SYSTEM_POWER_MODE"]
		if current_power_mode == "PS1"
		@diction["MIC_CSP_REBOOT"] = "True"
		write_to_json(@diction)
		return @diction
		end
		@diction["MIC_CSP_REBOOT"] = "False"
		write_to_json(@diction)
		return nil
	end

	#Change micron to donee mode
	def donee(micron_id, direction)
		return change_mode_pwr(micron_id, direction, 'DONEE')
	end

	#Charging the current micron 
	def charging_current_micron(micron_id, direction)
		donee_ret = donee(micron_id, direction)
		write_to_json(@diction)
		return @diction
	end

	def charging_neighbor(micron_id, direction)
		donee_ret = donor(micron_id, direction)
		write_to_json(@diction)
		return @diction
	end
	
	#Charging the next micron after donor from the current micron, move the next micron to ps2 and donee from
	#the pwr sharing of the current micron
	# def charging_next_micron(current_micron_id, direction_donor, next_micron_id, direction_donee, power_mode)
	# 	donor(current_micron_id, direction_donor)
	# 	sleep 8
	# 	@diction["CURRENT_SYSTEM_POWER_MODE_#{power_mode.upcase}_MICRON_ID_#{next_micron_id}"] = change_mode(next_micron_id, power_mode).to_s.upcase
	# 	sleep 3
	# 	donee(next_micron_id, direction_donee)
	# 	write_to_json(@diction)
	# end

	#Disable pwr sharing
	def disable_mode(micron_id)
		change_mode_pwr(micron_id, 'ALL_DISCONNECTED', 'DISABLED')
		write_to_json(@diction)
		return @diction
	end

	#Change micron to donor mode
	def donor(micron_id, direction)
		return change_mode_pwr(micron_id, direction, 'DONOR')
	end

	#Config power sharing mode
    def config_power_sharing_mode(micron_id, direction, mode)
		pwr = @micron.set_power_sharing("MIC_LSL", "MICRON_#{micron_id}", direction, mode, true, false, 0.2)
		return 'EMPTY_PACKET' unless !pwr.empty?
		return pwr[0]['MIC_SET_PWR_SHARING_RESULT_CODE']
    end

	#Verify power sharing mode
	def get_power_sharing(micron_id, packet)
		power_result = @micron.get_power_sharing("MIC_LSL", "MICRON_#{micron_id}", nil, nil, true, false, 1)
		return 'DISABLED' unless !power_result.empty? 
		return power_result[0][packet]
    end

	#Get current power sharing
	def get_current(micron_id)
		power_result = @micron.get_power_sharing("MIC_LSL", "MICRON_#{micron_id}", nil, nil, true, false, 1)
		return 'EMPTY_PACKET' unless !power_result.empty? 
		return power_result[0]['MIC_PSH_IN_CURRENT']
	end

	#Change pwr sharing mode
	def change_mode_pwr(micron_id, direction, mode)
		@diction["MICRON_ID_#{mode}"] = micron_id.to_s
		@diction["MIC_SET_PWR_SHARING_#{mode}_RESULT_CODE"] = config_power_sharing_mode(micron_id, direction, mode).to_s
		@diction["MIC_SHARE_MODE_#{mode}"] = get_power_sharing(micron_id, 'MIC_SHARE_MODE')
		direction_validation(micron_id, direction, mode)
		curr = get_current(micron_id)
		puts curr
		@diction["MIC_PSH_IN_CURRENT_#{mode}"] = curr.to_s
		return curr
	end
	#Validate is the same direction as its should be
	def direction_validation(micron_id, direction, mode)
		if direction.to_s.downcase.include? "north"
			@diction["MIC_PSH_NORTH_STATUS_#{mode}"] = get_power_sharing(micron_id, 'MIC_PSH_NORTH_STATUS')
		elsif direction.to_s.downcase.include? "south"
			@diction["MIC_PSH_SOUTH_STATUS_#{mode}"] = get_power_sharing(micron_id, 'MIC_PSH_SOUTH_STATUS')
		elsif direction.to_s.downcase.include? "east"
			@diction["MIC_PSH_EAST_STATUS_#{mode}"] = get_power_sharing(micron_id, 'MIC_PSH_EAST_STATUS')
		else
			@diction["MIC_PSH_WEST_STATUS_#{mode}"] = get_power_sharing(micron_id, 'MIC_PSH_WEST_STATUS')
		end
	end

	def epoch(microns)
		mic = MICRON_MODULE.new
		result = Array.new(microns.length) {false}
		microns.each_with_index do |micron_id, i|
			epoch_time = Time.now.to_i #Time in seconds since epoch
			converted_time = Time.at(epoch_time).strftime "%d%m%Y%H%M%S" #Epoch seconds converted to ddmmyyyyhourminuteseconds
			#there is an option of broadcast all
			mic.set_mic_time("MIC_LSL", micron_id, epoch_time, converted=true, raw=true, wait_check_timeout=0.1)
			value = mic.get_mic_time("MIC_LSL", micron_id)
			ret = 0
			if !value.empty?    
				ret = value[0]['MIC_UNIX_TIME_STAMP']
				puts epoch_time + 1
				puts ret
				if ret == epoch_time + 1
					result[i] = true
				end
			end
			@diction["MIC_SET_TIME_MICRON_ID_#{micron_id}"] = (epoch_time + 1).to_s 
			@diction["MIC_GET_TIME_MICRON_ID_#{micron_id}"] = ret.to_s
			@diction["MIC_TIME_STATUS_MICRON_ID_#{micron_id}"] = result[i].to_s.upcase
		end
		
		@diction["MIC_TIME_STATUS_ALL"] = result.all?.to_s.upcase
		return @diction
	end

	def upload_sw(microns, image, path_main, version_str, run_id = "", file_info = nil)
		time = Time.new


		version = version_str.strip.split('.')

		if image == 'bl1'
			version_info = {BOOT_L1_MAJOR: version[0].to_i, BOOT_L1_MINOR: version[1].to_i, BOOT_L1_PATCH: version[2].to_i}
		elsif image == 'bl2'
			version_info = {BOOT_L2_MAJOR: version[0].to_i, BOOT_L2_MINOR: version[1].to_i, BOOT_L2_PATCH: version[2].to_i}
		elsif image == 'app'
			version_info = {APP_MAJOR: version[0].to_i, APP_MINOR: version[1].to_i, APP_PATCH: version[2].to_i}
		end

		res,status = firmware_update("MIC_LSL", image, path_main, version_info, file_id = 12, from_golden = 0, microns, broadcast_all: true, reboot: false, use_automations: true, check_version: false)
		puts status
		keys = status.keys
		values = status.values

		for i in 0..keys.length()
			if(keys[i] == nil)
				next
			end
			write_to_log_file(run_id, time, "#{image.upcase}_SW_UPLOAD_VERSION_#{version_str}_MICRON_#{get_micron_id_filterd(keys[i])}",
			"TRUE", "TRUE", (values[i].to_s == "PASS"? true : false), "BOOLEAN", values[i].to_s, "BW3_COMP_SW_UPLOAD", file_info)
			@diction["#{image.upcase}_SW_UPLOAD_VERSION_#{version_str}_#{keys[i]}"] = values[i].to_s
		end
		return @diction, res
	end

	def upload_fpga(microns, path, version_str)

		fpgaRes, status = micron_fpga_update("MIC_LSL", path, version_str, microns, file_id: 25, entry_size: 1754, broadcast_all: true, reboot: false, do_file_check: false, use_automations: true)
		puts status
		keys = status.keys
		values = status.values

		for i in 0..keys.length()
			if(keys[i] == nil)
				next
			end
			@diction["FPGA_UPLOAD_VERSION_#{version_str}_#{keys[i]}"] = values[i].to_s
		end
		return @diction
	end

	def get_heaters_status_bat(micron_id)
		for i in 1..4
			cmd="micron_heater get_battery_heater_power_state #{i}"
			res =@micron.remote_cli(@board, micron_id, 0, cmd, "COMPLETED",0)
			puts res
			@diction["BAT_HTR#{i}"]=res.split(" ",-1)[-3].strip
		end
		write_to_json(@diction)
	end
	
	def get_heater_status_bat(micron_id, number)
		cmd="micron_heater get_battery_heater_power_state #{number}"
		res =@micron.remote_cli(@board, micron_id, 0, cmd, "COMPLETED",0)
		@diction["BAT_HTR#{number}"]=res.split(" ",-1)[-3].strip
		write_to_json(@diction)
	end
	
	def get_heaters_status_MB(micron_id)
		for i in 1..2
			cmd="micron_heater get_main_board_heater_power_state #{i}"
			res =@micron.remote_cli(@board, micron_id, 0, cmd, "COMPLETED",0)
			puts res
			@diction["MB_HTR#{i}"]=res.split(" ",-1)[-3].strip
		end
		write_to_json(@diction)
	end
	
	def get_heater_status_MB(micron_id, number)
		cmd="micron_heater get_main_board_heater_power_state #{number}"
		res =@micron.remote_cli(@board, micron_id, 0, cmd, "COMPLETED",0)
		@diction["MB_HTR#{number}"]=res.split(" ",-1)[-3].strip
		write_to_json(@diction)
	end
	
	def get_heaters_status_fem(micron_id)
		for i in 1..15
			cmd="micron_heater get_fem_heater_power_state #{i}"
			res =@micron.remote_cli(@board, micron_id, 0, cmd, "COMPLETED",0)
			puts res
			@diction["FEM_HTR#{i}"]=res.split(" ",-1)[-3].strip
		end
		write_to_json(@diction)
	end

	def get_heater_status_fem(micron_id, number)
		cmd="micron_heater get_fem_heater_power_state #{number}"
		res =@micron.remote_cli(@board, micron_id, 0, cmd, "COMPLETED",0)
		@diction["FEM_HTR#{number}"]=res.split(" ",-1)[-3].strip
		write_to_json(@diction)
	end

	
end