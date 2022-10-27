//#define RECORDING
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
using Infra.Connections.ProtoType;
using Infra.Responses;
using System.Runtime.InteropServices;
using System.IO;
using Infra.Messages;

namespace Infra.Connections

{


    public class KissConnection : ConnectionBaseClass,IConnection
    {
        // events
        public event PrintToMessegeCallback OnMessage = delegate { };
        public event PrintToMessegeCallback OnMessage2 = delegate { };
        public event ResetCallback OnReset = delegate { };
        public event ErrorCallback OnError = delegate { };


#if RECORDING
        StreamWriter wr = new StreamWriter("KIS_Trace.txt");
        
#endif

        const int INTERLEAVER = 50;//20mSec

        //const
        const int MAX_REPLY_LENGH = 255;
        const string EOM = "MC>";
        const string RESET_ID = "----+";
        readonly byte[] ERROR = new byte[] { 0x65, 0x72, 0x65, 0x72 };


        const int CSP_ID_PRIO_SIZE = 2;
        const int CSP_ID_HOST_SIZE = 5;
        const int CSP_ID_PORT_SIZE = 6;
        const int CSP_ID_FLAGS_SIZE = 8;
        const int REMOTE_CLI_TIMEOUT = 5000;


        // socket
        TcpClient tcpClient;
        NetworkStream socket;

        TcpListener TcpListener;
        Thread thread_listen;
        CancellationTokenSource cts;

        ManualResetEvent waitingForReply = new ManualResetEvent(false);

        Boolean isAlive = false;
        public string IP { get; set; }
        public int Port { get; set; }
        
        object locker = new object();
        object printlocker = new object();
        
        public ListChangedEventHandler ListChanged { get; set; }

#if RECORDING
        void Print(string text,byte[] bytes)
        {
            lock (printlocker)
            {
                wr.Write(DateTime.Now.ToString() + " " + text.PadRight(8) + ":");
                StringBuilder sb = new StringBuilder();
                for (int n = 0; n < bytes.Length; n++)
                {
                    sb.Append(bytes[n].ToString("X2") + " ");
                }
                wr.WriteLine(sb.ToString());
            }
        }

        void Print(string text, int src,int dest,int dport,int sport,int priority,int micronID)
        {
            lock (printlocker)
            {
                wr.Write(DateTime.Now.ToString() + " " + text.PadRight(8) + ":");

                wr.WriteLine($"Micron:{micronID} src:{src} dest:{dest} dport:{dport} sport:{sport} priority:{priority} ");
            }
        }

#endif

        public KissConnection(string m_IP, int m_Port)
        {
            IP = m_IP;
            Port = m_Port;
            mode = MODE.Moxa;
#if RECORDING
            wr.AutoFlush = true;
#endif
        }

        public Boolean OpenConnection()
        {
            isAlive = false;
            if (startConnection())
            {
                thread_listen = new Thread(new ThreadStart(listener));
                cts = new CancellationTokenSource();
                thread_listen.Name = "Kiss message Parser";
                thread_listen.IsBackground = true;
                thread_listen.Start();
                isAlive = true;
                return true;
            }
            return false;
        }

        public Boolean isOpen()
        {
            if (socket != null)
            {
                return (socket.CanWrite);
            }
            return false;
        }
        public void Close()
        {
            stopConnection();

        }
        public void Write(string command)
        {
            startConnection();
        }
        public void Read(out string reply)
        {
            reply = "";
            //startConnection();
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
                cts.Cancel();
                if(!thread_listen.Join(2000))
                {
                    thread_listen.Abort();
                }
                socket.Close();
                return true;
            }
            catch (Exception ex)
            {
                //OnError(ex.Message);
                return false;
            }
        }

        public void Write(byte[] buffer)
        {
            if (this.isOpen())
            {
                socket.Write(buffer, 0, buffer.Length);
                //Thread.Sleep(INTERLEAVER);
            }
        }

