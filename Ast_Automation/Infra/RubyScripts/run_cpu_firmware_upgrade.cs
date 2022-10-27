using Infra.Ruby;
using Infra.Settings;
using System;
using System.Xml;

namespace AST_Automation.Entrypoints
{
    public class RunCPUFirmwareUpgrade  
    {
        public static string Run(string micronIds) //@micronIds: separate ids by comma eg "104,105,106"
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(XmlSettings.XMLConfiguration);
            string pathToRubyScript = doc.GetElementsByTagName(XmlSettings.RubyScriptPathForCPUUpload)[0].InnerText;


            RubyRunner runner = new RubyRunner();
            runner.RunCosmos(pathToRubyScript, out string response, micronIds);

            Console.WriteLine(response);
            return response;
        }
    }
}
