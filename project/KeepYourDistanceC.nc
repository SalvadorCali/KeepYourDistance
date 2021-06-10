#include "printf.h"
#include "Timer.h"
#include "KeepYourDistance.h"

#define COUNTERS_SIZE 5

module KeepYourDistanceC @safe() {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface Timer<TMilli> as ResetTimer1;
    interface Timer<TMilli> as ResetTimer2;
    interface Timer<TMilli> as ResetTimer3;
    interface Timer<TMilli> as ResetTimer4;
    interface Timer<TMilli> as ResetTimer5;
    interface SplitControl as AMControl;
    interface Packet;
  }
}
implementation {
  message_t packet;
  bool locked;
  uint16_t counters[COUNTERS_SIZE] = { };
  uint16_t reset_counters[COUNTERS_SIZE] = { };
  
  void startResetTimer(uint8_t sender);
  
  void startResetTimer(uint8_t sender) {
  	switch(sender){
  		case 1:
  			call ResetTimer1.startPeriodic(3000);
  			break;
  		case 2:
  			call ResetTimer2.startPeriodic(3000);
  			break;
  		case 3:
  			call ResetTimer3.startPeriodic(3000);
  			break;
  		case 4:
  			call ResetTimer4.startPeriodic(3000);
  			break;
  		case 5:
  			call ResetTimer5.startPeriodic(3000);
  			break;
  		default:
  			break;
  		
  	}
  }        
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(500);
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
      keep_your_distance_msg_t* kydm = (keep_your_distance_msg_t*)call Packet.getPayload(&packet, sizeof(keep_your_distance_msg_t));
      if (kydm == NULL) {
		return;
      }
      kydm->sender_id = TOS_NODE_ID;
      
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(keep_your_distance_msg_t)) == SUCCESS) {
		locked = TRUE;
      }
    }
  }
  
  event void ResetTimer1.fired() {
  	call ResetTimer1.stop();
    if(counters[0] == reset_counters[0]){
    	counters[0] = 0;
    	reset_counters[0] = 0;
    }
  }
  
  event void ResetTimer2.fired() {
  	call ResetTimer2.stop();
    if(counters[1] == reset_counters[1]){
    	counters[1] = 0;
    	reset_counters[1] = 0;
    }
  }
  
  event void ResetTimer3.fired() {
  	call ResetTimer3.stop();
    if(counters[2] == reset_counters[2]){
    	counters[2] = 0;
    	reset_counters[2] = 0;
    }
  }
  
  event void ResetTimer4.fired() {
  	call ResetTimer4.stop();
    if(counters[3] == reset_counters[3]){
    	counters[3] = 0;
    	reset_counters[3] = 0;
    }
  }
  
  event void ResetTimer5.fired() {
  	call ResetTimer5.stop();
    if(counters[4] == reset_counters[4]){
    	counters[4] = 0;
    	reset_counters[4] = 0;
    }
  }

  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    
    if (len != sizeof(keep_your_distance_msg_t)) {return bufPtr;}
    else {
      keep_your_distance_msg_t* kydm = (keep_your_distance_msg_t*)payload;
      counters[kydm->sender_id - 1]++;
      
      if(counters[kydm->sender_id - 1] == 10){
      	counters[kydm->sender_id - 1] = 0;
      	printf("{\"value1\": %u, \"value2\": %u}\n", TOS_NODE_ID, kydm->sender_id);
		printfflush();
		return bufPtr;
      }
      
      reset_counters[kydm->sender_id - 1] = counters[kydm->sender_id - 1];
      startResetTimer(kydm->sender_id);
      printf("[DEBUG%u] Current counter for node %u: %u\n", TOS_NODE_ID, kydm->sender_id, counters[kydm->sender_id - 1]);
      printfflush();
      return bufPtr;
    }
    
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
}




