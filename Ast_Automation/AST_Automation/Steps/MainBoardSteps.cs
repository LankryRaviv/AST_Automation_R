using AST_Automation.Actions;
using Infra.Enums;

namespace AST_Automation.Steps
{
    public class MainBoardSteps
    {
        private readonly MainBoardActions _mainBoardActions;
        public MainBoardSteps()
        {
            _mainBoardActions = new MainBoardActions();
        }

        public bool InitMainBoard(string comPort)
        {
            return _mainBoardActions.InitMainBoard(comPort);
        }

        public bool SetMainBoardPowerModeOperational()
        {
            return _mainBoardActions.MainBoardSetAndValidate(MainBoardSetCommands.SetPowerModeOperational.GetDescription(),
                    MainBoardGetCommands.GetPowerMode.GetDescription(), MainBoardExpectedResponse.JitterCleanerlocked.GetDescription());
        }

        public bool SetMainBoardPowerModePS2()
        {
            return _mainBoardActions.MainBoardSetAndValidate(MainBoardSetCommands.SetPowerModePS2.GetDescription(),
                    MainBoardGetCommands.GetPowerMode.GetDescription(), MainBoardExpectedResponse.SystemInPS2Mode.GetDescription());
        }

        public bool ChangeMicronId(string id)
        {
            return _mainBoardActions.MainBoardSetAndValidate(MainBoardSetCommands.SetMicronId.GetDescription() + id,
                  MainBoardGetCommands.GetMicronId.GetDescription(), id + MainBoardExpectedResponse.OK.GetDescription());
        }
    }
}
