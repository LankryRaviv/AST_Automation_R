using Infra.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Infra.Connections.ProtoType;
namespace Infra.Responses
{
    public class Response_CLI : BaseResponse
    {

        public readonly  string Reply;
        public readonly  int    Order;
        public readonly Boolean Last;


        public Response_CLI(SimpleTelemetry telemetry):base(telemetry)
        {
            Order = GetByte(2);
            Last = GetBool(3);
            Reply = GetString(4);
            message_type = CSP_Message_Type.RemoteCLI;
        }
    }
}
