using Infra.Ruby;
using Infra.Settings;
using System;
using System.IO;
using System.Reflection;
using System.Xml;

namespace AST_Automation.Entrypoints
{
    public class RunFPGAFreqConfig
    {
        public static string Run(string micronIds) //@micronIds: separate ids by comma eg "104,105,106"
        {
            string pathToRubyScript = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            XmlDocument doc = new XmlDocument();
            doc.Load(XmlSettings.XMLConfiguration);
             pathToRubyScript += doc.GetElementsByTagName(XmlSettings.RubyScriptPathForConfigFPGAFreqTest)[0].InnerText;
            RubyRunner runner = new RubyRunner();
            runner.RunCosmos(pathToRubyScript, out string response, micronIds);

            Console.WriteLine(response);
            return response;
        }
    }
}
