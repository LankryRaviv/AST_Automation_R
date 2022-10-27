using AST_Automation.Actions;
using Infra.eNB;
using System.Collections.Generic;

namespace AST_Automation.Steps
{
    public class eNB_Steps
    {
        private readonly eNB_Actions _eNB_Actions;

        public eNB_Steps()
        {
            _eNB_Actions = new eNB_Actions();
        }

        public bool OpenAndConfig_eNB(ref eNB eNB, Dictionary<string, dynamic> testData)
        {
            return _eNB_Actions.OpenAndConfig_eNB(ref eNB, testData);
        }
    }
}
