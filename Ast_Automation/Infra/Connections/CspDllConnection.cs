using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Infra.Connections.ProtoType;
using Infra.Messages;
using Infra.Enums;
using static LibCSP_Dll_Wrapper.CSPWrapper;
using LibCSP_Dll_Wrapper;

namespace Infra.Connections

{
    public class CspDllConnection : IConnection
    {
        public MODE mode { get; set; }

        public event PrintToMessegeCallback OnMessage;
        public event ResetCallback OnReset;
        public event ErrorCallback OnError;

        public string comPort { get; set; }
        public int ReceiveTimeout { get; set ; }

        CSPWrapper cspWrapper;
        Queue<byte[]> telemetryPacketsQueue = new Queue<byte[]>();

        public CspDllConnection(string comPort)
        {
            this.comPort = comPort;
        }

        public bool OpenConnection()
        {
            this.comPort = comPort;
            try
            {
                cspWrapper = new CSPWrapper();
                cspWrapper.AddPacketToQueue += AddPacketToQueue;

                simplecsp_error err = cspWrapper.Init(comPort);
                return (err == simplecsp_error.SIMPLECSP_OK);
            }
            catch (Exception ex)
            {
                OnError(ex.Message);
                return false;
            }
        }

        private void AddPacketToQueue(byte[] dataPacket)
        {
            //byte[] arr = { 0x0, 0x0, 0x0 };
            //telemetryPacketsQueue.Enqueue(arr);
            telemetryPacketsQueue.Enqueue(dataPacket);
            Thread.Sleep(1);
        }

        public byte[] GetPacketFromQueue()
        {
            if (telemetryPacketsQueue.Count > 0)
                return telemetryPacketsQueue.Dequeue();
            else return null;
        }

        public void Read(out byte[] replyBuffer, int numberOfBytesToRead)
        {
            throw new NotImplementedException();
        }
        public void Close()
        {
            cspWrapper.ShutDown();
        }

        public bool isOpen()
        {
            return true;

        }

        public void Write(byte[] buffer)
        {
            cspWrapper.SendMessage(buffer, (UInt16)buffer.Length);
        }

        public bool WriteAndRead(byte[] requestBuffer, out byte[] replyBuffer)
        {
            try
            {
                cspWrapper.SendMessage(requestBuffer, (UInt16)requestBuffer.Length);

                replyBuffer = GetPacketFromQueue();
                DateTime endTime = DateTime.UtcNow + TimeSpan.FromSeconds(10);
                int x = 0;
                while ((replyBuffer == null) && (DateTime.UtcNow < endTime))
                {
                    cspWrapper.CheckIfMessageIsAvailable();
                    replyBuffer = GetPacketFromQueue();
                    Thread.Sleep(1);
                    x++;
                }


                // Parse reply
                if (replyBuffer != null)
                {
                    //    if (ConcatinateDataPacketsAndParseRecieve(replyBuffer, out string reply))
                    //        return true;
                    //    else return false;
                    return false;
                }
                else
                    return false;
            }
            catch (Exception ex)
            {
                replyBuffer = null;
                return false;
            }

        }





        public void Read(out string reply)
        {
            throw new NotImplementedException();
        }

        public void Write(string command)
        {
            throw new NotImplementedException();
        }

        public bool WriteAndRead(string command, out string reply, int micronID, int csp_id)
        {
            reply = "";
            command += "\r\n";
            // Build remote CLI message
            //dllHeader_requset dllHeader_Requset = new dllHeader_requset();
            //dllHeader_Requset.Source = 27;
            //dllHeader_Requset.Source_port = 13;
            //dllHeader_Requset.Csp_ID = 10;
            //dllHeader_Requset.DestinationPort = 13;
            //dllHeader_Requset.MicronID = (UInt16)micronID;
            //int headerLen = dllHeader_Requset.Buffer.Count;

            //byte[] requestBuffer = new byte[headerLen + 3 + command.Length];
            //for (int i = 0; i < headerLen; i++)
            //{
            //    requestBuffer[i] = dllHeader_Requset.Buffer.ToArray()[i];
            //}
            //requestBuffer[headerLen] = 1;
            //requestBuffer[headerLen + 1] = 0;
            //requestBuffer[headerLen + 2] = 0;

            //for (int i = 0; i < command.Length; i++)
            //{
            //    requestBuffer[headerLen + 3 + i] = (byte)command[i];
            //}

            //send request and get reply
            //if (command.Contains("ds1825u get_temperature") || command.Contains("max31820 get_temperature"))
            //    Thread.Sleep(8000);
            //else Thread.Sleep(150);
            //cspWrapper.SendMessage(requestBuffer, (UInt16)requestBuffer.Length);


            byte[] replyBuffer = GetPacketFromQueue();
            DateTime endTime = DateTime.UtcNow + TimeSpan.FromSeconds(10);
            int x = 0;
            while ((replyBuffer == null) && (DateTime.UtcNow < endTime))
            {
                cspWrapper.CheckIfMessageIsAvailable();
                replyBuffer = GetPacketFromQueue();
                x++;
            }


            // Parse reply
            if (replyBuffer != null)
            {
                //if (ConcatinateDataPacketsAndParseRecieve(replyBuffer, out reply))
                //    return true;
                //else return false;
                return false;
            }
            else
                return false;
        }

