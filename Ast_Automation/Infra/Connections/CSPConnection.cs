using Infra.Connections.ProtoType;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.Net.Sockets;
using System.Net;
using System.IO;
using System.ComponentModel; 
using Infra.Messages;
using Infra.Responses;

namespace Infra.Connections
{

    public class CSPConnection : ConnectionBaseClass, IConnection
    {
        // events
        public event PrintToMessegeCallback OnMessage = delegate { };
        public event PrintToMessegeCallback OnMessage2 = delegate { };
        //public event PrintCSPMessageCallback PrintCSPMessage;
        //public event PrintCSPResponseCallback PrintCSPResponse;
        public event ResetCallback OnReset = delegate { };
        public event ErrorCallback OnError = delegate { };

#if RECORDING
        StreamWriter wr = new StreamWriter("RS485_Trace.txt");

#endif

        const int INTERLEAVER = 50;//20mSec

        //const
        const int REMOTE_CLI_TIMEOUT = 5000;
        const int MAX_REPLY_LENGH = 255;
        const string EOM = "MC>";
        const string RESET_ID = "----+";
        readonly byte[] ERROR = new byte[] { 0x65, 0x72, 0x65, 0x72 };

        // socket
        TcpClient tcpClient;
        NetworkStream socket;

        Thread thread_listen;
        CancellationTokenSource cts;
        ManualResetEvent waitingForReply = new ManualResetEvent(false);

        Boolean isAlive = false;
        public string IP { get; set; }
        public int Port { get; set; }

        object locker = new object();
        public MODE mode { get; set; }
        long replyHashCode = INVALID;
        SimpleTelemetry _reply;

        public ListChangedEventHandler ListChanged { get; set; }

#if RECORDING
        void Print(string text, byte[] bytes)
        {
            wr.Write(DateTime.Now.ToString() + " " + text.PadRight(8) + ":");
            StringBuilder sb = new StringBuilder();
            for (int n = 0; n < bytes.Length; n++)
            {
                sb.Append(bytes[n].ToString("X2"));
            }
            wr.WriteLine(sb.ToString());
        }
#endif

        public CSPConnection(string m_IP, int m_Port)
        {
            IP = m_IP;
            Port = m_Port;
            mode = MODE.RS485;
        }
        public Boolean OpenConnection()
        {
            isAlive = false;
            if (startConnection())
            {
                thread_listen = new Thread(new ThreadStart(listener));
                cts = new CancellationTokenSource();
                thread_listen.IsBackground = true;
                thread_listen.Name = "Python adapter message Parser";
                thread_listen.Start();
                isAlive = true;
                return true;
            }
            return false;
        }
        public Boolean startConnection()
        {
            isAlive = false;
            IPHostEntry ipHost = Dns.GetHostEntry(Dns.GetHostName());
            IPAddress ipAddr = IPAddress.Parse(IP);
            IPEndPoint localEndPoint = new IPEndPoint(ipAddr, Port);
            if (socket != null)
                stopConnection();
            try
            {
                tcpClient = new TcpClient(IP, Port);
                socket = tcpClient.GetStream();
                socket.ReadTimeout = 2000;
                return true;
            }
            catch (Exception ex)
            {
                OnError(ex.Message);
                return false;
            }
        }
        protected Boolean stopConnection()
        {
            try
            {
                isAlive = false;
                if (socket != null )
                    socket.Close();
                return true;
            }
            catch (Exception ex)
            {
                //OnError(ex.Message);
                return false;
            }
        }
        public void Close()
        {
            stopConnection();

        }
        public Boolean isOpen()
        {
            if (socket != null)
            {
                return (socket.CanWrite);
            }
            return false;
        }

        // not implemented 
        public void Write(string command)
        {
            throw new NotImplementedException("CSP connection do not support this function!");
        }
        public void Read(out string reply)
        {
            throw new NotImplementedException("CSP connection do not support this function!");
        }

