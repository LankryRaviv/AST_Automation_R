using Infra.Connections;
using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Threading;
using static Infra.Logger.Logger;

namespace Infra.CPBF
{
    public class CPBF
    {
        private readonly SerialConnection[] _cpbfComports;
        public string DataRecived = string.Empty;

        public CPBF(string firstComport, string secondComport)
        {
            _cpbfComports = new SerialConnection[2];
            _cpbfComports[(int)Ports.FirstPort] = new SerialConnection(firstComport);
            _cpbfComports[(int)Ports.SecondPort] = new SerialConnection(secondComport);
            _cpbfComports[(int)Ports.FirstPort].DataReceived += new SerialDataReceivedEventHandler(DataReceivedHandlerFirstPort);
            _cpbfComports[(int)Ports.SecondPort].DataReceived += new SerialDataReceivedEventHandler(DataReceivedHandlerSecondPort);
        }

        public CPBF(List<object> initParams)
        {
            try
            {
                _cpbfComports = new SerialConnection[2];
                _cpbfComports[(int)Ports.FirstPort] = new SerialConnection(initParams[0].ToString());
                _cpbfComports[(int)Ports.SecondPort] = new SerialConnection(initParams[1].ToString());
                _cpbfComports[(int)Ports.FirstPort].DataReceived += new SerialDataReceivedEventHandler(DataReceivedHandlerFirstPort);
                _cpbfComports[(int)Ports.SecondPort].DataReceived += new SerialDataReceivedEventHandler(DataReceivedHandlerSecondPort);
                Open();
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }

        #region Open connection with both comports
        public bool Open()
        {
            try
            {
                Log.Info($"Try to open connection with CPBF first comport: {_cpbfComports[(int)Ports.FirstPort].PortName}," +
                                                        $" Second comport: {_cpbfComports[(int)Ports.SecondPort].PortName}.");
                _cpbfComports[(int)Ports.FirstPort].Open();
                _cpbfComports[(int)Ports.SecondPort].Open();

                Log.Info("Connection success");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return false;
            }
            return WaitForPowerUpIsDone();
        }
        #endregion

        #region Write to selected comport
        public bool WriteToPort(Ports port, string command)
        {
            try
            {
                _cpbfComports[(int)port].Write(command + "\r\n");
                Log.Info($"Send command: {command}, to {_cpbfComports[(int)port].PortName}");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            return true;
        }
        #endregion

        #region Close connections
        public bool Close()
        {
            try
            {
                _cpbfComports[(int)Ports.FirstPort].Close();
                _cpbfComports[(int)Ports.SecondPort].Close();
                Log.Info("Connectio with CPBF closed.");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return false;
            }

            return true;
        }
        #endregion

        #region Read log from second port
        public string ReadLog()
        {
            Thread.Sleep(3000);
            DataRecived = string.Empty;
            string readLogCmd = "tail -1000 /media/sd-mmcblk0p2/console.log";
            WriteToPort(Ports.SecondPort, readLogCmd);
            Thread.Sleep(5000);
            Log.Info($"CPBF log");
            Log.Info($"************************************************************************************");
            Log.Info(DataRecived);
            Log.Info($"************************************************************************************");
            return DataRecived;
        }
        #endregion


        public enum Ports
        {
            FirstPort = 0,
            SecondPort = 1,
        }

        public bool WaitForPowerUpIsDone()
        {
            WriteToPort(Ports.SecondPort, string.Empty);
            Thread.Sleep(1000);
            while (!(DataRecived.Contains("cpbf login:")) && !(DataRecived.Contains("root@cpbf:~#")))
            {
                DataRecived = string.Empty;
                WriteToPort(Ports.SecondPort, string.Empty);
                Thread.Sleep(1000);
                if (DataRecived.Contains("ZynqMP"))
                {
                    WriteToPort(Ports.SecondPort, "boot");
                }
            }
            if (DataRecived.Contains("cpbf login:"))
            {
                CPBF_Login();
            }
            return true;
        }

        private void CPBF_Login()
        {
            DataRecived = string.Empty;
            WriteToPort(Ports.SecondPort, "root");
            while (!DataRecived.Contains("Password"))
            {

            }
            WriteToPort(Ports.SecondPort, "root");
        }

        private void DataReceivedHandlerFirstPort(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sp = (SerialPort)sender;
            string indata = sp.ReadExisting();
            //Log.Info($"Data Received from CPBF, Comport: {sp.PortName}: {indata}");
        }

        private void DataReceivedHandlerSecondPort(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sp = (SerialPort)sender;
            string indata = sp.ReadExisting();
            DataRecived += indata;
            //Log.Info($"Data Received from CPBF, Comport: {sp.PortName}: {indata}");
        }
    }
}
