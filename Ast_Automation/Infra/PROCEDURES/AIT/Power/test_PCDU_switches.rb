load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility('Operations/EPS/EPS_PCDU')
load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/FSW/UTIL_CmdSender')

class PCDUSwitchTest < ASTCOSMOSTestPower
  def initialize(target = "BW3")
    @target = target
    @cmd_sender = CmdSender.new
    @telem = ModuleTelem.new
    @pcdu = PCDU.new
    @realtime_destination = 'COSMOS_UMBILICAL'
    @freq = 1

    @switch_list = ["RWA_YP0_Z",
                    "RWA_YM0_Z",
                    "RWA_YP1_X",
                    "RWA_YM1_X",
                    "ROD_POS",
                    "ROD_NEG",
                    "ST_XP",
                    "ST_XM",
                    "UHF_NADIR_V28_A",
                    "UHF_NADIR_V5_B",
                    "QVA_SW_RX",
                    "QVA_SW_TX",
                    "QVA_YM_V28",
                    "QVA_YP_V28",
                    "QVA_YM_V5",
                    "QVA_YP_V5",
                    "QVA_YM_V12",
                    "QVA_YP_V12",
                    "QV_TRANSCEIVER_YM_5V",
                    "QV_TRANSCEIVER_YP_5V",
                    "QVA_YP_LNA_RH",
                    "QVA_YP_LNA_LH",
                    "QVA_YM_LNA_RH",
                    "QVA_YM_LNA_LH",
                    "QVA_YP_PA_RH",
                    "QVA_YP_PA_LH",
                    "QVA_YM_PA_RH",
                    "QVA_YM_PA_LH",
                    "SBAND_YM",
                    "SBAND_YP",
                    "POWER_SHARE_MICRON_104",
                    "POWER_SHARE_MICRON_107",
                    "POWER_SHARE_MICRON_78",
                    "POWER_SHARE_MICRON_120",
                    "POWER_SHARE_MICRON_77",
                    "POWER_SHARE_MICRON_119",
                    "POWER_SHARE_MICRON_90",
                    "POWER_SHARE_MICRON_93",
                    "HEATER_SSYPXM_SSYPXP",
                    "HEATER_CAMYPXM_CAMYPXP",
                    "TTC_SW_SBAND",
                    "TTC_SW_UHF",
                    "HEATER_SSYMXM_SSYMXP",
                    "HEATER_CAMYMXM_CAMYMXP",
                    "HEATER_EIGHT",
                    "BFCP_XP",
                    "BFCP_XM",
                    "QV_TRANSCEIVER_YM_12V",
                    "QV_TRANSCEIVER_YP_12V",
                    "UHF_NADIR_V28_B",
                    "UHF_NADIR_V5_A",
                    "LVC_BACKUP_12V_YM",
                    "LVC_BACKUP_12V_YP"]

    super()
  end

  # def test_PCDU_Switches_APC_YP

  #   # Turn on telem
  #   @telem.set_realtime("APC_YP", "FSW_TLM_APC", @realtime_destination, @freq)
  #   @telem.set_realtime("APC_YP", "POWER_TLM", @realtime_destination, @freq)
    
  #   # Test the switches
  #   switch_test("APC_YP", @switch_list)

  # end

  # def test_PCDU_Switches_APC_YM

  #   #Turn on telem
    
  #   @telem.set_realtime("APC_YM", "FSW_TLM_APC", @realtime_destination, @freq)
  #   @telem.set_realtime("APC_YM", "POWER_TLM", @realtime_destination, @freq)

  #   switch_test("APC_YM", @switch_list)

  # end

  def test_individual_switch

    # Ask for board
    board = combo_box("Select board", "APC_YP", "APC_YM")

    # Turn on telem
    @telem.set_realtime(board, "FSW_TLM_APC", @realtime_destination, @freq)
    @telem.set_realtime(board, "POWER_PCDU_LVC_TLM", @realtime_destination, @freq)
    @telem.set_realtime(board, "POWER_CSBATS_TLM", @realtime_destination, @freq)

    ask_for_component = true
    while ask_for_component

      # Get component
      component = combo_box("Select component name.\n\nSelect 'Exit Procedure' to stop", "RWA_YP0_Z", "RWA_YM0_Z", "RWA_YP1_X", "RWA_YM1_X", "ROD_POS", "ROD_NEG", "ST_XP", "ST_XM", "UHF_NADIR_V28_A", "UHF_NADIR_V5_B", "QVA_SW_RX", "QVA_SW_TX", "QVA_YM_V28", "QVA_YP_V28", "QVA_YM_V5", "QVA_YP_V5", "QVA_YM_V12", "QVA_YP_V12", "QV_TRANSCEIVER_YM_5V", "QV_TRANSCEIVER_YP_5V", "QVA_YP_LNA_RH", "QVA_YP_LNA_LH", "QVA_YM_LNA_RH", "QVA_YM_LNA_LH", "QVA_YP_PA_RH", "QVA_YP_PA_LH", "QVA_YM_PA_RH", "QVA_YM_PA_LH", "SBAND_YM", "SBAND_YP", "POWER_SHARE_MICRON_104", "POWER_SHARE_MICRON_107", "POWER_SHARE_MICRON_78", "POWER_SHARE_MICRON_120", "POWER_SHARE_MICRON_77", "POWER_SHARE_MICRON_119", "POWER_SHARE_MICRON_90", "POWER_SHARE_MICRON_93", "HEATER_SSYPXM_SSYPXP", "HEATER_CAMYPXM_CAMYPXP", "TTC_SW_SBAND", "TTC_SW_UHF", "HEATER_SSYMXM_SSYMXP", "HEATER_CAMYMXM_CAMYMXP", "HEATER_GPSXM_GPSYM", "HEATER_EIGHT", "BFCP_XP", "BFCP_XM", "QV_TRANSCEIVER_YM_12V", "QV_TRANSCEIVER_YP_12V", "UHF_NADIR_V28_B", "UHF_NADIR_V5_A", "LVC_BACKUP_12V_YM", "LVC_BACKUP_12V_YP", "Exit Procedure")

      if component == "Exit Procedure"
        # Stop procedure
        break
      end
      # Get Value
      val = combo_box("Turn on or off?", "ON", "OFF")
      if val == "ON"
         val = 1
      elsif val == "OFF"
        val = 0
      else
        wait
      end

      # Construct method name
      method_name = "set_#{component}"
      @pcdu.public_send(method_name, board, val)
    end

  end

  def switch_test(board, switch_list)

    switch_list.each do |switch|

      # Construct method name
      method_name = "set_#{switch}"

      # Ask user if ready to turn on
      if $Manual
        # Pause and let user continue when ready
        message_box("Ready to turn ON #{switch}.\n\nPress continue to send command", "Continue")
      end

      # Turn on Switch
      @pcdu.public_send(method_name, board, 1)

      # Ask user if ready to turn off
      if $Manual
        # Pause and let user continue when ready
        message_box("Ready to OFF #{switch}.\n\nPress continue to send command","Continue")
      end

      # Turn off Switch
      @pcdu.public_send(method_name, board, 0)


    end


  end

end
#$Manual = true
#handle = PCDUSwitchTest.new
#handle.test_PCDU_Switches_APC_YM
