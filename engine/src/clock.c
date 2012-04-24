#include <stdio.h>
#include "SDL.h"
#include "common.h"
#include "clock.h"






/*
 * return the number of milliseconds elapsed since the engine was started
 */
int clock_ms()
{
	return SDL_GetTicks();
}




/*
 * keep time
 */
int clock_wait(int fps)
{
	int pf;      /* how many ticks should we take per-frame? */
	int diff;    /* how much time has passed? */

	/* record of SDL tick at last call, to gauge how much time has been spent */
	static int ticks = 0;

	/* how many milliseconds should this frame get? */
	pf = 1000 / fps;

	/* and how much has it had? */
	diff = SDL_GetTicks() - ticks;

	/*
	 * if less time has elapsed than the frame needed, delay for the
	 * difference
	 */
	if( diff < pf )
		{
			SDL_Delay(pf - diff);

			/* save the new ticks */
			ticks = SDL_GetTicks();
			return 0;

		}
	else
		{
			/*
			 * no .. so save the current ticks and return
			 * the # of frames that must be skipped
			 */
			ticks = SDL_GetTicks();
			return diff / pf;

		}

}
