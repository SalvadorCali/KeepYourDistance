#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "RadioLeds.h"

configuration RadioLedsAppC {}
implementation {
  components MainC, RadioLedsC as App, LedsC;
  components new AMSenderC(AM_RADIO_LEDS_MSG);
  components new AMReceiverC(AM_RADIO_LEDS_MSG);
  components new TimerMilliC();
  components PrintfC;
  components SerialStartC;
  components ActiveMessageC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  App.Packet -> AMSenderC;
}


