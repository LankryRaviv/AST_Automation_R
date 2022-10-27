using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infra.Ruby
{
    public class RubyResponse
    {
        private List<string> List = new List<string>();
        private List<string> ErrorList = new List<string>();
        public bool ResponseStatus
        {
            get; set; 
        }
                
        public string[] getResponses()
        {
            return List.ToArray();
        }

        public void Add(string response)
        {
            List.Add(response);
        }

        public string[] getErrors()
        {
            return ErrorList.ToArray();
        }

        public void AddError(string response)
        {
            ErrorList.Add(response);
        }

    }
}
