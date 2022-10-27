using static Infra.Logger.Logger;
using System;
using System.IO.Ports;
using System.Threading;
using System.Collections.Generic;

namespace Infra.PowerSupply
{
    public class SerialPowerSupply
    {
        private SerialPort _serialPort;
        private string _comPort;
        public string DataRecived = string.Empty;
        public SerialPowerSupply(string comPort)
        {
            _comPort = comPort;
        }

        public SerialPowerSupply(List<object> initParams)
        {
            _comPort = initParams[0].ToString();
            OpenConnection();
        }

        #region Data received handler
        private void DataReceivedHandler(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sp = (SerialPort)sender;
            string indata = sp.ReadExisting();
            DataRecived = indata;
            Log.Info($"Data Received from power supply: {indata}");
        }
        #endregion

        #region Open connection with serial power supply
        public bool OpenConnection()
        {
            try
            {
                Log.Info($"Trying to open connection with serial power supply comport = {_comPort}");
                _serialPort = new SerialPort(_comPort);
                _serialPort.BaudRate = 115200;
                _serialPort.Parity = Parity.None;
                _serialPort.StopBits = StopBits.One;
                _serialPort.DataBits = 8;
                _serialPort.Handshake = Handshake.None;
                _serialPort.DataReceived += new SerialDataReceivedEventHandler(DataReceivedHandler);
                _serialPort.Open();
                _serialPort.Write("remote\n");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }
        #endregion

        #region Close serial connection
        public bool CloseConnection()
        {
            try
            {
                Log.Info($"Close connection with serial power supply");
                _serialPort.Write("local\n");
                _serialPort.Close();
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }
        #endregion


        #region Change channel voltage and validate
        public bool ChangeChannelVoltageAndValidate(int channel, double voltage)
        {
            SetVoltageOfChannel(channel, voltage);

            return GetVoltageOfChannel(channel, voltage);
        }
        #endregion

        #region Get voltage of channel
        private bool GetVoltageOfChannel(int channel, double voltage)
        {
            try
            {
                _serialPort.Write($"vset{channel}?\n");
                Thread.Sleep(2000);
                Log.Info($"Get voltage of channel: {channel}, Expected value is: {voltage}, Actual value is: {DataRecived}");
                return double.Parse(DataRecived.Split('V')[0]) == voltage;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }
        #endregion

        #region Set voltage to channel
        private void SetVoltageOfChannel(int channel, double voltage)
        {
            try
            {
                Log.Info($"Change voltage of channel: {channel} to: {voltage}V");
                _serialPort.Write($"vset{channel}:{voltage}\n");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }
        #endregion

        #region Change power supply output state
        public bool ChangeOutputState(bool state)
        {
            try
            {
                string stateString = state ? "1" : "0";
                Log.Info($"Change power supply output state: {state}");
                _serialPort.Write($"out{stateString}\n");

            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            //TODO: any validate?
            return true;
        }
        #endregion

        #region Get current of channel
        public string GetCurrent(int channel)
        {
            Log.Info($"Get current of channel: {channel}");
            _serialPort.Write($"iout{channel}\n");
            return DataRecived;
        }
        #endregion
    }
}
