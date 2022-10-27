using System;
using Infra.Connections;
using static Infra.Logger.Logger;


namespace Infra.Main_Board
{
    public static class MainBoard 
    {
        public static SerialConnection MB;
    
        #region Init Main Board
        public static bool InitMainBoard(string comPort)
        {
            try
            {
                Log.Info($"Open serial connection with main board: {comPort}");
                MB = new SerialConnection(comPort);
                MB.Open();
                Log.Info("Connection success");
            }
            catch (Exception ex)
            {
                Log.Error(ex);  
                return false;
            }
            return true;
        }
        #endregion

        #region Close

        public static void Close()
        {
            try
            {
                if (MB.IsOpen)
                {
                    MB.Close();
                }
                Log.Info("Close connection with MainBoard");
            }
            catch(Exception ex)
            {
                Log.Error(ex);
            }
            
        }
        #endregion
    }
}
