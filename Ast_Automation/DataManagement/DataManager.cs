using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using DataManagement.Jsons;
using Infra.Enums;

namespace DataManagement
{
    public class DataManager : IDataManager
    {
        public Dictionary<string, dynamic> GetDictionaryByKey(string key)
        {
            if (Enum.IsDefined(typeof(JsonsEnum), key))
            {
                JsonsEnum enumtype = (JsonsEnum)Enum.Parse(typeof(JsonsEnum), key);
                string path = $"{Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)}\\{enumtype.GetDescription()}";
                return GetDictionaryByPath(path);
            }
            else
            {
                throw new KeyNotFoundException();
            }
        }

        public Dictionary<string, dynamic> GetDictionaryByPath(string path)
        {
            try
            {
                return JsonFileParser.GetDictionaryFromPath(path);
            }catch(Exception e)
            {
                return null;
            }
        }

        public string GetPathToDataFile(string key, bool fullPath = false)
        {
            if (Enum.IsDefined(typeof(JsonsEnum), key))
            {
                JsonsEnum enumtype = (JsonsEnum)Enum.Parse(typeof(JsonsEnum), key);
                return fullPath ? $"{Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)}\\{enumtype.GetDescription()}" : enumtype.GetDescription();
            }
            else
            {
                throw new KeyNotFoundException();
            }
        }
    }
}
