using DataManagement.Jsons;
using Infra.Enums;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

namespace DataManagement
{
    public static class JsonFileParser
    {
        public static Dictionary<string, dynamic> GetDictionary(JsonsEnum jsons)
        {
            var jsonFileText = File.ReadAllText(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\" + jsons.GetDescription());
            return JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(jsonFileText);
        }

        public static Dictionary<string, dynamic> GetDictionary(string jsonString)
        {
            var jsonFileText = File.ReadAllText(jsonString);
            return JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(jsonFileText);
        }

        public static Dictionary<string, dynamic> GetDictionaryFromPath(string jsonPath)
        {
            if (jsonPath.StartsWith(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)))
            {
                return GetDictionary(jsonPath);
            }

            var jsonFileText = File.ReadAllText(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) + "\\" + jsonPath);
            return JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(jsonFileText);
        }

        public static string GetDictionaryAsString(Dictionary<string, dynamic> dictionary)
        {
            return JsonConvert.SerializeObject(dictionary);
        }
    }
}
