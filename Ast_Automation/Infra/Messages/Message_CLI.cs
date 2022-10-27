using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infra.Messages
{
    public class Message_CLI : BaseMessage
    {
        public Message_CLI(int micronID, int cpsId, int dest,string text) : base(0x1, micronID, cpsId, dest, 3+text.Length)
        {
            Payload[0] = 0x1;
            Payload[1] = 0x0;//delay
            Payload[2] = 0x0;//delay

            for (int n = 0; n < text.Length; n++)
            {
                Payload[n + 3] = (byte)text[n];
            }
        }
    }
}