        public void Read(out byte[] replyBuffer, int numberOfBytesToRead)
        {
           
            replyBuffer = new byte[0];
            int totalbytecount = 0;
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


        public Boolean IsAlive
        {
            get
            {
                return isAlive;
            }
        }

        public MODE mode { get; set ; }

        long replyHashCode = INVALID;
        SimpleTelemetry _reply;

        public Boolean Write(BaseMessage message)
        {

            if (!this.isOpen())
            {
                return false;
            }

            try
            {
              

                byte[] bytes = new byte[message.Payload.Length+6];
               

                int src = 0x1b;// 27 0x1b; //5bit
                int dst =   message.CSP_ID;//10  5bit
                int dport = message.DEST; // 6bit
                int priority = 1;
                int sport = 0;


                 /*
                    |============30========25======20=========14=========0|
                      Priority[2] |  src[5] | dst[5]| dport[6] | sport[6]

                 */


                int reg = (priority<<30 | src<<25 | dst<<20 | dport<< 14 | sport);
                byte[] csp_id = BitConverter.GetBytes(reg);

                bytes[0] = csp_id[3];
                bytes[1] = csp_id[2];
                bytes[2] = csp_id[1];
                bytes[3] = csp_id[0];


            
                bytes[4] = (byte)(message.MICRONID & 0xff);
                bytes[5] = (byte)(message.MICRONID >> 8 & 0xff);

              

                Buffer.BlockCopy(message.Payload, 0, bytes, 6, message.Payload.Length);
          


                byte[] kissEncoded;
                if (KissConverter.KissEncoder(bytes, out kissEncoded))
                {
#if RECORDING
                    Print("OUT",kissEncoded);
#endif

                    Write(kissEncoded);
                    socket.Flush();
                    return true;
                }
            }
            catch 
            {
            }
            return false;

        }

        static long GenHashcode64(int micronID,int dst,int dport,int commandid)
        {
            return dst |                    //CSP
                   dport << 8 |             //DEST
                   micronID << 16 |         //MICRON ID -LSB
                   commandid << 32;         //CMDID 
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

                byte[] bytes = new byte[message.Payload.Length + 6];


                int src =  0x1b;// 27 0x1b; //5bit
                int dst = message.CSP_ID;//10  5bit
                int dport = message.DEST; // 6bit
                int priority = 1;
                int sport = 0;


                /*
                   |============30========25======20=========14=========0|
                     Priority[2] |  src[5] | dst[5]| dport[6] | sport[6]

                */


                int reg = (priority << 30 | src << 25 | dst << 20 | dport << 14 | sport);
                byte[] csp_id = BitConverter.GetBytes(reg);

                bytes[0] = csp_id[3];
                bytes[1] = csp_id[2];
                bytes[2] = csp_id[1];
                bytes[3] = csp_id[0];



                bytes[4] = (byte)(message.MICRONID & 0xff);
                bytes[5] = (byte)(message.MICRONID >> 8 & 0xff);
              


                Buffer.BlockCopy(message.Payload, 0, bytes, 6, message.Payload.Length);


                byte[] kissEncoded;
                if (KissConverter.KissEncoder(bytes, out kissEncoded))
                {

#if RECORDING
                    Print("OUT",kissEncoded);
#endif

                    Write(kissEncoded);
                    socket.Flush();
                    replyHashCode = GenHashcode64(message.MICRONID,dst,dport, bytes[6]); // Generate Hashcode based on CSP+DEST+MICRONID


                    waitingForReply.Reset();
                    if (waitingForReply.WaitOne(ReceiveTimeout)) //2sec
                    {
                        lock (locker)
                        {
                            telemetry = _reply;
                        }
                        return true;
                    }
                }
                replyHashCode = INVALID;
                return false;

            }
            catch (Exception)
            {
                return false;
            }

        }
       
