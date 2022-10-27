using NUnit.Framework;
using Infra.RubyScripts;
using AST_Automation.Steps;
using DataManagement.Jsons;
using Infra.Enums;
using System.Collections.Generic;
using Infra.Up_Down_Converter;
using Infra.UE;
using Infra.eNB;
using Infra.QV;
using Infra.SignalGenerator;
using Infra.PowerSupply;
using Infra.BPMS;
using Infra.Spectrum_Analyzers;
using DataManagement;
using System.IO;
using System.Reflection;
using System.Threading;
using Newtonsoft.Json.Linq;
using Infra.Digital_Attenuator;
using Infra.CPBF;
using Infra.ActionsRunner;
using Infra.Ruby;

namespace AST_Automation.Tests
{
    //TODO:Order Tests
    [TestFixture]
    public class E2ETest : TestBase
    {
        #region Test Equipments
        private TcpPowerSupply _tcpPowerSupply;
        private SerialPowerSupply _serialPowerSupply;
        private SignalGenerator _signalGenerator;
        private SignalGenerator _localSignalGenerator;
        private QV _qv;
        private eNB _eNB;
        private UE _ue;
        private Converter _upConverter;
        private Converter _downConverter;
        private Spectrum _spectrum;
        private List<string> _micronList;
        private DigitalAttenuator digitalAttenuator;
        private CPBF _cpbf;
        private BPMS _bpms;
        #endregion

        #region Steps
        private readonly MainBoardSteps _mainBoardSteps;
        private readonly QVSteps _qvSteps;
        private readonly CPBF_Steps _cpbfSteps;
        private readonly PowerSupplySteps _powerSupplySteps;
        private readonly SignalGeneratorSteps _signalGeneratorSteps;
        private readonly SpectrumAnalyzerSteps _spectrumAnalyzerSteps;
        private readonly BPMS_Steps _bpms_Steps;
        private readonly UE_Steps _uE_Steps;
        private readonly eNB_Steps _eNB_Steps;
        private readonly ConverterSteps _converterSteps;
        private readonly DigitalAttenuatorSteps _digitalAttenuatorSteps;
        #endregion

        public E2ETest() : base(JsonsEnum.E2ETest)
        {
            _mainBoardSteps = new MainBoardSteps();
            _qvSteps = new QVSteps();
            _powerSupplySteps = new PowerSupplySteps();
            _cpbfSteps = new CPBF_Steps();
            _signalGeneratorSteps = new SignalGeneratorSteps();
            _spectrumAnalyzerSteps = new SpectrumAnalyzerSteps();
            _uE_Steps = new UE_Steps();
            _eNB_Steps = new eNB_Steps();
            _bpms_Steps = new BPMS_Steps();
            _converterSteps = new ConverterSteps();
            _digitalAttenuatorSteps = new DigitalAttenuatorSteps();
        }

        [Test, Order(1)]
        [Description("Config Signal Generator")]
        public void SignalGeneratorTest()
        {
            Assert.IsTrue(_signalGeneratorSteps.InitSignalGenerator(ref _signalGenerator, _testData["SignalGenerator"]["IP"].ToString()));
            Assert.IsTrue(_signalGeneratorSteps.ConfigSignalGenerator(_signalGenerator, _testData));
        }

        [Test, Order(2)]
        [Description("Config Main Board")]
        public void MainBoardTest()
        {
            Assert.IsTrue(_mainBoardSteps.InitMainBoard(_testData["MainBoard"]["ComPort"].ToString()));
            Assert.IsTrue(_mainBoardSteps.SetMainBoardPowerModePS2());
            Assert.IsTrue(_mainBoardSteps.ChangeMicronId(GetMicronList()[0]));
            //TODO:make that value read from somewhere
            //Assert.IsTrue(_cpbfSteps.SendSingleCommandToCPBF("baudrate=2"));
            var path = base.GetRubyScriptPath(RubyScriptsKeys.ConfigFpgaFreq.GetDescription());
            //TODO:Make ruby script and assert
            var cosmosResult = JsonFileParser.GetDictionary(RunRubyScript.Run(path, dataManager.GetPathToDataFile(JsonsEnum.E2ETest.ToString())));
            //TODO: make ruby that validate freq and band and time 
            Assert.IsTrue(_mainBoardSteps.SetMainBoardPowerModeOperational());
        }

        [Test, Order(3)]
        [Description("Config Spectrum Analyzer")]
        public void SpectrumAnalyzerTest()
        {
            Assert.IsTrue(_spectrumAnalyzerSteps.ConfigSpectrumAndValidate(_testData, ref _spectrum));
            Assert.IsTrue(_spectrumAnalyzerSteps.GetEvmDataAndValidate(_spectrum));
            Assert.IsTrue(_spectrumAnalyzerSteps.CloseConnection(_spectrum));
        }

