using Infra.Up_Down_Converter;
using Newtonsoft.Json.Linq;
using System;

namespace AST_Automation.Actions
{
    public class ConverterActions
    {
        private static Converter.Band _band;
        public bool OpenConnection(ref Converter converter, JObject testData)
        {
            string ip = testData["IP"].ToString();
            string name = testData["Name"].ToString();
            _band = GetBandEnum(testData["Band"].ToString());
            converter = new Converter(ip, name);
            return converter.Open();
        }

        private Converter.Band GetBandEnum(string band)
        {
            return (Converter.Band)Enum.Parse(typeof(Converter.Band), band);
        }

        public bool SelectBand(Converter converter)
        {
            return converter.SelectBand(_band);
        }

        public bool TurnOutputOn(Converter converter)
        {
            return converter.SetOutput(Converter.OutputValue.ON);
        }

        public bool TurnOutputOff(Converter converter)
        {
            return converter.SetOutput(Converter.OutputValue.OFF);
        }

        public bool CloseConnection(Converter converter)
        {
            return converter.Close();
        }

        public bool SumLOs(Converter converter, double signalGeneratorFrequency)
        {
            var losSum = converter.SumLOs() + signalGeneratorFrequency;
            return true;
        }
}
}
