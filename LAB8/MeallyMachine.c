#include <avr/io.h>
#define StateA 0
#define StateB 3
#define StateC 1

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
				if (x != 1)
					state = StateB;
				else
					state = StateA;
			}
			else if (state == StateB)
			{
				if (x != 1)
					state = StateA;
				else
					state = StateC;
			}
			else
			{
				if (x != 1)
					state = StateA;
				else
					state = StateC;
			}
			done = 1;		//end state transistion until button is pressed again
		}

		if (clock == 0)		//on falling edge of clock set done to 0 to allow transistion again
			done = 0;

		if ((state == StateA)&&(x==1) | (state == StateB)&&(x==0) | (state == StateC)&&(x==1))
			z = 1;
		else
			z = 0;

		led = (state << 6) | z;
		led = led ^ 0xff;
		PORTC = led;
	}
	return 0;


	}






}