        [Test, Order(4)]
        [Description("Config CPBF")]
        public void CPBF_Test()
        {
            Assert.IsTrue(_cpbfSteps.OpenConnection(ref _cpbf, _testData["CPBF"]));
            Assert.IsTrue(_cpbfSteps.ConfigCPBF(_cpbf, _testData["CPBF"]["Commands"]));
            Assert.IsTrue(_cpbfSteps.ReadLogAndValidate(_cpbf, _testData["CPBF"]["Commands"]));
        }

        [Test, Order(5)]
        [Description("Config QV")]
        public void QVTest()
        {
            Assert.IsTrue(_powerSupplySteps.OpenSocket(ref _tcpPowerSupply, _testData));
            Assert.IsTrue(_powerSupplySteps.OpenSerialConnection(ref _serialPowerSupply, _testData));
            Assert.IsTrue(_powerSupplySteps.ChangeChannelVoltage(_tcpPowerSupply, Channels.Channel2, (double)_testData["PowerSupply"]["TcpPsVoltages"][((int)Channels.Channel2) - 1]));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel2, true));
            Assert.IsTrue(_powerSupplySteps.ChangeChannelVoltage(_tcpPowerSupply, Channels.Channel1, (double)_testData["PowerSupply"]["TcpPsVoltages"][((int)Channels.Channel1) - 1]));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel1, true));
            string comPort = _testData["QV"]["ComPort"].ToString();
            string configFilePath = _testData["QV"]["ConfigFilePath"].ToString();
            Assert.IsTrue(_qvSteps.OpenPort(ref _qv, comPort));
            //Put sleep in infra check that
            //Thread.Sleep(5000);
            Assert.IsTrue(_powerSupplySteps.CurrentValidation(_tcpPowerSupply, Channels.Channel2, 0.68));
            Assert.IsTrue(_powerSupplySteps.CurrentValidation(_tcpPowerSupply, Channels.Channel1, 2.33));
            Assert.IsTrue(_qvSteps.ConfigQV(_qv, configFilePath));
            //Put sleep in infra check that
            //Thread.Sleep(5000);
            Assert.IsTrue(_powerSupplySteps.CurrentValidation(_tcpPowerSupply, Channels.Channel2, 2.1));
            Assert.IsTrue(_powerSupplySteps.CurrentValidation(_tcpPowerSupply, Channels.Channel1, 2.6));
            Assert.IsTrue(_qvSteps.ValidateAllLocked(ref _qv));
            Assert.IsTrue(_powerSupplySteps.ChangeChannelVoltage(_serialPowerSupply, Channels.Channel1, (double)_testData["PowerSupply"]["SerialVoltages"][((int)Channels.Channel1) - 1]));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_serialPowerSupply, 0, true));
            Assert.IsTrue(_powerSupplySteps.ChangeChannelVoltage(_tcpPowerSupply, Channels.Channel4, (double)_testData["PowerSupply"]["TcpPsVoltages"][((int)Channels.Channel4) - 1]));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel4, true));
            Assert.IsTrue(_powerSupplySteps.CurrentValidation(_tcpPowerSupply, Channels.Channel4, 0.11));
            Assert.IsTrue(_powerSupplySteps.ChangeChannelVoltage(_tcpPowerSupply, Channels.Channel3, (double)_testData["PowerSupply"]["TcpPsVoltages"][((int)Channels.Channel3) - 1]));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel3, true));
            Assert.IsTrue(_powerSupplySteps.CurrentValidation(_tcpPowerSupply, Channels.Channel3, 0.0011));
            Assert.IsTrue(_powerSupplySteps.CloseSerialConnection(_serialPowerSupply));
            Assert.IsTrue(_powerSupplySteps.CloseTcpConnection(_tcpPowerSupply));
        }

        [Test, Order(6)]
        [Description("Config UE")]
        public void UE_Test()
        {
            Assert.IsTrue(_uE_Steps.OpenAndConfigUE(ref _ue, _testData));
        }

        [Test, Order(7)]
        [Description("Config eNB")]
        public void eNB_Test()
        {
            Assert.IsTrue(_eNB_Steps.OpenAndConfig_eNB(ref _eNB, _testData));
        }

        [Test, Order(8)]
        [Description("Config BPMS")]
        public void BPMS_Test()
        {
            Assert.IsTrue(_bpms_Steps.InitBPMS_ComportAndStartApplication(ref _bpms, _testData["BPMS"]));
            Assert.IsTrue(_bpms_Steps.SendCommands(_bpms, _testData["BPMS"]["FirstTcpPortCommands"], BPMS.Ports.FirstTcpPort));
            Assert.IsTrue(_bpms_Steps.SendCommands(_bpms, _testData["BPMS"]["SecondTcpPortCommands"], BPMS.Ports.SecondTcpPort));
            _bpms.CloseBPMS_Application();
        }

        [Test, Order(9)]
        [Description("Config Up/Down Converter")]
        public void ConverterTest()
        {
            Assert.IsTrue(_signalGeneratorSteps.InitSignalGenerator(ref _localSignalGenerator, _testData["LocalSignalGenerator"]["IP"].ToString()));
            var frequency = _signalGeneratorSteps.GetSignalGeneratorFrequency(_localSignalGenerator) / 1000;
            ConvertersConfig(ref _upConverter, _testData["UpConverter"], frequency);
            ConvertersConfig(ref _downConverter, _testData["DownConverter"], frequency);
        }

        [Test, Order(9999)]
        [Description("Debug")]
        public void Debug() //For debuging
        {

            var x = GetTestsData.GetSuites(); 
            var y = GetTestsData.GetSuitesTests("E2ETest");
            y = GetTestsData.GetSuitesTests("CPURegTest");
            y = GetTestsData.GetSuitesTests("PowerGoodsTest");
            ///-----------------------------------------------------------------------//
            //Get all file/folders from test folder - not include files in subfolders
            var filePaths = Directory.GetFileSystemEntries(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\Jsons\\Tests");

            //list of file names without extension to show in gui
            List<string> nameOfTestsForUI = new List<string>();

            for (int i = 0; i < filePaths.Length; i++)
            {
                var testName = string.Empty;

                if (Path.GetExtension(filePaths[i]).Length > 0) //if file have extension - .json,.csv,etc...
                {
                    testName = Path.GetFileName(filePaths[i]).Replace(Path.GetExtension(filePaths[i]), "");
                }
                else // else the file is folder
                {
                    testName = Path.GetFileName(filePaths[i]);
                }

                ///add test name list
                nameOfTestsForUI.Add(testName);
            }

            //init all devices in setup from json..
            TestSetup.InitSetup(JsonsEnum.Setup);

            //this method will parse json file or folder with jsons file to one list(order of file is needed to be 1_xxx 2_xxx in the file name
            var stepsList = JsonTestsParserToSteps.GetStepsList(filePaths[0]);

            //create new test class with the step list and devices dictionary
            var test = new TestExecutor(stepsList, TestSetup.GetDevicesDictionary());

            //run test 
            test.RunTest();
        }

        [Test, Order(10)]
        [Description("Config Digital Attenuator")]
        public void DigitalAttenuatorTest()
        {
            Assert.IsTrue(_digitalAttenuatorSteps.OpenConnection(ref digitalAttenuator, _testData["DigitalAttenuator"]["ComPort"].ToString()));
            Assert.IsTrue(_digitalAttenuatorSteps.ConfigDigitalAttenuator(digitalAttenuator, _testData["DigitalAttenuator"]["Values"]));
            Assert.IsTrue(_digitalAttenuatorSteps.CloseConnection(digitalAttenuator));
        }

        [Test, Order(11)]
        [Description("Close Power Supplies")]
        public void ClosePowerSupply()
        {
            Assert.IsTrue(_powerSupplySteps.OpenSocket(ref _tcpPowerSupply, _testData));
            Assert.IsTrue(_powerSupplySteps.OpenSerialConnection(ref _serialPowerSupply, _testData));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel3, false));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel4, false));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_serialPowerSupply, 0, false));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel1, false));
            Assert.IsTrue(_powerSupplySteps.ChangePowerSupplyState(_tcpPowerSupply, Channels.Channel2, false));
            Assert.IsTrue(_powerSupplySteps.CloseSerialConnection(_serialPowerSupply));
            Assert.IsTrue(_powerSupplySteps.CloseTcpConnection(_tcpPowerSupply));
        }

        [Test, Order(12)]
        [Description("Close Up/Down Converters Output")]
        public void CloseConveterOutput()
        {
            CloseConvertersOutput(ref _upConverter, _testData["UpConverter"]);
            CloseConvertersOutput(ref _downConverter, _testData["DownConverter"]);
        }

        private void ConvertersConfig(ref Converter converter, JObject testData, double signalGeneratorFrequency)
        {
            Assert.IsTrue(_converterSteps.OpenConnection(ref converter, testData));
            Assert.IsTrue(_converterSteps.SelectBand(converter));
            Assert.IsTrue(_converterSteps.TurnOutputOn(converter));
            Assert.IsTrue(_converterSteps.SumLOs(converter, signalGeneratorFrequency));
            Assert.IsTrue(_converterSteps.CloseConnection(converter));
        }

        private void CloseConvertersOutput(ref Converter converter, JObject testData)
        {
            Assert.IsTrue(_converterSteps.OpenConnection(ref converter, testData));
            Assert.IsTrue(_converterSteps.TurnOutputOff(converter));
        }
    }
}
