#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "SDL.h"
#include "SDL_opengl.h"
#include "common.h"
#include "graphics.h"




/*
 * available graphics options are:  output method (sdl or opengl),
 * platform (osx, linux, windows, etc), window mode (windowed or
 * full-screen), output rotation (0, 90, 180, 270).
 *
 * the active graphics mode is a bitmask:
 * sdl or hw-accel  0x0000000_
 * windowed or fs?  0x000000_0
 *
 */
static int display_rotation;
static int display_flags;
static int zoom;
static SDL_Surface *screen;




/* the rendering canvas */
frame *canvas;
dimensions canvas_overdraw = { 0, 0 };




/* for the optional accelerated blits */
#ifdef GL_BLIT
static GLuint gl_texture_id;
#endif

#ifdef OSX_BLIT
static GLuint osx_texture_id[2];
static frame *osx_canvas[2];      /* osx uses two gl-textures as a sort of double-buffering .. */
static int active_idx;            /* .. and this tracks the buffer in use. */
#endif










/*
 * open the graphics display.  there are two options:
 * - fullscreen (int)
 * - zoom factor (int)
 */
int graphics_open(int w, int h, int zf, int rot, int flags)
{
	int i;
	int dw, dh, sdlflags;
	SDL_PixelFormat *sdl_format;


	/* failsafe */
	if( canvas )
		return ERR_CANT_REOPEN;


	/*
	 * we are going to use video, so let's initialize and make blended drinks!
	 */
	sdlflags = SDL_SWSURFACE;

	/* Zoom factor out of bounds? */
	if( zf < 1 )
		zf = 1;

	/* Full-screen? */
	if( flags & GRAPHICS_FS )
		sdlflags |= SDL_FULLSCREEN;

	/* OpenGL-accelerated? */
#ifdef WITH_GL
	if( flags & GRAPHICS_ACCEL )
		sdlflags |= SDL_OPENGL;
#else
	/* a failsafe to ensure that non-accelerated builds always fall back to pure-sdl */
	flags &= ~GRAPHICS_ACCEL;

#endif

	/* Rotated? */
	if( rot == GRAPHICS_90 || rot == GRAPHICS_270 )
		{
			dw = h * zf;
			dh = w * zf;
		}
	else
		{
			dw = w * zf;
			dh = h * zf;
		}



	DEBUG("Initializing graphics...");
	if( SDL_InitSubSystem(SDL_INIT_VIDEO) < 0 )
		{
			DEBUGNF;
			return ERR_SDL_FAILED;
		}

	screen = SDL_SetVideoMode(dw, dh, RGBA_BITS, sdlflags);
	if( screen == NULL )
		{
			DEBUGNF;
			SDL_QuitSubSystem(SDL_INIT_VIDEO);	 /* shut down the SDL video subsystem */
			return ERR_SDL_VIDEO_FAILED;
		}
	DEBUGF;

	/* turn off the mouse cursor in full-screen mode */
	if( flags & GRAPHICS_FS )
		SDL_ShowCursor(SDL_DISABLE);
	else
		SDL_WM_SetCaption("The Brick Engine",NULL);



#ifdef WITH_GL

	/* if we've got an accelerated mode, set up the requisite opengl surface(s) .. */
	if( flags & GRAPHICS_ACCEL )
		{
			/* regardless of our target platform, initialize opengl thus. */
			glViewport(0, 0, dw, dh);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glOrtho(0, dw, -dh, 0, 0, 1000);
			glScalef(1.0, -1.0, 1.0);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();

			/* have we got a rotated display? */
			if( rot == GRAPHICS_90 )
				{
					glTranslatef(dw, 0, 0);
					glRotatef(90, 0, 0, 1);
				}
			else if( rot == GRAPHICS_180 )
				{
					glTranslatef(dw, dh, 0);
					glRotatef(180, 0, 0, 1);
				}
			else if( rot == GRAPHICS_270 )
				{
					glTranslatef(0, dh, 0);
					glRotatef(270, 0, 0, 1);
				}


			glDisable(GL_CULL_FACE);
			glDisable(GL_DEPTH_TEST);


#ifdef GL_BLIT
			/*
			 * opengl on most platforms uses a single texture surface with
			 * power-of-two dimensions.
			 */
			glEnable(GL_TEXTURE_2D);
			glGenTextures(1, &gl_texture_id);
			glBindTexture(GL_TEXTURE_2D, gl_texture_id);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_PRIORITY, 1);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, TEXTURE_W, TEXTURE_H, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, NULL);

