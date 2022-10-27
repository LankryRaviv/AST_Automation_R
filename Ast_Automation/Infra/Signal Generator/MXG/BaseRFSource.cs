using System;

using IntegratiCoInfrastructure.Instrumentation;

namespace Infra.SignalGenerator
{ 
    public class BaseRFSource: BaseInstrument
    {
        protected string IVI_RECALL_STATE = "*RCL {0},0";
        protected string IVI_SAVE_STATE = "*SAV {0},0";

        public BasicRFGenerator RFGenerator;
        public BasicIQControl Arbitrary;
        //:OUTPut:MODulation:STATe ON
        //:OUTPut:STATe ON
        public BaseRFSource(ICommunicationInterface communicationInterface) : base(communicationInterface)
        {
            AddModule(RFGenerator);
            AddModule(Arbitrary);
        }

        public void EnableRFOutput(Boolean enable)
        {
            RFGenerator.SetOutputState(enable);
        }

        public void EnableDigitalModulation(Boolean enable)
        {
            Arbitrary.SetEnableIQ(enable);
        }

        

        public Boolean SupportArbitrary
        {
            get
            {
                return Arbitrary != null;
            }
        }

        public void RecallState(int state)
        {
            Write(String.Format(IVI_RECALL_STATE, state));
        }

        public void SaveState(int state)
        {
            Write(String.Format(IVI_SAVE_STATE, state));

        }

    }
}
