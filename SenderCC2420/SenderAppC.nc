#include <Timer.h>

configuration SenderAppC{}

implementation
{
	components MainC, SenderC as App;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components ActiveMessageC;
	components new AMSenderC(6);	
	
	App.Boot -> MainC;
	App.Timer0 -> Timer0;
	App.Timer1 -> Timer1;
	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;	
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
}