#elif OSX_BLIT
			/*
			 * opengl on osx uses a pair texture surfaces, set to the size of
			 * the render canvas.
			 */
			glEnable(GL_TEXTURE_RECTANGLE_EXT);
			glGenTextures(2, osx_texture_id);
			for( i=0; i < 2; i++ )
				{
					/* create the render canvas */
					osx_canvas[i] = frame_create(FRAME_RGBA, w, h, NULL, NULL);

					/* configure the texture */
					glBindTexture(GL_TEXTURE_RECTANGLE_EXT, osx_texture_id[i]);
					glTextureRangeAPPLE(GL_TEXTURE_RECTANGLE_EXT, w * h * RGBA_BYTES, osx_canvas[i]->data);
					glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_SHARED_APPLE);
					glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
					glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
					glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
					glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
				}

#endif
	}

#endif


	/* now!  if there is an active graphics output, initialize the render surface */
	activate_canvas(w, h);

	/* save graphics state */
	display_rotation = rot;
	display_flags = flags;
	zoom = zf;


	/*
	 * now set the system-wide pixel format .. note that so far, every
	 * opengl platform i've seen favors the BGRA pixel arrangement.
	 */
	if( flags & GRAPHICS_ACCEL )
		set_pixel_order(16, 8, 0);
	else
		set_pixel_order(screen->format->Rshift, screen->format->Gshift, screen->format->Bshift);


	/* ok, done */
	return 0;

}











/*
 * close the graphics output
 */
void graphics_close()
{

	if( canvas )
		{
			/* re-enable the cursor */
			if( SDL_ShowCursor(SDL_QUERY) == SDL_DISABLE )
				SDL_ShowCursor(SDL_ENABLE);

			/* shut down the SDL portion of the graphics system */
			DEBUG("Shutting down graphics...");
			SDL_QuitSubSystem(SDL_INIT_VIDEO);


			/* if opengl support is enabled, check whether the accelerated graphics mode was set */
#ifdef WITH_GL

			if( display_flags & GRAPHICS_ACCEL )
				{
#ifdef GL_BLIT
					/* standard opengl?  free the texture .. */
					glDeleteTextures(1, &gl_texture_id);

#elif OSX_BLIT
					/* osx-specific opengl?  free the textures and the additional render surfaces .. */
					glDeleteTextures(2, osx_texture_id);
					frame_delete(osx_canvas[0]);
					frame_delete(osx_canvas[1]);

#endif
				}

#endif


		}

	/* and disable the active graphic mode */
	deactivate_canvas();
	DEBUGF;

}













/*
 * (re-)initialize the internal rendering canvas
 */
void activate_canvas(int w, int h)
{

	/* failsafe, in case of nonsense */
	if( w <= 0 || h <= 0 )
		return;

	if( w > MAX_WIDTH || h > MAX_HEIGHT )
		return;


	/* now, free the old canvas */
	if( canvas )
		frame_delete(canvas);

	/* and create the new one */
	canvas = frame_create(FRAME_RGB, w + canvas_overdraw.w * 2, h + canvas_overdraw.h * 2, NULL, NULL);

}






/*
 * remove the render canvas
 */
void deactivate_canvas()
{
	/* failsafe */
	if( canvas )
		{
			frame_delete(canvas);
			canvas = NULL;
		}

}


















/*
 * now, the most vexing part of the graphics system.  depending on the
 * compile-time settings, one of three show_rendered() routines will be
 * active:  pure sdl, opengl-based, or osx-optimized opengl-based.  what
 * follows are the three.  sdl is first.
 */