        // Remote CLI
        public Boolean WriteAndRead(string command, out string reply, int micronID, int cspID)
        {
            reply = "";
            command = command.Trim();
            Message_CLI message = new Message_CLI(micronID, cspID, 0xd, command + "\r\n");

            Write(message);
            Thread.Sleep(100);
            int retry = REMOTE_CLI_TIMEOUT / 10;
            SimpleTelemetry[] cliEntries = null;
            Boolean status = false;

            RetrieveLastResponses(message.GetHashcode64(), out cliEntries);
            while ((!status) && (retry >= 0))
            {
                if (cliEntries?.Length > 0)
                {
                    status = new Response_CLI(cliEntries[0]).Reply.Contains("MC>");
                }
                Thread.Sleep(10);
                RetrieveLastResponses(message.GetHashcode64(), out cliEntries);
                retry--;
            }
            Response_CLI cli = null;
            if (retry > 0)
            {
                DiscardResponses(cliEntries);
                StringBuilder sb = new StringBuilder();
                for (int n = cliEntries.Length - 1; n >= 0; n--)
                {
                    cli = new Response_CLI(cliEntries[n]);
                    sb.Append(cli.Reply);
                }
                reply = sb.ToString(); 
                OnMessage(command, reply, micronID, cliEntries[0].MicronID);
                return cli.Last;
            }
           
            return false;
        }

        // Pure CSP
        public void Write(byte[] buffer)
        {
            if (this.isOpen())
            {
                socket.Write(buffer, 0, buffer.Length);
                //Thread.Sleep(INTERLEAVER);
#if RECORDING
                Print("OUT", buffer);
#endif
            }
        }
        public void Read(out byte[] replyBuffer, int numberOfBytesToRead)
        {

            replyBuffer = new byte[0];
            if (this.isOpen())
            {
                using (var stream = new MemoryStream())
                {
                    byte[] buffer = new byte[255];
                    int bytesRead;
                    while (socket.DataAvailable)
                    {
                        bytesRead = socket.Read(buffer, 0, buffer.Length);
                        stream.Write(buffer, 0, bytesRead);
                        if (!socket.DataAvailable)
                            Thread.Sleep(1000);
                    }
                    replyBuffer = stream.ToArray();
                }
            }
        }
        public Boolean Write(BaseMessage message)
        {

            if (!this.isOpen())
            {
                return false;
            }

            try
            {
                byte[] bytes = new byte[message.Payload.Length + 9];
                int len = bytes.Length - 4;
                bytes[0] = (byte)(len & 0xff);
                bytes[1] = (byte)(len >> 8 & 0xff);
                bytes[2] = (byte)(len >> 16 & 0xff);
                bytes[3] = (byte)(len >> 24 & 0xff);
                bytes[4] = (byte)(1); //Priority
                bytes[5] = (byte)(message.CSP_ID);
                bytes[6] = (byte)(message.DEST);
                bytes[7] = (byte)(message.MICRONID & 0xff);
                bytes[8] = (byte)(message.MICRONID >> 8 & 0xff);
                Buffer.BlockCopy(message.Payload, 0, bytes, 9, message.Payload.Length);

#if RECORDING
                Print("OUT", bytes);
#endif

                Write(bytes);
                socket.Flush();
                return true;
            }
            catch (Exception)
            {
                return false;
            }

        }
        public Boolean WriteAndRead(BaseMessage message, out SimpleTelemetry telemetry)
        {

            telemetry = new SimpleTelemetry();
            if (!this.isOpen())
            {
                return false;
            }

            try
            {
                byte[] bytes = new byte[message.Payload.Length + 9];
                int len = bytes.Length - 4;
                bytes[0] = (byte)(len & 0xff);
                bytes[1] = (byte)(len >> 8 & 0xff);
                bytes[2] = (byte)(len >> 16 & 0xff);
                bytes[3] = (byte)(len >> 24 & 0xff);
                bytes[4] = (byte)(0); //Priority
                bytes[5] = (byte)(message.CSP_ID);
                bytes[6] = (byte)(message.DEST);
                bytes[7] = (byte)(message.MICRONID & 0xff);
                bytes[8] = (byte)(message.MICRONID >> 8 & 0xff);
                if (message.Payload.Length > 0)
                    Buffer.BlockCopy(message.Payload, 0, bytes, 9, message.Payload.Length); //9

#if RECORDING
                Print("OUT", bytes);
#endif
                Write(bytes);
                socket.Flush();
                replyHashCode = GenHashCode64(bytes); // Generate Hashcode based on CSP+DEST+MICRONID


                waitingForReply.Reset();
                if (waitingForReply.WaitOne(ReceiveTimeout)) //2sec
                {
                    lock (locker)
                    {
                        telemetry = _reply;
                    }
                    return true;
                }

                replyHashCode = INVALID;
                return false;

            }
            catch (Exception ex)
            {
                return false;
            }

        }
        

