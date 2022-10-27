using System.Collections.Generic;

namespace DataManagement
{
    public interface IDataManager
    {
        string GetPathToDataFile(string key, bool fullPath = false);
        Dictionary<string, dynamic> GetDictionaryByKey(string key);
        Dictionary<string, dynamic> GetDictionaryByPath(string path);
    }
}
