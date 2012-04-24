#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "SDL.h"
#include "common.h"
#include "io.h"



/* the keyboard-mapping equivalents for the joysticks */
static struct input_def key_defs[MAX_JOY];

static int joy_ct;
static SDL_Joystick *joy[MAX_JOY];

static int has_quit;



/* initialize the joystick and keyboard mappings */
void init_io()
{
	int i;


	DEBUG( "Initializing joystick...");
	if( !SDL_InitSubSystem(SDL_INIT_JOYSTICK) )
		{

			/* success!	let's see if we have a joystick */
			joy_ct = SDL_NumJoysticks();
			if( joy_ct )
				{
					/* make sure we don't try to read in too many joysticks .. */
					if( joy_ct >= MAX_JOY )
						joy_ct = MAX_JOY;

					DEBUG_N("found %i...",joy_ct);

					/* .. and read in one at a time. */
					for( i=0; i < joy_ct; i++ )
						joy[i] = SDL_JoystickOpen(i);

				}

			DEBUGF;

		}
	else
		DEBUGNF;



	DEBUG( "Initializing default keys..." );
	memset(&key_defs, 0, sizeof(struct input_def) * MAX_JOY);

#ifdef WITH_SDL13
	io_assign( 0, IO_AXIS, 0, IO_LEFT, SDL_SCANCODE_LEFT );
	io_assign( 0, IO_AXIS, 0, IO_RIGHT, SDL_SCANCODE_RIGHT );
	io_assign( 0, IO_AXIS, 1, IO_LEFT, SDL_SCANCODE_UP );
	io_assign( 0, IO_AXIS, 1, IO_RIGHT, SDL_SCANCODE_DOWN );

	io_assign( 0, IO_HAT, 0, IO_UP, SDL_SCANCODE_W );
	io_assign( 0, IO_HAT, 0, IO_RIGHT, SDL_SCANCODE_D );
	io_assign( 0, IO_HAT, 0, IO_DOWN, SDL_SCANCODE_S );
	io_assign( 0, IO_HAT, 0, IO_LEFT, SDL_SCANCODE_A );

	io_assign( 0, IO_BUTTON, 0, SDL_SCANCODE_LCTRL );
	io_assign( 0, IO_BUTTON, 1, SDL_SCANCODE_LALT );
	io_assign( 0, IO_BUTTON, 2, SDL_SCANCODE_Z );
	io_assign( 0, IO_BUTTON, 3, SDL_SCANCODE_X );
#else
	io_assign( 0, IO_AXIS, 0, IO_LEFT, SDLK_LEFT );
	io_assign( 0, IO_AXIS, 0, IO_RIGHT, SDLK_RIGHT );
	io_assign( 0, IO_AXIS, 1, IO_LEFT, SDLK_UP );
	io_assign( 0, IO_AXIS, 1, IO_RIGHT, SDLK_DOWN );

	io_assign( 0, IO_HAT, 0, IO_UP, SDLK_w );
	io_assign( 0, IO_HAT, 0, IO_RIGHT, SDLK_d );
	io_assign( 0, IO_HAT, 0, IO_DOWN, SDLK_s );
	io_assign( 0, IO_HAT, 0, IO_LEFT, SDLK_a );

	io_assign( 0, IO_BUTTON, 0, SDLK_LCTRL );
	io_assign( 0, IO_BUTTON, 1, SDLK_LALT );
	io_assign( 0, IO_BUTTON, 2, SDLK_z );
	io_assign( 0, IO_BUTTON, 3, SDLK_x );
#endif

	DEBUGF;


	has_quit = 0;

}








