using Infra.Settings;
using IntegratiCoInfrastructure.Instrumentation.Switches;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infra.Switches
{
    internal class DL_UL_Swtich
    {
        internal static MC_1SP16T_83H _dl_switch;
        internal static MC_1SP16T_83H _ul_switch;

        #region Source Switch Initialize
        public static bool InitSourceSwitch(InstrumentInitialize.InstrumentsEnum instrument ,string swtich)
        {
            return InstrumentInitialize.InitSwitches(instrument, swtich);
        }
        #endregion

        #region Get UL Switch object
        public static MC_1SP16T_83H ULSwitch()
        {
            if (InitSourceSwitch(InstrumentInitialize.InstrumentsEnum.ULSwitch, XmlSettings.ULSwitch))
            {
                return _ul_switch;
            }
            return null;
        }
        #endregion


        #region Get DL Switch object
        public static MC_1SP16T_83H DLSwitch()
        {
            if (InitSourceSwitch(InstrumentInitialize.InstrumentsEnum.DLSwitch,XmlSettings.DLSwitch))
            {
                return _dl_switch;
            }
            return null;
        }
        #endregion  
    }
}
