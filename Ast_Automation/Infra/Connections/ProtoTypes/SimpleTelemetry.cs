using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infra.Connections.ProtoType
{
    public struct SimpleTelemetry
    {

        public int Length { get;}

        public byte CSPID { get; }

        public byte DestPort { get;  }

        public ushort MicronID { get; }

        public byte[] Payload { get; }

        public byte CMDID { get; }

        public static int Talomer { internal set; get; } = 0;

        public SimpleTelemetry(int length, int cpid, int dest, int micronid,byte[] payload)
        {
            Length = length;
            CSPID = (byte)cpid;
            DestPort = (byte)dest;
            MicronID = (ushort)micronid;
            Payload = new byte[length];
            Buffer.BlockCopy(payload, 0, Payload, 0, length);
            if(Talomer<int.MaxValue)
            {
                Talomer++;
            }

            CMDID = Payload[0];
        }

        public override string ToString()
        {
            return GetHashCode().ToString("X") + " Len:" + Length;
        }



        public byte[] AsBytes()
        {
            byte[] data = new byte[8 + Payload.Length];
            int len = Payload.Length;
            data[0] = (byte)(len & 0xff);
            data[1] = (byte)(len>>8 & 0xff);
            data[2] = (byte)(len >> 16 & 0xff);
            data[3] = (byte)(len >> 24 & 0xff);

            data[4] = (byte)CSPID;
            data[5] = (byte)DestPort;
            data[6] = (byte)(MicronID & 0xff);
            data[7] = (byte)(MicronID >> 8 & 0xff);
            Buffer.BlockCopy(Payload, 0, data, 8, Payload.Length);

            return data;

        }

       
       

        public static bool operator ==(SimpleTelemetry t1, SimpleTelemetry t2)
        {
            return  t1.GetHashCode()==t2.GetHashCode();
        }

        public static bool operator !=(SimpleTelemetry t1, SimpleTelemetry t2)
        {
            return t1.GetHashCode() != t2.GetHashCode();

        }

        public bool Equals(SimpleTelemetry other)
        {
            if (ReferenceEquals(other, null))
            {
                return false;
            }
            if (ReferenceEquals(this, other))
            {
                return true;
            }

            int test = this.MicronID ^ other.MicronID | this.DestPort ^ other.DestPort | this.CSPID ^ other.CSPID;
            return test == 0;
        }



        public  long GetHashCode64()
        {
            unchecked
            {
                return CMDID<<32 | this.MicronID << 16 | this.DestPort << 8 | this.CSPID;
            }

        }
    }
}
