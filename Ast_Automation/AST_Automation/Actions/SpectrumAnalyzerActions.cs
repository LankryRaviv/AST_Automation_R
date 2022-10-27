using Infra.Spectrum_Analyzers;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AST_Automation.Actions
{
    public class SpectrumAnalyzerActions
    {
        public bool CloseConnection(Spectrum spectrum)
        {
            return spectrum.Close();
        }

        public bool ConfigSpectrumAndValidate(Dictionary<string, dynamic> testData, ref Spectrum spectrum)
        {
            spectrum = new Spectrum(testData["SpectrumAnalyzer"]["IP"].ToString(), (int)testData["SpectrumAnalyzer"]["Port"]);
            return spectrum.ConfigSpectrum(testData["SpectrumAnalyzer"]);
        }

        public bool GetEvmDataAndValidate(Spectrum spectrum)
        {
            return spectrum.GetEvmAndValidate();
        }
    }
}
