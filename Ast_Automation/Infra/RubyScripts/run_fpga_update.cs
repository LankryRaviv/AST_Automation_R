using System;
using System.Xml;
using Infra.Ruby;
using Infra.Settings;

namespace AST_Automation.Entrypoints
{
    public class RunFPGAUpdate
    {
        public static string Run(string micronIds, string path, string version)//micronIds="104,105,106", path to XXXXX, version="00.0010.03"
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(XmlSettings.XMLConfiguration);
            string pathToRubyScript = doc.GetElementsByTagName(XmlSettings.RubyScriptPathForFPGAUpload)[0].InnerText;
            RubyRunner runner = new RubyRunner();
            runner.RunCosmos(pathToRubyScript, out string response, micronIds, path, version);
            Console.WriteLine(response);
            return response;
        }
    }
}
