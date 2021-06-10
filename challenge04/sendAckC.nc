#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
	interface Boot;
    interface Timer<TMilli> as MilliTimer;
	interface Receive;
    interface AMSend;
	interface SplitControl;
    interface Packet;
    interface PacketAcknowledgements;
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter=0;
  uint8_t counter_received;
  message_t packet;

  void sendReq();
  void sendResp();
  
  void sendReq() {
	send_ack_msg_t* sam = (send_ack_msg_t*)(call Packet.getPayload(&packet, sizeof(send_ack_msg_t)));
		if (sam == NULL) {
			return;
		}
		counter++;
		sam->counter = counter;
		sam->type = REQ;
        dbg("packet","Message created by node 1 of type REQ and counter %u!\n", counter);
		call PacketAcknowledgements.requestAck(&packet);
		if (call AMSend.send(2, &packet, sizeof(send_ack_msg_t)) == SUCCESS) {
			dbg("packet", "Message sent at time %s!\n", sim_time_string());
		} else {
            dbgerror("packet", "Error sending message...");
        }
  }        

  void sendResp() {
	call Read.read();
  }

  event void Boot.booted() {
	dbg("boot", "Application booted on node %u at time %s\n", TOS_NODE_ID, sim_time_string());
	call SplitControl.start();
  }

  event void SplitControl.startDone(error_t err){
    if(err == SUCCESS) {
    	dbg("radio", "Radio on on node %u\n", TOS_NODE_ID);
        if (TOS_NODE_ID == 1){
		    call MilliTimer.startPeriodic(1000);
  		}
    } else{
        dbgerror("radio", "Radio error on node %u. Restarting...\n", TOS_NODE_ID);
        call SplitControl.start();
    }
  }
  
  event void SplitControl.stopDone(error_t err){
    //do nothing
  }

  event void MilliTimer.fired() {
	dbg("timer", "Timer fired on node %u\n", TOS_NODE_ID);
    sendReq();
  }
  
  event void AMSend.sendDone(message_t* buf,error_t err) {
	if(err == SUCCESS){
		 if(call PacketAcknowledgements.wasAcked(buf)){
		 	dbg("radio", "Ack received on node %u!\n", TOS_NODE_ID);
		 	if(TOS_NODE_ID == 1) {
		 		dbg("timer", "Stopping timer...\n");
		 		call MilliTimer.stop();
		 	}
		 }
		 else{
		 	dbg("radio", "No response...\n");
		 	if(TOS_NODE_ID == 2){
		 		dbg_clear("radio", "\t\t sending a new message...\n");
		 		sendResp();
		 	}
		 }
		}
		else{
			if(TOS_NODE_ID == 1){
				dbgerror("packet","Error sending message.");
			}
			else{
				dbgerror("packet","Error sending message.");
				sendResp();
			}
		}
  }

  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	if (len != sizeof(send_ack_msg_t)) {
        dbgerror("packet", "Malformed packet.");
        return buf;
    } else {
      send_ack_msg_t* sam = (send_ack_msg_t*)payload;
      dbg("packet", "Message received\n");	
      dbg_clear("packet","\t\t at node %u\n", TOS_NODE_ID);
      if(sam->type == REQ){
      	counter_received = sam->counter;
      	dbg_clear("packet","\t\t of type REQ\n");
        dbg_clear("packet","\t\t with counter %u\n", counter_received);
      	sendResp();
      }
      else{
      	dbg_clear("packet","\t\t of type RESP\n");
      }
      return buf;
    }

  }
  
  event void Read.readDone(error_t result, uint16_t data) {
	if(result == SUCCESS){
		 	send_ack_msg_t* sam = (send_ack_msg_t*)(call Packet.getPayload(&packet, sizeof(send_ack_msg_t)));
			if (sam == NULL) {
                return;
            }
			sam->counter = counter_received;
			sam->type = RESP;
			sam->value = data;
		
			call PacketAcknowledgements.requestAck(&packet);
			if (call AMSend.send(1, &packet, sizeof(send_ack_msg_t)) == SUCCESS) {
		   	  dbg("packet", "Packet sent, with data %u\n", data);
			}
		}
		else{
			dbgerror("packet", "Error in data reading from sensor...\n");
			sendResp();
		}
	}

}

