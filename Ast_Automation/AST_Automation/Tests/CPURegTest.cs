using NUnit.Framework;
using Infra.Main_Board;
using System.Collections.Generic;
using AST_Automation.Steps;
using System;
using static Infra.Logger.Logger;
using AST_Automation.Entrypoints;
using Infra.RubyScripts;
using DataManagement;
using DataManagement.Jsons;
using System.IO;
using System.Reflection;
using Infra.Ruby;

namespace AST_Automation.Tests
{
    [TestFixture]
    public class CPURegTest : TestBase
    {
        const string Category = "CPUReggression";
        #region Configuration Values
        CPURegSteps cpuRegSteps = new CPURegSteps();

        #endregion

        #region Test Equipments
        string filePathGetSetCommands;
        string[] getCommands;
        string[] micronIds;
        string micronIdsArr;
        bool ifCSPCommand;
        List<string[]> listOfSetValues = new List<string[]>();
        Dictionary<string, dynamic> data = JsonFileParser.GetDictionary(JsonsEnum.CPURegTest_GeneralData);
        #endregion

        #region Controls
        //private MainBoard _mainBoard;
        #endregion

        public CPURegTest()
        {

        }


        [OneTimeSetUp]
        public void OneTimeSetupCPUReg()
        {
            try
            {
                micronIds = cpuRegSteps.getCommandOrPath("micron_list").Split(',');
                micronIdsArr = cpuRegSteps.getCommandOrPath("micron_list");
            }
            catch (Exception ex)
            {
                Log.Fatal($"Some issues with the data inputs: {ex}");
            }
        }
        [Test, Order(1)]
        [Description("Check if there calibration settings")]
        [Category(Category)]
        public void CheckIfThereCalibrationSettings()
        {
            Log.Info($"[START TEST] Check If There Calibration Settings");
            string path = cpuRegSteps.getCommandOrPath("Calibrations", "GetSetCommandPath");
            foreach (var micronId in micronIds)
            {
                filePathGetSetCommands = cpuRegSteps.GetFilePath(path, $"Micron{micronId}_param_set_get.txt");
                Log.Info($"[STEP DONE] Get File Path from {path} for micron number {micronId}");
                string[] setGetCommands = cpuRegSteps.ReadCommandsFromFile(filePathGetSetCommands);
                Log.Info($"[STEP DONE] Read CLI commands from {filePathGetSetCommands} and save the values");
                cpuRegSteps.SendGetAndSetCommandAndSaveValuesAndReturnValues(setGetCommands, micronId, filePathGetSetCommands);
                Log.Info($"[STEP DONE] CLI set and ge command for micron number{micronId} sent");
            }
            Log.Info($"[END TEST] Check If There Calibration Settings");
        }

        [Test, Order(2)]
        [Description("Clear file system 7 and 8 test")]
        [Category(Category)]
        public void ClearFileSystem7And8Test()
        {
           
            string response;
            Log.Info($"[START TEST] Clear File System 7 And 8 Test");
            foreach (var micronId in micronIds)
            {
                string[] fsClearCommand;
                var command = cpuRegSteps.getCommandOrPath("Calibrations", "fwupd_sysinfo_command");
                Log.Info($"[STEP DONE] Get {command} command");
                var rubyScriptPath = cpuRegSteps.getCommandOrPath("Calibrations", "path_for_remote_cli");
                var board = cpuRegSteps.getCommandOrPath("Calibrations", "board");
                response = RunRubyScript.Run(rubyScriptPath, board, micronId, command);
                Log.Info($"Run the {command} command in remote CLI");


                Log.Info($"[STEP DONE] The response is: {response}");

                var mcuUid = cpuRegSteps.Get8FirstDigitsOfMCUUID(response);
                Log.Info($"[STEP DONE] Get mcuUid: {mcuUid} ");
                long calcNum = cpuRegSteps.GetCalculationNumberProcedure(mcuUid);
                Log.Info($"[STEP DONE] Calculate the mcuUid to: {calcNum} ");
                fsClearCommand = cpuRegSteps.GetFsClearCommands(calcNum.ToString());
                Log.Info($"[STEP DONE] Calculate the mcuUid to: {calcNum} ");
                for (int i = 0; i < fsClearCommand.Length; i++)
                {
                    response = RunRubyScript.Run(rubyScriptPath, board, micronId, fsClearCommand[i]);
                    Assert.IsTrue(response.Contains("OK"));
                    Log.Info($"[STEP DONE] fs clear command: {fsClearCommand[i]} sent and the response is: {response} ");

                }

                Log.Info($"[END TEST] Clear File System 7 And 8 Test");
            }
        }
        [Test, Order(3)]
        [Description("Run CPU upload test")]
        [Category(Category)]
        public void RunCpuUploadTest()
        {
            Log.Info($"[START TEST] Run Cpu Upload Test");
            var path = cpuRegSteps.getCommandOrPath("CPU_Upload", "RubyScriptPath");

            var dataPath = GetDynamicPath(cpuRegSteps.getCommandOrPath("CPU_Upload", "PathForData"));

            var response = RunRubyScript.Run(path, micronIdsArr, dataPath);
            try
            {
                Assert.IsTrue((!response.Contains("FAIL")) && response != "");//dummy
            }

            catch (Exception ex)
            {
                Log.Error($"[Error] Response: {response}");
                Log.Error(ex);
            }
            Log.Info($"[END TEST] Run Cpu Upload Test");
        }

