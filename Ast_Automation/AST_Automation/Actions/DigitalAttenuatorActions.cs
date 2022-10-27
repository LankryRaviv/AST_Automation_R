using Infra.Digital_Attenuator;
using Newtonsoft.Json.Linq;
using System;
using static Infra.Logger.Logger;

namespace AST_Automation.Actions
{
    public class DigitalAttenuatorActions
    {
        public bool OpenConnection(ref DigitalAttenuator digitalAttenuator,string comport)
        {
            digitalAttenuator = new DigitalAttenuator(comport);
            return digitalAttenuator.Open();   
        }

        public bool CloseConnection(DigitalAttenuator digitalAttenuator)
        {
            return digitalAttenuator.Close();
        }

        public bool SetAttenuator(DigitalAttenuator digitalAttenuator , JArray values)
        {
            try
            {
                for (int i = 0; i < values.Count; i++)
                {
                    digitalAttenuator.SetAttenuatorToChannel((i + 1), (int)values[i]);
                }
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                return false;
            }
            return true;
        }
    }
}
