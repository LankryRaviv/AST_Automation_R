using Infra.Ssh_Connection;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;

namespace Infra.UE
{
    public class UE : SshConnection
    {
        public UE(string host, string user, string password, string name) : base(host, user, password, name)
        { 
        }

        public UE(List<object> initParams) : base(initParams)
        {

        }

        public bool ConfigUE(JArray commands)
        {
            return Config(commands);
        }
    }
}
