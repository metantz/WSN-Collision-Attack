/*from printf.h
#ifndef NEW_PRINTF_SEMANTICS
#warning \
"                                  *************************** PRINTF SEMANTICS HAVE CHANGED! ********************************************* Make sure you now include the following two components in your top level application file: PrintfC and SerialStartC. To supress this warning in the future, #define the variable NEW_PRINTF_SEMANTICS. Take a look at the updated tutorial application under apps/tutorials/printf for an example. ************************************************************************************"
#endif
*/

configuration ReceiverAppC{}

implementation
{
	components MainC, ReceiverC as App, LedsC;
	components PrintfC, SerialStartC;
	components new AMReceiverC(6); 
	components ActiveMessageC;
	components CC2420ActiveMessageC;

	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Packet -> CC2420ActiveMessageC.CC2420Packet;
	App.Receive -> AMReceiverC;
	App.AMControl -> ActiveMessageC;
}

