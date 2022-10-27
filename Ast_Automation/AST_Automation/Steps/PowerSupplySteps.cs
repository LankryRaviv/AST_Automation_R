using AST_Automation.Actions;
using Infra.Enums;
using Infra.PowerSupply;
using System.Collections.Generic;

namespace AST_Automation.Steps
{
    public class PowerSupplySteps
    {
        private readonly PowerSupplyActions _powerSupplyActions;
        public PowerSupplySteps()
        {
            _powerSupplyActions = new PowerSupplyActions();
        }

        public bool OpenSocket(ref TcpPowerSupply powerSupply, Dictionary<string, dynamic> testData)
        {
            return _powerSupplyActions.OpenSocket(ref powerSupply, testData);
        }

        public bool CurrentValidation(object powerSupply, Channels channel, double expectedValue)
        {
            return _powerSupplyActions.CurrentValidation(powerSupply, channel, expectedValue);
        }

        public bool OpenSerialConnection(ref SerialPowerSupply powerSupply, Dictionary<string, dynamic> testData)
        {
            return _powerSupplyActions.OpenSerialConnection(ref powerSupply, testData);
        }

        public bool ChangeChannelVoltage(object powerSupply, Channels channel, double voltage)
        {
            return _powerSupplyActions.ChangePowerSupplyChannelVoltage(powerSupply, channel, voltage);
        }

        public bool ChangePowerSupplyState(object powerSupply, Channels channel, bool on)
        {
            return _powerSupplyActions.ChangePowerSupplyState(powerSupply, channel, on);
        }

        public bool CloseSerialConnection(SerialPowerSupply powerSupply)
        {
            return _powerSupplyActions.CloseSerialConnection(powerSupply);
        }

        public bool CloseTcpConnection(TcpPowerSupply powerSupply)
        {
            return _powerSupplyActions.CloseTcpConnection(powerSupply);
        }
    }
}
