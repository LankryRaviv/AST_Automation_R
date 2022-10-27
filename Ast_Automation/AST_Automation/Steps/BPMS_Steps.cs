using AST_Automation.Actions;
using Infra.BPMS;
using Newtonsoft.Json.Linq;

namespace AST_Automation.Steps
{
    public class BPMS_Steps
    {
        private readonly BPMS_Actions _bpms_Actions;

        public BPMS_Steps()
        {
            _bpms_Actions = new BPMS_Actions();
        }

        public bool InitBPMS_ComportAndStartApplication(ref BPMS bpms,JObject bpmsInitParameters)
        {
            return _bpms_Actions.InitBPMS(ref bpms, bpmsInitParameters);
        }

        public bool SendCommands(BPMS bpms, JArray commands, BPMS.Ports port)
        {
            return _bpms_Actions.SendCommands(bpms, commands, port);
        } 
    }
}
