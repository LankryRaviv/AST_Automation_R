using DataManagement;
using DataManagement.Jsons;
using Infra.PowerSupply;
using Infra.QV;
using Infra.Ruby;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using Infra.ActionsRunner;
using AST_Automation.Tests;

namespace AST_Automation
{
    public static class TestSetup
    {
        private static Dictionary<string, object> SetupDevices;
        private static QV _qv;
        private static TcpPowerSupply _tcpPowerSupply;
        private static SerialPowerSupply _serialPowerSupply;
        private static RubyRunner _rubyRunner;
        private static CPURegTest _cpuRegTest;

        public static void InitSetup(JsonsEnum setupEnum)
        {
            SetupDevices = new Dictionary<string, object>();
            var setupData = JsonFileParser.GetDictionary(setupEnum);
            var keys = setupData.Keys;

            foreach (var key in keys)
            {
                var initParameters = GetInitParametersList(setupData[key]);
                InitTestEquipment(key.ToString(), initParameters);
            }
        }

        private static void InitTestEquipment(string objectName, List<object> initParameters)
        {
            switch (objectName)
            {
                case "QV":
                    {
                        _qv = InitGenericObject(ref _qv, initParameters);
                        AddDeviceToDictionary(objectName, _qv);
                        break;
                    }

                case "TcpPowerSupply":
                    {
                        _tcpPowerSupply = InitGenericObject(ref _tcpPowerSupply, initParameters);
                        AddDeviceToDictionary(objectName, _tcpPowerSupply);
                        break;
                    }

                case "SerialPowerSupply":
                    {
                        _serialPowerSupply = InitGenericObject(ref _serialPowerSupply, initParameters);
                        AddDeviceToDictionary(objectName, _serialPowerSupply);
                        break;
                    }
                case "Cosmos":
                    {
                        _rubyRunner = new RubyRunner();
                        AddDeviceToDictionary(objectName, _rubyRunner);
                        break;
                    }    
                case "CPURegTest":
                    {
                        _cpuRegTest = new CPURegTest();
                        _cpuRegTest.OneTimeSetupCPUReg();
                        AddDeviceToDictionary(objectName, _cpuRegTest);
                        break;
                    }
            }
        }

        private static T InitGenericObject<T>(ref T t, List<object> initParameters)
        {
            if (initParameters == null)
            {
                initParameters = new List<object>();
            }

            return (T)Activator.CreateInstance(typeof(T), initParameters);
        }

        private static List<object> GetInitParametersList(JObject keyValues)
        {
            return (List<object>)Activator.CreateInstance(typeof(List<object>), keyValues.Values());
        }

        private static void AddDeviceToDictionary(string deviceName, object device)
        {
            SetupDevices.Add(deviceName, device);
        }

        public static Dictionary<string, object> GetDevicesDictionary()
        {
            return SetupDevices;
        }
    }
}
