using Infra.Tcp_Connection;
using System.Collections.Generic;
using System.Threading;
using static Infra.Logger.Logger;

namespace Infra.PowerSupply
{
    public class TcpPowerSupply : TcpConnection
    {
        public TcpPowerSupply(string ip, int port) : base(ip, port)
        {
        }

        public TcpPowerSupply(List<object> initParams) : base(initParams)
        {
        }

        public bool ChangeChannelState(int channel, bool on)
        {
            int isOn = on ? 1 : 0;
            string command = $":OUTPut{channel}:STATe";
            string set = $" {isOn}";
            string get = "?";
            string state = on ? "ON" : "OFF";
            Write(command + set);
            Thread.Sleep(500);
            return Validate(command + get, state);
        }

        public bool ChangeChannelVoltageAndValidate(int channel, double value)
        {
            string command = $":SOURce{channel}:VOLTage";
            string set = $" {value}";
            string get = "?";
            Write(command + set);
            Thread.Sleep(500);
            return Validate(command + get, value.ToString());
        }

        public bool ChangeChannelCurrent(int channel, double value)
        {
            string command = $":SOURce{channel}:CURRent";
            string set = $" {value}";
            string get = "?";
            Write(command + set);
            return Validate(command + get, value.ToString());
        }

        public string GetCurrent(int channel)
        {
            string command = $"IOUT{channel}?"; //$":SOURce{channel}:CURRent?";
            Write(command);
            return Read();
        }

        public bool CurrentValidation(int channel, double expectedValue)
        {
            var actualCurrent = GetCurrent(channel);
            actualCurrent = actualCurrent.Split('A')[0];
            Log.Info($"Actual current is: {actualCurrent}, Expected current is: {expectedValue}");
            return float.Parse(actualCurrent) < expectedValue + 0.2 && float.Parse(actualCurrent) > expectedValue - 0.2;
        }

        private bool Validate(string command, string value)
        {
            Write(command);
            return Read().StartsWith(value);
        }
    }
}
