using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Infra.Connections.ProtoType;
using Infra.Messages;
using Infra.Enums;
namespace Infra.Connections

{
    public enum MODE
    {
        RS232,
        RS485,
        CSP_dll,
        Moxa,
        None
    };

    public interface IConnection
    {
        event PrintToMessegeCallback OnMessage;
        event ResetCallback OnReset;
        event ErrorCallback OnError;

        MODE mode
        {
            get;
            set;
        }
        int ReceiveTimeout { set; get; } 

        Boolean OpenConnection();
        Boolean isOpen();
        void Close();
        void Write(string command);
        Boolean Write(BaseMessage message);
        void Read(out string reply);
        void Read(out byte[] replyBuffer, int numberOfBytesToRead);
        Boolean WriteAndRead(string command, out string reply, int micronID, int cspID);
        Boolean Search(int micronID, out SimpleTelemetry[] found);
        Boolean WriteAndRead(BaseMessage message, out SimpleTelemetry telemetry);
        Boolean RetrieveLastResponses(CSP_PORT destinationPort, out SimpleTelemetry[] found);
        Boolean RetrieveLastResponses(CSP_PORT destinationPort, int tlmIndex, out SimpleTelemetry[] found);

        Boolean RetrieveLastResponses(long hashCode64, out SimpleTelemetry[] found);
        void DiscardResponses(SimpleTelemetry[] discardList);

        //Queue
        Boolean GetAsynchResponses(out SimpleTelemetry[] asynchResponses);
        Boolean RetrieveLastResponses(int micronId, int commandid, out SimpleTelemetry[] found);
    }
}
