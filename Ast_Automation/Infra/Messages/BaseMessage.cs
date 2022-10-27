#define LITTLE_ENDIAN

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Infra.Messages
{
    public enum CSP_Message_Type
    {
        None,
        Ping,
        File_info,
        File_format,
        File_check,
        File_upload,
        File_Download,
        File_Cancel,
        Data_Packet_Stream,
        Data_Packet,
        FPGA_install,
        FPGA_info,
        Validate_signature_FU,
        Start_FU,
        Start_From_Golden_Image_FU,
        Abort_FU,
        Get_System_Information_FU,
        Get_Current_State_FU,
        Get_Current_Update_Descriptor_FU,
        Get_Golden_Image_Update_Descriptor_FU,
        Abort_Boot_FU,
        Install_FU,
        Reboot,
        RemoteCLI,
        /* Operational */
        Get_PowerSaveMode,
        Set_PowerSaveMode,
        Get_Routing_Parameters,
        Set_Routing_Parameters,
        set_DefaultRoutingParameters,
        Set_PowerSharing,
        Get_PowerSharing,
        Get_EPS_DetailedTelemetry,
        Get_Thermal_DetailedTelemetry,
        Get_MIC_BatteryStatus,
        Get_SlimTLM,
        SetPS2_AutoTransition,
        Get_SlimPeriodic,
        Get_ThermalStat
            
    };

    public class BaseMessage
    {
        public int commandID { get; }
        public int CSP_ID { get; }
        public int DEST { get; }

        public int MICRONID { get; set; }

        public readonly byte[] Payload;

        public CSP_Message_Type message_type { get; set; }

        public BaseMessage(int id, int micronID, int cpsId, int dest, int payloadLength)
        {
            this.commandID = id;
            this.CSP_ID = cpsId;
            this.DEST = dest;
            this.MICRONID = micronID;
            Payload = new byte[payloadLength];
        }

        protected void WriteByte(byte value, int offset)
        {
            Payload[offset++] = (byte)(value & 0xff);
        }

        protected void WriteInt32(int value, int offset)
        {
#if LITTLE_ENDIAN
            Payload[offset++] = (byte)(value & 0xff);
            Payload[offset++] = (byte)(value >> 8 & 0xff);
            Payload[offset++] = (byte)(value >> 16 & 0xff);
            Payload[offset++] = (byte)(value >> 24 & 0xff);
#else
            Payload[offset++] = (byte)(value >> 24 & 0xff);
            Payload[offset++] = (byte)(value >> 16 & 0xff);
            Payload[offset++] = (byte)(value >> 8 & 0xff);
            Payload[offset]   = (byte)(value & 0xff);

#endif
        }

        protected void WriteInt16(int value, int offset)
        {

#if LITTLE_ENDIAN

            Payload[offset++] = (byte)(value & 0xff);
            Payload[offset++] = (byte)(value >> 8 & 0xff);
#else
            Payload[offset++] = (byte)(value >> 8 & 0xff);
            Payload[offset]   = (byte)(value & 0xff);


#endif

        }

        public long GetHashcode64()
        {
            return CSP_ID |         //CSP
                   DEST << 8 |         //DEST
                   MICRONID << 16 |         //MICRON ID -LSB
                   commandID << 32;            //CMDID 
        }

        public override string ToString()
        {
            return $"{message_type.ToString()} to: micron ID: {MICRONID}, CSP ID: {CSP_ID}";
        }
    }


}
