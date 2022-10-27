using AST_Automation.Entrypoints;
using AST_Automation.Tests;
using DataManagement;
using DataManagement.Jsons;
using Infra.IOTools;
using Infra.Main_Board;
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
    public class FPGARegSteps : TestBase
    {
        Dictionary<string, dynamic> data = JsonFileParser.GetDictionary(JsonsEnum.FPGARegTest_GeneralData);
        MainBoardSteps _mainBoardSteps = new Steps.MainBoardSteps();



        public string[] ReadCommandsFromFile(string path)
        {
            string[] lines = System.IO.File.ReadAllLines(path);

            return lines;
        }

        public string GetFilePath(string path, string name = null)
        {
            string[] file;
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

        public string getCommandOrPath(string type, string pathOrCommandKey = null)
        {
            string pathOrCommandValue = null;
            if (pathOrCommandKey == null)
                pathOrCommandValue = data[type].ToString();
            else
                pathOrCommandValue = data[type][pathOrCommandKey].ToString();
            return pathOrCommandValue;
        }
      

        public string [] GetKeys(Dictionary<string, dynamic> data) 
        {
            string[] keys = data.Keys.ToArray();
            return keys;
        }
    }
}
