using System;
using System.IO;
using System.Linq;

namespace Infra.IOTools
{
    public class WriteAndReadToFile
    {
        public static void WriteStringFile(string path, params string[] content)
        {
            try
            { 
                var pathAsArr = path.Split(new Char[] { '/', '\\' }, StringSplitOptions.RemoveEmptyEntries);
                var pathOfFile = String.Join("\\", pathAsArr.Take(pathAsArr.Length > 1 ? pathAsArr.Length - 1: pathAsArr.Length));
                if (!Directory.Exists(pathOfFile) && pathAsArr.Length > 1)
                {
                    Directory.CreateDirectory(pathOfFile);
                }

                StreamWriter sw = new StreamWriter(path);
                foreach (var line in content)
                {
                    sw.WriteLine(line);
                }
                sw.Close();
            }
            catch(Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }

        public static string[] ReadStringFile(string path)
        {
            string[] lines = File.ReadAllLines(path);
            return lines;
        }
    }
}
