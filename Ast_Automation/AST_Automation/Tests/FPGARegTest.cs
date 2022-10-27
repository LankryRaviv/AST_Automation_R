using NUnit.Framework;
using Infra.QV;
using Infra.SignalGenerator;
using Infra.Enums;
using Infra.LDA;
using Infra.Main_Board;
using System.Collections.Generic;
using AST_Automation.Steps;
using Infra.Settings;
using System;
using static Infra.Logger.Logger;
using AST_Automation.Entrypoints;
using Infra.RubyScripts;
using Newtonsoft.Json;
using DataManagement;
using DataManagement.Jsons;
using System.IO;
using System.Reflection;
using Infra.Ruby;

namespace AST_Automation.Tests
{
    [TestFixture]
    public class FPGARegTest : TestBase
    {
        #region Configuration Values
        CPURegSteps cpuRegSteps = new CPURegSteps();

        string DOWNLINK_BANDWIDTH;
        int DOWNLINK_FREQUENCY;
        string UPLINK_BANDWIDTH;
        int UPLINK_FREQUENCY;
        #endregion

        #region Test Equipments

        string[] micronIds;
        string micronIdsArr;
        FPGARegSteps fpgaRegSteps = new FPGARegSteps();
        string cpbfRemoteCliCommandPath;
        #endregion

        #region Controls
        //private MainBoard _mainBoard;
        #endregion

        public FPGARegTest()
        {

        }


        [OneTimeSetUp]
        public void OneTimeSetupFPGAReg()
        {
            try
            {
                micronIds = fpgaRegSteps.getCommandOrPath("micron_list").Split(',');
                micronIdsArr = fpgaRegSteps.getCommandOrPath("micron_list");

                 DOWNLINK_BANDWIDTH = fpgaRegSteps.getCommandOrPath("Setup_Band", "DOWNLINK_BANDWIDTH");
                 DOWNLINK_FREQUENCY = int.Parse(fpgaRegSteps.getCommandOrPath("Setup_Band", "DOWNLINK_FREQUENCY"));
                 UPLINK_BANDWIDTH = fpgaRegSteps.getCommandOrPath("Setup_Band", "UPLINK_BANDWIDTH");
                 UPLINK_FREQUENCY = int.Parse(fpgaRegSteps.getCommandOrPath("Setup_Band", "UPLINK_FREQUENCY"));
                 cpbfRemoteCliCommandPath = GetDynamicPath(fpgaRegSteps.getCommandOrPath("Setup_Band", "CPBF_CLI_Command"));
                 

            }
            catch(Exception ex) 
            {
                Log.Error($"Some issues with the data inputs: {ex}");
            }


        }
        [Test]
        public void TurnOnTheSystem()
        {

            if (bool.Parse(fpgaRegSteps.getCommandOrPath("Lack_APCAndDPC")))
            {
                var cmdbaudrate = fpgaRegSteps.getCommandOrPath("Turn_On_The_System", "baudrate_command");
                MainBoard.InitMainBoard(fpgaRegSteps.getCommandOrPath("Turn_On_The_System", "COMPort"));
                var reply = Run_CLI_Command(cmdbaudrate);
                Log.Info(reply);
            }

            foreach (var micronId in micronIds)
            {
                              
                var runSetupScript = fpgaRegSteps.getCommandOrPath("Turn_On_The_System", "Turn_On_The_System_Script");
                var runSetupScriptResponse = RunRubyScript.Run(runSetupScript, micronId, DOWNLINK_BANDWIDTH, DOWNLINK_FREQUENCY.ToString(),
                   UPLINK_BANDWIDTH, UPLINK_FREQUENCY.ToString(), cpbfRemoteCliCommandPath);
                Log.Info(runSetupScriptResponse);
            }
        }

        [TearDown]
        public void TearDownFPGAReg()
        {
            
        }

        [OneTimeTearDown]
        public void OneTimeTearDown()
        {
            if (bool.Parse(fpgaRegSteps.getCommandOrPath("Lack_APCAndDPC")))
            {
                MainBoard.Close();
            }
        }

        private static string GetDynamicPath(string path)
        {
            string dynamicPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + path;
            return dynamicPath;
        }

        public string Run_CLI_Command(string command)
        {
            string reply;
            string command1 = command.Replace('+', ' ');
            MainBoard.MB.WriteAndRead(command1, out reply, 0, 0);
            return reply;
        }
    }
}
