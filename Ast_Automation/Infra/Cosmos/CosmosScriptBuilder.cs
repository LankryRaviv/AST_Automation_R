using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
namespace Infra.Cosmos
{
    public class CosmosScriptBuilder
    {
        List<string> _scripts = new List<string>();
        static readonly string[] bw_labels = new string[] { "10MHz", "5MHz", "3MHz", "1.4MHz", "BYPASS" };

        public CosmosScriptBuilder()
        {
            Add_LoadModules();
        }

        #region Micron control

        public void Add_ClearMCLUTLookupTable(int micronID)
        {
            Comment($"Clear Lookup table for micron{micronID}");
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708b00000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708b40000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708b80000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708bc0000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708c00000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708c40000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708c80000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002708cc0000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb9000000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb9040000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb9080000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb90c0000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb9100000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb9140000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb9180000000",0.1);
            Add_CPBF_RemoteCLI($"send=o,0x0440{micronID.ToString("X2")},0x002bb91c0000000",0.1);
        }

        public void Add_LoadMCLUTcript(int micronID, string fileName, double cmdRate = 0.05, int wait = 1)
        {
            GenericScript gs = new GenericScript(fileName);
            gs.Modify("MicronID", micronID.ToString("X2"));
            //fileName = ReplaceFileNameExtension(fileName, "mod");
            //gs.SaveAs(fileName);
            string[] script = gs.GetLines();
            _scripts.Add($"# Running Script {fileName}");
            for (int n = 0; n < script.Length; n++)
            {
                if (script[n].Trim() == "")
                {
                    _scripts.Add("");
                }
                else
                {
                    Add_CPBF_RemoteCLI(script[n].Replace('"', ' ').Trim(), 0.1);
                }
            }

            //_scripts.Add($"send_cli_cmds_from_file({FileNameFormat(fileName)},{cmdRate}, {wait})");
        }
        public void Add_LoadMCLUTcript(string[] script, double cmdRate = 0.05, int wait = 1)
        {

            for (int n = 0; n < script.Length; n++)
            {
                if (script[n].Trim() == "")
                {
                    _scripts.Add("");
                }
                else
                {
                    Add_CPBF_RemoteCLI(script[n].Replace('"', ' ').Trim(), 0.1);
                }
            }

            //_scripts.Add($"send_cli_cmds_from_file({FileNameFormat(fileName)},{cmdRate}, {wait})");
        }
        public void Add_BroadcastMicrons_OperationalPowerMode()
        {
            Add_SetMicronPowerMode(0xffff, CosmosEnumerations.PS.PS2);
            Add_SetMicronPowerMode(0xffff, CosmosEnumerations.PS.OPERATIONAL);

        }

        public void Add_BroadcastMicrons_OperationalPowerMode(int[] micronIDs)
        {
            for (int i = 0; i < micronIDs.Length; i++)
            {
                _scripts.Add($"micron.set_system_power_mode('MIC_LSL', {micronIDs[i]}, '{CosmosEnumerations.PS.PS2.ToString()}')");
            }
            Add_Delay(5);

            for (int i = 0; i < micronIDs.Length; i++)
            {
                _scripts.Add($"micron.set_system_power_mode('MIC_LSL', {micronIDs[i]}, '{CosmosEnumerations.PS.OPERATIONAL.ToString()}')");
                Add_Delay(14);
                Add_JitterCleanerCheck(14);
            }
        }

        public void Add_BroadcastMicrons_SetPowerMode(CosmosEnumerations.PS powerMode,int[] micronIDs)
        {
            for (int i = 0; i < micronIDs.Length; i++)
            {
                _scripts.Add($"micron.set_system_power_mode('MIC_LSL', {micronIDs[i]}, '{powerMode.ToString()}')");
            }
            switch (powerMode)
            {
                case CosmosEnumerations.PS.PS2:
                case CosmosEnumerations.PS.PS1:
                    _scripts.Add("sleep 8 # wait for system to switch");
                    break;
                case CosmosEnumerations.PS.OPERATIONAL:
                    _scripts.Add("sleep 20 # wait for system to switch");
                    break;
            }
        }

