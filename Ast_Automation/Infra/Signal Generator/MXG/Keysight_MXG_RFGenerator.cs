using IntegratiCoInfrastructure.Instrumentation;

namespace Infra.SignalGenerator
{
    public class Keysight_MXG_RFGenerator : BasicRFGenerator
    {
        public Keysight_MXG_RFGenerator(ICommunicationInterface communicationInterface):base(communicationInterface)
        {
            MAX_LEVEL = 24;
            MIN_LEVEL = -144;

            MAX_FREQUENCY = 6e+9;
            MIN_FREQUENCY = 9e+3;

            IVI_OUTPUT_STATE= "OUTP {0}";
            IVI_SET_FREQUENCY= "FREQ:CW {0}";
            IVI_GET_FREQUENCY = "FREQ:CW?";
            IVI_SET_LEVEL = "POW:AMPL {0}";
            IVI_GET_LEVEL= "POW:AMPL?";

        }
    }
}
