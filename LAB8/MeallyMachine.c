#include <avr/io.h>
#define StateA 0
#define StateB 3
#define StateC 1

int main(void)
{
	//initialization
	unsigned char x, clck, led, z, state, done;
	DDRA = 0;		//port A all bits input
	DDRC = 0xff;	//port C all bits output
	done = 0;		//if done is 0 and clock is 1, change state
	led = 0;
	state = StateA; //set initial state

	while(1)
	{
		clck = (PINA^0xff) & 1;
		x = (PINA ^ 0xff) & 8;				// pick up bit 0 of port B

		//state assignments as a function of x
		if((done==0)&&(clck!=0))
		{
			if (state == StateA)
			{
				if (x == 0)
					state = StateB;
				else
					state = StateA;
			}
			else if (state == StateB)
			{
				if (x == 0)
					state = StateA;
				else
					state = StateC;
			}
			else
			{
				if (x == 0)
					state = StateA;
				else
					state = StateC;
			}
			done = 1;		//end state transistion until button is pressed again
		}

		/************************************************************************/
		/* debounce                                                             */
		/************************************************************************/
		if (clck == 0)		//on falling edge of clock set done to 0 to allow transistion again
			done = 0;

		/************************************************************************/
		/* set states' output                                                   */
		/************************************************************************/
		if (((state == StateA)&&(x!=0)) || ((state == StateB)&&(x==0)) || ((state == StateC)&&(x!=0)))
			z = 1;
		else
			z = 0;

		/************************************************************************/
		/* Set output                                                           */
		/************************************************************************/
		led = (state << 6) | z;
		led = led ^ 0xff;
		PORTC = led ;
	}
	return 0;


}

