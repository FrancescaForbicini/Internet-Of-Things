#ifndef PROJECT_H
#define PROJECT_H



typedef nx_struct msg {
	nx_uint8_t msg_type;
  	nx_uint8_t data[20];
  	nx_uint16_t X;
  	nx_uint16_t Y;
}msg_t;


typedef struct ChildStatus {
	uint8_t status[10];
	uint16_t X;
    uint16_t Y;
}child_status;

enum {
	AM_RADIO_TYPE = 6,
};



static const char *randomkeys[]={"P3N0vLZMfz3i53vdrl7J",
								 "dK2lZs3hqbAj88S10LqW",
								 "Iu19K1s3gsYb3r6uZEPc",
								 "fnE5x47KsBBJ5k3qfNR2",
								 "c4P1PNzVxD5uf5e33teS",
								 "91POg813XlrMCmjakNl4",
								 "Te5kX9eht0Gi1zmPs42K",
								 "zvjrIH2Ivx9sMe89E8r3",
								 "fz49jITICua2T5wq69AO",
								 "DtEErVzC3HZ9E8RG420i",
								 "Q3e6CSsjv67qoj6YqO8v",
								 "5IebE2LtbC05cSBEvB10",
								 "0wmMnVSz700B3y0qTwPT",
								 "3FVExbswe9xOk3319Joh",
								 "4juJ4esEm4r95aRrZ5Mv",
								 "c9J3F4dp9FpkdmCYS6h0",
								 "7mFeFIff8SW6CZp9V51N",
								 "RTP7V49bs1H6hfONJ9AU",
								 "h92Zt4FFv571jjeUgFyZ",
								 "k99uEs8cHF6Jz44UGkLu"};

#endif
