#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "KeepYourDistance.h"

configuration KeepYourDistanceAppC {}
implementation {
  components MainC, KeepYourDistanceC as App;
  components new AMSenderC(AM_KEEP_YOUR_DISTANCE_MSG);
  components new AMReceiverC(AM_KEEP_YOUR_DISTANCE_MSG);
  components new TimerMilliC() as TimerMilli;
  components new TimerMilliC() as ResetTimer1;
  components new TimerMilliC() as ResetTimer2;
  components new TimerMilliC() as ResetTimer3;
  components new TimerMilliC() as ResetTimer4;
  components new TimerMilliC() as ResetTimer5;
  components PrintfC;
  components SerialStartC;
  components ActiveMessageC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.MilliTimer -> TimerMilli;
  App.ResetTimer1 -> ResetTimer1;
  App.ResetTimer2 -> ResetTimer2;
  App.ResetTimer3 -> ResetTimer3;
  App.ResetTimer4 -> ResetTimer4;
  App.ResetTimer5 -> ResetTimer5;
  App.Packet -> AMSenderC;
}


