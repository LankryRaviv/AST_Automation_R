load 'Operations/FSW/FSW_Config.rb'
load 'Operations/FSW/UTIL_CmdSender.rb'

class ModuleFdir
  def initialize
    @cmd_sender = CmdSender.new
    @module_config = ModuleConfig.new
    @type_u32 = 4 # Index of U32 in type_id_array
    @type_fdir_config = 12 # Index of fdir config type in type_id_array
    @bytes_per_config = 38
    #This needs to be updated manually
    @boards = {
      "APC_YP" => {id_of_num_of_rows: 14,  id_of_start_of_fdir_configs: 15},
      "FC_YP" => {id_of_num_of_rows: 4,  id_of_start_of_fdir_configs: 5},
      "APC_YM" => {id_of_num_of_rows: 14,  id_of_start_of_fdir_configs: 15},
      "FC_YM" => {id_of_num_of_rows: 4,  id_of_start_of_fdir_configs: 5}
    }
    @num_of_rows_in_configs_file
  end


  # Manually uploads the config that holds the number of fdir configs
  #  --> The number of any number of existing rows starts at 1 (Ex. If there is a single fdir config, the number of rows will be 1)
      def hard_upload_num_config_rows(board, num_of_rows, no_hazardous_check = false)
        @module_config.config_set(board, @boards[board][:id_of_num_of_rows], @type_u32, num_of_rows, no_hazardous_check)
      end

  # Uploads the config that holds the number of fdir configs from the binary config file
  #  --> file_path must use forward slashes and should be an absolute file path (unless the file is located in the local directory)
      def upload_num_config_rows(board, file_path, no_hazardous_check = false)
        f = File.open(file_path)
        f.seek(0) # Need to rewind the stream to the beginning of the file to get the num of configs
        @num_of_rows_in_configs_file = f.read(4).unpack("L").first # Read the number of configs (first 4 bytes) and unpack the binary data as a single element uint32 array (we only use the first element)
        hard_upload_num_config_rows(board, @num_of_rows_in_configs_file, no_hazardous_check)
        f.close
      end


  # Manually uploads a particular row/failure mode code of the fdir configs for a particular board
  #  --> Rows are zero indexed and need to be an admissible value (between 0 and (number of failure mode codes that the binary file contains - 1))
      def hard_upload_config_row(board, row_num, new_config, no_hazardous_check = false)
        property_id = @boards[board][:id_of_start_of_fdir_configs] + row_num # Property ID of the fdirConfigRow<row_num> config 
        @module_config.config_set(board, property_id, @type_fdir_config, new_config, no_hazardous_check)
      end


  # uploads a particular row/failure mode code of the fdir configs for a particular board from the binary fdir config file
  #  --> Rows are zero indexed and need to be an admissible value (between 0 and the number of failure mode codes that the binary file contains)
  #  --> file_path must use forward slashes and should be an absolute file path (unless the file is located in the local directory)
      def upload_config_row(board, row_num, file_path, no_hazardous_check = false)
        f = File.open(file_path)
        f.seek(4+(row_num*@bytes_per_config)) # Need to fast forward past the number of configs (first 4 bytes), then past the first "row_num" number of config rows
        new_config = f.read(@bytes_per_config)
        f.close

        property_id = @boards[board][:id_of_start_of_fdir_configs] + row_num # Property ID of the fdirConfigRow<row_num> config 
        @module_config.config_set(board, property_id, @type_fdir_config, new_config, no_hazardous_check)
      end


  # uploads a particular row/failure mode code of the fdir configs for all boards from the binary fdir config file
  #  --> Rows are zero indexed and need to be an admissible value (between 0 and the number of failure mode codes that the binary file contains)
  #  --> file_path must use forward slashes and should be an absolute file path (unless the file is located in the local directory)
      def upload_config_row_all_boards(row_num_to_upload, file_path, no_hazardous_check = false)
        # Loop through all boards and upload the specified config row
        @boards.each_key do |board|
          upload_config_row(board, row_num_to_upload, file_path, no_hazardous_check = false)
        end
      end

  # uploads the number of configs and all config rows/failure mode codes for a particular board from the binary fdir config file
  #  --> Rows are zero indexed and need to be an admissible value (between 0 and the number of failure mode codes that the binary file contains)
  #  --> file_path must use forward slashes and should be an absolute file path (unless the file is located in the local directory)
      def upload_configs(board, file_path, no_hazardous_check = false)
        upload_num_config_rows(board, file_path)

        f = File.open(file_path)
        f.seek(4)

        for row in 0..(@num_of_rows_in_configs_file-1) do
          config = f.read(@bytes_per_config) # Read one config at a time
          hard_upload_config_row(board, row, config, no_hazardous_check)
          sleep(0.8)
        end
        f.close
      end

  # uploads the number of configs and all config rows/failure mode codes for all boards from the binary fdir config file
  #  --> Rows are zero indexed and need to be an admissible value (between 0 and the number of failure mode codes that the binary file contains)
  #  --> file_path must use forward slashes and should be an absolute file path (unless the file is located in the local directory)
      def upload_config_file_all_boards(file_path, no_hazardous_check = false)
        # Loop through all boards and upload the specified config row
        @boards.each_key do |board|
          upload_configs(board, file_path, no_hazardous_check)
        end
      end

  # FDIR Manager Commands
      def update_configs(board, no_hazardous_check = false)
        cmd_name = "FDIR_UPDATE_CONFIGS"
        cmd_params = {}

        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
      end

      def clear_diag_status(board, failure_mode_code, no_hazardous_check = false)
        #formulate parameters
        cmd_name = "FDIR_CLEAR_DIAG_STATUS"
        cmd_params = {
          "FAILURE_MODE_CODE": failure_mode_code
        }

        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
      end

      def enable_diag(board, failure_mode_code, no_hazardous_check = false)
        #formulate parameters
        cmd_name = "FDIR_ENABLE_DIAG"
        cmd_params = {
          "FAILURE_MODE_CODE": failure_mode_code
        }

        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
      end

      def disable_diag(board, failure_mode_code, no_hazardous_check = false)
        #formulate parameters
        cmd_name = "FDIR_DISABLE_DIAG"
        cmd_params = {
          "FAILURE_MODE_CODE": failure_mode_code
        }

        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
      end

      def enable_failsafe_resp(board, failure_mode_code, no_hazardous_check = false)
        #formulate parameters
        cmd_name = "FDIR_ENABLE_DIAG_FAILSAFE"
        cmd_params = {
          "FAILURE_MODE_CODE": failure_mode_code
        }

        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
      end

      def disable_failsafe_resp(board, failure_mode_code, no_hazardous_check = false)
        #formulate parameters
        cmd_name = "FDIR_DISABLE_DIAG_FAILSAFE"
        cmd_params = {
          "FAILURE_MODE_CODE": failure_mode_code
        }

        @cmd_sender.send(board, cmd_name, cmd_params, no_hazardous_check)
      end

  # Helper function 
      def hex_string_to_config(config)
        config = config.split(' ')
        i = 0
        config.each do |x|
            config[i] = config[i].to_i(16)
            i += 1
        end
        config = config.pack('C*')
        return config
      end
end 