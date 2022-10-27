using System;
using System.IO;
using System.Reflection;
using log4net;
using log4net.Appender;
using log4net.Config;
using log4net.Core;
using log4net.Layout;

namespace Infra.Logger
{
    public static class Logger
    {
        public static ILog Log = null;

        public static void InitLogger(string logName)
        {
            if (Log != null)
            {
                Log.Logger.Repository.Shutdown();
            }

            var patternLayout = new PatternLayout();
            patternLayout.ConversionPattern = "%date{dd-MM-yyyy HH:mm:ss:fff} [%class] [%level] [%method] -  %message%newline";
            patternLayout.ActivateOptions();

            var consoleApender = new ConsoleAppender()
            {
                Name = "ConsoleAppender",
                Layout = patternLayout,
                Threshold = Level.All
            };

            var fileAppender = new FileAppender()
            {
                Name = "Logger",
                Layout = patternLayout,
                Threshold = Level.All,
                AppendToFile = false,
                File = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\Logs\\" + $"{logName} {DateTime.Now.ToString("dd-MM-yyyy HH-mm-ss")}.log"
            };

            fileAppender.ActivateOptions();
            consoleApender.ActivateOptions();

            BasicConfigurator.Configure(consoleApender, fileAppender);

            Log = LogManager.GetLogger(typeof(Logger));
        }

    }
}
