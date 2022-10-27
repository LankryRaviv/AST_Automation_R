using Infra.Enums;
using Infra.Tcp_Connection;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using static Infra.Logger.Logger;

namespace Infra.Spectrum_Analyzers
{
    public class Spectrum : TcpConnection
    {
        #region SCPI commands
        private const string GetEvmCommand = ":FETCh:EVM?";
        private const string GetFrequencyCommand = ":SENSe:CCARrier:REFerence?";
        private const string GetInvertCommand = "SENSe:RADio:STANdard:DIRection?";
        private const string GetBandwithCommand = "SENSe:RADio:STANdard:PRESet?";
        private const string GetDirectionCommand = "SENSe:RADio:STANdard:DIRection?";
        #endregion

        public Spectrum(string ip, int port) : base(ip, port)
        {   
        }

        public Spectrum(List<object> initParams) :base (initParams)
        {

        }

        #region Config spectrum from json
        public bool ConfigSpectrum(JObject parameters)
        {
            string freq = string.Empty, direction = string.Empty, band = string.Empty, invert = string.Empty;
            GetValuesFromJson(parameters, out freq, out direction, out band, out invert);
            List<string> commandsList = GetCommandList(freq, direction, band, invert);

            for (int i = 0; i < commandsList.Count; i++)
            {
                Write(commandsList[i]);
                if (commandsList[i].Equals("*OPC?"))
                {
                    Log.Info("Waiting for OPC command to end");
                    while (!Read().Contains("1"))
                    {
                    }
                }
            }

            return Validate(freq, direction, band, invert);
        }

        #endregion

        #region Get values for configuration from json
        private void GetValuesFromJson(JObject parameters, out string freq, out string direction, out string band, out string invert)
        {
            freq = parameters["CarrierReferenceFrequency"].ToString();
            direction = parameters["Direction"].ToString();
            band = parameters["SystemBandwith"].ToString();
            invert = GetInvertString((bool)parameters["Invert"]);
        }
        #endregion

        #region Get invert string from bool

        private string GetInvertString(bool invert)
        {
            return invert ? "INVert" : "NORMal";
        }
        #endregion

        #region Get command list for configuration
        private List<string> GetCommandList(string freq, string direction, string band, string invert)
        {
            return new List<string>
            {
                ":INSTrument:SELect LTEAFDD",
                "*OPC?",
                ":CONFigure:EVM",
                "*OPC?",
                ":INITiate:CONTinuous 1",
                ":FORMat:TRACe:DATA ASCii",
                $":SENSe:CCARrier:REFerence {freq}",
                $":SENSe:RADio:STANdard:DIRection {direction}",
                $":SENSe:RADio:STANdard:PRESet B{band}M",
                $":SENSe:CCARrier:SPECtrum {invert}",
                ":INITiate:CONTinuous 0",
                ":INITiate:EVM",
                "*OPC?"
            };
        }
        #endregion



        #region Validation for configuration values

        private bool Validate(string freq, string direction, string band, string invert)
        {
            return ValidateFrequency(freq) &&
                   ValidateDirection(direction) &&
                   ValidateBandwith(band) &&
                   ValidateInvert(invert);
        }
        private bool ValidateInvert(string invert)
        {
            Log.Info($"The expected value is: {invert}");
            return invert.StartsWith(WriteAndReadString(GetInvertCommand));
        }

        private bool ValidateBandwith(string band)
        {
            Log.Info($"The expected value is: B{band}M");
            return WriteAndReadString(GetBandwithCommand).Equals($"B{band}M");
        }

        private bool ValidateDirection(string direction)
        {
            Log.Info($"The expected value is: {direction}");
            return WriteAndReadString(GetDirectionCommand).Equals(direction);
        }

        private bool ValidateFrequency(string freq)
        {
            Log.Info($"The expected value is: {freq}");
            return double.Parse(WriteAndReadString(GetFrequencyCommand)).ToString().Equals(freq);
        }
        #endregion

        //TODO: validate
        #region Get EVM data and validate 

        public bool GetEvmAndValidate()
        {
            var evmData = GetEvmData();
            return ValidateEvm(evmData);
        }

        private List<string> GetEvmData()
        {
            return WriteAndReadStringList(GetEvmCommand);
        }

        private bool ValidateEvm(List<string> evmData)
        {
            try
            {
                foreach (EvmData index in (EvmData[])Enum.GetValues(typeof(EvmData)))
                {
                    double number = double.Parse(evmData[(int)index]);

                    if (index == EvmData.FreqError)
                    {
                        number /= 1000;
                    }

                    Log.Info($"The value of: {index.GetDescription()}, is: {number.ToString("0.000")}");
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return false;
            }
            return true;
        }
        #endregion

        private enum EvmData
        {
            [Description("EVM")]
            EVM = 0,
            [Description("EVM Data")]
            DataEVM = 5,
            [Description("Freq Error")]
            FreqError = 12,
            [Description("Channel Power")]
            ChannelPower = 29,
        }
    }
}