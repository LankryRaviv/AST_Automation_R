using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Runtime.Remoting.Contexts;
using System.Threading;

namespace LibCSP_Dll_Wrapper
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct simplecsp_settings
    {
        [MarshalAs(UnmanagedType.LPStr)]
        // name of the com port
        public string com_port;
        // name of the com port
        //public char [] //com_port;
        // baudrate for the serial port
        [MarshalAs(UnmanagedType.U4)]
        public UInt32 baudrate;
        // minimum delay between packets (in ms)
        [MarshalAs(UnmanagedType.U2)]
        public UInt16 delay;
        // sets the debug mode to quiet/verbose (quiet by default)
        [MarshalAs(UnmanagedType.U1)]
        public byte verbose;
        // NOTE: ADDED
        // Local and remote addresses:ports
        [MarshalAs(UnmanagedType.U1)]
        public byte remote_address;
        [MarshalAs(UnmanagedType.U1)]
        public byte remote_port;
        [MarshalAs(UnmanagedType.U1)]
        public byte local_address;
        // Whether to require a succesful ping attempt at connection

        [MarshalAs(UnmanagedType.U1)]
        public byte require_successful_ping;

        [MarshalAs(UnmanagedType.U4)]
        public UInt32 successful_ping_timeout;
        // Size of the sender and receiver queues.
        // A longer sender queue required if messages are send quickly and
        // with a long delay.
        // A longer receiver queue is required if incoming messages are processed
        // with potential high latency.
        [MarshalAs(UnmanagedType.U4)]
        public UInt32 sender_queue_size;
        [MarshalAs(UnmanagedType.U4)]
        public UInt32 receiver_queue_size;
        [MarshalAs(UnmanagedType.U1)]
        public byte settings_header;

    }

    [StructLayout(LayoutKind.Sequential)]
    public struct simplecsp_stats_struct
    {
        UInt16 mtu;              //!< Maximum Transmission Unit of interface
        UInt32 tx;               //!< Successfully transmitted packets
        UInt32 rx;               //!< Successfully received packets
        UInt32 tx_error;         //!< Transmit errors (packets)
        UInt32 rx_error;         //!< Receive errors, e.g. too large message
        UInt32 drop;             //!< Dropped packets
        UInt32 autherr;          //!< Authentication errors (packets)
        UInt32 frame;            //!< Frame format errors (packets)
        UInt32 txbytes;          //!< Transmitted bytes
        UInt32 rxbytes;          //!< Received bytes
        UInt32 irq;              //!< Interrupts
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct simplecsp_header_struct
    {
        [MarshalAs(UnmanagedType.U1)]
        public byte flags;
        [MarshalAs(UnmanagedType.U1)]
        public byte dest_port;
        [MarshalAs(UnmanagedType.U1)]
        public byte source_port;
        [MarshalAs(UnmanagedType.U1)]
        public byte dest_address;
        [MarshalAs(UnmanagedType.U1)]
        public byte source_address;
        [MarshalAs(UnmanagedType.U1)]
        public byte priority;
    }

    public class CSPWrapper
    {
        public enum simplecsp_error
        {
            SIMPLECSP_OK = SIMPLECSP_INFO + 1,
            SIMPLECSP_NOTHING_PROCESSED,
            SIMPLECSP_PROCESSED_ONE,
            SIMPLECSP_ERROR_MAX_CONTEXTS = SIMPLECSP_ERROR + 1,
            SIMPLECSP_ERROR_INVALID_CONFIG,
            SIMPLECSP_ERROR_UNKNOWN_CONTEXT,
            SIMPLECSP_ERROR_CSP_ERROR,
            SIMPLECSP_ERROR_CONNECTION_FAILED,
            SIMPLECSP_ERROR_REQUIRED_PING_TIMEOUT,
            SIMPLECSP_ERROR_QUEUE_ERROR
        }
        const int SIMPLECSP_INFO = 0b00000000;
        const int SIMPLECSP_ERROR = 0b11000000;



        const string DLLNAME = "libsimplecsp.dll";
        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        static extern void simplecsp_default_settings(ref simplecsp_settings settings);

        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_init(ref simplecsp_settings settings);

        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_send(byte[] data_packet, UInt16 len);

        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_send_and_free(byte[] data_packet, UInt16 len);

        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_run_processing_thread();

        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_process_one_message_if_available();

        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_shutdown();

        public delegate void callback_func(IntPtr data_packet, UInt16 len);
        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_set_callback(callback_func callback);

        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern void simplecsp_print_version();



        [DllImport(DLLNAME, CallingConvention = CallingConvention.Cdecl)]
        public static extern simplecsp_error simplecsp_process_one_message_sync(IntPtr buffer, IntPtr len);
        //public static extern simplecsp_error simplecsp_process_one_message_sync();

       



        public delegate void EventHandler_AddPacketToQueue(byte[] dataPacket);
        public event EventHandler_AddPacketToQueue AddPacketToQueue = delegate { return; };



        // Sensmetry
        private callback_func on_message_cb;

        public void on_message(IntPtr data_packet, UInt16 len)
        {
            try
            {
                byte[] managedArray = new byte[len];
                Marshal.Copy(data_packet, managedArray, 0, len);
                AddPacketToQueue(managedArray);
            }
            catch (Exception ex)
            {

            }

        }


        public CSPWrapper()
        {

        }

        public simplecsp_error Init(string comPort)
        {
            simplecsp_settings settings = new simplecsp_settings();

            simplecsp_default_settings(ref settings);
            settings.com_port = $"//./{comPort}";
            settings.baudrate = (UInt32)4000000;
            settings.delay = 0;
            settings.verbose = 0;
            settings.require_successful_ping = 0;
            settings.settings_header = 1;
            settings.local_address = 27;
            //settings.remote_port = 0xa; // dset_port
            //// fpga= 0x29, ping =0x1, cli=0xd, fileSystem=0xa;
            //settings.remote_address = 0xa; //csp_id
            //settings.local_address = 0x1b; //source

            simplecsp_print_version();

            simplecsp_error err = simplecsp_init(ref settings);
            if (err != simplecsp_error.SIMPLECSP_OK)
                return err;

            // Sensmetry
            on_message_cb = new callback_func(on_message);
            err = simplecsp_set_callback(on_message_cb);
            if (err != simplecsp_error.SIMPLECSP_OK)
                return err;
            //err = simplecsp_run_processing_thread();
            if (err != simplecsp_error.SIMPLECSP_OK)
                return err;

            return err;
        }

        public bool ShutDown()
        {
            simplecsp_error err = simplecsp_shutdown();
            if (err == simplecsp_error.SIMPLECSP_OK)
                return true;
            else return false;
        }

        public simplecsp_error SendMessage(byte[] dataPacket, UInt16 len)
        {
            return simplecsp_send(dataPacket, len);
        }

        public simplecsp_error SendMessageAndRecieveTelmetry (byte[] dataPacket, UInt16 len, bool flagToLongTimeout= false)
        {
            simplecsp_error err;
            err= simplecsp_send(dataPacket, len);
            
            //byte[] array = new byte[250];
            //UInt16 len1 = 250;
            //if (flagToLongTimeout)
            //    Thread.Sleep(10000);
            //else  Thread.Sleep(300);
            //IntPtr unmanagedPointer = Marshal.AllocHGlobal(array.Length);
            //IntPtr unmangedLenPointer = Marshal.AllocHGlobal(len1);
            err = simplecsp_process_one_message_if_available();
            
            //Thread.Sleep(50);
            //Marshal.Copy(array, 0, unmanagedPointer, array.Length);
            //Marshal.FreeHGlobal(unmanagedPointer);

            return err;
        }

        public simplecsp_error CheckIfMessageIsAvailable()
        {
            simplecsp_error err;
            //byte[] array = new byte[250];
            //UInt16 len1 = 250;
            //IntPtr unmanagedPointer = Marshal.AllocHGlobal(array.Length);
            //IntPtr unmangedLenPointer = Marshal.AllocHGlobal(len1);
           
            err = simplecsp_process_one_message_if_available();

            //Marshal.Copy(array, 0, unmanagedPointer, array.Length);
            //Marshal.FreeHGlobal(unmanagedPointer);

            return err;
        }


    }
}