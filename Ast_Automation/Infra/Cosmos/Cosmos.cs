using System;
using System.IO;
using Infra.Ruby;

//TODO: clean code
namespace Infra.Cosmos
{
    public class Cosmos
    {
        static string defaultCostmosScriptRunner = @"C:\Cosmos\COSMOS-CONF\cosmos-local\tools\Scriptrunner";
        static string defaultTlmServer = @"C:\Cosmos\COSMOS-CONF\cosmos-local\tools\CmdTlmServer";
        static string defaultLogPath = @"C:\Cosmos\COSMOS-CONF\cosmos-local\outputs\logs";
        static string terminationString = "EndOfProgram";
        public enum TOOL
        {
            TLM_SERVER
        };
        /*
            There are few ways to pass info from Cosmos script to c#

            Print to Standard output
            STDOUT.write 'text'

            Second is to capture Log file C:\Cosmos\COSMOS-CONF\cosmos-local\outputs\logs
            
            To terminate the running script
            1. Add exit! to the script end, it will terminate immediately and no guaranty that all data will be flushed to log
            2. Use injected "Termination string" to Ruby code, and monitor the console output,
                if termination string identified, abort the script.
         
         
         */

        private static string[] display = new string[] { "--minimized", "--maximized", "--defaultsize", " --stay-on-top" };
        public enum DISPLAY_OPTION
        {
            MINIMIZED,
            MAXIMIZED,
            DEFAULT,
            STAY_ON_TOP
//--minimized                  Start the tool minimized
//--maximized                  Start the tool maximized
//--defaultsize                Start the tool in its default size
//--stay-on-top                Force the tool to stay on top of all other windows
        };

        public static DISPLAY_OPTION DisplayOption = DISPLAY_OPTION.MINIMIZED;

        public static void Start(TOOL tool)
        {
            string reply;
            switch(tool)
            {
                case TOOL.TLM_SERVER:
                    Ruby.Ruby.RunRubyScript(defaultTlmServer, out reply,false);
                    break;
            }
        }

        public static Boolean RunCosmosScriptForcedTermination(string fileName, out string consoleOutput  )
        {

            string termination = $"exit;";

            using (StreamReader rd = new StreamReader(fileName))
            {
                string text = rd.ReadToEnd();
                if (!text.Contains(termination))
                {
                    text += termination;
                }
                rd.Close();
                using (StreamWriter sw = new StreamWriter(fileName))
                {
                    sw.WriteLine(text);
                    sw.Close();
                }
            }

            

            Boolean status = Ruby.Ruby.RunRubyScript($"{defaultCostmosScriptRunner} {display[(int)DisplayOption]} -r {fileName}",  out consoleOutput);


           return (consoleOutput!="")&& status;
      
        }

        //ruby -r "./test.rb" -e "TestClass.test_function 'hi'"

        //public static Boolean RunCosmosFunction(string fileName, string arguments,  out string consoleOutput, out string cosmoseReply  )
        //{

        //    string termination = $"\nSTDOUT.write '{terminationString}\\n\\n'";

        //    using (StreamReader rd = new StreamReader(fileName))
        //    {
        //        string text = rd.ReadToEnd();
        //        if (!text.Contains(terminationString))
        //        {
        //            text += termination;
        //        }
        //        rd.Close();
        //        using (StreamWriter sw = new StreamWriter(fileName))
        //        {
        //            sw.WriteLine(text);
        //            sw.Close();
        //        }
        //    }

        //    string[] files1 = Directory.GetFiles(defaultLogPath, "*sr_Test_messages.txt");
        //    //Boolean status = Ruby.RunRubiScript($"{defaultCostmosScriptRunner} {display[(int)DisplayOption]} -r {fileName} -e {arguments}", terminationString, out consoleOutput);
        //    Boolean status = Ruby.RunRubiScript($"{defaultCostmosScriptRunner} -r required {fileName} -e {arguments}", terminationString, out consoleOutput);
        //    string[] files2 = Directory.GetFiles(defaultLogPath, "*sr_Test_messages.txt");


        //    string[] result = files2.Except(files1).ToArray();

        //    cosmoseReply = "";
        //    if (result != null)
        //    {
        //        for (int n = 0; n < result.Length; n++)
        //        {
        //            using (var fs = new FileStream(result[n], FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        //            using (var sr = new StreamReader(fs, Encoding.Default))
        //            {
        //                cosmoseReply += sr.ReadToEnd();
        //            }

        //        }
        //    }

        //    using (StreamReader rd = new StreamReader(fileName))
        //    {
        //        string text = rd.ReadToEnd();
        //        if (text.Contains(termination))
        //        {
        //            text = text.Replace(termination, "").Trim();
        //        }
        //        rd.Close();

        //        using (StreamWriter sw = new StreamWriter(fileName))
        //        {
        //            sw.WriteLine(text);
        //            sw.Close();
        //        }

        //    }

        //    return status;

       // }
        public static Boolean RunCosmosScript(string fileName, out string consoleOutput)
        {

            string termination = $"\nSTDOUT.write '{terminationString}\\n\\n'";

            using (StreamReader rd = new StreamReader(fileName))
            {
                string text = rd.ReadToEnd();
                if (!text.Contains(terminationString))
                {
                    text += termination;
                }
                rd.Close();
                using (StreamWriter sw = new StreamWriter(fileName))
                {
                    sw.WriteLine(text);
                    sw.Close();
                }
            }

            //string[] files1 = Directory.GetFiles(defaultLogPath, "*sr_Test_messages.txt");
            Boolean status = Ruby.Ruby.RunRubyScript($"{defaultCostmosScriptRunner} {display[(int)DisplayOption]} -r {fileName}", terminationString, out consoleOutput);
            //Boolean status = Ruby.RunRubiScript($"{defaultCostmosScriptRunner} -r {fileName}", terminationString, out consoleOutput);
            //string[] files2 = Directory.GetFiles(defaultLogPath, "*sr_Test_messages.txt");


            //string[] result = files2.Except(files1).ToArray();

            //cosmoseReply = "";
            //if (result!=null)
            //{
            //    for(int n=0;n<result.Length;n++)
            //    {
            //        using (var fs = new FileStream(result[n], FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            //        using (var sr = new StreamReader(fs, Encoding.Default))
            //        {
            //            cosmoseReply += sr.ReadToEnd();
            //        }
         
            //    }
            //}

            using (StreamReader rd = new StreamReader(fileName))
            {
                string text = rd.ReadToEnd();
                if (text.Contains(termination))
                {
                    text = text.Replace(termination, "").Trim();
                }
                rd.Close();

                using (StreamWriter sw = new StreamWriter(fileName))
                {
                    sw.WriteLine(text);
                    sw.Close();
                }

            }

            return status;

        }
    }
}
