using IntegratiCoInfrastructure.Instrumentation;

namespace Infra.SignalGenerator
{
    public class Keysight_MXG_IQ : BasicIQControl
    {
        public Keysight_MXG_IQ(ICommunicationInterface communicationInterface):base(communicationInterface)
        {
            IVI_ENABLE_IQ_ADJUSTMENTS = ":DM:IQADjustment {0}";
            IVI_ENABLE_IQ = ":DM:STATe {0}";
            IVI_SET_GAIN_IMBALANCE = ":DM:IQADjustment:Gain {0}";
            IVI_GET_GAIN_IMBALANCE = ":DM:IQADjustment:Gain?";

            IVI_SET_PHASE_IMBALANCE = ":DM:IQADjustment:QSKew {0}";
            IVI_GET_PHASE_IMBALANCE = ":DM:IQADjustment:QSKew?";

            //IVI_SET_CLOCK;
            IVI_LOAD_WAVEFORM = ":SOURce:RADio:ARB:WAVeform \"{0}\"";
            
            IVI_ENABLE_IQ = ":SOURce:RADio:ARB:STATe {0};:OUTPut:MODulation {0}";

            IVI_SET_CLOCK = ":RADio:ARB:CLOCk:SRATe {0}";

            IVI_SET_DC_DIFFRENTAIL = ":DM:IQADjustment:IOFFset{0};:DM:IQADjustment:QOFFset{1}";
            IVI_COPY_NSVM_TO_RAM = ":MEM:COPY \"{0}\",\"{0}\"";
         }
    }
}
