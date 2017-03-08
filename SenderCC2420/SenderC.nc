#include <Timer.h>
#include "Sender.h"

module SenderC
{
	uses
	{
		interface Boot;
		interface Timer<TMilli> as Timer0;
		interface Timer<TMilli> as Timer1;
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
	}
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
			call Timer0.startPeriodic(16);
		}
		else
		{
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err){}

	event void Timer0.fired()
	{
		counter++;
		if(!busy)
		{
			TestRadioMsg *trpkt = (TestRadioMsg*)(call Packet.getPayload(&pkt, sizeof(TestRadioMsg)));
			trpkt->nodeid = TOS_NODE_ID;
			trpkt->counter = counter;
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(TestRadioMsg)) == SUCCESS){
				busy = TRUE;
			}
		}

		if((counter % 1000) == 0)//everytime we send 1000 packets we wait 5 seconds to add the attacker in the network..
		{
			call Timer0.stop(); //we stop the timer to avoid the node to send other packets
			call Timer1.startOneShot(5000); 
		} 
	}

	event void Timer1.fired() //After 5 second from Timer1 activation...
	{
		call Timer0.startPeriodic(16); //we restart Timer0
	}

	event void AMSend.sendDone(message_t* msg, error_t error)
	{
   		if (&pkt == msg)
		{
      			busy = FALSE;
    		}
  	}
}
