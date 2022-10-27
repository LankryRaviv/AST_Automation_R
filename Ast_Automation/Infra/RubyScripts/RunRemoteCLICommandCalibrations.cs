using System;
using System.Xml;
using Infra.Ruby;
using Infra.Settings;

namespace AST_Automation.Entrypoints
{
    public class RunRemoteCLICommandCalibrations
    {
        public static string Run(string board,string micronId, string packetDelay, string pathForCLICalbirationsCommands ,string messegeCompleted = "COMPLETED", string pathToRubyScript=null)//micronIds="104,105,106", path to XXXXX, version="00.0010.03"
        {
            RubyRunner runner = new RubyRunner();
            runner.RunCosmos(pathToRubyScript, out string response, board, micronId, packetDelay, pathForCLICalbirationsCommands, messegeCompleted);
            return response;
        }
    }
}
