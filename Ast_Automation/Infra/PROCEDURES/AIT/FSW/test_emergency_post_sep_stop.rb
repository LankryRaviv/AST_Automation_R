load 'Operations/FSW/FSW_CSP.rb'
load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'AIT/FSW/individual_tests/TLM_test_individual.rb'
load 'Operations/FSW/FSW_Telem.rb'
load 'Operations/FSW/FSW_CSP.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/FSW_FS_Upload.rb'
load 'Operations/FSW/FSW_FS_Continue_Upload.rb'
load 'Operations/FSW/FSW_FS.rb'
load 'Operations/FSW/UTIL_ByteString.rb'
load 'Operations/FSW/FSW_Config_Types.rb'
load 'Operations/FSW/FSW_Config_Properties.rb'
load 'AIT/FSW/individual_tests/Config_test_individual.rb'
load 'Operations/FSW/FSW_SE.rb'
load 'AIT/FSW/individual_tests/SE_BasicTest_individual.rb'
load 'Operations/FSW/FSW_FWUPD.rb'



class EMERGENCY_POST_SEP_ABORT < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @command_sender = CmdSender.new
    @module_SE = ModuleSE.new
    @medic = ModuleMedic.new
    @config = ModuleConfig.new
    
    @stack = "YP"
    @target = "BW3"
    @realtime_destination = 'COSMOS_UMBILLICAL'

    super()
  end
  
  def test_ABORT_POST_SEP
    status_bar("ABORT_POST_SEP")

    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @test_case_util = ModuleTestCase.new(@realtime_destination)
    @board = combo_box("Select board", "APC_YP", "APC_YM")

    @module_telem.set_realtime(@board, "FUNCTION_RUNNER_TLM_APC", @realtime_destination, 1)
    @command_sender.send(@board, "FR_ABORT_FUNCTION", {"FUNCTION_ID": "APC_POST_SEP"},true)
    wait_check(@target, @board + "-FUNCTION_RUNNER_TLM_APC", "FR_FUNCTION_STAGE_4", " == 'IDLE'", 3)

    @config.config_set(@board, 529, 0, 1)
    # Unlock saving
    @command_sender.send(@board, "FSW_UNLOCK_CONFIG_SAVING", {})
    # Save
    @command_sender.send(@board, "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})
    # Unlock saving
    @command_sender.send(@board, "FSW_UNLOCK_CONFIG_SAVING", {})
    # Save
    @command_sender.send(@board, "FSW_SAVE_ACTIVE_CONFIG_FALLBACK_FILE", {})
    # Lock saving
    @command_sender.send(@board, "FSW_LOCK_CONFIG_SAVING", {})

    value_raw = read_config_parameter(529, 0, "MAIN")
    value_converted = convert_value(value_raw, 0)
    value = message_box("Post-Sep Value set to #{value_converted} (0 = notSeparated, 1 =  Separated): Should Be disarmed (Separated)", 'Ok')
  end

  # ----------------------------------------------------------------------
  def read_config_parameter(property_id, type, location)
    if location == "MAIN" # the MAIN response packet has an extra P and the end of the packet name
      extra_character = "P"
    else
      extra_character = ""
    end    

    # Get initial response packet count
    init_cnt = tlm(@target, "#{@board}-GET_#{location}_CONFIG_PARAM_RES#{extra_character}", "RECEIVED_COUNT")

    # Send command
    cmd_params = {"ID": property_id,
                "TYPE_ID": type}
    @command_sender.send_with_crc_poll(@board, "FSW_GET_#{location}_CONFIG_PARAMETER", cmd_params)

    # wait until a new response packet arrives
    wait_check(@target, "#{@board}-GET_#{location}_CONFIG_PARAM_RES#{extra_character}", "RECEIVED_COUNT", "> #{init_cnt}",5)


    return tlm(@target, "#{@board}-GET_#{location}_CONFIG_PARAM_RES#{extra_character}", "CONFIG_UNION")

end

def convert_value(value, type)

    type_array = ['C', 'c', 'S', 's','L','l','F','D','H','H','H','H','H','H','H','H','H','H','H','H']
    type_val = type_array[type]
    unpacked_value = value.unpack("#{type_val}*")
    converted_value = unpacked_value[0]
    
    if type == 9
      converted_value = converted_value[0..31]
    elsif type == 10
      converted_value = converted_value[0..64]
    end         
    return converted_value

end



end
