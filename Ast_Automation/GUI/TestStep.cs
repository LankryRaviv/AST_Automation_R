using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using DataManagement;
using System.Linq;

namespace GUI
{
    public class TestStep
    {
        private int _number;

        public int Number
        {
            get { return _number; }
            set { _number = value; }
        }

        private string _name;

        public string Name
        {
            get { return _name; }
            set { _name = value; }
        }

        private string _device;

        public string Device
        {
            get { return _device; }
            set { _device = value; }
        }

        private string _remote;

        public string Remote
        {
            get { return _remote; }
            set { _remote = value; }
        }
       
        private string _parameters;

        public string Parameters
        {
            get { return _parameters; }
            set { _parameters = value; }
        }

        private string _status;

        public string Status
        {
            get { return _status; }
            set { _status = value; }
        }

        public static Dictionary<string, dynamic> GetJsonData(string file_path)
        {
            var jsonFileText = File.ReadAllText(file_path);
            return JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(jsonFileText);
        }

        public static ObservableCollection<TestStep> AllSteps(string path)
        {
            var steps = new ObservableCollection<TestStep>();
            Dictionary<string, dynamic> text = GetJsonData(path);
            
            var step_name = "";
            var device = "";
            var remote = "";
            var parameters = new List<string>();
            var paramsStr = "";

            int i = 1;
            foreach (KeyValuePair<string, dynamic> vals in text)
            {
                step_name = "";
                device = "";
                remote = "";
                parameters.Clear();

                foreach (JProperty specs in vals.Value)
                {
                    switch (specs.Name)
                    {
                        case "Step_Name":
                            step_name = (string)specs.First;
                            break;
                        case "Device":
                            device = (string)specs.First;
                            break;
                        case "Remote":
                            remote = (string)specs.First;
                            break;
                        case "Parameters":
                            foreach (string elem in specs.First)
                            {
                                parameters.Add(elem);
                            }
                            paramsStr = string.Join(",", parameters);
                            break;
                        default:
                            break;
                    }
                }
                
                steps.Add(new TestStep() { 
                    Number = i++, 
                    Name = step_name, 
                    Device = device, 
                    Remote = remote, 
                    Parameters = paramsStr, 
                    Status = "" });
            }

            return steps;
        }
    }

}