        //protected bool ConcatinateDataPacketsAndParseRecieve(byte[] recievedMess, out string stringCommand)
        //{
        //    string incomingMicronID = "";
        //    stringCommand = "";
        //    if (recievedMess.Length > 10)
        //    {
        //        // Parse header
        //        byte[] manipulatedArray = new byte[recievedMess.Length - 6];
        //        Array.Copy(recievedMess, 0, manipulatedArray, 0, 6);
        //        dllHeader_requset dllHeader_Response = new dllHeader_requset(manipulatedArray);
        //        incomingMicronID = dllHeader_Response.MicronID.ToString();

        //        int partOfThePacket = 1;
        //        bool lastTruncatedPacket = false;
        //        try
        //        {
        //            // Parse truncated indications
        //            manipulatedArray = new byte[3];
        //            Array.Copy(recievedMess, 6, manipulatedArray, 0, 3);
        //            partOfThePacket = GetInt(manipulatedArray);
        //            lastTruncatedPacket = (recievedMess[9] == 0x0 ? false : true);

        //            // Parse payload
        //            manipulatedArray = new byte[recievedMess.Length - 10];
        //            Array.Copy(recievedMess, 10, manipulatedArray, 0, recievedMess.Length - 10);
        //            stringCommand += CleanString(ASCIIEncoding.ASCII.GetString(manipulatedArray));

        //            // if this is not the last part of the packet- keep reading
        //            DateTime endTime = DateTime.UtcNow + TimeSpan.FromSeconds(10);
        //            while ((!lastTruncatedPacket) && (DateTime.UtcNow < endTime))
        //            {
        //                cspWrapper.CheckIfMessageIsAvailable();
        //                recievedMess = GetPacketFromQueue();
        //                if (recievedMess != null)
        //                {
        //                    manipulatedArray = new byte[recievedMess.Length - 6];
        //                    Array.Copy(recievedMess, 0, manipulatedArray, 0, 6);
        //                    dllHeader_Response = new dllHeader_requset(manipulatedArray);
        //                    if (dllHeader_Response.MicronID.ToString() == incomingMicronID)
        //                    {
        //                        // Parse truncated indications
        //                        manipulatedArray = new byte[3];
        //                        Array.Copy(recievedMess, 6, manipulatedArray, 0, 3);
        //                        partOfThePacket = GetInt(manipulatedArray);
        //                        lastTruncatedPacket = (recievedMess[9] == 0x0 ? false : true);

        //                        // Parse payload
        //                        manipulatedArray = new byte[recievedMess.Length - 10];
        //                        Array.Copy(recievedMess, 10, manipulatedArray, 0, recievedMess.Length - 10);
        //                        stringCommand += CleanString(ASCIIEncoding.ASCII.GetString(manipulatedArray));
        //                    }
        //                }
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            return false;
        //        }
        //    }
        //    else
        //    {
        //        return false;
        //    }
        //    return true;
        //}

        protected string CleanString(string text)
        {
            string cleaned_text = "";
            char[] a = text.ToCharArray();
            for (int n = 0; n < a.Length; n++)
            {
                if (n < a.Length - 2)
                {
                    if (a[n] == 0x000a && a[n + 1] == 0x000d)
                    {
                        n++;
                        continue;
                    }
                }
                if ((a[n] != 0x0000) && (a[n] != 0x0001) && a[n] != 0x0023 && a[n] != 0x0055)
                {
                    cleaned_text += a[n];
                }
            }
            return cleaned_text;
        }

        public int GetInt(byte[] arr)
        {
            int size = arr.Length;
            if ((size < 4) && (size > 1))
                return BitConverter.ToInt16(arr, 0);
            else
            {
                if (size == 1)
                    return (int)arr[0];
                else return BitConverter.ToInt32(arr, 0);
            }
        }

        public bool Write(BaseMessage message)
        {
            throw new NotImplementedException();
        }

        public bool WriteAndRead(BaseMessage message, out SimpleTelemetry telemetry)
        {
            throw new NotImplementedException();
        }

        public bool RetrieveLastResponses(int micronId, int commandid, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException();
        }

        public bool Search(int micronID, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException();
        }

        public bool RetrieveLastResponses(CSP_PORT destinationPort, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException();
        }

        public bool RetrieveLastResponses(CSP_PORT destinationPort, int tlmIndex, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException();
        }

        public bool RetrieveLastResponses(long hashCode64, out SimpleTelemetry[] found)
        {
            throw new NotImplementedException();
        }

        public void DiscardResponses(SimpleTelemetry[] discardList)
        {
            throw new NotImplementedException();
        }

        public bool GetAsynchResponses(out SimpleTelemetry[] asynchResponses)
        {
            throw new NotImplementedException();
        }
    }
}