/* retrieve the current input state and return a useful array */
int io_fetch(int num, input *io)
{
	int i,lim;


	/* these store temporary sdl info */
	SDL_Event event;
	Uint8 *keys;
	Sint16 ares;	/* axis results */
	Uint8 hres;	 /* hat results */



	/* fetch events first!	and check if quit is requested? */
	while(SDL_PollEvent(&event))
		if( event.type == SDL_QUIT )
		 has_quit = 1;




	/* but, after respecting the quit-request, ignore out-of-range input requests */
	if( num < 0 || num >= MAX_JOY )
		return ERR;




#ifdef WITH_SDL13
	/* read in the input state, 1.3-style */
	keys = SDL_GetKeyboardState(NULL);

	/* fetch the fixed-assignment keys */
	io->tab = keys[SDL_SCANCODE_TAB] ? 1 : 0;
	io->esc = keys[SDL_SCANCODE_ESCAPE] ? 1 : 0;
	io->sel = (keys[SDL_SCANCODE_RETURN] || keys[SDL_SCANCODE_KP_ENTER]) ? 1 : 0;
	io->space = keys[SDL_SCANCODE_SPACE] ? 1 : 0;

	/* pause key, or has the app lost focus? */
	io->pause = ( keys[SDL_SCANCODE_PAUSE] || !(SDL_APPACTIVE & SDL_GetAppState()) ) ? 1 : 0;

#else
	/* read in the input state, 1.2-style */
	keys = SDL_GetKeyState(NULL);

	/* fetch the fixed-assignment keys */
	io->tab = keys[SDLK_TAB] ? 1 : 0;
	io->esc = keys[SDLK_ESCAPE] ? 1 : 0;
	io->sel = (keys[SDLK_RETURN] || keys[SDLK_KP_ENTER]) ? 1 : 0;
	io->space = keys[SDLK_SPACE] ? 1 : 0;

	/* pause key, or has the app lost focus? */
	io->pause = ( keys[SDLK_PAUSE] || !(SDL_APPACTIVE & SDL_GetAppState()) ) ? 1 : 0;
#endif

	if( joy[num] )
		SDL_JoystickUpdate();



	/*
	 * read in axis-keyboard mapping
	 */
	for( i=0; i < MAX_AXES; i++ )
		{

			/* if there are key-defs attached to this input and axis .. */
			if( key_defs[num].axis[i].l || key_defs[num].axis[i].r )
				{

					/* check the axis for conflicting keypresses */
					if( keys[ key_defs[num].axis[i].l ] && keys[ key_defs[num].axis[i].r ] )
						{
							/* prefer the most recent one */
							if( key_defs[num].axis_flag[i] == 1 )
							 io->axis[i] = -RANGE;
							else if( key_defs[num].axis_flag[i] == -1 )
							 io->axis[i] = RANGE;
							else
							 {
								 io->axis[i] = 0;
								 key_defs[num].axis_flag[i] = 0;
							 }
						}
					else if( keys[ key_defs[num].axis[i].l ] )
						{
							io->axis[i] = -RANGE;
							key_defs[num].axis_flag[i] = -1;
						}
					else if( keys[ key_defs[num].axis[i].r ] )
						{
							io->axis[i] = RANGE;
							key_defs[num].axis_flag[i] = 1;
						}
					else
						{
							io->axis[i] = 0;
							key_defs[num].axis_flag[i] = 0;
						}

				}
			else
				io->axis[i] = 0;	/* no key defs mean no activity */

		}




	/*
	 * parse the keyboard for hat activity
	 */
	for( i=0; i < MAX_HATS; i++ )
		{

			/* if there are key defs for this hat - horizontal .. */
			if( key_defs[num].hat[i].l || key_defs[num].hat[i].r )
				{

					/* check the hat for conflicting keypresses - horizontal */
					if( keys[ key_defs[num].hat[i].l ] && keys[ key_defs[num].hat[i].r ] )
						{
							if( key_defs[num].hat_flag[i].horiz == 1 )
								io->hat[i].x = -1;
							else if( key_defs[num].hat_flag[i].horiz == -1 )
								io->hat[i].x = 1;
							else
								{
									io->hat[i].x = 0;
									key_defs[num].hat_flag[i].horiz = 0;
								}
						}
					else if( keys[ key_defs[num].hat[i].l ] )
						{
							io->hat[i].x = -1;
							key_defs[num].hat_flag[i].horiz = -1;
						}
					else if( keys[ key_defs[num].hat[i].r ] )
						{
							io->hat[i].x = 1;
							key_defs[num].hat_flag[i].horiz = 1;
						}
					else
						{
							io->hat[i].x = 0;
							key_defs[num].hat_flag[i].horiz = 0;
						}

				}
			else
				io->hat[i].x = 0;	/* no key defs mean no activity */


			/* if there are key defs for this hat - vertical .. */
			if( key_defs[num].hat[i].u || key_defs[num].hat[i].d )
				{

					/* check the hat for conflicting keypresses - vertical */
					if( keys[ key_defs[num].hat[i].u ] && keys[ key_defs[num].hat[i].d ] )
						{
							if( key_defs[num].hat_flag[i].vert == 1 )
								io->hat[i].y = -1;
							else if( key_defs[num].hat_flag[i].vert == -1 )
								io->hat[i].y = 1;
							else
								{
									io->hat[i].y = 0;
									key_defs[num].hat_flag[i].vert = 0;
								}
						}
					else if( keys[ key_defs[num].hat[i].u ] )
						{
							io->hat[i].y = -1;
							key_defs[num].hat_flag[i].vert = -1;
						}
					else if( keys[ key_defs[num].hat[i].d ] )
						{
							io->hat[i].y = 1;
							key_defs[num].hat_flag[i].vert = 1;
						}
					else
						{
							io->hat[i].y = 0;
							key_defs[num].hat_flag[i].vert = 0;
						}

				}
			else
				io->hat[i].y = 0;	/* again, no key defs mean no activity */

		}






	/*
	 * and last, check for key-mapped button activity
	 */
	for( i=0; i < MAX_BUTTONS; i++ )
		io->button[i] = key_defs[num].button[i] ? (keys[ key_defs[num].button[i] ] ? 1 : 0) : 0;





	/*
	 * now read the joystick input
	 */
	if( joy[num] ) {


		/* read the axes */
		lim = SDL_JoystickNumAxes(joy[num]);
		for( i=0; i < lim; i++ )
			{
				ares = SDL_JoystickGetAxis(joy[num], i);

				/* only use the joystick input if the axis has sufficient motion */
				if( ares < -THRESH || ares > THRESH ) {

					io->axis[i] = ares >> SHIFT;

					/* and make sure it's pinned to the desired range */
					if( io->axis[i] < -RANGE )
						io->axis[i] = -RANGE;

				}

			}



		/* the hats need to be parsed a bit */
		lim = SDL_JoystickNumHats(joy[num]);
		for( i=0; i < lim; i++ )
			{
				hres = SDL_JoystickGetHat(joy[num], i);

				if( hres & SDL_HAT_UP )
					io->hat[i].y = -1;
				else if( hres & SDL_HAT_DOWN )
					io->hat[i].y = 1;

				if( hres & SDL_HAT_LEFT )
					io->hat[i].x = -1;
				else if( hres & SDL_HAT_RIGHT )
					io->hat[i].x = 1;

			}


		/* and last, read the buttons */
		lim = SDL_JoystickNumButtons(joy[num]);
		for( i=0; i < lim; i++ )
			io->button[i] |= SDL_JoystickGetButton(joy[num], i);


		/* and map button 1 onto `select' */
		io->sel |= SDL_JoystickGetButton(joy[num], 0) ? 1 : 0;


	}


	return 0;

}









