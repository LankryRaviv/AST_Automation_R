using System;
using System.Xml;
using Infra.Ruby;
using Infra.Settings;

namespace AST_Automation.Entrypoints
{
    public class RunGoldenFile
    {
        public static string Run(string micronIds, string imageLocationPath, string fileId, string fileDescriptorId, string imageType,
            string link , string broadcastAll, string reboot , string useAutomations)//micronIds="104,105,106", path to XXXXX, version="00.0010.03"
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(XmlSettings.XMLConfiguration);
            var path = doc.GetElementsByTagName("ruby_script_golden_file_path")[0].InnerText;
            string pathToRubyScript = path;
            RubyRunner runner = new RubyRunner();
            runner.RunCosmos(pathToRubyScript, out string response, micronIds, link, imageType, imageLocationPath,
                fileId, fileDescriptorId, broadcastAll, reboot, useAutomations);

            Console.WriteLine(response);
            return response;
        }
    }
}
