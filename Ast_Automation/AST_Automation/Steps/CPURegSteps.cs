using AST_Automation.Entrypoints;
using AST_Automation.Tests;
using DataManagement;
using DataManagement.Jsons;
using Infra.IOTools;
using Infra.Main_Board;
using Infra.RubyScripts;
using Infra.Settings;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using static Infra.Logger.Logger;

namespace AST_Automation.Steps
{
    public class CPURegSteps : TestBase
    {
        Dictionary<string, dynamic> data = JsonFileParser.GetDictionary(JsonsEnum.CPURegTest_GeneralData);
        MainBoardSteps _mainBoardSteps = new Steps.MainBoardSteps();



        public string[] ReadCommandsFromFile(string path)
        {
            string[] lines = System.IO.File.ReadAllLines(path);

            return lines;
        }

        public string GetFilePath(string path, string name = null)
        {
            string[] file;
            try
            {
                if (name != null)
                {
                    file = Directory.GetFiles((Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)) + path, name);
                    Log.Info($"The Path: {Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + path},The File name: {name}");
                }
                else
                {
                    file = Directory.GetFiles(path);
                    Log.Info($"The Path: {path},The File name: {file[0].ToString()}");
                }

                return file[0];
            }
            catch(Exception ex) 
            {
                Log.Fatal(ex.Message);
                Assert.Fail(ex.Message);
                return null;
            }
        }

        public string getCommandOrPath(string type, string pathOrCommandKey = null)
        {
            string pathOrCommandValue = null;
            if (pathOrCommandKey == null)
                pathOrCommandValue = data[type].ToString();
            else
                pathOrCommandValue = data[type][pathOrCommandKey].ToString();
            return pathOrCommandValue;
        }

        public void SendGetAndSetCommandAndSaveValuesAndReturnValues(string[] getSetCommands, string micronId, string pathForCLICalibrationsCommand)
        {
            bool ifCSPCommand = bool.Parse(getCommandOrPath("Calibrations", "RemoteCLI"));
            List<string> setValues = new List<string>();
            string[] validateCommand = null;
            var pathToWrite1 = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
                + getCommandOrPath("Calibrations", "PathForCreatedSetValues") + micronId + ".txt";
            WriteAndReadToFile.WriteStringFile(pathToWrite1, pathToWrite1);

            var rubyScriptPath = getCommandOrPath("Calibrations", "rubyScriptPath");
            var board = getCommandOrPath("Calibrations", "board");
            RunRubyScript.Run(rubyScriptPath, board, micronId, pathForCLICalibrationsCommand, pathToWrite1);

            Log.Info("Text File has been created in: " +
                Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) +
                (getCommandOrPath("Calibrations", "PathForCreatedSetValues") + micronId + ".txt"));
        }

        public string Get8FirstDigitsOfMCUUID(string reply)
        {

            var temp = reply.Split(new string[] { "mcuUid: " }, StringSplitOptions.None);
            string mcuUid = temp[temp.Length - 1].Substring(0, 8);
            return mcuUid;
        }

        public long GetCalculationNumberProcedure(string hex2)
        {
            uint eightTimeA = 2863311530;
            hex2 = hex2.ToUpper();
            int hex2Int = Convert.ToInt32(hex2, 16);
            long calculationNum = eightTimeA ^ hex2Int;
            return calculationNum;
        }

        public string[] GetFsClearCommands(string calcnum)
        {
            List<string> fsClearCommand = new List<string>();
            fsClearCommand.Add(getCommandOrPath("Calibrations", "fs_clear_7_command") + "+" + calcnum);
            fsClearCommand.Add(getCommandOrPath("Calibrations", "fs_clear_8_command") + "+" + calcnum);
            Log.Info($"fs clear 7 command : {fsClearCommand[0]}");
            Log.Info($"fs clear 8 command : {fsClearCommand[1]}");
            return fsClearCommand.ToArray();
        }

        public void CheckCalibrationSettingsInRemoteCLI(string micronId)
        {
            var valuesPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + getCommandOrPath("Calibrations", "PathForCreatedSetValues") + micronId+".txt";
            Assert.True(File.Exists(valuesPath));
            var rubyScriptPath = getCommandOrPath("Calibrations", "PathForCheckCallibrationSettingsRubyScript");
            var board = getCommandOrPath("Calibrations", "board");
            var commandFilePath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)+ getCommandOrPath("Calibrations", "GetCommandPath");
            RunRubyScript.Run(rubyScriptPath, board, micronId, valuesPath, commandFilePath);
            Log.Info($"Text file of set commands for Micron : {micronId} is exist");

        }

        public string[] GetKeys(Dictionary<string, dynamic> data)
        {
            string[] keys = data.Keys.ToArray();
            return keys;
        }
    }
}