void show_rendered()
{
	int i, j, k, l, zc;
	unsigned char *src, *dest;

#ifdef WITH_GL
	/* .. used to span the texture */
	point skip;
	int cw, ch;
#endif


	/* First, the sdl blit */
	if( !(display_flags & GRAPHICS_ACCEL) )
		{

			/* copy the visible canvas to the screen surface and flip the display */
			SDL_LockSurface(screen);
			src = canvas->data + (canvas_overdraw.w + canvas->w * canvas_overdraw.h) * RGBA_BYTES;

			if( display_rotation == GRAPHICS_0 )
				{
					/*
					 * the screen is in normal orientation
					 */
					dest = screen->pixels;
					i = canvas->h - canvas_overdraw.h * 2;
					while( i-- )
						{
							zc = zoom;
							while( zc-- )
								{
									blit_line(canvas->w - canvas_overdraw.w * 2, zoom, src, dest);
									dest += screen->pitch;
								}
							src += canvas->w * RGBA_BYTES;

						}

				}
			else if( display_rotation == GRAPHICS_90 )
				{
					/*
					 * the screen is rotated 90 degrees clockwise
					 */
					dest = screen->pixels + (canvas->h * RGBA_BYTES * zoom) - RGBA_BYTES;

					for( i=0; i < canvas->h; i += 8 )
						{
							for( j=0; j < canvas->w; j += 8 )
								{
									blit_90( min(canvas->w - j, 8), min(canvas->h - i, 8), zoom, src, dest);
									src += 8 * RGBA_BYTES;
									dest += screen->pitch * 8 * zoom;
								}

							/* skip back up */
							src += (canvas->w * 7) * RGBA_BYTES;
							dest -= (screen->pitch * j * zoom) + 8 * RGBA_BYTES * zoom;

						}

				}
			else if( display_rotation == GRAPHICS_180 )
				{
					/*
					 * the screen is rotated 180 degrees
					 */
					dest = screen->pixels + (screen->pitch * canvas->h * zoom) - RGBA_BYTES;

					for( i=0; i < canvas->h; i += 8 )
						{
							for( j=0; j < canvas->w; j += 8 )
								{
									blit_180( min(canvas->w - j, 8), min(canvas->h - i, 8), zoom, src, dest);
									src += 8 * RGBA_BYTES;
									dest -= 8 * RGBA_BYTES * zoom;
								}

							/* skip back up */
							src += (canvas->w * 7) * RGBA_BYTES;
							dest -= (screen->pitch * 7) * zoom + screen->pitch;

						}

				}
			else if( display_rotation == GRAPHICS_270 )
				{
					/*
					 * the screen is rotated 90 degrees counter-clockwise
					 */
					dest = screen->pixels + (screen->pitch * canvas->w * zoom) - screen->pitch;

					for( i=0; i < canvas->h; i += 8 )
						{
							for( j=0; j < canvas->w; j += 8 )
								{
									blit_270( min(canvas->w - j, 8), min(canvas->h - i, 8), zoom, src, dest);
									src += 8 * RGBA_BYTES;
									dest -= screen->pitch * 8 * zoom;
								}

							/* skip back up */
							src += (canvas->w * 7) * RGBA_BYTES;
							dest += (screen->pitch * j * zoom) + 8 * RGBA_BYTES * zoom;

						}

				}



			/* now, create the frame */
			SDL_UnlockSurface(screen);
			SDL_Flip(screen);


		}
#ifdef WITH_GL
	else if( display_flags & GRAPHICS_ACCEL )
		{

			/* calculate the dimensions of the canvas */
			cw = canvas->w - canvas_overdraw.w * 2;
			ch = canvas->h - canvas_overdraw.h * 2;

#ifdef GL_BLIT
			/* and prepare the texture */
			glBindTexture(GL_TEXTURE_2D, gl_texture_id);
			glPixelStorei(GL_UNPACK_ROW_LENGTH, canvas->w);

			for( skip.x=0; skip.x < cw; skip.x += TEXTURE_W )
				for( skip.y=0; skip.y < ch; skip.y += TEXTURE_H )
					{

						glPixelStorei(GL_UNPACK_SKIP_PIXELS, skip.x + canvas_overdraw.w);
						glPixelStorei(GL_UNPACK_SKIP_ROWS, skip.y + canvas_overdraw.h);
						glTexSubImage2D(GL_TEXTURE_2D,
														0,
														0, 0,
														( cw - skip.x < TEXTURE_W ) ? cw - skip.x : TEXTURE_W,
														( ch - skip.y < TEXTURE_H ) ? ch - skip.y : TEXTURE_H,
														GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV,
														canvas->data);

						/* and draw it! */
						glBegin(GL_QUADS);
						glTexCoord2i(0, 0); glVertex2i(skip.x * zoom, skip.y * zoom);
						glTexCoord2i(0, 1); glVertex2i(skip.x * zoom, (skip.y + TEXTURE_H) * zoom);
						glTexCoord2i(1, 1); glVertex2i( (skip.x + TEXTURE_W) * zoom, (skip.y + TEXTURE_H) * zoom);
						glTexCoord2i(1, 0); glVertex2i( (skip.x + TEXTURE_W) * zoom, skip.y * zoom);
						glEnd();
					}

#elif OSX_BLIT
			/* blit the canvas to the proper osx-surface */
			src = canvas->data + (canvas_overdraw.w + canvas->w * canvas_overdraw.h) * RGBA_BYTES;
			dest = osx_canvas[active_idx]->data;
			for( i=0; i < (canvas->h - canvas_overdraw.h * 2); i++ )
				{
					memcpy(dest, src, (canvas->w - canvas_overdraw.w * 2) * RGBA_BYTES);
					src += canvas->w * RGBA_BYTES;
					dest += osx_canvas[active_idx]->w * RGBA_BYTES;
				}


			/* create the texture */
			glBindTexture(GL_TEXTURE_RECTANGLE_EXT, osx_texture_id[active_idx]);
			glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA, canvas->w - canvas_overdraw.w * 2, canvas->h - canvas_overdraw.h * 2, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, osx_canvas[active_idx]->data);

			/* draw it! */
			glBegin(GL_QUADS);
			glTexCoord2i(0, 0); glVertex2i(0, 0);
			glTexCoord2i(0, ch); glVertex2i(0, canvas->h * zoom);
			glTexCoord2i(cw, ch); glVertex2i(canvas->w * zoom, canvas->h * zoom);
			glTexCoord2i(cw, 0); glVertex2i(canvas->w * zoom, 0);
			glEnd();

			/* now flip the active_idx canvas */
			active_idx = 1 - active_idx;
#endif

			/* pretty easy, huh! */
			SDL_GL_SwapBuffers();

		}
