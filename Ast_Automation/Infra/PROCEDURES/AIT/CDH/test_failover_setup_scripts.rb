load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load('Operations/FSW/FSW_FS_Upload.rb')
load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/FSW/UTIL_CmdSender')
load_utility("Operations/FSW/FSW_CSP")
load_utility('Operations/FSW/FSW_FDIR')
load_utility('Operations/FSW/FSW_MEDIC')
load_utility('AIT/CDH/failover_setup_functions')

# TODO: Add in the DPC eventually

class FailoverSetupScripts < ASTCOSMOSTestCDH
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @module_fs = ModuleFS.new
    @fdir = ModuleFdir.new
    @cmd_sender = CmdSender.new
    @medic = ModuleMedic.new
    @failover = FailoverSetup.new

    @entry_size = 186
    @fdir_script_file_id = 23
    @fdir_config_file = "#{__dir__}\\config_binary_all_fsa_disabled.bin"
    @check_aspect = "CRC"
    @target = "BW3"
    @secondary_board_failover_fmc = 120 # Failure Mode CDH_045
    @fdir_script_file_name = "#{__dir__}\\medic_failover_secondary_board_script.txt"
    @alloted_failover_time = 7
    @realtime_destination = 'COSMOS_DPC'

    @apcs =  {apc_yp: "APC_YP", apc_ym: "APC_YM"}

    @medic_enums = {yp_stack_location: 0, ym_stack_location: 1, primary_state: 0, secondary_state: 1, me_ok_enabled: 1, me_ok_disabled: 0}

    @medic_task_tlm_pkts = [
      {yp_board: "APC_YP", ym_board: "APC_YM", pkt_name: "MEDIC_LEADER_TLM", sid: "MEDIC", tid: "NORMAL"},
      {yp_board: "FC_YP",  ym_board: "FC_YM", pkt_name: "MEDIC_FOLLOWER_TLM_FC", sid: "MEDIC", tid: "NORMAL"}
    ]

    @yp_fsw_collectors = [
      {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}
    ]

    @ym_fsw_collectors = [
      {board: 'APC_YM', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL"},
      {board: 'FC_YM', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL"}
    ]

    @file_ids = {
        fdir_script_file_id: 23,
        config_file_main: 4103,
        config_file_main_backup: 4104,
        config_file_fallback: 4105,
        config_file_fallback_backup: 4106
    }

    super()
  end

  def setup_environment(stack)
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    # Step 2 - Turn on live telem
    @medic_task_tlm_pkts.each do | collector |
        if stack == "YP"
            @module_telem.set_realtime(collector[:yp_board], collector[:pkt_name], @realtime_destination, 1)
        elsif stack == "YM"
            @module_telem.set_realtime(collector[:ym_board], collector[:pkt_name], @realtime_destination, 1)
        end
    end
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def test_0_setup_yp_as_primary
    setup_environment("YP")
    @failover.setup_yp_as_primary(@realtime_destination)
  end
  

  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def test_0_setup_ym_as_primary
    setup_environment("YP")
    @failover.setup_ym_as_primary(@realtime_destination)
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  # This function sets up the fdir diagnostics and failsafe response scripts for APC_YP
  def test_0_setup_yp_fdir
    setup_environment("YP")
    @failover.setup_yp_fdir()
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  # This function sets up the fdir diagnostics and failsafe response scripts for APC_YM
  def test_0_setup_ym_fdir
    setup_environment("YM")
    @failover.setup_ym_fdir()
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def test_0_clear_yp_files
    setup_environment("YP")
    @failover.clear_yp_files()
  end


  # This function assumes that it will be run from a COSMOS instance linked to stack YM
  def test_0_clear_ym_files
    setup_environment("YM")
    @failover.clear_ym_files()
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def test_0_power_APC_YP_on
    @failover.power_APC_YP_on()
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def test_0_power_APC_YP_off
    @failover.power_APC_YP_off()
  end

      # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def test_0_power_APC_YM_on
    @failover.power_APC_YM_on()
  end

  # This function assumes that it will be run from a COSMOS instance linked to stack YP
  def test_0_power_APC_YM_off
    @failover.power_APC_YM_off()
  end



end