        void listener()
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
                    if((ms.Length>13))//minimal requirement for KISS(Prefix 2) + CSP (6) + CRC(4) + KISS(suffix 1)
                    {
                        /*
                            Hot to decode this adapter message?

                            ==========================================================================================================================================================
                            |KISS 0xc0| |KISS 0x0| |  Priority[2b] |  src[5b] | dst[5b]| dport[6b] | sport[6b] flags[8b]| MICRONID[2] | PAYLOAD ....................| |CRCx4| |KISS 0xc0|
                            ==========================================================================================================================================================

                            Important Facts
                            ------------------
                            * Require at least 15 bytes of Data  =  KISS(Prefix 2) + CSP (8) + CRC(4) + KISS(suffix 1)
                            * FullKiss(ref bytes,out start,out end) Looks for 0xc0 for start and 0xc0 for end
                            * kissConverter.KissDecoder(temp, out decodedMessage) return the CSP message, without KISS headers, nor CRC, return TRUE if CRC is correct
                            
                            After Kiss decoding 
                            ------------------------
                            * Payload Length                          = Legnth[4] - 4
                            * Cut leftovers from received byes        = end (last occurence of 0xc0)
                         
                           

                         */


                        byte[] bytes = ms.ToArray();

                        int start, end;
                        if (KissConverter.FullKiss(ref bytes,out start,out end))
                        {
                            lock (locker)
                            {
                                byte[] temp = new byte[end - start+1];
                                Buffer.BlockCopy(bytes, start, temp, 0, temp.Length);
                                byte[] decodedMessage;
                                Boolean decodeResult = KissConverter.KissDecoder(temp, out decodedMessage);

#if RECORDING
                    Print("IN"+(decodeResult?"":"*"), temp);
#endif
                                if (decodeResult)
                                {
                                    //File.WriteAllBytes("text.txt", decodedMessage);

                                    int src = 0;// 27 0x1b; //5bit
                                    int dst = 0;//10  5bit
                                    int dport = 0; // 6bit
                                    int sport = 0;
                                    int priority = 0;

                                    /*
                                        |============30========25======20=========14=========0|
                                          Priority[2] |  src[5] | dst[5]| dport[6] | sport[6]
                                        |============30========25======20=========14=========0|
                                     */

                                    int r = decodedMessage[0] <<16 | decodedMessage[1] <<8 | decodedMessage[2]  ;
                                    sport =  r&0x3f;
                                    dport = (r >> 6)&0x3f;
                                    dst =   (r>>12) & 0x1f;
                                    src =   (r >>17) & 0x1f;
                                    priority = (r >> 29) & 0x3;

                                    // Version 3.18
                                    //int messageLength = decodedMessage.Length - 6;
                                    //_reply = new SimpleTelemetry(messageLength, src, sport, decodedMessage[4] | decodedMessage[5] << 8, Cut(decodedMessage,6));
                                    int messageLength = decodedMessage.Length - 10; // remove 4 bytes for CRC
                                    _reply = new SimpleTelemetry(messageLength, src, sport, decodedMessage[4] | decodedMessage[5] << 8, Cut(decodedMessage,6, messageLength));
                                    Push(_reply);

#if RECORDING
                                    Print("Detail" + (decodeResult ? "" : "*"),src,dst,dport,sport, priority, decodedMessage[4] | decodedMessage[5] << 8);

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

                                    // moved outside Check CRC
                                    //ms.Close();
                                    //ms = new System.IO.MemoryStream();
                                    //if (bytes.Length > end) // case there are more bytes than read message, keep them for the next
                                    //{
                                    //    ms.Write(bytes, end+1, bytes.Length - end-1);
                                    //}
                                }
                                
                                // Why did I move this code here and not after Kiss CRC32 check
                                // While doing experiment : Multicast file upload + Periodic health monitor
                                // the incoming  health monitor corrupt the bit stream
                                // So instead of repeating CRC on corrupted bits, move to Next Kiss frame
                                
                                ms.Close();
                                ms = new System.IO.MemoryStream();
                                if (bytes.Length > (end )) // case there are more bytes than read message, keep them for the next
                                {
                                  ms.Write(bytes, end + 1, bytes.Length - end - 1);
                                }


                                /*
                                  Normal Packet MUST be

                                        ======================================== | ======================================== | ========================================
                                        |0xc0|0x00|xxxxxxxxxxxxxxxxx|CRC32|0xc0|   |0xc0|0x00|xxxxxxxxxxxxxxxxx|CRC32|0xc0|   |0xc0|0x00|xxxxxxxxxxxxxxxxx|CRC32|0xc0|

                                   injected Packet will look like
                                    
                                        ============================================================================ | ======================================== | ========================================
                                        |0xc0|0x00|xxxxxx|0xc0|0x00|xxxxxxxxxxxxxxxxx|CRC32|0xc0|xxxxxxxxxxx|CRC32|0xc0|   |0xc0|0x00|xxxxxxxxxxxxxxxxx|CRC32|0xc0|   |0xc0|0x00|xxxxxxxxxxxxxxxxx|CRC32|0xc0|
                                        ==================| injection                            |-------------------|


                                        So..
                                        If bytes[end+1] !=0xc0 -> means that there is NO next message
                                        if bytes[end+1] ==0xc0 -> Begining of next message


                                 */
                                // Detect injected packet
                                if ((bytes.Length > (end + 1))&& (bytes[end + 1] != 0xc0))
                                {

                                }

                                //if (bytes.Length > (end+1)) // case there are more bytes than read message, keep them for the next
                                //{
                                //    if (bytes[end + 1] == 0xc0) // the next valid message
                                //    {
                                //        ms.Write(bytes, end + 1, bytes.Length - end - 1);
                                //    }
                                //    else
                                //    {
                                //        ms.Write(bytes, end , bytes.Length - end );
                                //    }
                                //}
                            }
                         
                        }
                    }

                }
            }
        }

        public bool WriteAndRead(byte[] requestBuffer, out byte[] replyBuffer)
        {
            throw new NotImplementedException();
        }

        public bool WriteAndRead(string command, out string reply, int micronID, int cspID)
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
    }
}
