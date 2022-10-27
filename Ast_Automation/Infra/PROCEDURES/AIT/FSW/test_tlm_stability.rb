load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'AIT/FSW/individual_tests/TLM_test_individual.rb'
load("Operations/FSW/FSW_Telem.rb")
load("Operations/FSW/FSW_CSP.rb")


class TELEMETRY_STABILITY_TEST < ASTCOSMOSTestFSW
  def initialize
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @target = "BW3"
    @missed_pkts_allowed = 2
    @freq = 10
    @duration_ms = 30 * 1000 # 2 minutes
    @realtime_destination = 'COSMOS_DPC'

    @collectors = [
      {board: 'FC_YP', pkt_name: 'FSW_TLM_FC',  sid: "FSW", tid: "NORMAL", start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
      {board: 'APC_YP', pkt_name: 'FSW_TLM_APC',  sid: "FSW", tid: "NORMAL", start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
      {board: 'FC_YP', pkt_name: 'AOCS_TLM',  sid: "AOCS", tid: "NORMAL", start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
      {board: 'DPC_1', pkt_name: 'FSW_TLM_DPC', sid: 'FSW', tid: 'NORMAL', start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
      {board: 'DPC_2', pkt_name: 'FSW_TLM_DPC', sid: 'FSW', tid: 'NORMAL', start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
      {board: 'DPC_3', pkt_name: 'FSW_TLM_DPC', sid: 'FSW', tid: 'NORMAL', start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
      {board: 'DPC_4', pkt_name: 'FSW_TLM_DPC', sid: 'FSW', tid: 'NORMAL', start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
      {board: 'DPC_5', pkt_name: 'FSW_TLM_DPC', sid: 'FSW', tid: 'NORMAL', start_recv: 0, expected_packets: 0, end_recv: 0, expected_pkts: 0},
    ]

    super()
  end

  def setup
    @realtime_destination = combo_box("Choose Environment", 'COSMOS_UMBILICAL','COSMOS_DPC')
    @freq                 = ask("Frequency to run at:")
    @module_csp.reboot("FC_YP", true)
    @module_csp.reboot("DPC_1", true)
    @module_csp.reboot("DPC_2", true)
    @module_csp.reboot("DPC_3", true)
    @module_csp.reboot("DPC_4", true)
    @module_csp.reboot("DPC_5", true)
    @module_csp.reboot("APC_YP",true)
    wait(7)
    status_bar("setup")
  end

  def test_stability
    check_tlm_stability(@collectors, @module_telem, @realtime_destination, @target, @freq, @duration_ms, @missed_pkts_allowed)
  end

  def teardown
    status_bar("teardown")
  end

end
