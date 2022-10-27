using IntegratiCoInfrastructure;
using IntegratiCoInfrastructure.Instrumentation;
using System;
using System.Diagnostics;
using IntegratiCoInfrastructure.Instrumentation.Switches;

namespace Infra.Settings
{
    public static class InstrumentInitialize
    {
        private static void InitilaieInstrumentByType(NationalInstruementsInterface national, string communication, InstrumentsEnum type)
        {
            switch (type)
            {
                case InstrumentsEnum.SourceSwitch:
                    {
                        Switches.SourceSwitch._source_switch = new MC_USB_2SP2T_DCH();
                        Switches.SourceSwitch._source_switch.Open(communication);
                        break;
                    }
                //TODO:change to ul
                case InstrumentsEnum.ULSwitch:
                    {
                        Switches.SourceSwitch._source_switch = new MC_USB_2SP2T_DCH();
                        Switches.SourceSwitch._source_switch.Open(communication);
                        break;
                    }
                //TODO:change to dl
                case InstrumentsEnum.DLSwitch:
                    {
                        Switches.SourceSwitch._source_switch = new MC_USB_2SP2T_DCH();
                        Switches.SourceSwitch._source_switch.Open(communication);
                        break;
                    }
                default:
                    {
                        //instrument = null;
                        break;
                    }
            }
        }

        public static bool InitSwitches(InstrumentsEnum type, string instrument)
        {
            bool instrumentEnabled;
            bool status = false;
            try
            {
                XmlInitFile ini = new XmlInitFile();

                if (ini.Open(XmlSettings.XmlSettingsPath))
                {
                    ini.GetAsBoolean(instrument, XmlSettings.Enabled, out instrumentEnabled);
                    if (instrumentEnabled)
                    {
                        string serial;
                        ini.GetAsString(instrument, XmlSettings.Serial, out serial);
                        InitilaieInstrumentByType(null, serial, type);
                        status = true;
                    }
                }
            }
            catch (Exception ex)
            {
                Trace.WriteLine(ex);
            }

            return status;
        }

        public enum InstrumentsEnum
        {
            Keysight_MXG,
            N9000x,
            QV,
            DLSwitch,
            ULSwitch,
            SourceSwitch,
            MainBoard,
            CPBF,
            BPMS,
        }
    }
}
