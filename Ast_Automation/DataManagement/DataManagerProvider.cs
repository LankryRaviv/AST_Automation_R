namespace DataManagement
{
    public class DataManagerProvider
    {
        public static IDataManager GetDataManager()
        {
            return new DataManager();
        }
    }
}
