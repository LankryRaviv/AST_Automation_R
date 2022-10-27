using Newtonsoft.Json.Linq;
using Renci.SshNet;
using System;
using System.Collections.Generic;
using static Infra.Logger.Logger;

namespace Infra.Ssh_Connection
{
    public class SshConnection
    {
        private readonly SshClient _client;
        private readonly string _name;
        public SshConnection(string host, string user, string password,string name)
        {
            _name = name;
            _client = new SshClient(host, user, password);
            Connect();
        }

        public SshConnection(List<object> initParams)
        {
            try
            {
                _name = initParams[0].ToString();
                var host = initParams[1].ToString();
                var user = initParams[2].ToString();
                var password = initParams[3].ToString();
                _client = new SshClient(host, user, password);
                Connect();
            }
            catch(Exception ex)
            {
                Log.Error(ex);
            }
        }

        public bool Connect()
        {
            try
            {
                _client.Connect();
                Log.Info($"Open SSH connection with {_name} - Success");
            }
            catch (Exception ex)
            {
                Log.Info($"Open SSH connection with {_name} - Failed");
                Log.Error(ex);
                throw;
            }
            return true;
        }

        public bool Disconnect()
        {
            try
            {
                _client.Disconnect();
                Log.Info($"Close SSH connection with {_name} - Success");
            }
            catch (Exception ex)
            {
                Log.Info($"Close SSH connection with {_name} - Failed");
                Log.Error(ex);
                throw;
            }
            return true;
        }

        private bool SendCommand(string command)
        {
            try
            {
                Log.Info($"Send command: {command} to: {_name}");
                var result =_client.RunCommand(command);
                if (!result.Result.Equals(string.Empty))
                {
                    Log.Info($"The response: {result.Result}");
                }

                if (!result.Error.Equals(string.Empty))
                {
                    Log.Error($"The response: {result.Error}");
                    return false;
                }

            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }

        protected bool Config(JArray commands)
        {
            bool status = true;
            for (int i = 0; i < commands.Count; i++)
            {
                status &= SendCommand(commands[i].ToString());
            }
            return status;
        }
    }
}
