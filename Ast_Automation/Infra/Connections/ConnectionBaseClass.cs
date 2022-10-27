using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Infra.Connections.ProtoType;
using Infra.Enums;

namespace Infra.Connections
{

    public class ConnectionBaseClass
    {
        object locker = new object();
        protected const long INVALID = 0xffff;
        const int DEFAULT_MAX_QUEUE_SIZE = 100;

        public delegate void EventHandler_QueueOverFlow(ConnectionBaseClass obj);

        public event EventHandler_QueueOverFlow OnQueueOverFlow = delegate { };

        public List<SimpleTelemetry> queue = new List<SimpleTelemetry>();

        int maxQueueLenegth = DEFAULT_MAX_QUEUE_SIZE;

        public int ReceiveTimeout { set; get; } = 2000;

        public ConnectionBaseClass()
        {
        }


        public void Clear()
        {
            queue.Clear();
        }

        public void Push(SimpleTelemetry t)
        {
            lock (locker)
            {
                queue.Insert(0, t);
                if (queue.Count > maxQueueLenegth)
                {
                    OnQueueOverFlow(this);
                }
            }
        }

        public Boolean Pop(out SimpleTelemetry t)
        {
            lock (locker)
            {
                if (queue.Count > 0)
                {
                    t = queue[0];
                    queue.Remove(t);

                    return true;
                }
            }
            t = new SimpleTelemetry();
            return false;
        }

        public SimpleTelemetry this[int index]
        {
            get
            {
                return queue[index];
            }
        }

        /// <summary>
        /// Search Example
        /// </summary>
        /// <param name="micronID"></param>
        /// <param name="found"></param>
        /// <returns></returns>
        public Boolean Search(int micronID, out SimpleTelemetry[] found)
        {
            List<SimpleTelemetry> t = new List<SimpleTelemetry>();
            Parallel.ForEach(queue, x =>
            {
                if (x.MicronID == micronID)
                {
                    t.Add(x);
                }
            });

            found = t.ToArray();
            return found.Length > 0;
        }

        public int Length
        {
            get
            {
                return queue.Count;

            }
        }

        #region Static Bytes manipulation
        static public byte[] Cut(byte[] x1, int from)
        {
            byte[] output = new byte[x1.Length - from];
            Buffer.BlockCopy(x1, from, output, 0, x1.Length - from);
            return output;
        }

        static public byte[] Combine(byte[] x1, byte[] x2)
        {
            if (x1 == null)
            {
                return x2;
            }


            byte[] output = new byte[x1.Length + x2.Length];
            Buffer.BlockCopy(x1, 0, output, 0, x1.Length);
            Buffer.BlockCopy(x2, 0, output, x1.Length, x2.Length);
            return output;
        }

        static public byte[] Combine(byte[] x1, byte[] x2, int x2Length)
        {
            byte[] output;
            if (x1 == null)
            {
                output = new byte[x2Length];
                Buffer.BlockCopy(x2, 0, output, 0, x2Length);
                return output;
            }

            output = new byte[x1.Length + x2.Length];
            Buffer.BlockCopy(x1, 0, output, 0, x1.Length);
            Buffer.BlockCopy(x2, 0, output, x1.Length, x2Length);

            return output;
        }

        //static public long GenHashCode64(byte[] bytes)
        //{
        //    /*
        //    [0..3] Length
        //    [4] Prioirty
        //    [5] CSP
        //    [6] DEST
        //    [7..8] Micron ID


        //     */
        //    int cmd_id;

        //    if (bytes.Length == 8 || bytes.Length == 9)
        //        cmd_id = 0;
        //    else cmd_id = bytes[9] << 32;


        //        return bytes[5] |         //CSP
        //           bytes[6] << 8 |         //DEST
        //           bytes[7] << 16 |         //MICRON ID -LSB
        //           bytes[8] << 24 |         //MICRON ID -MSB
        //           cmd_id;            //CMDID 


        //}

        static public int BytesToLength(byte[] bytes)
        {
            return bytes[0] | bytes[1] << 8 | bytes[2] << 16 | bytes[3] << 24;
        }
        #endregion

        public Boolean RetrieveLastResponses(int micronId, int commandid, out SimpleTelemetry[] found)
        {
            List<SimpleTelemetry> t = new List<SimpleTelemetry>();
            int n = 0;
            lock (locker)
            {
                while ((n < queue.Count) && (queue[n].MicronID != micronId) && (queue[n].CMDID != commandid))
                {
                    n++;
                }
                // found start 
                while ((n < queue.Count) && (queue[n].MicronID == micronId) && (queue[n].CMDID == commandid))
                {
                    t.Add(queue[n]);
                    n++;
                }
            }

            found = t.ToArray();
            return found.Length > 0;
        }

        public Boolean RetrieveLastResponses(CSP_PORT destinationPort, out SimpleTelemetry[] found)
        {
            byte p = (byte)destinationPort;
            List<SimpleTelemetry> t = new List<SimpleTelemetry>();
            lock (locker)
            {
                for (int n = 0; n < queue.Count; n++)
                {
                    if (queue[n].DestPort == p)
                    {
                        t.Add(queue[n]);
                    }
                }
            }

            found = t.ToArray();
            return found.Length > 0;
        }

        public Boolean RetrieveLastResponses(CSP_PORT destinationPort, int tlmIndex, out SimpleTelemetry[] found)
        {
            byte p = (byte)destinationPort;
            List<SimpleTelemetry> t = new List<SimpleTelemetry>();
            lock (locker)
            {
                for (int n = 0; n < queue.Count; n++)
                {
                    if ((queue[n].DestPort == p) && (queue[n].CMDID == tlmIndex))
                    {
                        t.Add(queue[n]);
                    }
                }
            }

            found = t.ToArray();
            return found.Length > 0;
        }


        public Boolean RetrieveLastResponses(long hashCode64, out SimpleTelemetry[] found)
        {
            List<SimpleTelemetry> t = new List<SimpleTelemetry>();
            int n = 0;
            lock (locker)
            {
                while ((n < queue.Count) && (queue[n].GetHashCode64() != hashCode64))
                {
                    n++;
                }
                // found start 
                while ((n < queue.Count) && (queue[n].GetHashCode64() == hashCode64))
                {
                    t.Add(queue[n]);
                    n++;
                }
            }

            found = t.ToArray();
            return found.Length > 0;
        }

        public void DiscardResponses(SimpleTelemetry[] discardList)
        {
            if (discardList == null) return;
            lock (locker)
            {
                for (int n = 0; n < discardList.Length; n++)
                {
                    queue.Remove(discardList[n]);
                }
            }
        }

        public Boolean GetAsynchResponses(out SimpleTelemetry[] asynchResponses)
        {
            List<SimpleTelemetry> found = new List<SimpleTelemetry>();
            lock (locker)
            {
                for (int n = 0; n < queue.Count; n++)
                {
                    if (queue[n].DestPort == (int)CSP_PORT.HEALTH_MONITOR)
                    {
                        found.Add(queue[n]);
                    }
                }

                asynchResponses = found.ToArray();
                DiscardResponses(asynchResponses);
                return asynchResponses.Length > 0;
            }
        }
        static public byte[] Cut(byte[] x1, int from, int length)
        {
            byte[] output = new byte[length];
            Buffer.BlockCopy(x1, from, output, 0, length);
            return output;
        }

    }
}
