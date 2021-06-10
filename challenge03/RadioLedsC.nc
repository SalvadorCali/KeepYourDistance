#include "printf.h"
#include "Timer.h"
#include "RadioLeds.h"

module RadioLedsC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
  }
}
implementation {

  message_t packet;

  bool locked;
  bool led0 = FALSE;
  bool led1 = FALSE;
  bool led2 = FALSE;
  uint16_t counter = 0;
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      if (TOS_NODE_ID == 1) {
      	call MilliTimer.startPeriodic(1000);
      }
      if (TOS_NODE_ID == 2) {
      	call MilliTimer.startPeriodic(1000/3);
      }
      if (TOS_NODE_ID == 3) {
      	call MilliTimer.startPeriodic(1000/5);
      }
    }
    else {
      call AMControl.start();
    }
  }
  
  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  event void MilliTimer.fired() {
    if (locked) {
      return;
    }
    else {
      radio_leds_msg_t* rlm = (radio_leds_msg_t*)call Packet.getPayload(&packet, sizeof(radio_leds_msg_t));
      if (rlm == NULL) {
		return;
      }
      rlm->counter = counter;
      rlm->sender_id = TOS_NODE_ID;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_leds_msg_t)) == SUCCESS) {
		locked = TRUE;
      }
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    
    if (len != sizeof(radio_leds_msg_t)) {return bufPtr;}
    else {
      radio_leds_msg_t* rlm = (radio_leds_msg_t*)payload;
      counter++;
      
      if(rlm->counter % 10 == 0){
      	call Leds.led0Off();
      	led0 = FALSE;
      	call Leds.led1Off();
      	led1 = FALSE;
      	call Leds.led2Off();
      	led2 = FALSE;
      } else {
      	if (rlm->sender_id == 1) {
			call Leds.led0Toggle();
			led0 = !led0;
      	}
      	if (rlm->sender_id == 2) {
			call Leds.led1Toggle();
			led1 = !led1;
      	}
      	if (rlm->sender_id == 3) {
			call Leds.led2Toggle();
			led2 = !led2;
      	}
      }
      
      if(TOS_NODE_ID == 2){
      	printf("Bitmask: %d %d %d of Mote 2.\n", led2, led1, led0);
		printfflush();
      }
      
      return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}




