using Infra.QV;
using System;
using static Infra.Logger.Logger;

namespace AST_Automation.Actions
{
    public class QVActions
    {
        public bool OpenPort(ref QV qv, string comPort)
        {
            try
            {
                qv = new QV(comPort);
                return qv.OpenPort();
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw;
            }       
        }

        public bool ConfigQV(QV qv,string configFilePath)
        {
            return qv.ConfigQV(configFilePath);
        }

        public bool ValidateAllLocked(ref QV qv)
        {
            try
            {
                return qv.AllLocked();
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }
    }
}
