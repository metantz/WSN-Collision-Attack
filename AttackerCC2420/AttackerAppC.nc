#include <Timer.h>

configuration AttackerAppC{}

implementation
{
	components MainC;
	components new TimerMilliC() as Timer0;
	components AttackerC as App;
	components ActiveMessageC;
	components new AMSenderC(6);	//ActiveMessage of type 6
	
	App.Boot -> MainC;
	App.Timer0 -> Timer0;
	App.AMPacket -> AMSenderC;
	App.Packet -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
}