        [Test, Order(4)]
        [Description("Upload golden file test")]
        [Category(Category)]
        public void UploadGoldenFileTest()
        {
            Log.Info($"[START TEST] Upload Golden File Test");
            var path = cpuRegSteps.getCommandOrPath("Golden_File_Upload", "RubyScriptPath");

            var dataPath = GetDynamicPath(cpuRegSteps.getCommandOrPath("Golden_File_Upload", "PathForData"));

            var response = RunRubyScript.Run(path, micronIdsArr, dataPath);
            try
            {
                Assert.IsTrue((!response.Contains("FAIL")) && response != "");//dummy
            }

            catch (Exception ex)
            {
                Log.Error($"[Error] Response: {response}");
                Log.Error(ex);
            }
            Log.Info($"[END TEST] Upload Golden File Test");
        }

        [Test, Order(5)]
        [Description("Make sure the calibration settings are saved test")]
        [Category(Category)]
        public void MakeSureTheCalibrationSettingsAreSavedTest()
        {
            Log.Info($"[START TEST] Make Sure The Calibration Settings Are Saved Test");


            foreach (var micronId in micronIds)
            {
                    cpuRegSteps.CheckCalibrationSettingsInRemoteCLI(micronId);
                
            }
            Log.Info($"[END TEST] Make Sure The Calibration Settings Are Saved Test");
        }

        [Test, Order(6)]
        [Description("Upload FDIR test")]
        [Category(Category)]
        public void UploadFDIRTest()
        {
            Log.Info($"[START TEST] Upload FDIR Test");
            var runUploadFdirRubyScriptPath = cpuRegSteps.getCommandOrPath("Upload_FDIR", "RubyScriptPath");
            var generalDataJsonPath = GetDynamicPath(cpuRegSteps.getCommandOrPath("GeneralDataPath"));
            RubyResponse resp = new RubyResponse();
            foreach (var micronId in micronIds)
            {
                var uploadFdirResponse = RunRubyScript.Run(runUploadFdirRubyScriptPath, out resp, micronId, generalDataJsonPath);
                Log.Info(resp);
            }
            Log.Info($"[END TEST] Upload FDIR Test");
        }

        [Test, Order(7)]
        [Description("Upgrade APC and DPC")]
        [Category(Category)]
        public void UpgradeAPCAndDPC()
        {
            Log.Info($"[START TEST]  Upgrade APC And DPC Test");
            var upgradeAPCAndDPCDataPath = GetDynamicPath(cpuRegSteps.getCommandOrPath("Upgrade_APC&DPC", "PathForData"));
            var runUpgradeBoardScript = cpuRegSteps.getCommandOrPath("Upgrade_APC&DPC", "RubyScriptPath");
            string[] boards = cpuRegSteps.getCommandOrPath("Upgrade_APC&DPC", "boards").Split(',');
            RubyResponse resp = new RubyResponse();
            foreach (var board in boards)
            {
                var upgradeBoardResponse = RunRubyScript.Run(runUpgradeBoardScript, out resp, upgradeAPCAndDPCDataPath, board);
                Log.Info(upgradeBoardResponse);
                Log.Info(resp);
            }
            Log.Info($"[END TEST] Upgrade APC And DPC Test");
        }



