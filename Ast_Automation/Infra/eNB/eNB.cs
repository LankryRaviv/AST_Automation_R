using Infra.Ssh_Connection;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;

namespace Infra.eNB
{
    public class eNB : SshConnection
    {
        public eNB(string host, string user, string password, string name) : base(host, user, password, name)
        {

        }
        public eNB(List<object> initParams) : base(initParams)
        {

        }

        public bool Config_eNB(JArray commands)
        {
            return Config(commands);
        }
    }
}
