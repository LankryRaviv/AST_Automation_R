using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Infra.Settings
{
    public static class XmlSettings
    {
        //Start General 
        public static string MicronsId = "micron_ids";
        //End General

        //Start XML files
        public static string XmlSettingsPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\Settings\\Instruments.xml";
        public static string XMLConfiguration = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\Settings\\XMLConfiguration.xml";
        public static string XMLCommandAndPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\Settings\\XmlCommandAndPath.xml";
        //End XML files

        //Start Callibration tests
        public static string GetSetCommandPath = "GetSetCommandPath";
        public static string fwupd_sysinfo_Command = "fwupd_sysinfo_command";
        public static string fs_clear_7_command = "fs_clear_7_command";
        public static string fs_clear_8_command = "fs_clear_8_command";
        public static string PathForRemoteCLI = "path_for_remote_cli";
        public static string Board = "board_for_calibration";
        public static string PacketDelay = "packet_delay_for_calibration";
        public static string PathForRemoteCLIForCalibrationsTest = "path_for_remote_cli_for_calibrations_test";


        //End Calibration Test

        //Start CPU Upload test
        public static string RubyScriptPathForFPGAUpload = "ruby_script_path_for_fpga_upload";

        //End CPU Upload test

        //Start Golden File
        public static string PathForUploadGoldenFileTest = "ruby_script_golden_file_path";
        //End Golden File

        //Start FPGA Uload Test
        public static string PathForFPGAUpload = "path_for_fpga_upload";
        public static string VersionForFPGAUpload = "version_for_fpga_upload";
        public static string RubyScriptPathForCPUUpload = "ruby_script_path_for_cpu_upload";

        //End FPGA Uload Test

        //start change all power mode
        public static string RubyScriptPathForChangeAllPowerModeTest = "ruby_script_path_for_change_all_power_mode_test";

        //END change all power mode

        //start change all power mode
        public static string RubyScriptPathForConfigFPGAFreqTest = "ruby_script_path_for_fpga_freq_config";

        //END change all power mode

        public static string Enabled = "Enabled";
        public static string SignalGenerator = "SignalGenerator";
        public static string Model = "Model";
        public static string VISA_RESOURCE = "VISA_RESOURCE";
        public static string SpectrumAnalyzer = "SpectrumAnalyzer";
        public static string QV = "QV";
        public static string Comport = "Comport";
        public static string DLSwitch = "DLSwitch";
        public static string ULSwitch = "ULSwitch";
        public static string SourceSwitch = "SourceSwitch";
        public static string Serial = "Serial";
        public static string CPBF = "CPBF";
        public static string MainBoard = "MainBoard";
        public static string BPMS_COM = "BPMS_COM";
        public static string BaudRate = "BaudRate";
        public static string Parity = "Parity";
        public static string Stopbits = "Stopbits";
    }
}