/*
 * a simple thing to reassign key inputs:
 * - type is one of IO_AXIS, IO_HAT, IO_BUTTON
 * -- if IO_AXIS, then pass in the axis #, axis direction (IO_LEFT or IO_RIGHT), and new key
 * -- if IO_HAT, then pass in the hat #, hat direction (IO_UP, IO_RIGHT, IO_DOWN, IO_LEFT), and new key
 * -- if IO_BUTTON, then pass in button # and new key
 */
void io_assign(int num, int type, ...)
{
	/* which axis, button, hat?  if an axis or hat, which direction? */
	int idx, dir;
	int key;

	va_list args;


	/* first, make sure the request is in range */
	if( num < 0 || num > (MAX_JOY-1) )
		return;


	/* start reading the variadic args */
	va_start(args, type);


	switch(type)
		{

			case IO_AXIS:
				/* load a key-def for one pole of an axis */
				idx = va_arg(args, int);
				dir = va_arg(args, int);
				key = va_arg(args, int);

				/* some safety-checking */
				if( idx < MAX_AXES )
					{
						if( dir == IO_LEFT )
							key_defs[num].axis[idx].l = key;
						else if( dir == IO_RIGHT )
							key_defs[num].axis[idx].r = key;
					}
				break;

			case IO_HAT:
				/* load a key-def for one direction of a hat */
				idx = va_arg(args, int);
				dir = va_arg(args, int);
				key = va_arg(args, int);

				/* some safety-checking */
				if( idx < MAX_HATS )
					{
						if( dir == IO_UP )
							key_defs[num].hat[idx].u = key;
						else if( dir == IO_RIGHT )
							key_defs[num].hat[idx].r = key;
						else if( dir == IO_DOWN )
							key_defs[num].hat[idx].d = key;
						else if( dir == IO_LEFT )
							key_defs[num].hat[idx].l = key;
					}
				break;


			case IO_BUTTON:
				/* load a key-def for one button */
				idx = va_arg(args, int);
				key = va_arg(args, int);

				/* some safety-checking */
				if( idx < MAX_BUTTONS )
					key_defs[num].button[idx] = key;

				break;
		}

	/* end the variadic args */
	va_end(args);

}






