#ifndef SENDACK_H
#define SENDACK_H

typedef nx_struct send_ack_msg {
	nx_uint8_t type;
	nx_uint8_t counter;
	nx_uint16_t value;
} send_ack_msg_t;

#define REQ 1
#define RESP 2 

enum{
AM_SEND_ACK_MSG = 6,
};

#endif
