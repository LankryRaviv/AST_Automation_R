using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Infra.Connections.ProtoType;
using Infra.Messages;

namespace Infra.Responses
{

    public class BaseResponse
    {
        public readonly SimpleTelemetry telemetry;
        public readonly int commandID;
        public Boolean HSTATUS = true;
        int a_offset = 0;

        public CSP_Message_Type message_type { get; set; }

        public BaseResponse(SimpleTelemetry telemetry)
        {
            this.commandID = telemetry.CMDID;
            this.telemetry = telemetry;
        }


        public static Boolean CheckBoolean(Boolean[] evaluation)
        {
            Boolean status = true;
            for (int n = 0; n < evaluation.Length; n++)
            {
                status &= evaluation[n];
            }

            return status;
        }

        public static Boolean CheckNonNull(byte[] evaluation)
        {
            Boolean status = false;
            for (int n = 0; n < evaluation.Length; n++)
            {
                status |= evaluation[n] != 0;
            }

            return status;
        }

        public static Boolean CheckNull(byte[] evaluation)
        {
            Boolean status = true;
            for (int n = 0; n < evaluation.Length; n++)
            {
                status &= evaluation[n] == 0;
            }

            return status;
        }

        #region Manual offset parsing

        public float GetAsFloat(int offset)
        {
            // input[2], input[3], input[0], input[1]


            return BitConverter.ToSingle(new byte[] { telemetry.Payload[offset + 0],
                                                      telemetry.Payload[offset + 1],
                                                      telemetry.Payload[offset + 2],
                                                      telemetry.Payload[offset + 3] }, 0);
        }


        public Boolean GetAsBoolean(int offset)
        {
            return telemetry.Payload[offset] != 0;
        }

        public byte GetAsByte(int offset)
        {
            return telemetry.Payload[offset];
        }

        public double GetAsDouble(int offset)
        {
            return BitConverter.ToDouble(new byte[] { telemetry.Payload[offset],
                                                      telemetry.Payload[offset + 1],
                                                      telemetry.Payload[offset + 2],
                                                      telemetry.Payload[offset + 3] ,
                                                      telemetry.Payload[offset + 4],
                                                      telemetry.Payload[offset + 5],
                                                      telemetry.Payload[offset + 6] ,
                                                      telemetry.Payload[offset + 7] }, 0);
        }


        public int GetInt(int offset)
        {
            return telemetry.Payload[offset] | telemetry.Payload[offset + 1] << 8 | telemetry.Payload[offset + 2] << 16 | telemetry.Payload[offset + 3] << 24;
        }

        public int GetUInt(int offset)
        {
            return telemetry.Payload[offset] | telemetry.Payload[offset + 1] << 8 | telemetry.Payload[offset + 2] << 16 | telemetry.Payload[offset + 3] << 24;
        }
        public int GetSignedByte(int offset)
        {
            if (telemetry.Payload[offset] > 127)
            {
                return telemetry.Payload[offset] - 256;
            }

            return telemetry.Payload[offset];
        }

        public Byte GetByte(int offset)
        {
            return telemetry.Payload[offset];
        }

        public UInt16 GetUInt16(int offset)
        {
            return (UInt16)(telemetry.Payload[offset] | telemetry.Payload[offset + 1] << 8);
        }

        public Int16 GetInt16(int offset)
        {
            UInt16 xval = GetUInt16(offset);
            //if((xval & 0x8000)!=0)
            //{
            //    return (Int16)(xval - 0xffff);
            //}


            return (Int16)xval;
        }
        public string GetString(int offset, int length)
        {
            return System.Text.Encoding.UTF8.GetString(Cut(telemetry.Payload, offset, length));
        }
        public Boolean GetBool(int offset)
        {
            return telemetry.Payload[offset] != 0;
        }

        public string GetString(int offset)
        {
            return System.Text.Encoding.UTF8.GetString(Cut(telemetry.Payload, offset, telemetry.Payload.Length - offset));
        }

        #endregion

        #region Auto offsetincrement
        public byte GetByte()
        {
            return GetByte(a_offset++);
        }

        public Boolean GetBoolean()
        {
            return GetAsBoolean(a_offset++);
        }

        public int GetSignedByte()
        {
            return GetSignedByte(a_offset++);
        }

        public float GetFloat()
        {
            float t = GetAsFloat(a_offset);
            a_offset += 4;
            return t;
        }

        public Int16 GetInt16()
        {
            Int16 t = GetInt16(a_offset);
            a_offset += 2;
            return t;
        }

        public double GetDouble()
        {
            double t = GetAsDouble(a_offset);
            a_offset += 8;
            return t;
        }

        public int GetInt()
        {
            int t = GetInt(a_offset);
            a_offset += 4;
            return t;
        }
        public int GetUInt()
        {
            int t = GetUInt(a_offset);
            a_offset += 4;
            return t;
        }




        #endregion


        public static byte[] Cut(byte[] x1, int from, int len)
        {
            byte[] output = new byte[x1.Length - from];
            Buffer.BlockCopy(x1, from, output, 0, len);
            return output;
        }

        static public byte[] Cut(byte[] x1, int from)
        {
            byte[] output = new byte[x1.Length - from];
            Buffer.BlockCopy(x1, from, output, 0, x1.Length - from);
            return output;
        }

    }
}
