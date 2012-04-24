#include <stdio.h>
#include "SDL.h"
#include "common.h"
#include "init.h"





void init_brick()
{
	DEBUG_N( "--- Brick Engine %s ---\n", BRICK_VERSION);
	DEBUG( "Initializing SDL...");
#ifdef WITH_SDL13
	SDL_Init(SDL_INIT_TIMER);
#else
	SDL_Init(SDL_INIT_EVENTTHREAD|SDL_INIT_TIMER);
#endif
	DEBUGF;

	/* init our environment */
	init_layers();
	init_renderer();
	init_io();
	init_fonts();
	init_events();

	/* set a default pixel order */
	set_pixel_order(16, 8, 0);
}





void quit_brick()
{
	/* always disable the input grab */
	io_grab(0);

	/* and shut down the graphics and sound output */
	audio_close();
	graphics_close();

	/* and unwind the startup process */
	quit_events();
	quit_fonts();
	quit_layers();


	if( SDL_WasInit(SDL_INIT_EVERYTHING) )
		{
			DEBUG( "Shutting down SDL...");
			SDL_Quit();
			DEBUGF;
		}

}
