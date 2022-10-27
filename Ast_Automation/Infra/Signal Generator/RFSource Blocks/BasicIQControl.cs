using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using IntegratiCoInfrastructure.Instrumentation;

namespace Infra.SignalGenerator
{
    public class BasicIQControl : BaseInstrument
    {

        protected string IVI_SET_GAIN_IMBALANCE;
        protected string IVI_GET_GAIN_IMBALANCE;

        protected string IVI_SET_PHASE_IMBALANCE;
        protected string IVI_GET_PHASE_IMBALANCE;

        protected string IVI_SET_DC_COMMON;
        protected string IVI_SET_DC_DIFFRENTAIL;

        protected string IVI_SET_CLOCK;

        protected string IVI_ENABLE_IQ;
        protected string IVI_ENABLE_IQ_ADJUSTMENTS;
        protected string IVI_LOAD_WAVEFORM;
        protected string IVI_COPY_NSVM_TO_RAM;

        public BasicIQControl(ICommunicationInterface communicationInterface) : base(communicationInterface)
        {

        }

        public void SetGainImbalance(double gainImbalance)
        {
            Write(string.Format(IVI_SET_GAIN_IMBALANCE, gainImbalance));
        }

        public double GetGainImbalance()
        {
            return QueryAsDouble(IVI_GET_GAIN_IMBALANCE);
        }

        public void SetPhaseImbalance(double phaseImbalance)
        {
            Write(string.Format(IVI_SET_PHASE_IMBALANCE, phaseImbalance));
        }

        public double GetPhaseImbalance()
        {
            return QueryAsDouble(IVI_GET_PHASE_IMBALANCE);
        }

        public void SetClock(double clock)
        {
            Write(string.Format(IVI_SET_CLOCK, clock));
        }

        public void SetCommonDC(double dc)
        {
            Write(string.Format(IVI_SET_DC_COMMON, dc));
        }

        public void SetDiffrentialDC(double dc)
        {
            Write(string.Format(IVI_SET_DC_DIFFRENTAIL, dc,-dc));
        }

        public void SetEnableIQ(Boolean enable)
        {
            Write(string.Format(IVI_ENABLE_IQ, ConvertBooleanToON_OFF(enable)));
        }

        public void SetEnableIQAjdustments(Boolean enable)
        {
            Write(string.Format(IVI_ENABLE_IQ_ADJUSTMENTS, ConvertBooleanToON_OFF(enable)));
        }

        public void LoadWaveform(string fileName)
        {
            Write(string.Format(IVI_LOAD_WAVEFORM, fileName));
            WaitUntilDone();
        }

        public void CopyFromNonVolotileMemToRAM(string fileName)
        {
            Write(string.Format(IVI_COPY_NSVM_TO_RAM, fileName));
            WaitUntilDone();
        }
    }
}
