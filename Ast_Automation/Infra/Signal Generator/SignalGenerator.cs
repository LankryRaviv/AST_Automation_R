using IntegratiCoInfrastructure.Instrumentation;
using Infra.Settings;
using System;
using static Infra.Logger.Logger;
using System.Collections.Generic;

namespace Infra.SignalGenerator
{
    public class SignalGenerator
    {
        private Keysight_MXG _signalGenerator;
        private readonly NationalInstruementsInterface national;
        private readonly string _ip;

        public SignalGenerator(string ip)
        {
            _ip = ip;
            national = new NationalInstruementsInterface();
        }

        public SignalGenerator(List<object> initParams)
        {
            _ip = initParams[0].ToString();
            national = new NationalInstruementsInterface();
        }

        #region Signal Generator Initialize

        public bool InitSignalGenerator()
        {
            try
            {
                national.OpenTCP("TCPIP::" + _ip);
                _signalGenerator = new Keysight_MXG(national);
                _signalGenerator.Timeout = 6000;
                Log.Info($"Connection to Signal Generator: {_ip}, Succeed.");
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                return false;
            }

            return true;
        }
        #endregion

        #region Get Signal Generator object

        public Keysight_MXG GetSignalGenerator()
        {
            return _signalGenerator;
        }
        #endregion
    }
}
