using Infra.Ruby;
using System;
using System.IO;
using System.Reflection;
using static Infra.Logger.Logger;

namespace Infra.RubyScripts
{
    public class RunRubyScript
    {
        public static string Run(string rubyScriptPath, params string[] parameters)
        {
            return Run(rubyScriptPath, out _, parameters);
        }

        public static string Run(string rubyScriptPath, out RubyResponse rubyResponse, params string[] parameters)
        {
            try
            {
                string pathToRubyScript = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + rubyScriptPath;
                Log.Info($"[Ruby script path]: {pathToRubyScript},[Parameters]: {GetParametersString(parameters)}");
                RubyRunner runner = new RubyRunner();
                rubyResponse = runner.RunCosmos(pathToRubyScript, out string response, parameters);
                Log.Info($"*****************************************************");
                Log.Info($"Ruby script response: {response}");
                Log.Info($"*****************************************************");
                return response;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }

        private static string GetParametersString(params string[] parameters)
        {
            if (parameters.Length > 0)
            {
                var str = string.Join(",", parameters);
                return str;
            }
            return string.Empty;
        }
    }
}
