using System.Collections.Generic;
using AST_Automation.Actions;
using Infra.SignalGenerator;

namespace AST_Automation.Steps
{
    public class SignalGeneratorSteps
    {
        private readonly SignalGeneratorActions _signalGeneratorActions;
        public SignalGeneratorSteps()
        {
            _signalGeneratorActions = new SignalGeneratorActions();
        }

        public bool InitSignalGenerator(ref SignalGenerator signalGenerator, string ip)
        {
            return _signalGeneratorActions.InitSignalGenerator(ref signalGenerator, ip);
        }

        public bool ConfigSignalGenerator(SignalGenerator signalGenerator, Dictionary<string, dynamic> testData)
        {
            return _signalGeneratorActions.ConfigSignalGenerator(signalGenerator, testData);
        }

        public double GetSignalGeneratorFrequency(SignalGenerator signalGenerator)
        {
            return _signalGeneratorActions.GetFrequency(signalGenerator);
        }
    }
}