/* read a single keypress and return it */
int io_read_key()
{
	int i;

	/* the results from sdl */
	SDL_Event event;
	Uint8 *keys;
	int key_ct, kp_ct;
	int key_res;

	/*
	 * loop until we have a single keypress
	 */
	while(1)
		{

			/* first, read events */
			SDL_WaitEvent(&event);
			if( event.type == SDL_QUIT )
				exit(0);


			/* then, get keys */
#ifdef WITH_SDL13
			keys = SDL_GetKeyboardState(&key_ct);
#else
			keys = SDL_GetKeyState(&key_ct);
#endif

			/* and check to see if one or more are held down .. */
			for( i=0, kp_ct = 0, key_res = 0; i < key_ct; i++ )
				if( keys[i] )
					{
						key_res = i;
						kp_ct++;
					}

			/* if only one was held down, that's our result! */
			if( kp_ct == 1 )
				return key_res;

		}

}






/* grab all input and hide the mouse cursor */
void io_grab(int mode)
{
	/* was the cursor visible? */
	static int cvis = 0;

	if( mode )
		{
			/* first, grab the input */
			SDL_WM_GrabInput( SDL_GRAB_ON );

			/* then, grab the current cursor mode before disabling it */
			cvis = SDL_ShowCursor( SDL_QUERY );
			SDL_ShowCursor( SDL_DISABLE );
		}
	else
		{
			/* release the input-grab and restore the previous cursor mode */
			SDL_WM_GrabInput( SDL_GRAB_OFF );
			SDL_ShowCursor( cvis );
		}

}








/*
 * read the position and button firings of the requested mouse
 */
int io_mouse(int num, mouse *in)
{
	int i;
	SDL_Event event;

	/* button results */
	int b;


	/* fetch events first!	and check if quit is requested? */
	while(SDL_PollEvent(&event))
		if( event.type == SDL_QUIT )
			exit(0);


	/* but, after respecting the quit-request, ignore out-of-range input requests */
	if( num < 0 || num >= MAX_MOUSE )
		return -1;




	/* read the mouse */
	b = SDL_GetRelativeMouseState(&in->x, &in->y);

	/* and parse out the button results - the buttons start at 1 */
	for( i=0; i < 8; i++)
		in->button[i] = b & SDL_BUTTON(i+1) ? 1 : 0;

	return 0;


}






/*
 * has the user pressed the application-quit button?
 */
int io_has_quit()
{
	int res;

	/* zero the value after reading */
	res = has_quit;
	has_quit = 0;

	return res;

}








/*
 * wait until the input buffers are all totally clear, and then wait
 * until an input is set ..
 */
int io_wait(int fps)
{
	int num, i;

	/* the input buffer, and a pointer to scan */
	input io;
	char *io_p;

	/* the state we have, and the state we want */
	int have, want;


	/* zero out the input buffer */
	io_p = memset(&io, 0, sizeof(input));


	/* first, wait until the input buffers are totally empty */
	want = 0;
	while( want < 2 )
		{
			clock_wait(fps);

			/* let the user break out by pressing the application-close button */
			if( io_has_quit() )
				return ERR;


			/* loop across all inputs */
			for( num=0, have=0; num < MAX_JOY; num++ )
				{
					/* read the input buffer */
					io_fetch(num, &io);

					/* scan the input buffer for any signs of life */
					for( i=0; i < sizeof(input); i++ )
						if( *(io_p + i) )
							have = 1;

				}

			/*
			 * oh, so clever!  if we have nothing, and we want nothing, then change what we want,
			 * so that the next time through, we want something.  once we have something and we
			 * want something, then we're done.
			 */
			if( have == want )
				want++;


		}

	return 0;

}
