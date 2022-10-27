using AST_Automation.Actions;
using Infra.Up_Down_Converter;
using Newtonsoft.Json.Linq;

namespace AST_Automation.Steps
{
    public class ConverterSteps
    {
        private readonly ConverterActions _converterActions;
        public ConverterSteps()
        {
            _converterActions = new ConverterActions();
        }

        public bool OpenConnection(ref Converter converter ,JObject testData)
        {
            return _converterActions.OpenConnection(ref converter, testData);   
        }

        public bool SelectBand(Converter converter)
        {
            return _converterActions.SelectBand(converter);
        }

        public bool CloseConnection(Converter converter)
        {
            return _converterActions.CloseConnection(converter);
        }

        public bool SumLOs(Converter converter,double signalGeneratorFrequency)
        {
            return _converterActions.SumLOs(converter, signalGeneratorFrequency);
        }

        public bool TurnOutputOn(Converter converter)
        {
            return _converterActions.TurnOutputOn(converter);
        }

        public bool TurnOutputOff(Converter converter)
        {
            return _converterActions.TurnOutputOff(converter);
        }
    }
}
