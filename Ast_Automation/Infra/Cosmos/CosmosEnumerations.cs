using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infra.Cosmos
{
    public class CosmosEnumerations
    {
        public enum PS
        {
            PS1 = 0,
            PS2,
            OPERATIONAL,
            REDUCED

        }

        public enum BW
        {
            BW_10MHZ,
            BW_5MHZ,
            BW_3MHZ,
            BW_1_4MHZ,
            BYPASS
        }

        public enum DL_CF
        {
            BAND_5 = 881500,
            BAND_8 = 942500,
            BAND_14 = 763000
        };

        public enum UL_CF
        {
            BAND_5 = 836500,
            BAND_8 = 892500,
            BAND_14 = 793000
        };

    }
}
