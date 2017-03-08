#ifndef ATTACKER_H
#define ATTACKER_H

// packet's payload structure
typedef nx_struct AttackerMsg		
{
	nx_int16_t nodeid;
	nx_int16_t counter;
}AttackerMsg;

#endif
