#include <avr/io.h>

int main(void) {

	unsigned char inc,dec,button, counter, done;

	/**
	* set up inputs and outputs
	*/	
	DDRA = 0; //set A Ports as input
	DDRB = 0; //set B Ports as inputs
	
	DDRC = 0xff; //set C as output	

	//other varibles
	done = 0; 
	counter = 0;

	while (1) {
		button = (PINA ^ 0xff);
		//if increment is hit
		if( (button&1)  != 0 && (done == 0)) {

			if (counter < 13) {
				counter += 1; //incremenet counter by one
			} else {
				counter = 0; //set back once counter is past 13 
			}
			done = 1; 
			
		}
		
		else if( (button& 0x08) != 0 && (done == 0)) {

			if (counter > 0) {
				counter -= 1; //incremenet counter by one
			} else {
				counter = 13; //set back once counter is past 13 
			} 
			done = 1;	
		}
		
		//make sure clock doesnt mess up output 
		if(button == 0){
			done = 0;

		}
		
		//output to the LED
		PORTC = counter ^ 0xff;

	}
	
	return 0;
	

}

