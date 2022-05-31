#include "Timer.h"
#include "Project.h"
#include <stdio.h>

module ProjectC @safe(){
	uses {
		interface Boot;
		interface AMSend;
		interface Receive;
		interface SplitControl as AMControl;
		interface Packet;
		interface AMPacket;
		interface PacketAcknowledgements;

		interface Timer<TMilli> as TimerPairing;
		interface Timer<TMilli> as ChildTimer;
		interface Timer<TMilli> as ParentTimer;

		interface Read<child_status> as FakeSensor;
	}
}

implementation{
	bool locked = FALSE;
	uint16_t counter = 0;
	message_t packet;
	am_addr_t address_paired_device;
	am_addr_t destination;
	uint16_t mode;

	child_status actual_status;
	child_status last_status;

	void send_pairing();
	void send_INFO_msg();




	event void Boot.booted() {
		dbg("boot","Application booted.\n");
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
	  		dbg("Bracelet", "Bracelet Sensor device is ready\n");
	  		dbg("Pairing Phase", "Pairing phase started\n\n");
	  
	  		call TimerPairing.startPeriodic(1000);
		} else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {}

	event void TimerPairing.fired(){

		dbg("TimerPairing","TimerPairing: timer fired at time %s\n\n", sim_time_string());

		if (!locked){
			msg_t* msg = (msg_t*)call Packet.getPayload(&packet,sizeof(msg_t));
			msg->msg_type = 0;
		   
		    strcpy(msg->data,randomkeys[TOS_NODE_ID/2]);
		   
		    if (call AMSend.send (AM_BROADCAST_ADDR,&packet,sizeof(msg)) == SUCCESS){
				dbg("Bracelet","Bracelet Sensor is sending pairing packet -> key = %s\n\n",randomkeys[TOS_NODE_ID/2]);
				locked = TRUE;
		    }
		}
	}

	event void ChildTimer.fired(){
		dbg("ChildTimer","ChildTimer: timer fired at time %s\n",sim_time_string());
	    call FakeSensor.read();
	}

	event void ParentTimer.fired(){
		dbg("ParentTimer","ParentTimer: timer fired at time %s\n",sim_time_string());
	    dbg("ParentTimer","ALERT: MISSING\n");
	    dbg("ParentTimer","Last location X: %hhu, Y: %hhu\n\n",last_status.X,last_status.Y);
	}

	event void AMSend.sendDone(message_t*buffer,error_t error){
		if(&packet == buffer && error == SUCCESS){
			dbg("AMSend","AMSend: Packet is sent\n");
			locked = FALSE;
		
		    if (mode == 1){
				if (call PacketAcknowledgements.wasAcked(buffer)){
					mode = 2; 
					dbg("AMSend","AMSend ACK received at time %s\n",sim_time_string());
					dbg("Pairing Phase","Pairing Phase -> pairing has been completed for node %hhu\n\n",address_paired_device);

					if (TOS_NODE_ID % 2 ==0){
						dbg("OperationalMode","Parent bracelet has been activated\n\n");
						call ParentTimer.startOneShot(60000);
					}
					else{
						dbg("OperationalMode","Child bracelet has been activated\n\n");
						call ChildTimer.startPeriodic(10000);
					}
				}
				else{
					dbg("AMSend","Pairing FAILED-> ACK not received at time %s\n",sim_time_string()); 
					send_pairing();
				}
			}
		else 
			if (mode == 2){
				if (call PacketAcknowledgements.wasAcked(buffer)){
					dbg("AMSend","OperationalMode SUCCESS-> ACK received at time %s\n\n",sim_time_string()); 
				}
				else{
					dbg("AMSend","OperationalMode FAILED-> ACK not received at time %s\n\n",sim_time_string()); 
					send_INFO_msg();
				}
			}
		}
	}


	void send_pairing(){
		if (!locked){
	  		msg_t* msg = (msg_t*) call Packet.getPayload(&packet,sizeof(msg_t));
	  		msg->msg_type = mode;
	  		strcpy(msg->data,randomkeys[TOS_NODE_ID/2]);
	  		call PacketAcknowledgements.requestAck(&packet);
	  		if (call AMSend.send(address_paired_device,&packet,sizeof(msg_t)) == SUCCESS){
				dbg("Bracelet","Bracelet Sensor: sending pairing ACK to node %hhu\n\n",address_paired_device);
				locked = TRUE;
	  		}
		}
	}

	void send_INFO_msg(){
		if (!locked){
	  		msg_t* msg = (msg_t*) call Packet.getPayload(&packet,sizeof(msg_t));
	  		msg->msg_type = mode;
			msg->X = actual_status.X;
			msg->Y = actual_status.Y;

			strcpy(msg->data,actual_status.status); 

			call PacketAcknowledgements.requestAck(&packet);

			if (call AMSend.send(address_paired_device,&packet,sizeof(msg_t)) == SUCCESS){
				dbg("Bracelet","Bracelet Sensor is sending INFO to node %hhu\n\n",address_paired_device);
				locked = TRUE;
	  		}
		} 
	}



	event message_t* Receive.receive(message_t* buffer, void*payload,uint8_t length){
		msg_t* msg = (msg_t*)payload;
		dbg("Receive","Message has been received from node %hhu at time %s\n",call AMPacket.source(buffer),sim_time_string());
		dbg("Receive","Payload -> type: %hu, data: %s\n",msg->msg_type,msg->data);

		destination = call AMPacket.destination(buffer); 


		if (destination == AM_BROADCAST_ADDR && mode == 0 && (strcmp(msg->data,randomkeys[TOS_NODE_ID/2]) == 0)){
			address_paired_device = call AMPacket.source(buffer);
			mode = 1;
			dbg("Receive","Message for the PAIRING PHASE --> Address: %hhu\n\n",address_paired_device);
			send_pairing();
		}
		else
			if (destination == TOS_NODE_ID){
				if (msg->msg_type == 1){
			  		dbg("Receive","Message for PAIRING PHASE has been received\n\n");
			  		call TimerPairing.stop();
				}
			else
				if (msg->msg_type == 2){
					dbg("Receive","INFO Message received\n");
					dbg("OperationalMode","Position X: %hhu, Y: %hhu\n",msg->X,msg->Y);
					dbg("OperationalMode","Child Status: %s\n\n\n",msg->data);
					last_status.X = msg->X;
					last_status.Y = msg->Y;
					call ParentTimer.startOneShot(60000);
				
					if (strcmp(msg->data,"FALLING") == 0){
						dbg("OperationalMode","ALERT: FALLING\n");
						dbg("OperationalMode", "Position of the child: X: %hhu, Y: %hhu\n\n\n", msg->X, msg->Y);
					}
				}  
			}
		return buffer;    
	}


	event void FakeSensor.readDone(error_t result, child_status status){
		if (result == SUCCESS){
			actual_status = status;
			dbg("ChildSensor","Child Status: %s\n", actual_status.status);
			dbg("ChildSensor","Position X: %hhu, Y: %hhu\n",actual_status.X,actual_status.Y); 
			send_INFO_msg();
		}
		else
			call FakeSensor.read();
	}
	
}
