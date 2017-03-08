#include "Receiver.h"
#include "printf.h" 

module ReceiverC
{
	uses
	{
		interface Boot;
		interface Receive;
		interface CC2420Packet as Packet;
		interface SplitControl as AMControl;
	}
}

implementation
{
	Nodes_Packet_Counter rec[3]; //up to 3 nodes..nodeIDs must be between 0 and 2. We use them to access to array's elements.
	int8_t rssi = 0, lqi = 0;
	int16_t actual_loss = 0;
	int16_t old_loss = 0;
	
	event void Boot.booted()
	{
		int8_t i;

		for(i=0; i<3; i++)
		{
			rec[i].received = 0;
			rec[i].should_be_received = 0;		
		} 
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err)
	{
		if (err != SUCCESS)
		{
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err){}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if(len == sizeof(TestRadioMsg))
		{
			TestRadioMsg * trpkt = (TestRadioMsg*)payload;
			if(trpkt->nodeid == 1)
			{
				/*
       				  The RSSI register value RSSI.RSSI_VAL can be referred to the power P at the RF 
				  pins by using the following equations: P = RSSI_VAL + RSSI_OFFSET [dBm]
				  where the RSSI_OFFSET is found empirically during system development
				  from the front end gain. RSSI_OFFSET is approximately –45. E.g. if reading a value
				  of –20 from the RSSI register, the RF input power is approximately –65 dBm. (p. 48 datasheet cc2420)
				*/


				rssi = ((int8_t) call Packet.getRssi(msg)) - 45;
				lqi = (int8_t) call Packet.getLqi(msg);
				rec[trpkt->nodeid].received++;
				rec[trpkt->nodeid].should_be_received = trpkt->counter;
			
				if(rec[trpkt->nodeid].should_be_received == 1)
				{
					rec[trpkt->nodeid].received = 1;
					actual_loss = 0;
					old_loss = 0;
					
				}
				if(trpkt->nodeid == 1)
				{
					if((rec[trpkt->nodeid].received % 100) == 0) //every 100 packets received, print how many packet we have lost.
					{
						actual_loss = rec[trpkt->nodeid].should_be_received - rec[trpkt->nodeid].received;
							
						printf("Node %d: %d / %d\t[persi: %d/100 tot: %d (%d)]\tReceived Signal Strength (RSSI): %d dBm  Link Quality (LQI): %d\n", trpkt->nodeid, rec[trpkt->nodeid].received, rec[trpkt->nodeid].should_be_received, actual_loss - old_loss, actual_loss, trpkt->nodeid, rssi, lqi);
						printfflush();
						old_loss = actual_loss; 
					}
				}
			}
		}
			
		return msg;
	}
}