        // hash code
        static long GenHashCode64(byte[] bytes)
        {
            /*
            [0..3] Length
            [4] Prioirty
            [5] CSP
            [6] DEST
            [7..8] Micron ID
             
             
             */


            return bytes[5] |         //CSP
                   bytes[6] << 8 |         //DEST
                   bytes[7] << 16 |         //MICRON ID -LSB
                   bytes[8] << 24 |         //MICRON ID -MSB
                   bytes[9] << 32;            //CMDID 
        }


        //listener 
        void listener()
        {
            try
            {
                byte[] recieve = new byte[MAX_REPLY_LENGH];
                int bytecount = 0;
                MemoryStream ms = new System.IO.MemoryStream();
                {
                    while (!cts.IsCancellationRequested)
                    {
                        if (socket.DataAvailable)
                        {
                            bytecount = socket.Read(recieve, 0, MAX_REPLY_LENGH);
                            ms.Write(recieve, 0, bytecount);
                        }


                        Thread.Sleep(1);

                        // This should indicate pause between incoming messages
                        if ((ms.Length > 4))//minimal requirement for 4xbytes Length
                        {
                            /*
                                Hot to decode this adapter message?

                                ==========================================================================================================================================================
                                | Length[4] | CSP[1] | DEST[1] | MICRONID[2] | PAYLOAD ....................|xxx| Length[4] | CSP[1] | DEST[1] | MICRONID[2] | PAYLOAD ....................|
                                ==========================================================================================================================================================

                                Legnth[4] = is the Payload length - 4 bytes for (CSP+DEST+MICRONID)
                                Payload Starts from 8th bytes received

                                Important Facts
                                ------------------
                                * Bytes needed for full message decoding  = Legnth[4] + 4
                                * Payload Length                          = Legnth[4] - 4
                                * Cut leftovers from received byes        = Length[4] + 4



                             */


                            byte[] bytes = ms.ToArray();
                            int messageLength = BytesToLength(bytes) + 4;
                            if ((bytes.Length >= messageLength) && (messageLength>=8))
                            {
                                lock (locker)
                                {
                                    // ping response has no payload
                                    if (bytes.Length == 8)
                                        _reply = new SimpleTelemetry(messageLength - 8, bytes[4], bytes[5], bytes[6] | bytes[7] << 8, new byte[0]);
                                    else
                                        _reply = new SimpleTelemetry(messageLength - 8, bytes[4], bytes[5], bytes[6] | bytes[7] << 8, Cut(bytes, 8));
                                    Push(_reply);

#if RECORDING
                                    Print("IN" , bytes);
#endif
                                    // Handle Sync Reply
                                    if (replyHashCode != INVALID)
                                    {
                                        if (_reply.GetHashCode64() == replyHashCode)
                                        {
                                            replyHashCode = INVALID;
                                            waitingForReply.Set();
                                        }
                                    }
                                }
                                ms.Close();
                                ms = new System.IO.MemoryStream();
                                if (bytes.Length > messageLength) // case there are more bytes than read message, keep them for the next
                                {
                                    ms.Write(bytes, messageLength, bytes.Length - messageLength);
                                }
                            }
                        }

                    }
                }
            }
            catch (Exception ex)
            {

            }

        }


       
    }
}
