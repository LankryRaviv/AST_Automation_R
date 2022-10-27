using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IntegratiCoInfrastructure.Instrumentation;
namespace Infra.SignalGenerator
{
    public class BasicRFGenerator : BaseInstrument
    {

        protected string IVI_OUTPUT_STATE;
        protected string IVI_SET_FREQUENCY;
        protected string IVI_GET_FREQUENCY;
        protected string IVI_SET_LEVEL;
        protected string IVI_GET_LEVEL;

        protected double MAX_FREQUENCY;
        protected double MIN_FREQUENCY;
        protected double MAX_LEVEL;
        protected double MIN_LEVEL;


        public BasicRFGenerator(ICommunicationInterface communicationInterface) : base(communicationInterface)
        {

        }

        public void SetFrequency(double frequency)
        {
            if ((frequency >= MIN_FREQUENCY) && (frequency <= MAX_FREQUENCY))
            {
                Write(string.Format(IVI_SET_FREQUENCY, frequency));
            }
            else
            {
                // TODO : error
            }
        }

        public double GetFrequency()
        {
            return QueryAsDouble(string.Format(IVI_GET_FREQUENCY));
        }

        public void SetLevel(double level)
        {
            if ((level >= MIN_LEVEL) && (level <= MAX_LEVEL))
            {
                Write(string.Format(IVI_SET_LEVEL, level));
            }
            else
            {
                // TODO : error
            }
        }
        public string GetModulation()
        {
            return Query("RAD:ARB:WAV?");
        }

        public double GetLevel()
        {
            return QueryAsDouble(string.Format(IVI_GET_LEVEL));
        }

        public void SetOutputState(Boolean enable)
        {
            Write(string.Format(IVI_OUTPUT_STATE, enable ? "ON" : "OFF"));
        }

    }
}
