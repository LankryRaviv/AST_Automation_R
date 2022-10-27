using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infra.Enums
{
    public enum CSP_PORT
    {
        FILE_SYSTEM = 10,
        FIRMWARE_UPDATE = 11,
        CSP_REBOOT = 4,
        TIME_SYNC = 8,
        REMOTE_CLI = 13,
        GPS = 33,
        IMU = 34,
        MAG = 35,
        FPGA = 41,
        TELEMETRY = 7,
        SYSTEM = 32,
        THERMAL = 17,
        HEALTH_MONITOR = 38,
        ROUTING = 39,
        EPS = 36
    };
}
