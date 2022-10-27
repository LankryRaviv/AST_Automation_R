using System;
using System.Diagnostics;
using System.Collections;
using static Infra.Logger.Logger;

namespace Infra.Ruby
{
    public class RubyRunner
    {
        //LAB15
        //private static string defaultCosmosScriptRunner = @"C:\Users\labuser15\Documents\cosmos\COSMOS-CONF\cosmos-local\tools\ScriptRunner";
        
        //LAB27
        //private static string defaultCosmosScriptRunner = @"C:\Users\labuser27\Documents\cosmos\COSMOS-CONF\cosmos-local\tools\ScriptRunner";
        
        //Regular
        private static string defaultCosmosScriptRunner = @"C:\cosmos\COSMOS-CONF\cosmos-local\tools\ScriptRunner";
        private string pathScriptRunner = $"{defaultCosmosScriptRunner} --defaultsize -r ";
        private bool RunRubyUsingCosmos = true;

        public void SetRunRubyScriptOnly()
        {
            RunRubyUsingCosmos = false;
        }

        //@parameters: the parameters provided should not include any spaces
        public RubyResponse RunCosmos(string pathToRubyFile, out string response, params string[] parameters)
        {
            RubyResponse responseObj = new RubyResponse();
            response = "";
            string tempResponse = "";

            string arguments = RunRubyUsingCosmos? (pathScriptRunner + pathToRubyFile): pathToRubyFile;

            if (parameters != null && parameters.Length > 0)
            {
                foreach (string p in parameters)
                {
                    arguments += " " + p;
                }
            }

            Log.Info(arguments);

            try
            {

                using (var proc = new Process())
                {
                    var startInfo = new ProcessStartInfo(GetRubyExe());
                    startInfo.Arguments = arguments;
                    startInfo.RedirectStandardOutput = true;
                    startInfo.RedirectStandardError = true;
                    startInfo.UseShellExecute = false;
                    startInfo.CreateNoWindow = true;


                    proc.StartInfo = startInfo;
                    proc.Start();

                    proc.OutputDataReceived += new DataReceivedEventHandler((sender, e) =>
                    {
                        if (!String.IsNullOrEmpty(e.Data))
                        {
                            responseObj.Add(e.Data);
                            Log.Info(e.Data);
                            if (e.Data.StartsWith("RESPONSE="))
                            {
                                tempResponse = e.Data.Substring(9);
                            }
                        }

                        //Console.WriteLine($"data received: {e.Data}");
                    });

                    proc.ErrorDataReceived += new DataReceivedEventHandler((sender, e) =>
                    {
                        if (!String.IsNullOrEmpty(e.Data))
                        {
                            responseObj.AddError(e.Data);
                            Log.Error(e.Data);
                            if (e.Data.StartsWith("RESPONSE="))
                            {
                                tempResponse = e.Data.Substring(9);
                            }
                        }

                        //Console.WriteLine($"error received: {e.Data}");
                    }
                    );

                    proc.BeginOutputReadLine();
                    proc.BeginErrorReadLine();
                    proc.WaitForExit();

                    proc.Close();
                    responseObj.ResponseStatus = true;
                    int numValidResponses = responseObj.getResponses().Length;
                    //response = !String.IsNullOrEmpty(tempResponse) ? tempResponse : numValidResponses > 0 ? responseObj.getResponses()[numValidResponses-1] : "" ;
                    response = tempResponse;
                    return responseObj;
                }
            }
            catch (Exception e)
            {
                responseObj.ResponseStatus = false;
                responseObj.AddError($"Process threw exception: {e.Message}");
            }

            return responseObj;
        }


        private string GetRubyExe()
        {
            string[] dataGlobal = Environment.GetEnvironmentVariable("Path", EnvironmentVariableTarget.Machine).Split(';');
            string[] dataUser = Environment.GetEnvironmentVariable("Path", EnvironmentVariableTarget.User).Split(';');

            return GetPath(dataGlobal) != null ? GetPath(dataGlobal) : GetPath(dataUser) != null ? GetPath(dataUser) : @"C:\Ruby25-x64\bin\ruby.exe";

        }

        private string GetPath(string[] data)
        {
            for (int n = 0; n < data.Length; n++)
            {
                if (data[n].ToLower().Contains("ruby"))
                {
                    return data[n] + "\\ruby.exe";
                }
            }
            return null;
        }

    }
}



