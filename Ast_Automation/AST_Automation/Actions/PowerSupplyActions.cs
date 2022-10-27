using Infra.Enums;
using Infra.PowerSupply;
using System;
using System.Collections.Generic;
using static Infra.Logger.Logger;

namespace AST_Automation.Actions
{
    public class PowerSupplyActions
    {
        public bool OpenSocket(ref TcpPowerSupply powerSupply, Dictionary<string, dynamic> testData)
        {
            try
            {
                string ip = testData["PowerSupply"]["IP"].ToString();
                int port = (int)testData["PowerSupply"]["Port"];
                powerSupply = new TcpPowerSupply(ip, port);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }

        public bool CurrentValidation(object powerSupply, Channels channel, double expectedValue)
        {
            return powerSupply.GetType() == typeof(TcpPowerSupply) ? ValidateCurrentForTcpPowerSupply(powerSupply,channel, expectedValue) : ValidateCurrentForSerialPowerSupply(powerSupply,channel, expectedValue);
        }

        private bool ValidateCurrentForSerialPowerSupply(object powerSupply, Channels channel, double expectedValue)
        {
            double actualCurrent = double.Parse(((SerialPowerSupply)powerSupply).GetCurrent((int)channel));
            Log.Info($"Actual current is: {actualCurrent}, Expected current is: {expectedValue}");
            return actualCurrent < expectedValue + 0.2 && actualCurrent > expectedValue - 0.2;
        }

        private bool ValidateCurrentForTcpPowerSupply(object powerSupply, Channels channel, double expectedValue)
        {
            string actualCurrent = ((TcpPowerSupply)powerSupply).GetCurrent((int)channel);
            actualCurrent = actualCurrent.Split('A')[0];
            Log.Info($"Actual current is: {actualCurrent}, Expected current is: {expectedValue}");
            return double.Parse(actualCurrent) < expectedValue + 0.2 && double.Parse(actualCurrent) > expectedValue - 0.2;
        }

        public bool ChangePowerSupplyState(object powerSupply, Channels channel, bool on)
        {
            return powerSupply.GetType() == typeof(TcpPowerSupply) ? ChangeChannelStateForTcpPowerSupply(powerSupply, channel, on) : ChangeStateForSerialPowerSupply(powerSupply, on);
        }

        private bool ChangeStateForSerialPowerSupply(object powerSupply, bool on)
        {
            return ((SerialPowerSupply)powerSupply).ChangeOutputState(on);
        }

        private bool ChangeChannelStateForTcpPowerSupply(object powerSupply, Channels channel, bool on)
        {
            return ((TcpPowerSupply)powerSupply).ChangeChannelState((int)channel, on);
        }

        public bool ChangePowerSupplyChannelVoltage(object powerSupply, Channels channel, double voltage)
        {
            return powerSupply.GetType() == typeof(TcpPowerSupply) ? ChangeChannelVoltageForTcpPowerSupply(powerSupply, channel, voltage) : ChangeVoltageForSerialPowerSupply(powerSupply, channel, voltage);
        }

        private bool ChangeVoltageForSerialPowerSupply(object powerSupply, Channels channel, double voltage)
        {
            return ((SerialPowerSupply)powerSupply).ChangeChannelVoltageAndValidate((int)channel, voltage);
        }

        private bool ChangeChannelVoltageForTcpPowerSupply(object powerSupply, Channels channel, double voltage)
        {
            return ((TcpPowerSupply)powerSupply).ChangeChannelVoltageAndValidate((int)channel, voltage);
        }

        public bool OpenSerialConnection(ref SerialPowerSupply powerSupply, Dictionary<string, dynamic> testData)
        {
            powerSupply = new SerialPowerSupply(testData["PowerSupply"]["ComPort"].ToString());
            return powerSupply.OpenConnection();
        }

        public bool CloseSerialConnection(SerialPowerSupply powerSupply)
        {
            return powerSupply.CloseConnection();
        }

        public bool CloseTcpConnection(TcpPowerSupply powerSupply)
        {
            return powerSupply.Close();
        }
    }
}

