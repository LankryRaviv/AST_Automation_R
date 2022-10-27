using IntegratiCoInfrastructure.Instrumentation;

namespace Infra.SignalGenerator
{
    public class Keysight_MXG:BaseRFSource
    {
        public Keysight_MXG(ICommunicationInterface communicationInterface) : base(communicationInterface)
        {
            RFGenerator = new Keysight_MXG_RFGenerator(communicationInterface);
            Arbitrary = new Keysight_MXG_IQ(communicationInterface);
        }
    }
}
