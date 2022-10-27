using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AST_Automation
{
    public class Step
    {
        public Step(string step_Name, string device, string remote, List<object> parameters)
        {
            Step_Name = step_Name;
            Device = device;
            Remote = remote;
            Parameters = parameters;
        }

        public string Step_Name { get; set; }
        public string Device { get; set; }
        public string Remote { get; set; }
        public List<object> Parameters { get; set; }
    }
}
