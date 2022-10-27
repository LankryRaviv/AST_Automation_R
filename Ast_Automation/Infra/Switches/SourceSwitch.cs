using IntegratiCoInfrastructure.Instrumentation.Switches;
using Infra.Settings;

namespace Infra.Switches
{
    static class SourceSwitch
    {
        internal static MC_USB_2SP2T_DCH _source_switch;

        #region Source Switch Initialize
        public static bool InitSourceSwitch()
        {
            return InstrumentInitialize.InitSwitches(InstrumentInitialize.InstrumentsEnum.SourceSwitch, XmlSettings.SourceSwitch);
        }
        #endregion

        #region Get Source Switch object
        public static MC_USB_2SP2T_DCH GetSourceSwitch()
        {
            if (InitSourceSwitch())
            {
                return _source_switch;
            }
            return null;
        }
        #endregion  
    }
}