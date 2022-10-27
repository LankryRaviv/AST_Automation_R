using System.ComponentModel;

namespace DataManagement.Jsons
{
    public enum JsonsEnum
    {
        [Description("Jsons\\E2ETest.json")]
        E2ETest,
        [Description("Jsons\\Setup.json")]
        Setup,
        [Description("Jsons\\TestJson.json")]
        TestJson,
        [Description("Jsons\\Tests\\E2E Test\\1_QV.json")]
        QVTestJson,
        [Description("\\CPUReg\\DataSets\\GeneralData.json")]
        CPURegTest_GeneralData, 
        [Description("\\FPGAReg\\DataSets\\GeneralDataFPGA.json")]
        FPGARegTest_GeneralData,
        [Description("Jsons\\pwr_goods_input_data.json")]
        PowerGoodsTest,
        [Description("Jsons\\pwr_mode_switching_w_pwr_goods.json")]
        PowerGoodsChangePowerModes,
        [Description("\\CPUReg\\DataSets\\CPBF_Upload.json")]
        CPURegTest_CPBFUploadDataTest
    }
}
