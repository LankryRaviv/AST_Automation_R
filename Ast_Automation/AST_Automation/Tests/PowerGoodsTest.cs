using NUnit.Framework;
using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using AST_Automation.Entrypoints;
using Infra.RubyScripts;
using Infra.Ruby;
using static Infra.Logger.Logger;
using System.Reflection;
using System.IO;
using DataManagement.Jsons;
using DataManagement;
using Infra.IOTools;
using NUnit.Framework.Interfaces;
using AST_Automation.Callbacks;
using static AST_Automation.Callbacks.UIResponse;


namespace AST_Automation.Tests
{
    [TestFixture]
    public class PowerGoodsTest : Tests.TestBase
    {

        [Test, Order(1)]
        [Category("PowerGoods")]
        [Description("Power Goods Test")]
        public void RunPowerGoodsTest()
        {
            IDataManager dataManager = new DataManager();

            string path_data_file = dataManager.GetPathToDataFile(JsonsEnum.PowerGoodsTest.ToString());
            Log.Info($"Path to Json data file: {path_data_file}");
            UI_Callback_Singleton.Instance.SendUpdateToUI(new UIResponse().UpdateUILog(MethodBase.GetCurrentMethod().Name, path_data_file));
            
            Dictionary <string, dynamic> dataFile = JsonFileParser.GetDictionaryFromPath(path_data_file);

            string relPathToRubyScript = dataFile["ruby_script_path"];
            Log.Info($"Path to Ruby script: {relPathToRubyScript}");
            UI_Callback_Singleton.Instance.SendUpdateToUI(new UIResponse().UpdateUILog(MethodBase.GetCurrentMethod().Name, $"Path to Ruby script: {relPathToRubyScript}"));

            string output_path = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\ast_reports\";
            Log.Info($"Report output path: {output_path}");
            UI_Callback_Singleton.Instance.SendUpdateToUI(new UIResponse().UpdateUILog(MethodBase.GetCurrentMethod().Name, $"Report output path: {output_path}"));

            dataFile["output_path"] = output_path;
            string tempFilePath = $@"{Directory.GetCurrentDirectory()}\temp\{path_data_file.Split('\\')[1]}";
            Log.Info($"Temp input data file path: {tempFilePath}");

            WriteAndReadToFile.WriteStringFile(tempFilePath, JsonFileParser.GetDictionaryAsString(dataFile));

            string response = RunRubyScript.Run(relPathToRubyScript, out RubyResponse rubyResponse, tempFilePath);
            Log.Info($"[Response] {response}");
            UI_Callback_Singleton.Instance.SendUpdateToUI(new UIResponse().UpdateUILog(MethodBase.GetCurrentMethod().Name, $"[Response] {response}"));

            File.Delete(tempFilePath);

            if (!String.IsNullOrEmpty(response))
            {
                Dictionary<string, dynamic> converted = JsonFileParser.GetDictionary(response);
                if (converted != null && converted.TryGetValue("final_status", out dynamic final_result))
                {
                     TestResult testResult = final_result ? TestResult.PASS : TestResult.FAIL;
                    UI_Callback_Singleton.Instance.SendUpdateToUI(new UIResponse().UpdateTestResult(MethodBase.GetCurrentMethod().Name, testResult));
                    Log.Info($"final_status={final_result}");
                    Assert.IsTrue(final_result);
                }
            }
            else
            {
                Log.Error("Response is null");
                UI_Callback_Singleton.Instance.SendUpdateToUI(new UIResponse().UpdateUILog(MethodBase.GetCurrentMethod().Name, "Response is null"));
                UI_Callback_Singleton.Instance.SendUpdateToUI(new UIResponse().UpdateTestResult(MethodBase.GetCurrentMethod().Name, TestResult.FAIL));
                Assert.Fail();
            }
        }

        [Test, Order(2)]
        [Category("PowerGoods")]
        [Description("Power Goods Test with changing power modes")]
        public void RunChangePowerModesWithPowerGoodsTest()
        {
            
            string path_data_file = dataManager.GetPathToDataFile(JsonsEnum.PowerGoodsChangePowerModes.ToString());
            Log.Info($"Path to Json data file: {path_data_file}");

            Dictionary<string, dynamic> dataFile = JsonFileParser.GetDictionaryFromPath(path_data_file);

            string relPathToRubyScript = dataFile["ruby_script_path"];
            Log.Info($"Path to Ruby script: {relPathToRubyScript}");

            string output_path = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\ast_reports\";
            Log.Info($"Report output path: {output_path}");

            dataFile["output_path"] = output_path;
            string tempFilePath = $@"{Directory.GetCurrentDirectory()}\temp\{path_data_file.Split('\\')[1]}";
            Log.Info($"Temp input data file path: {tempFilePath}");

            WriteAndReadToFile.WriteStringFile(tempFilePath, JsonFileParser.GetDictionaryAsString(dataFile));

            string response = RunRubyScript.Run(relPathToRubyScript, out RubyResponse rubyResponse, tempFilePath);
            Log.Info($"[Response] {response}");

            File.Delete(tempFilePath);

            if (!String.IsNullOrEmpty(response))
            {
                Dictionary<string, dynamic> converted = JsonFileParser.GetDictionary(response);
                if (converted != null && converted.TryGetValue("final_status", out dynamic final_result))
                {
                    Log.Info($"final_status={final_result}");
                    Assert.IsTrue(final_result);
                }
            }
            else
            {
                Log.Error("Response is null");
                Assert.Fail();
            }
        }

        //[Test]
        public void TestSTDOutFromRuby()
        {
            RubyRunner runner = new RubyRunner();
            runner.SetRunRubyScriptOnly();
            RubyResponse responseObj = runner.RunCosmos(@"C:\Users\sander.zeemann-radai\testscripts\TestStdOut.rb", out string response, "123");
            Console.WriteLine($"Final response: {response}");
            foreach (string item in responseObj.getResponses())
            {
                Console.WriteLine(item);
            }

            foreach(string item in responseObj.getErrors())
            {
                Console.WriteLine(item);
            }
            Console.WriteLine($"Response code: {responseObj.ResponseStatus}");
        }

    }
}
