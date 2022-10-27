using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Infra.ActionsRunner;
using Infra.QV;

namespace AST_Automation
{
    public class TestExecutor
    {
        private readonly List<Step> _testSteps;
        private readonly Dictionary<string, object> _setupDevices;
        public TestExecutor(List<Step> testSteps, Dictionary<string, object> setupDevices)
        {
            _testSteps = testSteps;
            _setupDevices = setupDevices;
        }

        public void RunTest()
        {
            try
            {
                for (int i = 0; i < _testSteps.Count; i++)
                {
                    _setupDevices[_testSteps[i].Device].RunAction(_testSteps[i].Remote, _testSteps[i].Parameters);
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}
