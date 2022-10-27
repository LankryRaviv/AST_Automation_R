using Infra.eNB;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Infra.Logger.Logger;

namespace AST_Automation.Actions
{
    internal class eNB_Actions
    {
        public bool OpenAndConfig_eNB(ref eNB eNB, Dictionary<string, dynamic> testData)
        {
            try
            {
                JArray commands = testData["eNB"]["Commands"];
                string host, user, password, name;
                host = testData["eNB"]["Host"].ToString();
                user = testData["eNB"]["User"].ToString();
                password = testData["eNB"]["Password"].ToString();
                name = testData["eNB"]["Name"].ToString();
                eNB = new eNB(host, user, password, name);
                return eNB.Config_eNB(commands);

            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }
    }
}
