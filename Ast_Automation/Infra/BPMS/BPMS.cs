using Infra.Connections;
using Infra.Tcp_Connection;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Threading;
using static Infra.Logger.Logger;

namespace Infra.BPMS
{
    public class BPMS
    {
        private SerialConnection _serialConnection;
        private TcpConnection[] _tcpConnections = new TcpConnection[2];
        private readonly int[] _tcpPorts;
        private readonly string _comPort;
        private readonly string _ip;

        public BPMS(string ip, int firstPort, int secondPort, string comPort)
        {
            _ip = ip;
            _tcpPorts = new int[2];
            _tcpPorts[0] = firstPort;
            _tcpPorts[1] = secondPort;
            _comPort = comPort;

            LogConnection();
        }

        public BPMS(List<object> initParams)
        {
            try
            {
                _ip = initParams[0].ToString();
                _tcpPorts = new int[2];
                _tcpPorts[0] = int.Parse(initParams[1].ToString());
                _tcpPorts[1] = int.Parse(initParams[2].ToString());
                _comPort = initParams[3].ToString();
                LogConnection();
                OpenSerialConnectionWithBPMS();
            }
            catch(Exception ex)
            {
                Log.Error(ex);
            }
        }


        #region Log for connection both constructors
        private void LogConnection()
        {
            Log.Info($"BPMS Comport: {_comPort}");
            Log.Info($"BPMS IP: {_ip}");
            Log.Info($"BPMS First Port: {_tcpPorts[(int)Ports.FirstTcpPort]}");
            Log.Info($"BPMS Second Port: {_tcpPorts[(int)Ports.FirstTcpPort]}");
        }
        #endregion

        #region If init BPMS success , run applicaion
        public bool InitBPMS_ComportAndStartApplication(JArray commands)
        {
            return OpenSerialConnectionWithBPMS() ? StartApplication(commands) : false;
        }
        #endregion

        #region Wait for tcp socket to be available after start application - maximum try time 20 sec
        private bool WaitForTcpPortsToBeAvailable()
        {
            Log.Info("Waiting for tcp ports to be available......");
            bool portsAvailable = false;
            DateTime startTime = DateTime.Now;
            while (!portsAvailable && DateTime.Now < startTime.AddSeconds(20))
            {
                try
                {
                    for (int i = 0; i < _tcpConnections.Length; i++)
                    {
                        _tcpConnections[i] = new TcpConnection(_ip, _tcpPorts[i]);
                    }
                    portsAvailable = true;
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                    portsAvailable = false;
                }
            }
            Log.Info($"Tcp connecion success = {portsAvailable} , to ports: {_tcpPorts[(int)Ports.FirstTcpPort]} ,{_tcpPorts[(int)Ports.SecondTcpPort]}");

            for (int i = 0; i < _tcpConnections.Length; i++)
            {
                _tcpConnections[i].ClearBuffer();
            }

            return portsAvailable;
        }
        #endregion

        #region Init BPMS serial connection
        private bool OpenSerialConnectionWithBPMS()
        {
            try
            {
                Log.Info($"Try to open connection with BPMS serial connection comport: {_comPort}");
                _serialConnection = new SerialConnection(_comPort);
                _serialConnection.Open();
                Log.Info("Connection success");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            return true;
        }
        #endregion

        #region Start BPMS app by sending linux commands to serial port
        private bool StartApplication(JArray commands)
        {
            Log.Info($"Start BPMS application");
            for (int i = 0; i < commands.Count; i++)
            {
                if (!WrtieAndReadFromComport(commands[i].ToString()))
                {
                    Log.Error("BPMS application start failed");
                    return false;
                }
            }

            Log.Info("BPMS application start success");
            return WaitForTcpPortsToBeAvailable();
        }
        #endregion

        #region Write and read from BPMS comport
        public bool WrtieAndReadFromComport(string command)
        {
            try
            {
                Log.Info($"Send command to BPMS comport, Command: {command}");
                string reply;
                _serialConnection.WriteAndRead(command, out reply, 0, 0);
                Log.Info($"The reply: {reply}");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }
        #endregion

        #region Write and read from BPMS tcp connection
        public bool WriteAndReadFromTcpConnection(Ports port, string command, ref string output)
        {
            try
            {
                Log.Info($"Send command to BPMS port: [{_tcpPorts[(int)port]}]");
                _tcpConnections[(int)port].Write(command);
                Thread.Sleep(1000);
                string reply = _tcpConnections[(int)port].Read();
                output += reply;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }
        #endregion

        #region Close all BPMS connections

        public void Close()
        {
            try
            {
                Log.Info("Close all BPMS connection");
                _serialConnection.Close();
                _tcpConnections[0].Close();
                _tcpConnections[1].Close();
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }
        #endregion

        #region Close BPMS appliation
        public void CloseBPMS_Application()
        {
            try
            {
                _serialConnection.Write("\x3");
                Log.Info("BPMS application closed");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }
        #endregion


        public enum Ports
        {
            FirstTcpPort,
            SecondTcpPort,
            ComPort
        }
    }
}