        public void Add_BroadcastMicrons_SetFrequency(CosmosEnumerations.BW bw, double dl_cf_MHz, double ul_cf_MHz,int[] micronIds)
        {
            for(int n=0; n<micronIds.Length; n++)
            {
                Add_MicronFpgaFreqParam(micronIds[n],bw,dl_cf_MHz,ul_cf_MHz);
            }
            
        }

        public void Add_JitterCleanerCheck(int micronID)
        {
            Comment("------------------ Read Jitter Cleaner status ---------------------------------------------");
            _scripts.Add($"status = micron.get_micron_JitterCleanerStatus('MIC_LSL', {micronID})[0]['MIC_JC_RESULT_CODE']");
            PrintToOS($"'JC{micronID}='+status");
            Comment("-------------------------------------------------------------------------------------------");

        }

        public void Add_JitterCleanerStatusFromMicron(int micronID)
        {
            Comment("-----------------------------------------------------------------------");
            Add_MicronRemoteCLI(micronID, "i2c tx i2c4 0x6B 0100");
            Add_MicronRemoteCLI(micronID, "i2c tx i2c4 0x6B 0e");
            Add_MicronRemoteCLI(micronID, "i2c rx i2c4 0x6B 1", false);
            Comment("-----------------------------------------------------------------------");

        }

        public void Add_MicronRemoteCLI(int micronID, string commmand, Boolean ignorReply = true)
        {
            //def remote_cli(board, micron_id, packet_delay, input_data, message_completed, converted=false, raw=false, wait_check_timeout=0.1)
            _scripts.Add($"reply = micron.remote_cli('MIC_LSL',{micronID},0,'{commmand}','COMPLETED',true,false,1)");
            if (!ignorReply)
            {
                PrintToOS($"' [{commmand}]->Micron{micronID}:'+reply");
            }
        }

        public void Add_MicronFpgaFreqParam(int micronID, CosmosEnumerations.BW bw, CosmosEnumerations.DL_CF cf_dl, CosmosEnumerations.UL_CF cf_ul)
        {
            _scripts.Add($"# Set DL {(int)cf_dl / 1000}MHz");
            _scripts.Add($"# Set UL {(int)cf_ul / 1000}MHz");

            _scripts.Add($"micron.set_fpga_freq_param('MIC_LSL',{micronID},true,false,1,'{bw_labels[(int)bw]}',{(int)cf_dl},'{bw_labels[(int)bw]}',{(int)cf_ul})");
        }


        public void Add_MicronFpgaFreqParam(int micronID, CosmosEnumerations.BW bw, double dl_cf_MHz, double ul_cf_MHz)
        {
            _scripts.Add($"# Set DL {dl_cf_MHz}MHz");
            _scripts.Add($"# Set UL {ul_cf_MHz}MHz");

            _scripts.Add($"micron.set_fpga_freq_param('MIC_LSL',{micronID},true,false,1,'{bw_labels[(int)bw]}',{dl_cf_MHz * 1000},'{bw_labels[(int)bw]}',{ul_cf_MHz * 1000})");
        }
        public void Add_SetMicronPowerMode(int micronID, CosmosEnumerations.PS ps)
        {
            _scripts.Add("# Change Powe mode");
            _scripts.Add($"micron.set_system_power_mode('MIC_LSL', {micronID}, '{ps.ToString()}')");
            switch (ps)
            {
                case CosmosEnumerations.PS.PS2:
                case CosmosEnumerations.PS.PS1:
                    _scripts.Add("sleep 8 # wait for system to switch");
                    break;
                case CosmosEnumerations.PS.OPERATIONAL:
                    _scripts.Add("sleep 20 # wait for system to switch");
                    break;
            }


        }

        //  def sys_reboot(board, micron_id, converted=false, raw=false, wait_check_timeout=5)#was 10 sec
        public void Add_MicronReboot(int micronID)
        {
            _scripts.Add($"# Reboot micron {micronID}");
            _scripts.Add($"micron.sys_reboot('MIC_LSL', {micronID},false,false,5)");
            _scripts.Add("sleep 10 # wait for system to switch");

        }

