using System.ComponentModel;

namespace Infra.Enums
{
    public enum MainBoardSetCommands
    {
        [Description("system_mode set_power_mode ps2")]
        SetPowerModePS2,
        [Description("system_mode set_power_mode operational")]
        SetPowerModeOperational,
        [Description("csp micronidset ")]
        SetMicronId,
    }

    public enum MainBoardGetCommands
    {
        [Description("system_mode get_power_mode")]
        GetPowerMode,
        [Description("csp micronidget")]
        GetMicronId,
    }

}

