using NUnit.Framework;
using static Infra.Logger.Logger;
using DataManagement.Jsons;
using DataManagement;
using System.Collections.Generic;
using System;
using System.Linq;

namespace AST_Automation.Tests
{
    [TestFixture]
    public class TestBase
    {
        protected Dictionary<string, dynamic> _testData;
        private readonly JsonsEnum json;
        private readonly string testStartTime;
        protected readonly IDataManager dataManager;
        public TestBase(JsonsEnum json = JsonsEnum.E2ETest)
        {
            dataManager = DataManagerProvider.GetDataManager();
            this.json = json;
            this.testStartTime = DateTime.Now.ToString("dd-MM-yyyy HH-mm-ss");
        }

        [OneTimeSetUp]
        public void OneTimeSetup()
        {
            _testData = JsonFileParser.GetDictionary(json);
        }

        [SetUp]
        public void SetUp()
        {
            var classNameAndTestTime = TestContext.CurrentContext.Test.ClassName.Replace("AST_Automation.Tests.", "") + "\\" + testStartTime + "\\";
            InitLogger(classNameAndTestTime + TestContext.CurrentContext.Test.Name);
        }

        protected string GetRubyScriptPath(string key)
        {
            return _testData["RubyScripts"][key]["Path"].ToString();
        }

        protected List<string> GetMicronList()
        {
            return ((string[])_testData["MicronList"].ToString().Split(',')).ToList();
        }
    }
}
