using AST_Automation.Actions;
using Infra.UE;
using System.Collections.Generic;

namespace AST_Automation.Steps
{
    public class UE_Steps
    {
        private readonly UE_Actions _uE_Actions;

        public UE_Steps()
        {
            _uE_Actions = new UE_Actions();
        }

        public bool OpenAndConfigUE(ref UE ue, Dictionary<string, dynamic> testData)
        {
            return _uE_Actions.OpenAndConfigUE(ref ue, testData);
        }
    }
}
