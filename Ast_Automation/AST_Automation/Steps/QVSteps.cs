using AST_Automation.Actions;
using Infra.QV;

namespace AST_Automation.Steps
{
    public class QVSteps
    {
        private readonly QVActions _qvActions;
        public QVSteps()
        {
            _qvActions = new QVActions();
        }

        public bool OpenPort(ref QV qv, string comPort)
        {
            return _qvActions.OpenPort(ref qv, comPort);
        }

        public bool ConfigQV(QV qv, string configFilePath)
        {
            return _qvActions.ConfigQV(qv, configFilePath);
        }


        public bool ValidateAllLocked(ref QV qv)
        {
            return _qvActions.ValidateAllLocked(ref qv);
        }
    }
}
