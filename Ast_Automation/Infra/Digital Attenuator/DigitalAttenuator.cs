using System;
using System.Collections.Generic;
using System.IO.Ports;
using static Infra.Logger.Logger;

namespace Infra.Digital_Attenuator
{
    public class DigitalAttenuator
    {
        private SerialPort _serialPort;
        private readonly string _comPort;
        public DigitalAttenuator(string comport)
        {
            _comPort = comport;
        }

        public DigitalAttenuator(List<object> initParams)
        {
            try
            {
                _comPort = initParams[0].ToString();
                Open();
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw ex;
            }
        }


        #region Open Port
        public bool Open()
        {
            try
            {
                _serialPort = new SerialPort(_comPort, 9600);
                _serialPort.Open();
                Log.Info($"Open connection with digital attenuator comport: {_comPort}, Succeed");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return false;
            }
            return true;
        }
        #endregion

        #region Close Port
        public bool Close()
        {
            try
            {
                _serialPort.Close();
                Log.Info($"Connection with digital attenuator closed.");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return false;
            }
            return true;
        }
        #endregion

        #region Set Attenuator to channel
        public bool SetAttenuatorToChannel(int channel, int value)
        {
            try
            {
                if (_serialPort != null)
                {
                    _serialPort.Write($"{channel},{value}\n");
                    Log.Info($"Set attenuator channel: {channel}, Value = {value}");
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return false;
            }
            return true;
        }
        #endregion
    }
}
