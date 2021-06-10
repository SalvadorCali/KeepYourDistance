#include "sendAck.h"

configuration sendAckAppC {}

implementation {


  components MainC, sendAckC as App;
  components new AMSenderC(AM_SEND_ACK_MSG);
  components new AMReceiverC(AM_SEND_ACK_MSG);
  components new FakeSensorC();
  components new TimerMilliC();
  components ActiveMessageC;

  App.Boot -> MainC.Boot;
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.SplitControl -> ActiveMessageC;
  App.MilliTimer -> TimerMilliC;
  App.Packet -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC;
  App.Read -> FakeSensorC;

}

