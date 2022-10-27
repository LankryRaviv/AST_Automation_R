using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.IO.Ports;
using System.Threading;
using Infra.Connections.ProtoType;
using Infra.Messages;
using Infra.Enums;

namespace Infra.Connections
{

    public delegate void PrintToMessegeCallback(string command, string reply, int out_micronID = -1, int micronID = -1);

    public delegate void ResetCallback(string reply);
    public delegate void ErrorCallback(string error);

    public class SerialConnection : SerialPort, IConnection
    {
        // events
        public event PrintToMessegeCallback OnMessage;// = delegate { };
        public event PrintToMessegeCallback OnMessage2 = delegate { };

        public event ResetCallback OnReset = delegate { };
        public event ErrorCallback OnError = delegate { };


        const string RESET_ID = "----+";

        public MODE mode { get; set; }
        public int ReceiveTimeout { get; set; }

        public SerialConnection(string comPort) : base(comPort, 115200, Parity.None, 8, StopBits.One)
        {
            mode = MODE.RS232;
        }



        public Boolean OpenConnection()
        {
            try
            {
                if (this.isOpen())
                    this.Close();
                this.Open();
            }
            catch (Exception ex)
            {
                OnError(ex.Message);
            }
            if (this.IsOpen)
                return true;
            else return false;
        }
        public Boolean isOpen()
        {
            if (this.IsOpen)
                return true;
            else return false;
        }

        public void Read(out string reply)
        {
            reply = ReadPort();
        }

        public Boolean WriteAndRead(string command, out string reply, int micronID, int cspID)
        {
            try
            {
                Write(command + "\r\n");
                reply = ReadPort();
                print(command, reply);
                if (reply == null)
                {
                    return false;
                }
                return !reply.Equals("Reset") && !reply.Equals("Comm_lost");
            }
            catch (Exception ex)
            {
                OnError(ex.ToString());
                reply = "";
                return false;
            }
        }

        public string ReadPort(string EOM = "MC>", string RESET_ID = "----+")
        {
            Boolean flagToNothing = false;
            int timeOFtimeout = 0;
            string answerLineFromWrite = "";
            StringBuilder sb = new StringBuilder();
            timeOFtimeout = 0;
            int timeOut = 0;
            while (!answerLineFromWrite.Contains(EOM) && !answerLineFromWrite.Contains(RESET_ID))
            {
                try
                {
                    if (this.isOpen())
                    {
                        timeOut++;
                        if (timeOut > 600)
                        {
                            OnError("Connection timeout error");
                            break;
                        }
                        int numberOfBytes = this.BytesToRead;
                        if (numberOfBytes > 0)
                            answerLineFromWrite += this.ReadExisting();
                        else
                        {
                            Thread.Sleep(5);
                        }
                        if (answerLineFromWrite.Contains(RESET_ID))
                        {
                            Thread.Sleep(6000);
                            answerLineFromWrite += this.ReadExisting();
                            Console.WriteLine(answerLineFromWrite);
                            timeOut = 0;
                            while (!answerLineFromWrite.Contains("failed") || (!answerLineFromWrite.Contains("succe")))
                            {
                                timeOut++;
                                if (timeOut > 20000)
                                {
                                    return "Reset";
                                }
                                numberOfBytes = this.BytesToRead;
                                if (numberOfBytes > 0)
                                    answerLineFromWrite += this.ReadExisting();
                                if (answerLineFromWrite.Contains("failed") || answerLineFromWrite.Contains("succe"))
                                {
                                    OnReset(answerLineFromWrite);
                                    OnMessage("", answerLineFromWrite);
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
                catch (TimeoutException ex)
                {
                    OnError(ex.ToString());
                    return null;
                    timeOFtimeout++;

                    if (timeOFtimeout > 5)
                    {
                        flagToNothing = true;
                        break;
                    }
                    else
                        continue;
                }
            }
            return answerLineFromWrite;
        }
        void print(string command, string reply)
        {   
            Console.WriteLine($"Message:{command}\n,Reply:{reply}\n");
        }




        // not implemented 
        public void Write(byte[] buffer)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public Boolean WriteAndRead(byte[] requestBuffer, out byte[] replyBuffer)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public void Read(out byte[] replyBuffer, int numberOfBytesToRead)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public bool Write(BaseMessage message)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public bool WriteAndRead(BaseMessage message, out SimpleTelemetry telemetry)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }


        public Boolean RetrieveLastResponses(int micronId, int commandid, out SimpleTelemetry[] found)
        {
            found = null;
            return true;
        }

        public bool Search(int micronID, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public bool RetrieveLastResponses(CSP_PORT destinationPort, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public bool RetrieveLastResponses(CSP_PORT destinationPort, int tlmIndex, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public bool RetrieveLastResponses(long hashCode64, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public void DiscardResponses(SimpleTelemetry[] discardList)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }

        public bool GetAsynchResponses(out SimpleTelemetry[] asynchResponses)
        {
            throw new NotImplementedException("Serial connection do not support CSP!");
        }



    }
}
