using IntegratiCoInfrastructure.Windows;
using System;
using System.Diagnostics;


namespace Infra.Ruby
{
    public class Ruby
    {
        static string rubyRunner = "";
        static public string GetRubyExe()
        {
            string[] data = Environment.GetEnvironmentVariable("Path", EnvironmentVariableTarget.Machine).Split(';');

            string rubyEx = @"C:\Ruby31-x64\bin\ruby.exe";
            for (int n = 0; n < data.Length; n++)
            {
                if (data[n].Contains("Ruby"))
                {
                    rubyEx = data[n] + "\\ruby.exe";
                    break;
                }
            }

            return rubyEx;
        }

        public static Boolean RunRubyScript(string arguments, out string reply, Boolean waitForExit = true, Boolean killProcessAfterFinished = false)
        {
            reply = "";
            try
            {
                if (rubyRunner == "") rubyRunner = GetRubyExe();

                using (var proc = new Process())
                {
                    var startInfo = new ProcessStartInfo(rubyRunner);
                    startInfo.Arguments = arguments;
                    startInfo.RedirectStandardOutput = true;
                    startInfo.RedirectStandardError = true;
                    startInfo.UseShellExecute = false;
                    startInfo.CreateNoWindow = false;

                    proc.StartInfo = startInfo;
                    proc.Start();
                    if (waitForExit)
                    {
                        proc.WaitForExit();
                        reply = proc.StandardOutput.ReadToEnd();
                    }

                    if (killProcessAfterFinished)
                    {
                        proc.Kill();

                    }
                    return true;
                }
            }
            catch { }
            reply = "";
            return false;
        }


        public static Boolean RunRubyScript(string arguments, string terminationString, out string reply)
        {
            try
            {
                if (rubyRunner == "") rubyRunner = GetRubyExe();

                using (var proc = new Process())
                {
                    var startInfo = new ProcessStartInfo(rubyRunner);
                    startInfo.Arguments = arguments;
                    startInfo.RedirectStandardOutput = true;
                    //startInfo.RedirectStandardError = true;

                    startInfo.UseShellExecute = false;
                    startInfo.CreateNoWindow = false;

                    proc.StartInfo = startInfo;
                    proc.Start();
                    reply = "";
                    while ((!proc.HasExited) && (!reply.Contains(terminationString)))
                    {
                        reply += (char)proc.StandardOutput.Read();
                    }

                    //Thread.Sleep(1000); // wait for logs to be flushed
                    //reply += proc.StandardOutput.ReadToEnd();
                    reply = reply.Replace(terminationString, "").Trim();
                    proc.Kill();

                    return true;
                }
            }
            catch (Exception e)
            {
            }
            reply = "";
            return false;

        }

        public static void KillRubyProcess()
        {
            WindowsProcess[] processes = WindowsProcesses.FindProcessByName("ruby");
            for (int o = 0; o < processes.Length; o++)
            {
                processes[o].Kill();
            }
        }
    }
}
