using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace Infra.Cosmos
{
    public class GenericScript
    {
        string content = "";
        public GenericScript(string fileName)
        {
            using(StreamReader sr = new StreamReader(fileName))
            {
                content = sr.ReadToEnd();
                sr.Close();
            }
        }

        public void Modify(string tag,string value)
        {
            content= content.Replace("<"+tag+">",value);
        }

        public void SaveAs(string fileName)
        {
            using(StreamWriter sw = new StreamWriter(fileName))
            {
                sw.Write(content);
                sw.Close();
            }
        }

        public string[] GetLines()
        {
            return content.Split('\n');
        }
    }
}
