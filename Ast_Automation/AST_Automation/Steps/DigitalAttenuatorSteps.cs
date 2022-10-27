using AST_Automation.Actions;
using Infra.Digital_Attenuator;
using Newtonsoft.Json.Linq;

namespace AST_Automation.Steps
{
    public class DigitalAttenuatorSteps
    {
        private readonly DigitalAttenuatorActions _digitalAttenuatorActions;
        public DigitalAttenuatorSteps()
        {
            _digitalAttenuatorActions = new DigitalAttenuatorActions();
        }

        public bool OpenConnection(ref DigitalAttenuator digitalAttenuator, string comport)
        {
            return _digitalAttenuatorActions.OpenConnection(ref digitalAttenuator, comport);
        }

        public bool CloseConnection(DigitalAttenuator digitalAttenuator)
        {
            return _digitalAttenuatorActions.CloseConnection(digitalAttenuator);
        }

        public bool ConfigDigitalAttenuator(DigitalAttenuator digitalAttenuator,JArray values)
        {
            return _digitalAttenuatorActions.SetAttenuator(digitalAttenuator,values);   
        }
    }
}
