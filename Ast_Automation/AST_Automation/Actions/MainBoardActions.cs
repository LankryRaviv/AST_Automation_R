using static Infra.Logger.Logger;
using Infra.Main_Board;
using System;

namespace AST_Automation.Actions
{
    public class MainBoardActions
    {
        public bool MainBoardSetAndValidate(string setCommand, string getCommand, string expectedResponse)
        {
            try
            {
                string reply;
                MainBoard.MB.WriteAndRead(setCommand, out reply, 0, 0);
                Log.Info($"The set command: {setCommand},The reply: {reply}");
                MainBoard.MB.WriteAndRead(getCommand, out reply, 0, 0);
                Log.Info($"The get command: {getCommand},The reply: {reply}");
                Log.Info($"The reply: {reply},The expected response: {expectedResponse}");
                return reply.Equals(expectedResponse) || reply.Contains(expectedResponse);
            }
            catch(Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }

        public bool InitMainBoard(string comPort)
        {
           return MainBoard.InitMainBoard(comPort);
        }
    }
}