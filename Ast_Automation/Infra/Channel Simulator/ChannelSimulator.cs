using System;
using System.Diagnostics;
using System.IO;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using static Infra.Logger.Logger;

namespace Infra.Channel_Simulator
{
    public class ChannelSimulator
    {
        private string _exePath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\Channel Simulator\\ChannelSimulator.exe";
        private TcpClient _tcpClient;
        private NetworkStream _networkStream;

        private string _ip;
        private int _port;

        public ChannelSimulator(string ip, int port)
        {
            _ip = ip;
            _port = port;
            _tcpClient = new TcpClient(_ip, _port);
            _networkStream = _tcpClient.GetStream();
            string cmd = ":OUTPut1:STATe?\n";
            byte[] buffer = Encoding.ASCII.GetBytes(cmd);
            _networkStream.Write(buffer, 0, buffer.Length);
            buffer = new byte[1024];
            _networkStream.Read(buffer, 0, buffer.Length);
        }



        public string ChannelSimulatorSendCommand(string option, string command)
        {
            Log.Info($"Send [Option]: {option}, [Command] {command}, to channel simulator");
            try
            {
                string arguments = $"ip={_ip} port={_port} option={option} command={command}";
                ProcessStartInfo procStartInfo = new ProcessStartInfo(_exePath, arguments);

                procStartInfo.RedirectStandardOutput = true;
                procStartInfo.UseShellExecute = false;
                procStartInfo.CreateNoWindow = true;

                using (Process process = new Process())
                {
                    process.StartInfo = procStartInfo;
                    process.Start();

                    process.WaitForExit();

                    string result = process.StandardOutput.ReadToEnd();
                    Log.Info($"Channel simulator response: {result}");
                    return result;
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return string.Empty;
            }


        }
    }
}
