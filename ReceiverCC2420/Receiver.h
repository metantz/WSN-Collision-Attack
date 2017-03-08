#ifndef RECEIVER_H
#define RECEIVER_H

typedef nx_struct TestRadioMsg
{
	nx_int16_t nodeid;
	nx_int16_t counter;
}TestRadioMsg;


typedef struct Nodes_Packet_Counter
{
	nx_int16_t received;
	nx_int16_t should_be_received;
}Nodes_Packet_Counter;

#endif
