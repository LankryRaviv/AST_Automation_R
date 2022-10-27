using AST_Automation.Actions;
using Infra.Spectrum_Analyzers;
using System.Collections.Generic;

namespace AST_Automation.Steps
{
    public class SpectrumAnalyzerSteps
    {
        private readonly SpectrumAnalyzerActions _spectrumAnalyzerActions;

        public SpectrumAnalyzerSteps()
        {
            _spectrumAnalyzerActions = new SpectrumAnalyzerActions();
        }

        public bool CloseConnection(Spectrum spectum)
        {
            return _spectrumAnalyzerActions.CloseConnection(spectum);
        }

        public bool ConfigSpectrumAndValidate(Dictionary<string, dynamic> testData, ref Spectrum spectrum)
        {
            return _spectrumAnalyzerActions.ConfigSpectrumAndValidate(testData, ref spectrum);
        }

        public bool GetEvmDataAndValidate(Spectrum spectrum)
        {
            return _spectrumAnalyzerActions.GetEvmDataAndValidate(spectrum);
        }
    }
}
