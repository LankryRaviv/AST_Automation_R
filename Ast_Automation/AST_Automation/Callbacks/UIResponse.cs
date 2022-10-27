using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AST_Automation.Callbacks
{
    public class UIResponse
    {



        public UIResponse UpdateUILog(string testName, string message)
        {
            this.TestName = testName;
            this.Message = message;
            return this;
        }


        public enum TestResult { PASS, FAIL }

        public UIResponse UpdateTestResult(string testName, TestResult testResult)
        {
           
            this.TestName = testName;
            this.Message = testResult.ToString();
            return this;
            
        }


        private string TestName;
        private string Message;


        public string GetTestName()
        {
            return this.TestName;
        }

        public string GetStatus()
        {
            return this.Message;
        }



        

    }
}
