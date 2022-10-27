using System.ComponentModel;


namespace Infra.Enums
{
    public enum MainBoardExpectedResponse
    {
        [Description(" system_mode get_power_mode\r\npower_mode = PS2\r\nOK\r\nMC>")]
        SystemInPS2Mode,
        [Description("\r\nOK\r\nMC>")]
        OK,
        [Description("Jitter Cleaner locked")]
        JitterCleanerlocked,
    }

    public enum CPBFExpectedResponse
    {
        [Description("command received")]
        CommandRecieved,
    }



}
