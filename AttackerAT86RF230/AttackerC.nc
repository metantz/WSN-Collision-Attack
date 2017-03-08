#include <Timer.h>
#include "Attacker.h"

module AttackerC
{
	uses interface Boot;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	//uses interface PacketField<uint8_t> as PacketTransmitPower;
}

implementation
{
	bool busy = FALSE;
	message_t pkt;
	int16_t counter = 0;
	
	event void Boot.booted()
	{
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err)
	{
		if(err == SUCCESS)
		{
			call Timer0.startPeriodic(0);
		}
		else
		{
			call AMControl.start();
		}
	}

	event void Timer0.fired()
	{
		if(!busy) //if the radio is not busy to send another packet..
		{
			//we initialize the packet to send with some data..
			AttackerMsg *btrpkt = (AttackerMsg*)(call Packet.getPayload(&pkt, sizeof(AttackerMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = ++counter;
			//we set max tx power for every outgoing packet..
			//call PacketTransmitPower.set(&pkt, 0x00);
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(AttackerMsg)) == SUCCESS) // we send packet in the air..
			{
				busy = TRUE;
			}
		}
	}

	event void AMControl.stopDone(error_t err){}

	event void AMSend.sendDone(message_t* msg, error_t error)
	{
   		if (&pkt == msg)
   		{
      			busy = FALSE;
    		}
  	}

}