        [Test, Order(8)]
        [Description("Upgarde CPBF")]
        [Category(Category)]
        public void UpgardeCPBF()
        {
            Log.Info($"[START TEST] Upgarde CPBF Test");
            var runCPBFSendPingPath = cpuRegSteps.getCommandOrPath("Upgrade_CPBF", "RubyScriptPath");
            var sendPingResponse = RunRubyScript.Run(runCPBFSendPingPath);
            //need to check the response

            var cpbfDataPath = cpuRegSteps.getCommandOrPath("Upgrade_CPBF", "PathForData");
            Dictionary<string, dynamic> data = JsonFileParser.GetDictionary(JsonsEnum.CPURegTest_CPBFUploadDataTest);
            string[] keys = cpuRegSteps.GetKeys(data);
            var runCPBFUploadRubyScriptPath = cpuRegSteps.getCommandOrPath("Upgrade_CPBF", "RunCPBFRubyScript");
            for (int i = 0; i < keys.Length; i++)
            {
                var Response = RunRubyScript.Run(runCPBFUploadRubyScriptPath, cpbfDataPath, keys[i]);
                Console.WriteLine(Response);
            }
            //need to check the response

            Log.Info($"[END TEST] Upgarde CPBF Test");
        }



        [Test, Order(9)]
        [Description("Run FPGA upload test")]
        [Category(Category)]
        public void RunFPGAUploadTest()
        {
            string rubyScriptPath;
            Log.Info($"[START TEST] Run FPGA Upload Test");
            if (!bool.Parse(cpuRegSteps.getCommandOrPath("FPGA_Upload", "IfViaCPBF")))
            {
                rubyScriptPath = cpuRegSteps.getCommandOrPath("FPGA_Upload", "RubyScriptPath");
            }
            else
            {
                rubyScriptPath = cpuRegSteps.getCommandOrPath("FPGA_Upload", "RubyScriptViaCPBFPath");
            }
            var dataPath = GetDynamicPath(cpuRegSteps.getCommandOrPath("FPGA_Upload", "PathForData"));
            var response = RunRubyScript.Run(rubyScriptPath, micronIdsArr, dataPath);
            try
            {
                Assert.IsTrue((!response.Contains("FAIL")) && response != "");
            }

            catch (Exception ex)
            {
                Log.Error($"[Error] error with FPGA UPLOAD response: {response}");
                Log.Error(ex);
            }
            Log.Info($"[END TEST] Run FPGA Upload Test");
        }

        [Test, Order(10)]
        [Description("Change all power mode test")]
        [Category(Category)]
        public void ChangeAllPowerModeTest()
        {
            Log.Info($"[START TEST] Change All Power Mode Test");
            var rubyScriptPath = cpuRegSteps.getCommandOrPath("Power_Modes_Switching", "RubyScriptPath");
            var generalDataPath = GetDynamicPath(cpuRegSteps.getCommandOrPath("GeneralDataPath"));
            RubyResponse resp = new RubyResponse();
            string response = RunRubyScript.Run(rubyScriptPath, out resp, micronIdsArr, generalDataPath);
            int numOfFailedChangestate = int.Parse(response);
            Assert.IsTrue(!(numOfFailedChangestate > 0));
            Log.Info($"[END TEST] Change All Power Mode Test");
        }


        [Test]
        public void Debug() //For debuging
        {
            //Get all file/folders from test folder - not include files in subfolders
            var filePaths = Directory.GetFileSystemEntries(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\Jsons\\Tests");

            //list of file names without extension to show in gui
            List<string> nameOfTestsForUI = new List<string>();

            for (int i = 0; i < filePaths.Length; i++)
            {
                var testName = string.Empty;

                if (Path.GetExtension(filePaths[i]).Length > 0) //if file have extension - .json,.csv,etc...
                {
                    testName = Path.GetFileName(filePaths[i]).Replace(Path.GetExtension(filePaths[i]), "");
                }
                else // else the file is folder
                {
                    testName = Path.GetFileName(filePaths[i]);
                }

                ///add test name list
                nameOfTestsForUI.Add(testName);
            }

            //init all devices in setup from json..
            TestSetup.InitSetup(JsonsEnum.Setup);

            //this method will parse json file or folder with jsons file to one list(order of file is needed to be 1_xxx 2_xxx in the file name
            var stepsList = JsonTestsParserToSteps.GetStepsList(filePaths[0]);

            //create new test class with the step list and devices dictionary
            var test = new TestExecutor(stepsList, TestSetup.GetDevicesDictionary());

            //run test 
            test.RunTest();
        }

        [TearDown]
        public void TearDownCPUReg()
        {

        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {

        }

        private static string GetDynamicPath(string path)
        {
            string dynamicPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + path;
            return dynamicPath;
        }

    }
}
