using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using static Infra.Logger.Logger;

namespace Infra.Tcp_Connection
{
    public class TcpConnection
    {
        private readonly TcpClient _tcpClient;
        public readonly NetworkStream _networkStream;
        private readonly string _ip;
        private readonly int _port;

        #region Create new tcp connection
        public TcpConnection(string ip, int port)
        {
            try
            {
                Log.Info($"Try to open TCP connection: [IP] = {ip} , [Port]= {port}");
                _ip = ip;
                _port = port;
                _tcpClient = new TcpClient(_ip, _port);
                _networkStream = _tcpClient.GetStream();
                _networkStream.ReadTimeout = 500;
                _networkStream.WriteTimeout = 500;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            Log.Info("TCP connection is open!!");
        }
        #endregion

        public TcpConnection(List<object> initParams)
        {
            try
            {
                Log.Info($"Try to open TCP connection: [IP] = {initParams[0]} , [Port]= {initParams[1]}");
                _ip = initParams[0].ToString();
                _port = int.Parse(initParams[1].ToString());
                _tcpClient = new TcpClient(_ip, _port);
                _networkStream = _tcpClient.GetStream();
                _networkStream.ReadTimeout = 500;
                _networkStream.WriteTimeout = 500;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            Log.Info("TCP connection is open!!");
        }

        #region Write to tcp socket
        public void Write(string command)
        {
            try
            {
                Log.Info($"Writing to socket-[CMD] = {command}");
                byte[] buffer = Encoding.ASCII.GetBytes(command + "\n");
                _networkStream.Write(buffer, 0, buffer.Length);
                Thread.Sleep(100);
            }
            catch (Exception ex)
            {
                Log.Error("Write to socket failed");
                Log.Error(ex);
            }
        }
        #endregion

        #region Read from tcp soket
        public string Read()
        {
            byte[] buffer = new byte[4096];
            try
            {
                Log.Info("Reading from socket.........");
                while (_networkStream.DataAvailable)
                {
                    _networkStream.Read(buffer, 0, buffer.Length);
                }
                _networkStream.Flush();
            }
            catch (Exception ex)
            {
                Log.Error("Read from socket failed");
                Log.Error(ex);
                throw;
            }
            Log.Info($"Socket response {Encoding.ASCII.GetString(buffer).Split('\0')[0]}");
            return Encoding.ASCII.GetString(buffer).Split('\0')[0];
        }
        #endregion

        #region Write and read - return string
        protected string WriteAndReadString(string command)
        {
            Write(command);
            Thread.Sleep(200);
            return Read().Replace("\n", "");
        }
        #endregion

        #region Write and read - return string list
        protected List<string> WriteAndReadStringList(string command)
        {
            Write(command);
            Thread.Sleep(200);
            return Read().Replace("\n", "").Split(',').ToList();
        }
        #endregion

        #region Close tcp connection
        public bool Close()
        {
            try
            {
                _networkStream.Close();
                _tcpClient.Close();
                Log.Info($"Connection with [IP]: {_ip} , [Port]: {_port}, is closed");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }
        #endregion

        #region Clear data buffer
        public void ClearBuffer()
        {
            var buffer = new byte[4096];
            while (_networkStream.DataAvailable)
            {
                _networkStream.Read(buffer, 0, buffer.Length);
            }
        }
        #endregion
    }
}