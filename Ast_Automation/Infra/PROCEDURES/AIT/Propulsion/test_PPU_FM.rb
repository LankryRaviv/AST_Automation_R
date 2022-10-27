load 'cosmos/tools/test_runner/test.rb'
load 'TestRunnerUtils/ast_test_base.rb'

load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Telem')
load_utility('Operations/Propulsion/PROP_PPU_CONOPS')
load_utility('TestRunnerUtils/test_case_utils.rb')

class PPUTest_FM < ASTCOSMOSTestPropulsion
  def initialize
    @PPU = ModulePPU.new
    @cmd_sender = CmdSender.new
    @module_telem = ModuleTelem.new
    @target = "BW3"
    @csp_destination = "COSMOS_UMBILICAL"
    @test_util = ModuleTestCase.new
    status_bar("setup")

	
    super()
  end

  def setup()
    stack = @test_util.initialize_test_case('PPU_FM')
    @board = "APC_" + stack
    
    @module_telem.set_realtime(@board, "PROP_TLM", @csp_destination,1)

    # Clear errors
    @PPU.reset_error(@board)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_ERRORS_FAULTS", "== 0", 3) 

  end

  def test_send_telemetry()
    setup()

    # Send command
    @PPU.send_telemetry(@board)

    # Check telemetry
    # Check telemetry values are not present
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_LOGIC_STAT_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_ANALOG_STAT_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_LOGIC_CNTL_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_STAT_CNTL_CONTROL_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_STAT_CNTL_STATUS_PRESENCE", "=='PRESENT'", 3)

	  check_tlm_nom_standby()

  end

  def test_send_status()
    setup()

    @PPU.send_status(@board)

    wait_check(@target, "#{@board}-PROP_TLM", "PPU_LOGIC_STAT_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_ANALOG_STAT_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_LOGIC_CNTL_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_STAT_CNTL_CONTROL_PRESENCE", "=='PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_STAT_CNTL_STATUS_PRESENCE", "=='PRESENT'", 3)

    # Check telemetry
    #wait_check(@target, "#{@board}-PROP_TLM", "PPU_ANS", "== 'PPU_ANSOK'", 3)  #PPU_ANS does not exist in a packet
      
  end


  def test_stop_telemetry()
    setup()

    # Stop telemetry
    @PPU.stop_telemetry(@board)

    # Wait
	puts "Waiting 2 minutes"
    wait(120)

    # Check telemetry values are not present
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_LOGIC_STAT_PRESENCE", "=='NOT_PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_ANALOG_STAT_PRESENCE", "=='NOT_PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_LOGIC_CNTL_PRESENCE", "=='NOT_PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_STAT_CNTL_CONTROL_PRESENCE", "=='NOT_PRESENT'", 3)
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_STAT_CNTL_STATUS_PRESENCE", "=='NOT_PRESENT'", 3)

  end

  def test_reset_PPU()
    setup() 

    @PPU.reset_PPU(@board)

    # Verify the status is standby mode
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_EPS_MODE", "== 'STANDBY'", 5) 
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_GO_TO_THE_REGIME", "== 'STANDBY'", 5) 
    wait_check(@target, "#{@board}-PROP_TLM", "PPU_THRUSTER_START_UP_STAGE", "== 'STANDBY'", 5)   

  end
  # ---------------------------------------------------------------------------------
  def check_tlm_nom_standby
    wait = 1
    packet = "#{@board}-PROP_TLM"

    check_tlm_nominal
    check_tlm_non_ops

    wait_check(@target, packet, "PPU_OUTPUT_HEATER_1_CURRENT", "< 1", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_HEATER_2_CURRENT", "< 1", wait) # A
    
    wait_check(@target, packet, "PPU_PRESSURE_STABILIZER_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_READY", "== 'NOT_READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_1_READY", "== 'NOT_READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_2_READY", "== 'NOT_READY'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_READY", "== 'NOT_READY'", wait) 

    # Modes
    wait_check(@target, packet, "PPU_EPS_MODE", "== 'STANDBY'", wait) 
    wait_check(@target, packet, "PPU_GO_TO_THE_REGIME", "== 'STANDBY'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_START_UP_STAGE", "== 'STANDBY'", wait) 

  end

  # ---------------------------------------------------------------------------------
  def check_tlm_nom_preheat
    wait = 1
    packet = "#{@board}-PROP_TLM"

    check_tlm_nominal
    check_tlm_non_ops

    # Modes
    wait_check(@target, packet, "PPU_EPS_MODE", "== 'PRE_HEAT'", wait) 
    wait_check(@target, packet, "PPU_GO_TO_THE_REGIME", "== 'PRE_HEAT'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_START_UP_STAGE", "== 'PRE_HEAT'", wait)   
    
    wait_check(@target, packet, "PPU_PRESSURE_STABILIZER_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_1_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_2_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_OUTPUT_HEATER_1_CURRENT", "< 1", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_HEATER_2_CURRENT", "< 1", wait) # A
    
  end

  # ---------------------------------------------------------------------------------
  def check_tlm_nom_ready
    wait = 1
    packet = "#{@board}-PROP_TLM"

    check_tlm_nominal
    check_tlm_non_ops

    # Modes
    wait_check(@target, packet, "PPU_EPS_MODE", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_GO_TO_THE_REGIME", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_START_UP_STAGE", "== 'READY'", wait)   
    
    wait_check(@target, packet, "PPU_PRESSURE_STABILIZER_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_READY", "== 'NOT_READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_1_READY", "== 'NOT_READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_2_READY", "== 'NOT_READY'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_OUTPUT_HEATER_1_CURRENT", "< 1", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_HEATER_2_CURRENT", "< 1", wait) # A

  end

  # ---------------------------------------------------------------------------------
  def check_tlm_nom_init
    wait = 1
    packet = "#{@board}-PROP_TLM"
    check_tlm_nominal
    check_tlm_ops
   
    # Modes
    wait_check(@target, packet, "PPU_EPS_MODE", "== 'INITIALIZATION'", wait) 
    wait_check(@target, packet, "PPU_GO_TO_THE_REGIME", "== 'INITIALIZATION'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_START_UP_STAGE", "== 'INITIALIZATION'", wait)   

    wait_check(@target, packet, "PPU_VALVE_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_2_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_3_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_4_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_5_TURN_ON", "== 'ON'", wait) 

    wait_check(@target, packet, "PPU_SOLENOID_1_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_SOLENOID_2_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_SOURCE_TURN_ON", "== 'ON'", wait) 

    wait_check(@target, packet, "PPU_INPUT_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_ANODE_SOURCE_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_DISCHARGE_SOURCE_1_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_DISCHARGE_SOURCE_2_TURN_ON", "== 'OFF'", wait)
 
    wait_check(@target, packet, "PPU_PRESSURE_STABILIZER_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_2_TURN_ON", "== 'ON'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_TURN_ON", "== 'OFF'", wait) 

  end

  # ---------------------------------------------------------------------------------
  def check_tlm_nom_ops
    wait = 1
    packet = "#{@board}-PROP_TLM"
    check_tlm_nominal
    check_tlm_ops
   
    # Modes
    wait_check(@target, packet, "PPU_EPS_MODE", "== 'OPERATION'", wait) 
    wait_check(@target, packet, "PPU_GO_TO_THE_REGIME", "== 'OPERATION'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_START_UP_STAGE", "== 'OPERATION'", wait)   

    wait_check(@target, packet, "PPU_VALVE_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_2_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_3_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_4_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_5_TURN_ON", "== 'ON'", wait) 

    wait_check(@target, packet, "PPU_SOLENOID_1_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_SOLENOID_2_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_SOURCE_TURN_ON", "== 'ON'", wait) 

    wait_check(@target, packet, "PPU_INPUT_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_ANODE_SOURCE_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_DISCHARGE_SOURCE_1_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_DISCHARGE_SOURCE_2_TURN_ON", "== 'OFF'", wait)

    wait_check(@target, packet, "PPU_PRESSURE_STABILIZER_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_TURN_ON", "== 'ON'", wait)
    wait_check(@target, packet, "PPU_CATHODE_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_2_TURN_ON", "== 'ON'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_TURN_ON", "== 'ON'", wait)  


  end

  # ---------------------------------------------------------------------------------
  def check_tlm_ops
    wait = 1
    packet = "#{@board}-PROP_TLM"

    wait_check(@target, packet, "PPU_OUTPUT_ANODE_VOLTAGE", " < 450", wait) # V
    wait_check(@target, packet, "PPU_OUTPUT_ANODE_CURRENT", "< 3", wait) # A

    wait_check(@target, packet, "PPU_DISCHARGE_VOLTAGE_1", "< 1300", wait) # V
    wait_check(@target, packet, "PPU_DISCHARGE_CURRENT_1", "< 3", wait) # A
    wait_check(@target, packet, "PPU_DISCHARGE_VOLTAGE_2", "< 1300", wait) # V
    wait_check(@target, packet, "PPU_DISCHARGE_CURRENT_2", "< 3", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_SOLENOID_1_CURRENT", "< 3", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_SOLENOID_2_CURRENT", "< 3", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_HEATER_1_CURRENT", "< 1", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_HEATER_2_CURRENT", "< 1", wait) # A

    wait_check(@target, packet, "PPU_OUTPUT_ANODE_POWER", "< 600", wait) # W

    wait_check(@target, packet, "PPU_SOLENOID_1_CURRENT", "< 3", wait) # A
    wait_check(@target, packet, "PPU_SOLENOID_2_CURRENT", "< 3", wait) # A

    wait_check(@target, packet, "PPU_INPUT_ON", "== 0", wait)

    wait_check(@target, packet, "PPU_PRESSURE_STABILIZER_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_1_READY", "== 'NOT_READY'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_2_READY", "== 'READY'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_READY", "== 'READY'", wait) 


        
  end

  # ---------------------------------------------------------------------------------
  def check_tlm_nominal

    wait = 1
    packet = "#{@board}-PROP_TLM"

    # Inlet
    wait_check(@target, packet, "PPU_INLET_VOLTAGE", "< 36", wait) # V
    wait_check(@target, packet, "PPU_INLET_CURRENT", "< 12", wait) # A

    # High Pressure
    wait_check(@target, packet, "PPU_HIGH_PRESSURE_1", "< 130", wait) # bar
    wait_check(@target, packet, "PPU_HIGH_PRESSURE_2", "< 130", wait) # bar
    wait_check(@target, packet, "PPU_HIGH_PRESSURE_3", "< 130", wait) # bar
    
    # Low Pressure
    wait_check(@target, packet, "PPU_LOW_PRESSURE_1", "< 3", wait) # bar
    wait_check(@target, packet, "PPU_LOW_PRESSURE_2", "< 3", wait) # bar
    wait_check(@target, packet, "PPU_LOW_PRESSURE_3", "< 3", wait) # bar

    # Temp
    wait_check(@target, packet, "PPU_XFS_TEMPERATURE_1", "< 65", wait) # deg C
    wait_check(@target, packet, "PPU_XFS_TEMPERATURE_2", "< 65", wait) # deg C
    wait_check(@target, packet, "PPU_XFS_TEMPERATURE_3", "< 65", wait) # deg C
    wait_check(@target, packet, "PPU_PPU_TEMPERATURE", "< 85", wait) # deg C

    # Pressure
    wait_check(@target, packet, "PPU_ACCUMULATOR_TANK_PRESSURE", "< 3", wait) # bar
    
    # Faults
    wait_check(@target, packet, "PPU_INPUT_FAULT", "== 'NO_FAULT'", wait) 
    wait_check(@target, packet, "PPU_VALVE_1_FAULT", "== 'NO_FAULT'", wait) 
    wait_check(@target, packet, "PPU_VALVE_2_FAULT", "== 'NO_FAULT'", wait) 
    wait_check(@target, packet, "PPU_VALVE_3_FAULT", "== 'NO_FAULT'", wait) 
    wait_check(@target, packet, "PPU_VALVE_4_FAULT", "== 'NO_FAULT'", wait) 
    wait_check(@target, packet, "PPU_VALVE_5_FAULT", "== 'NO_FAULT'", wait) 
    wait_check(@target, packet, "PPU_ERRORS_FAULTS", "== 0", wait) 
    wait_check(@target, packet, "PPU_SOLENOID_HEATER_SOURCES_FAULT", "=='NO_FAULT'", wait) 
        

  end

  # ---------------------------------------------------------------------------------
  def check_tlm_non_ops

    wait = 1
    packet = "#{@board}-PROP_TLM"

    wait_check(@target, packet, "PPU_OUTPUT_ANODE_VOLTAGE", "< 1", wait) # V
    wait_check(@target, packet, "PPU_OUTPUT_ANODE_CURRENT", "< 1", wait) # A

    wait_check(@target, packet, "PPU_DISCHARGE_VOLTAGE_1", "< 1", wait) # V
    wait_check(@target, packet, "PPU_DISCHARGE_CURRENT_1", "< 1", wait) # A
    wait_check(@target, packet, "PPU_DISCHARGE_VOLTAGE_2", "< 1", wait) # V
    wait_check(@target, packet, "PPU_DISCHARGE_CURRENT_2", "< 1", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_SOLENOID_1_CURRENT", "< 1", wait) # A
    wait_check(@target, packet, "PPU_OUTPUT_SOLENOID_2_CURRENT", "< 1", wait) # A

    wait_check(@target, packet, "PPU_OUTPUT_ANODE_POWER", "< 1", wait) # W

    wait_check(@target, packet, "PPU_SOLENOID_1_CURRENT", "< 1", wait) # A
    wait_check(@target, packet, "PPU_SOLENOID_2_CURRENT", "< 1", wait) # A

    wait_check(@target, packet, "PPU_INPUT_ON", "== 0", wait)

    wait_check(@target, packet, "PPU_INPUT_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_ANODE_SOURCE_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_DISCHARGE_SOURCE_1_TURN_ON", "== 'OFF'", wait)
    wait_check(@target, packet, "PPU_DISCHARGE_SOURCE_2_TURN_ON", "== 'OFF'", wait)

    wait_check(@target, packet, "PPU_VALVE_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_2_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_3_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_4_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_VALVE_5_TURN_ON", "== 'OFF'", wait) 

    wait_check(@target, packet, "PPU_SOLENOID_1_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_SOLENOID_2_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_SOURCE_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_SOURCE_TURN_ON", "== 'OFF'", wait) 
    
    
    wait_check(@target, packet, "PPU_PRESSURE_STABILIZER_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_HEATER_2_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_1_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_CATHODE_2_TURN_ON", "== 'OFF'", wait) 
    wait_check(@target, packet, "PPU_THRUSTER_TURN_ON", "== 'OFF'", wait) 
    
  end


  def teardown
    #@module_telem.realtime_off(@board, "PROP", 128, "PROP_TLM")
    start_logging("ALL")
  end
   
end