#endif



}



static void blit_line(int len, int zc, unsigned char *src, unsigned char *dest)
{
	int i;

	/* do a memcpy for zoom = 1 */
	if( zc == 1 )
		memcpy(dest, src, len * RGBA_BYTES);
	else
		{
			/* for zoom > 1, copy each pixel several times */
			while( len-- )
				{
					i = zc;
					while( i-- )
						{
							*(int32_t *)(dest) = *(int32_t *)(src);
							dest += RGBA_BYTES;
						}

					/* and finally, advance the source */
					src += RGBA_BYTES;

				}

		}

}










/*
 * some routines to blit rotated subsets of the internal render canvas to
 * the sdl display surface
 */
static void blit_90(int w, int h, int zc, unsigned char *src, unsigned char *dest)
{
	int i;

	while( h-- )
		{
			i = zc;
			while( i-- )
				{
					blit_strip(w, GRAPHICS_90, zoom, src, dest);
					dest -= RGBA_BYTES;
				}
			/* skip to the next line */
			src += canvas->w * RGBA_BYTES;

		}

}


static void blit_180(int w, int h, int zc, unsigned char *src, unsigned char *dest)
{
	int i;

	while( h-- )
		{
			i = zc;
			while( i-- )
				{
					blit_strip(w, GRAPHICS_180, zoom, src, dest);
					dest -= screen->pitch;
				}
			/* skip to the next line */
			src += canvas->w * RGBA_BYTES;

		}

}


static void blit_270(int w, int h, int zc, unsigned char *src, unsigned char *dest)
{
	int i;

	while( h-- )
		{
			i = zc;
			while( i-- )
				{
					blit_strip(w, GRAPHICS_270, zoom, src, dest);
					dest += RGBA_BYTES;
				}
			/* skip to the next line */
			src += canvas->w * RGBA_BYTES;

		}

}


static void blit_strip(int len, int rot, int zc, unsigned char *src, unsigned char *dest)
{
	int i, inc;

	switch( rot )
		{
			case GRAPHICS_90:
				inc = screen->pitch;
				break;
			case GRAPHICS_180:
				inc = -RGBA_BYTES;
				break;
			case GRAPHICS_270:
				inc = -screen->pitch;
				break;
		}


	/* for zoom > 1, copy each pixel several times */
	while( len-- )
		{
			i = zc;
			while( i-- )
				{
					*(int32_t *)(dest) = *(int32_t *)(src);
					dest += inc;
				}

			/* and finally, advance the source */
			src += RGBA_BYTES;

		}

}
