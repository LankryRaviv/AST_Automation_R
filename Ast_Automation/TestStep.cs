using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

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

        private string _status;

        public string Status
        {
            get { return _status; }
            set { _status = value; }
        }

        public static Dictionary<string, dynamic> GetJsonData(string file_path)
        {
            // var path = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\" + file_path;
            var jsonFileText = File.ReadAllText(file_path);
            return JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(jsonFileText);
        }

        public static ObservableCollection<TestStep> AllSteps(string path)
        {
            var steps = new ObservableCollection<TestStep>();
            Dictionary<string, dynamic> text = GetJsonData(path);

            int i = 1;
            foreach (KeyValuePair<string, dynamic> test_vals in text)
            {
                steps.Add(new TestStep() { Number = i++, Name = test_vals.Key, Status = "" }); ; 
            }

            return steps;
        }
    }

}
