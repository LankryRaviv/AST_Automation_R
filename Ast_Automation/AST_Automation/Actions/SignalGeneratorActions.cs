using System;
using System.Collections.Generic;
using Infra.SignalGenerator;
using static Infra.Logger.Logger;

namespace AST_Automation.Actions
{
    public class SignalGeneratorActions
    {
        public bool ConfigSignalGenerator(SignalGenerator signalGenerator, Dictionary<string, dynamic> testData)
        {
            try
            {
                bool isUlTest = (bool)testData["IsUlTest"];
                return isUlTest ? ConfigurationForUlTest(signalGenerator,testData) : ConfigurationForDlTest(signalGenerator,testData);
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }

        private bool ConfigurationForUlTest(SignalGenerator signalGenerator, Dictionary<string, dynamic> testData)
        {
            Log.Info("Config SignalGenerator For UL Test");
            try
            {
                double freq = (double)testData["SignalGenerator"]["UL_Freq"];
                double level = (double)testData["SignalGenerator"]["UL_dB"];
                string waveFormFile = testData["SignalGenerator"]["UL_QAM"].ToString();
                return Config(signalGenerator,freq, level, waveFormFile);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }            
        }

        private bool ConfigurationForDlTest(SignalGenerator signalGenerator, Dictionary<string, dynamic> testData)
        {
            Log.Info("Config SignalGenerator For DL Test");
            try
            {
                double freq = (double)testData["SignalGenerator"]["DL_Freq"];
                double level = (double)testData["SignalGenerator"]["DL_dB"];
                string waveFormFile = testData["SignalGenerator"]["DL_QAM"].ToString();
                return Config(signalGenerator, freq, level, waveFormFile);
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw;
            }        
        }

        private bool Config(SignalGenerator signalGenerator,double freq, double level, string waveFormFile)
        {
            try
            {
                var keysight_MXG = signalGenerator.GetSignalGenerator();
                keysight_MXG.RFGenerator.SetFrequency(freq);
                Log.Info($"Set SignalGenerator Freq: {freq}");
                keysight_MXG.RFGenerator.SetLevel(level);
                Log.Info($"Set SignalGenerator Amplitude: {level}");
                keysight_MXG.Arbitrary.LoadWaveform(waveFormFile);
                Log.Info($"Set SignalGenerator WaveForm: {waveFormFile}");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return false;
            }
            return Validate(signalGenerator,freq, level,waveFormFile);
        }

        private bool Validate(SignalGenerator signalGenerator, double freq, double level, string waveFormFile)
        {
            try
            {
                Log.Info("Validate SignalGenerator configuration");
                var keysight_MXG = signalGenerator.GetSignalGenerator();
                double actualFreq = keysight_MXG.RFGenerator.GetFrequency();
                Log.Info($"Expected freq: {freq}, Actual Value: {actualFreq}");
                var actualLevel = keysight_MXG.RFGenerator.GetLevel();
                Log.Info($"Expected amplitude: {level}, Actual Value: {actualLevel}");
                string actualWaveFormFile = keysight_MXG.RFGenerator.GetModulation();
                Log.Info($"Expected wave form file: {waveFormFile}, Actual Value: {actualWaveFormFile}");
                return actualFreq == freq && actualLevel == level && actualWaveFormFile.Contains(waveFormFile);
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw;
            }   
        }

        public bool InitSignalGenerator(ref SignalGenerator signalGenerator ,string ip)
        {
            signalGenerator = new SignalGenerator(ip);
            return signalGenerator.InitSignalGenerator();
        }

        public double GetFrequency(SignalGenerator signalGenerator)
        {
            var keysight_MXG = signalGenerator.GetSignalGenerator();
            return keysight_MXG.RFGenerator.GetFrequency();
        }
    }
}
