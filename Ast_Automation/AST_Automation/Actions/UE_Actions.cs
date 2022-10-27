using Infra.UE;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using static Infra.Logger.Logger;

namespace AST_Automation.Actions
{
    public class UE_Actions
    {
        public bool OpenAndConfigUE(ref UE ue, Dictionary<string, dynamic> testData)
        {
            try
            {
                string host, user, password, name;
                JArray commands = testData["UE"]["Commands"];
                host = testData["UE"]["Host"].ToString();
                user = testData["UE"]["User"].ToString();
                password = testData["UE"]["Password"].ToString();
                name = testData["UE"]["Name"].ToString();
                ue = new UE(host, user, password, name);
                return ue.ConfigUE(commands);
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }
    }
}
