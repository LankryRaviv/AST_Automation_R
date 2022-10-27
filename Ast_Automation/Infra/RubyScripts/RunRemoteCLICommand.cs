using System;
using System.Xml;
using Infra.Ruby;
using Infra.Settings;
using static Infra.Logger.Logger;

namespace AST_Automation.Entrypoints
{
    public class RunRemoteCLICommand 
    {
        public static string Run(string board,string micronId, string packetDelay, string inputData, string messegeCompleted = "COMPLETED" )//micronIds="104,105,106", path to XXXXX, version="00.0010.03"
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(XmlSettings.XMLConfiguration);
            string pathToRubyScript = doc.GetElementsByTagName(XmlSettings.PathForRemoteCLI)[0].InnerText;
            Log.Info($"[Ruby script path]: {pathToRubyScript},[Parameters]: Board: {board}, Micron Id: {micronId}, Packet Dealy {packetDelay}, Input Data: {inputData}," +
                $"Messege: {messegeCompleted} ");
            RubyRunner runner = new RubyRunner();
            runner.RunCosmos(pathToRubyScript, out string response, board, micronId, packetDelay, inputData, messegeCompleted);

            Console.WriteLine(response);
            return response;
        }
    }
}
