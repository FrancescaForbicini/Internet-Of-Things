#include <stdio.h>
generic module FakeSensorP() {

	provides interface Read<child_status>;
	uses interface Random;

}

implementation 
{

	task void readDone();

	//***************** Read interface ********************//
	command error_t Read.read(){
		post readDone();
		return SUCCESS;
	}

	//******************** Read Done **********************//
	task void readDone() {
	  
		child_status status;

		int choice = (call Random.rand32() % 10);
		
		switch(choice){
			case 0: 
				strcpy(status.status, "STANDING");
				break;
				
			case 1:
				strcpy(status.status, "WALKING");
				break;
			
			case 2:
				strcpy(status.status, "RUNNING");
				break;
			
			case 3:
				strcpy(status.status, "FALLING");
				break;
			
			case 4: 
				strcpy(status.status, "STANDING");
				break;
				
			case 5:
				strcpy(status.status, "WALKING");
				break;
			
			case 6:
				strcpy(status.status, "RUNNING");
				break;
			
			case 7: 
				strcpy(status.status, "STANDING");
				break;
				
			case 8:
				strcpy(status.status, "WALKING");
				break;
			
			case 9:
				strcpy(status.status, "RUNNING");
				break;
		
		}
	  
	  
	    status.X = call Random.rand16();
	  	status.Y = call Random.rand16();
	  	
		signal Read.readDone( SUCCESS, status);
	  

	}
}  
