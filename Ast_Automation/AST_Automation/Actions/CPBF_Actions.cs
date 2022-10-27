using Infra.CPBF;
using Newtonsoft.Json.Linq;
using System;
using static Infra.Logger.Logger;


namespace AST_Automation.Actions
{
    public class CPBF_Actions
    {
        public bool SendSingleCommandToCPBF(CPBF cpbf, string command)
        {
            try
            {
                cpbf.WriteToPort(CPBF.Ports.FirstPort, command);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            return true;
        }

        public bool OpenConnection(ref CPBF cpbf, JObject configData)
        {
            cpbf = new CPBF(configData["FirstComPort"].ToString(), configData["SecondComPort"].ToString());
            return cpbf.Open();
        }

        public bool ConfigCPBF(CPBF cpbf, JArray commands)
        {
            try
            {
                for (int i = 0; i < commands.Count; i++)
                {
                    cpbf.WriteToPort(CPBF.Ports.FirstPort, commands[i].ToString());    
                }
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            return true;            
        }

        public bool ReadLogAndValidate(CPBF cpbf, JArray commands)
        {
            cpbf.ReadLog();
            return true;
        }
    }
}
