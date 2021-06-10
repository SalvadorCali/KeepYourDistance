#ifndef RADIO_LEDS_H
#define RADIO_LEDS_H

typedef nx_struct radio_leds_msg {
  nx_uint16_t counter;
  nx_uint8_t sender_id;
} radio_leds_msg_t;

enum {
  AM_RADIO_LEDS_MSG = 6,
};

#endif
