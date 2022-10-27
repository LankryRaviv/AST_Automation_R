using Infra.BPMS;
using Newtonsoft.Json.Linq;
using System;
using static Infra.Logger.Logger;

namespace AST_Automation.Actions
{
    public class BPMS_Actions
    {
        public bool InitBPMS(ref BPMS bpms, JObject bpmsInitParameters)
        {
            try
            {
                string ip = bpmsInitParameters["IP"].ToString();
                string comPort = bpmsInitParameters["ComPort"].ToString();
                int firstPort = (int)bpmsInitParameters["FirstTcpPort"];
                int secondPort = (int)bpmsInitParameters["SecondTcpPort"];
                bpms = new BPMS(ip, firstPort, secondPort, comPort);
                return bpms.InitBPMS_ComportAndStartApplication((JArray)bpmsInitParameters["ComPortCommands"]);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }

        public bool SendCommands(BPMS bpms, JArray commands, BPMS.Ports port)
        {
            if (port == BPMS.Ports.ComPort)
            {
                return SendComPortCommands(bpms, commands);
            }
            else
            {
                return SendTcpCommands(bpms, commands, port);
            }
        }

        private bool SendTcpCommands(BPMS bpms, JArray commands, BPMS.Ports port)
        {
            string output = string.Empty;
            for (int i = 0; i < commands.Count; i++)
            {
                if (!bpms.WriteAndReadFromTcpConnection(port, commands[i].ToString(), ref output))
                {
                    Log.Error($"{commands[i]},To [TCP], Return with error");
                    return false;
                }
            }

            return port == BPMS.Ports.FirstTcpPort ? true : ValidateSecondPortCommands(output, commands);
        }

        private bool SendComPortCommands(BPMS bpms, JArray commands)
        {
            for (int i = 0; i < commands.Count; i++)
            {
                if (!bpms.WrtieAndReadFromComport(commands[i].ToString()))
                {
                    Log.Error($"{commands[i]},To [Comport], Return with error");
                    return false;
                }
            }

            return true;
        }

        private bool ValidateSecondPortCommands(string bpmsOutput, JArray commands)
        {
            var returnStatus = true;

            for (int i = 0; i < commands.Count - 1; i++)
            {
                if (!bpmsOutput.Contains(commands[i].ToString()))
                {
                    returnStatus = false;
                    break;
                }
            }

            return returnStatus;
        }
    }
}
