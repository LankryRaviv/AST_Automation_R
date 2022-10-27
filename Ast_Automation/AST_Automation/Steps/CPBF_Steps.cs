using AST_Automation.Actions;
using Infra.CPBF;
using Newtonsoft.Json.Linq;

namespace AST_Automation.Steps
{
    public class CPBF_Steps
    {
        private readonly CPBF_Actions _cpbfActions;
        public CPBF_Steps()
        {
            _cpbfActions = new CPBF_Actions();
        }
      
        public bool SendSingleCommandToCPBF(CPBF cpbf, string command)
        {
            return _cpbfActions.SendSingleCommandToCPBF(cpbf,command);
        }

        public bool OpenConnection(ref CPBF cpbf ,JObject configData)
        {
            return _cpbfActions.OpenConnection(ref cpbf , configData);
        }

        public bool ConfigCPBF(CPBF cpbf, JArray commands)
        {
            return _cpbfActions.ConfigCPBF(cpbf, commands);
        }

        public bool ReadLogAndValidate(CPBF cpbf, JArray commands)
        {
            return _cpbfActions.ReadLogAndValidate(cpbf,commands);
        }
    }
}
