#include "Project.h"

configuration ProjectAppC{}

implementation{
	components MainC,ProjectC as App;
	
	components new AMSenderC(AM_RADIO_TYPE);
	components new AMReceiverC(AM_RADIO_TYPE);
	components ActiveMessageC as AMControl;

	components new FakeSensorC();

	components new TimerMilliC() as TimerPairing;
	components new TimerMilliC() as ChildTimer;
	components new TimerMilliC() as ParentTimer;

	App.Boot -> MainC.Boot;

	App.AMSend -> AMSenderC;
	App.Receive -> AMReceiverC;
	App.AMControl -> AMControl;

	App.Packet -> AMSenderC;
	App.PacketAcknowledgements -> AMControl;
	App.AMPacket -> AMSenderC;

	App.TimerPairing -> TimerPairing;
	App.ChildTimer -> ChildTimer;
	App.ParentTimer -> ParentTimer;


	App.FakeSensor -> FakeSensorC;

}