        #endregion

        #region CPBF

        public void Add_SingleAggregationChannel(int channel)
        {
            Add_CPBF_RemoteCLI("vgtbypassaggr=1", 0.1);
            Add_CPBF_RemoteCLI($"vgt0select={channel}", 0.1);
        }

        public void Add_CPBF_RemoteCLI(string command, double wait)
        {
            command = RemoveAllSpaces(command);
            _scripts.Add($"cpbf.cpbf_remote_cli_cmd('{command}', {wait})");
        }

        public void Add_CPBF_Reboot()
        {
            _scripts.Add($"# Reboot CPBF");
            _scripts.Add($"cpbf.cpbf_restart()");
            _scripts.Add("sleep 30 # wait for system to switch");

        }


        #endregion

        #region Misc

        public void PrintToOS(string text)
        {
            _scripts.Add($"STDOUT.write  {text}+\"\\n\"");

        }

        public void Comment(string text)
        {
            _scripts.Add($"#{text}");
        }

        void Add_LoadModules()
        {
            // TODO: Fix relative path
            _scripts.Add("############################################################");
            _scripts.Add("# Auto generated script");
            _scripts.Add("# Time Stamp " + DateTime.Now.ToString());
            _scripts.Add("#");
            _scripts.Add("# Load External libraries");
            _scripts.Add("load('Operations/CPBF/CPBF_MODULE.rb')");
            _scripts.Add("load('Operations/Micron/MICRON_MODULE.rb')");
            //_scripts.Add("load_utility('Operations/CPBF/CPBF_send_cli_list.rb')");
            _scripts.Add("micron = MICRON_MODULE.new");
            _scripts.Add("cpbf = ModuleCPBF.new");
            _scripts.Add("###########################################################");
        }

        public void Add_Delay(double delay)
        {
            _scripts.Add($"sleep {delay} # wait");

        }

        #endregion


        public void Patch_UL_Bug(int micronID)
        {
            Comment("**************    PATCH    ***************************");
            Add_CPBF_RemoteCLI("rgtcpurst=1", 1);
            Add_CPBF_RemoteCLI("vgtcpurst=1", 1);
            Add_Delay(3);
            Add_CPBF_RemoteCLI($"send=o,0x0180{micronID.ToString("X2")},0x12000000000000", 1);
            Add_Delay(3);
            Add_CPBF_RemoteCLI($"send=o,0x0180{micronID.ToString("X2")},0x12000000000000", 1);
            Comment("**************    EOP    ***************************");
        }

    
        //C:/cosmos/MB78_MCLUT/Remote_CLI_MB64_AFE_0_only_chamber_demo_1_beam_to_16_antennas_rx_tx_both_az_el_0.txt


        //  def set_fpga_freq_param(board, micron_id, converted=true, raw=false, wait_check_timeout=1,dl_ban = "10MHz",dl_freq = 881500, ul_ban = "10MHz", ul_freq = 836500)#was 2 sec


      
        static string FileNameFormat(string fileName)
        {
            return "'"+fileName.Replace("\\", "/")+"'";
        }
        static string ReplaceFileNameExtension(string fileName,string newExtension)
        {
            int x = fileName.IndexOf('.');
            if (x != -1)
            {
                return fileName.Substring(0,x+1)+newExtension;
            }

            return fileName;
        }

        static string RemoveAllSpaces(string text)
        {
            string t = "";
            for(int n=0;n<text.Length;n++)
            {
                if(text[n]!=' ')
                {
                    t += text[n];
                }
            }

            return t;
        }

        public void SaveAs(string fileName)
        {
            using(StreamWriter sw = new StreamWriter(fileName))
            {
                StringBuilder sb = new StringBuilder();
                for (int n = 0; n < _scripts.Count; n++)
                {
                    sb.Append(_scripts[n] + "\n");
                }
                sw.Write(sb.ToString());
                sw.Flush();
                sw.Close();
            }
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            for(int n=0;n<_scripts.Count;n++)
            {
                sb.Append(_scripts[n] + "\n");
            }
            
            return base.ToString();
        }


    }
}
