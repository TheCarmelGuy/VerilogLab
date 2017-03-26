#include <avr/io.h>
#define StateA 0
#define StateB 3
#define StateC 1
#define StateD 7
#define StateE 4

int main(void)
{
	//initialization
	unsigned char x, clock, led, z, state, done;
	DDRA = 0;		//port A all bits input
	DDRB = 0;		//port B all bits input
	DDRC = 0xff;	//port C all bits output
	done = 0;		//if done is 0 and clock is 1, change state
	led = 0;
	state = StateA;

	while(1)
	{ 
		clock = (PINA^0xff) & 1;
		x = PINB & 1;				// pick up bit 0 of port B

		//state assignments as a function of x
		if((done==0)&&(clock!=0))
		{
			if (state == StateA)
			{
				if (x != 1) {
					state = StateB;
				}
				else {
					state = StateE;
				}
			}
			else if (state == StateB)
			{
				if (x != 1) {
					state = StateA;
				}
				else {
					state = StateD;
				}
			}
			else if (state == StateC)
			{
				if (x != 1) {
					state = StateB;
				}
				else{
					state = StateD;
				}
			} 
			else if(state == StateD){
				if(x != 1) 
					 state == StateA;
				else {
					state = StateE;
				}
			else 
				state == StateC;
			}
			
			done = 1;		//end state transistion until button is pressed again
		}


		if (clock == 0)		//on falling edge of clock set done to 0 to allow transistion again
			done = 0;

		/**Set output values**/
		if ((state == StateA) | (state == StateC) | (state == StateE))
			z = 1;
		else
			z = 0;

		/**Set LEDS to have both z and the states**/
		led = (state << 5) | z;
		led = led ^ 0xff;
		PORTC = led;
	}
	return 0;


	}






}
