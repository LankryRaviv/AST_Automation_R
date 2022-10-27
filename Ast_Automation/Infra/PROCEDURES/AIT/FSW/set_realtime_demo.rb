load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load_utility("Operations/FSW/FSW_Telem")
load_utility("Operations/FSW/FSW_CSP")

class TlmDemo
   def test
    @module_telem = ModuleTelem.new
    @module_csp = ModuleCSP.new
    @target = "BW3"
    
    @apc_pkts = ['FSW_TLM_APC','FDIR_TLM_APC','MEDIC_LEADER_TLM']
    
    @fc_pkts = ['FDIR_TLM_FC','FDIR_TLM_FC','MEDIC_FOLLOWER_TLM_FC']

    @boards = [
      {board_name: 'APC_YP', pkts: @apc_pkts, destination_csp_id: 'COSMOS_DPC'},
      {board_name: 'FC_YP', pkts: @fc_pkts, destination_csp_id: 'COSMOS_DPC'}]
                 
    @module_csp.reboot("FC_YP")
    @module_csp.reboot("APC_YP")
    wait(4)
      
      @fc_pkts.each do | pkt |
        # Get a single packet with instantaneous telemtry
        @module_telem.send_instantaneous_tlm(@boards[1][:board_name], pkt, @boards[1][:destination_csp_id])
      end

    
  end
end


demo = TlmDemo.new
demo.test()
    
