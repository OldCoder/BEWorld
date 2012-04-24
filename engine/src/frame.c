#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "SDL.h"
#define USE_RWOPS 1
#include "SDL_rwops.h"
#include "common.h"
#include "frame.h"
#ifdef WITH_IMAGE
#include "SDL_image.h"
#endif









/*
 * get some info about a frame
 */
int frame_info(frame *f, int *w, int *h, int *type)
{
	/* a failsafe */
	if( !f )
		return ERR;

	*w = f->w;
	*h = f->h;
	*type = f->tag;

	/* and, done! */
	return 0;
}








/*
 * add a frame
 */
frame *frame_create(int type, int w, int h, const void *data, const void *aux)
{
	/* auxiliary */
	frame *f;
	const color *key;

	/* allocate the new frame */
	f = ck_calloc(1, sizeof(frame));


	/* now, copy the data into the frame */
	switch(type)
		{
			case FRAME_NONE:
				break;

			case FRAME_RGBA:
				/*
				 * allocate the surface.  if some data has been
				 * supplied, unpack and copy in the surface
				 */
				f->data = ck_malloc(w * h * RGBA_BYTES);
				if( data )
					memcpy(f->data, data, w * h * RGBA_BYTES);
				break;


			case FRAME_RGB:
				/*
				 * allocate the surface.  if some data has been
				 * supplied, unpack and copy in the surface
				 */
				f->data = ck_malloc(w * h * RGBA_BYTES);
				if( data )
					unpack_rgb(w * h, data, f->data);
				break;


			case FRAME_HL:
			case FRAME_SL:
			case FRAME_BR:
			case FRAME_XOR:
				/* allocate the memory for the user data and copy */
				f->data = ck_malloc(w * h * RGBA_BYTES);
				if( data )
					unpack_rgb(w * h, data, f->data);
				break;


			case FRAME_CT:
			case FRAME_SAT:
				/* allocate the memory for the user data and copy */
				f->data = ck_malloc(w * h);
				if( data )
					memcpy( f->data, data, w * h);
				break;


			case FRAME_DISPL:
				/* allocate and copy displacement data for this sprite frame */
				f->data = ck_malloc(w * h * DISPL_SPAN * sizeof(short));
				if( data )
					memcpy(f->data, data, w * h * DISPL_SPAN * sizeof(short));
				break;


			case FRAME_CONVO:
				/* allocate the memory for the user data and copy */
				f->data = ck_malloc(w * h);
				f->aux = ck_malloc(sizeof(convolution));

				if( data && aux )
					{
						memcpy(f->data, data, w * h);
						memcpy(f->aux, aux, sizeof(convolution));
					}
				break;


			case FRAME_LUT:
				/* allocate the memory for the bitmask and copy */
				f->data = ck_malloc(w * h);
				f->aux = ck_malloc(sizeof(lut));

				if( data && aux )
					{
						memcpy( f->data, data, w * h);
						memcpy( f->aux, aux, sizeof(lut));
					}
				break;



			default:
				/* unknown frame type */
				free(f);
				return NULL;

		}



	/* now store the frame data */
	f->tag = type;
	f->w = w;
	f->h = h;

	f->pixel.rshift = 0;
	f->pixel.gshift = 8;
	f->pixel.bshift = 16;
	f->pixel.ashift = 24;

	/* and set the upper bounds on the clipping rectangle */
	f->clip_rect.x2 = w;
	f->clip_rect.y2 = h;

	/* and we're done! */
	return f;

}











/*
 * duplicate a frame
 */
frame *frame_copy(frame *fr)
{
	/* the necessary frame pointers */
	frame *new;

	/* failsafe */
	if( !fr )
		return NULL;


	/* allocate the new frame */
	new = ck_calloc(1, sizeof(frame));
	new->tag = fr->tag;
	new->w = fr->w;
	new->h = fr->h;
	new->pixel = fr->pixel;

	/* and copy it .. */
	switch(fr->tag)
		{
			case FRAME_NONE:
				break;

			case FRAME_RGBA:
			case FRAME_RGB:
			case FRAME_HL:
			case FRAME_SL:
			case FRAME_BR:
			case FRAME_XOR:
				/* allocate the rgb data area and copy it over */
				new->data = ck_malloc(fr->w * fr->h * RGBA_BYTES);
				memcpy(new->data, fr->data, fr->w * fr->h * RGBA_BYTES);
				break;


			case FRAME_CT:
			case FRAME_SAT:
				/* allocate the rgb data area and copy it over */
				new->data = ck_malloc(fr->w * fr->h);
				memcpy(new->data, fr->data, fr->w * fr->h);
				break;


			case FRAME_DISPL:
				/* allocate and copy the displacement data */
				new->data = ck_malloc(fr->w * fr->h * DISPL_SPAN * sizeof(short));
				memcpy(new->data, fr->data, fr->w * fr->h * DISPL_SPAN * sizeof(short) );
				break;


			case FRAME_CONVO:
				/* allocate memory for pixel mask, kernel, and scratchpad surface */
				new->data = ck_malloc(fr->w * fr->h);
				new->aux = ck_malloc(sizeof(convolution));

				/* and copy */
				memcpy(new->data, fr->data, fr->w * fr->h);
				memcpy(new->aux, fr->aux, sizeof(convolution));
				break;


			case FRAME_LUT:
				/* allocate the bit mask and table memory */
				new->data = ck_malloc(fr->w * fr->h);
				new->aux = ck_malloc(sizeof(lut));

				/* and copy */
				memcpy(new->data, fr->data, fr->w * fr->h);
				memcpy(new->aux, fr->aux, sizeof(lut));
				break;

		}


	/* and duplicate the frame's pixel mask */
	if( fr->mask )
		{
			new->mask = ck_malloc(fr->w * fr->h);
			memcpy(new->mask, fr->mask, fr->w * fr->h);
		}
	else
		new->mask = NULL;


	/* and we're done! */
	return new;

}







/*
 * delete a frame
 */
void frame_delete(frame *fr)
{
	/* failsafe */
	if( !fr )
		return;

	/* free the data structures used by this frame type */
	switch(fr->tag)
		{
			case FRAME_NONE:
				break;
			case FRAME_RGBA:
			case FRAME_RGB:
			case FRAME_HL:
			case FRAME_SL:
			case FRAME_BR:
			case FRAME_CT:
			case FRAME_SAT:
			case FRAME_DISPL:
			case FRAME_XOR:
				free(fr->data);
				break;
			case FRAME_CONVO:
			case FRAME_LUT:
				free(fr->data);
				free(fr->aux);
				break;
		}

	/* and any pixel mask that may be set */
	if( fr->mask )
		free(fr->mask);

	/* and last, delete the frame */
	free(fr);

}






/*
 * set a frame offset
 */
void frame_set_offset(frame *fr, int x, int y)
{
	/* failsafe */
	if( !fr )
		return;

	fr->offset.x = x;
	fr->offset.y = y;

}








/*
 * set a frame's pixel mask
 */
int frame_set_mask(frame *fr, const unsigned char *data)
{
	/* failsafe */
	if( !fr || !data)
		return ERR;

	/* now, allocate the memory and copy the data .. note the use of realloc */
	fr->mask = ck_realloc(fr->mask, fr->w * fr->h);
	memcpy(fr->mask, data, fr->w * fr->h);

	/* all ok */
	return 0;

}





/*
 * set a frame's pixel mask fro m a source RGB frame.  the pixel
 * mask is generated either by the transparency of the source
 * frame or by desaturating the source image and using the
 * resulting pixel value to determine whether or not the pixel is
 * on.
 */
int frame_set_mask_from(frame *fr, frame *src)
{
	/* .. variables for the desaturation and pixel determination */
	int i;
	unsigned char *rgb, *mask;

	/* failsafe */
	if( !fr || !src || (src->tag != FRAME_RGB && src->tag != FRAME_RGBA) )
		return ERR;

	/* now, allocate the memory and set the pixel mask */
	fr->mask = ck_realloc(fr->mask, fr->w * fr->h);


	/* for alpha frames, use alpha >= 128 as a "hot" pixel */
	if( src->tag == FRAME_RGBA )
		{
			/* check the transparency of each original pixel */
			rgb = src->data;
			mask = fr->mask;
			for( i=0; i < fr->w * fr->h; i++ )
				{
					*mask = *(rgb + (fr->pixel.ashift>>3)) >= A_MID ? 1 : 0;
					rgb += RGBA_BYTES;
					mask++;
				}
		}
	else
		{
			/* check the desaturated value of each original pixel */
			rgb = src->data;
			mask = fr->mask;
			for( i=0; i < fr->w * fr->h; i++ )
				{
					*mask = desaturate_pixel(rgb, fr->pixel) >= A_MID ? 1 : 0;
					rgb += RGBA_BYTES;
					mask++;
				}
		}

	/* all ok */
	return 0;

}








/*
 * create a new frame from a selection of the given frame ..
 * note that frame slicing only works on RGB frames.
 */
frame *frame_slice(frame *fr, int x, int y, int w, int h)
{
	/* .. variables for the data copy */
	int i;
	unsigned char *src, *dest;

	/* the necessary frame pointers */
	frame *new;


	/* failsafe */
	if( !fr || (fr->tag != FRAME_RGB && fr->tag != FRAME_RGBA) )
		return NULL;

	/* test for invalid requested dimensions */
	if( x >= fr->w || x+w <= 0 || y >= fr->h || y+h <= 0 || w <= 0 || h <= 0 )
		return NULL;


	/* set up the clip rectangle */
	if( x < 0 )
		{
			w -= x;
			x = 0;
		}
	if( y < 0 )
		{
			h -= y;
			y = 0;
		}
	if( x+w >= fr->w )
		w = fr->w - x;
	if( y+h >= fr->h )
		h = fr->h - y;


	/* allocate the new frame */
	new = frame_create(fr->tag, w, h, NULL, NULL);

	/* copy the data */
	src = fr->data + (x + fr->w * y) * RGBA_BYTES;
	dest = new->data;
	for( i=0; i < h; i++ )
		{
			memcpy(dest, src, w * RGBA_BYTES);
			src += fr->w * RGBA_BYTES;
			dest += w * RGBA_BYTES;
		}


	/* if there is a pixel mask, create a slice of it as well */
	if( fr->mask )
		{
			/* by allocating the mask buffer .. */
			new->mask = ck_malloc(w * h);

			/* and copying out the slice */
			src = fr->mask + x + fr->w * y;
			dest = new->mask;
			for( i=0; i < h; i++ )
				{
					memcpy(dest, src, w);
					src += fr->w;
					dest += w;
				}

		}

	/* and copy the pixel format */
	new->pixel = fr->pixel;

	/* ok, done! */
	return new;

}





/*
 * convert a frame to a new type ..
 * note that conversion only works on RGB(A) frames.
 */
frame *frame_convert(frame *fr, int type, const void *aux)
{
	int i;

	/* for use in some conversions .. */
	unsigned char *src, *dest;
	frame *blend;
	point ofs;


	/* failsafe */
	if( !fr || (fr->tag != FRAME_RGB && fr->tag != FRAME_RGBA) || type == FRAME_DISPL )
		return NULL;


	switch(type)
		{
			/*
			 * just set the frame type
			 */
			case FRAME_RGBA:
			case FRAME_RGB:
			case FRAME_XOR:
				fr->tag = type;
				break;


			case FRAME_HL:
			case FRAME_SL:
				/*
				 * rgba frames are converted to hard- and soft-lighting frames by
				 * rendering the frame over an all-neutral frame to reflect the alpha
				 * transparency of the original frame.  rgb frames are left unchanged.
				 */
				if( fr->tag == FRAME_RGBA )
					{
						/* prepare a neutral frame */
						blend = frame_create(FRAME_RGBA, fr->w, fr->h, NULL, NULL);
						memset(blend->data, 0x80, blend->w * blend->h * RGBA_BYTES);

						/* lay this frame down onto the neutral one */
						ofs.x = 0;
						ofs.y = 0;
						system_frame.rgba(blend, fr, &ofs);

						/* copy out the new frame data */
						memcpy(fr->data, blend->data, fr->w * fr->h * RGBA_BYTES);

						/* and free the blending frame */
						frame_delete(blend);

					}

				/* update the frame tag and done! */
				fr->tag = type;
				break;


			case FRAME_BR:
				/*
				 * rgba frames are converted to brightness frames by rendering the frame
				 * over an all-neutral frame to reflect the alpha transparency of the
				 * original frame.  rgb frames are left unchanged.
				 */
				if( fr->tag == FRAME_RGBA )
					{
						/* prepare a neutral frame */
						blend = frame_create(FRAME_RGBA, fr->w, fr->h, NULL, NULL);
						memset(blend->data, 0x40, blend->w * blend->h * RGBA_BYTES);

						/* lay this frame down onto the neutral one */
						ofs.x = 0;
						ofs.y = 0;
						system_frame.rgba(blend, fr, &ofs);

						/* copy out the new frame data */
						memcpy(fr->data, blend->data, fr->w * fr->h * RGBA_BYTES);

						/* and free the blending frame */
						frame_delete(blend);

					}

				/* update the frame tag and done! */
				fr->tag = type;
				break;


			case FRAME_CT:
			case FRAME_SAT:
				/*
				 * for these types, the rgb data is converted to greyscale
				 */
				src = fr->data;
				dest = fr->data;

				for( i=0; i < fr->w * fr->h; i++ )
					{
						*dest = desaturate_pixel(src, fr->pixel);
						src += RGBA_BYTES;
						dest++;
					}

				/* update the frame tag and done! */
				fr->data = ck_realloc(fr->data, fr->w * fr->h);
				fr->tag = type;
				break;


			case FRAME_CONVO:
				/*
				 * if the original frame has an alpha component, use the alpha
				 * midpoint as the cutoff for the pixel mask.  if it doesn't,
				 * use the desaturated rgb midpoint instead.
				 */
				src = fr->data;
				dest = fr->data;

				if( fr->tag == FRAME_RGBA )
					{
						for( i=0; i < fr->w * fr->h; i++ )
							{
								*dest = *(src + (system_pixel.ashift>>3)) >= A_MID ? 1 : 0;
								src += RGBA_BYTES;
								dest++;
							}
					}
				else
					{
						for( i=0; i < fr->w * fr->h; i++ )
							{
								*dest = desaturate_pixel(src, fr->pixel) >= A_MID ? 1 : 0;
								src += RGBA_BYTES;
								dest++;
							}
					}


				/* now prepare the auxiliary and scratchpad data */
				fr->data = ck_realloc(fr->data, fr->w * fr->h);
				fr->aux = ck_malloc(sizeof(convolution));

				/* copy the convolution definition */
				memcpy(fr->aux, aux, sizeof(convolution));

				/* and done! */
				fr->tag = type;
				break;


			case FRAME_LUT:
				/*
				 * if the original frame has an alpha component, use the alpha
				 * midpoint as the cutoff for the pixel mask.  if it doesn't,
				 * use the desaturated rgb midpoint instead.
				 */
				src = fr->data;
				dest = fr->data;

				if( fr->tag == FRAME_RGBA )
					{
						for( i=0; i < fr->w * fr->h; i++ )
							{
								*dest = *(src + (system_pixel.ashift>>3)) >= A_MID ? 1 : 0;
								src += RGBA_BYTES;
								dest++;
							}
					}
				else
					{
						for( i=0; i < fr->w * fr->h; i++ )
							{
								*dest = desaturate_pixel(src, fr->pixel) >= A_MID ? 1 : 0;
								src += RGBA_BYTES;
								dest++;
							}
					}

				/* now prepare the auxiliary data */
				fr->data = ck_realloc(fr->data, fr->w * fr->h);
				fr->aux = ck_malloc(sizeof(lut));

				/* copy in the lookup table */
				memcpy(fr->aux, aux, sizeof(lut));

				/* and done! */
				fr->tag = type;
				break;

		}

	return fr;

}











/*
 * create an effect frame from a given frame.
 */
frame *frame_effect(frame *fr, int type, ...)
{
	/* drop-shadow inputs */
	int x, y, blur;
	color *c;

	/* counters and scratchpad variables */
	int i;
	point ofs;

	int32_t packed_c;
	unsigned char *buf;

	/* a scratch convolution kernel frame */
	frame *cf;
	unsigned char *cf_buf;
	convolution cf_kern;


	/* the output frame */
	frame *new;

	va_list args;


	/* failsafe */
	if( !fr || (fr->tag != FRAME_RGB && fr->tag != FRAME_RGBA) )
		return NULL;

	/* start reading the variadic args */
	va_start(args, type);


	switch(type)
		{
			case FRAME_EFFECT_DROP_SHADOW:
				/*
				 * generate a drop shadow from the given rgb frame ..
				 * for this, we need an x and y offset, a blur
				 * dimension, and a shadow color.
				 *
				 * the result frame will be expanded by the blur dimension.
				 */
				x = va_arg(args, int);
				y = va_arg(args, int);
				blur = va_arg(args, int);
				c = va_arg(args, color *);

				/*
				 * prepare the shadow frame, setting a border around the original frame
				 * by rounding the blur dimension down to the nearest even number.
				 *
				 * the magic number 0x40 here is the brightness filter neutral value.
				 */
				new = frame_create(FRAME_RGBA, fr->w + (blur & ~1) * 2, fr->h + (blur & ~1) * 2, NULL, NULL);
				memset(new->data, 0x40, new->w * new->h * RGBA_BYTES);

				/* draw the original frame onto the shadow frame */
				ofs.x = blur & ~1;
				ofs.y = blur & ~1;
				system_frame.rgba(new, fr, &ofs);

				/* convert it to a brightness frame .. */
				new->pixel = fr->pixel;
				new = frame_convert(new, FRAME_BR, NULL);

				/* .. and reduce all pixels where alpha < A_MID to the given color. */
				buf = new->data;
				packed_c = (c->r << new->pixel.rshift) | (c->g << new->pixel.gshift) | (c->b << new->pixel.bshift) | (0xff << new->pixel.ashift);

				for( i=0; i < new->w * new->h; i++ )
					{
						*(int32_t *)buf = *(buf + (new->pixel.ashift>>3)) >= A_MID ? packed_c : 0x40404040;
						buf += RGBA_BYTES;
					}


				/*
				 * last, prepare a convolution kernel frame
				 */
				cf_buf = ck_malloc(new->w * new->h);
				memset(cf_buf, 1, new->w * new->h);

				/* set up a box blur */
				cf_kern.kw = blur;
				cf_kern.kh = blur;
				for( i=0; i < blur * blur; i++ )
					cf_kern.kernel[i] = 1;
				cf_kern.divisor = blur * blur;
				cf_kern.offset = 0;

				/* and create the frame */
				cf = frame_create(FRAME_CONVO, new->w, new->h, cf_buf, &cf_kern);

				/* now, render the convolution kernel onto the shadow frame */
				ofs.x = 0;
				ofs.y = 0;
				system_frame.convo(new, cf, &ofs);

				/* and we're done */
				free(cf_buf);
				frame_delete(cf);

				/* store the drop shadow offset, and that's it */
				frame_set_offset(new, x - (blur & ~1), y - (blur & ~1));

				break;


			default:
				/* unknown effect type */
				return(NULL);

		}


	/* ok, done! */
	return new;

}














/*
 * load the named file and store it into the results buffer
 */
frame *frame_from_disk(const char *file)
{
	SDL_Surface *src;
	frame *fr;

	/* load the file */
#ifdef WITH_IMAGE
	src = IMG_Load(file);
#else
	src = SDL_LoadBMP(file);
#endif

	if( !src )
		return NULL;

	/* call the surface-specific unpacker */
	fr = img_unpack(src);

	/* free the temp surface */
	SDL_FreeSurface(src);

	/* pass back the newly-created frame */
	return fr;

}






/*
 * load the image stored in the provided buffer and store it into the results buffer
 */
frame *frame_from_buffer(int len, const unsigned char *data)
{
	/* the structures to hold the SDL-parsed data */
	SDL_Surface *src;
	SDL_RWops *rw_buf;

	frame *fr;

	/* make the RWops buffer .. */
	rw_buf = SDL_RWFromConstMem(data, len);
	if( !rw_buf )
		fatal("RWops buffer alloc failed!",99);

	/* load the file */
#ifdef WITH_IMAGE
	src = IMG_Load_RW(rw_buf, 1);
#else
	src = SDL_LoadBMP_RW(rw_buf, 1);
#endif

	if( !src )
		return NULL;

	/* call the surface-specific unpacker */
	fr = img_unpack(src);

	/* free the temp surface */
	SDL_FreeSurface(src);

	/* pass back the new frame */
	return fr;

}








/*
 * unpack the image to plain ol' RGB data
 */
static frame *img_unpack(SDL_Surface *img)
{
	int i;

	/* the pixel format */
	SDL_PixelFormat pix =
#ifdef WITH_SDL13
	{ SDL_PIXELFORMAT_RGBA8888, NULL, 32, 4, {0, 0},  0xff, 0xff00, 0xff0000, 0xff000000,  0, 0, 0, 0,  0, 8, 16, 24,  0, NULL };
#else
	{ NULL, 32, 4,  0, 0, 0, 0,  0, 8, 16, 24,  0xff, 0xff00, 0xff0000, 0xff000000,  0, 255 };
#endif


	/* the SDL surfaces and pointers used in unpacking the SDL-loaded data */
	SDL_Surface *surf;
	void *src, *dest;

	/* the result */
	frame *fr;

	/*
	 * first, convert the given SDL surface, which could be any pixel format (it's just
	 * been loaded from disk..), into the predefined display pixel format.
	 */
	surf = SDL_ConvertSurface(img, &pix, 0);
	if( !surf )
		fatal("SDL_ConvertSurface failed!",98);

	SDL_LockSurface(surf);

	/* then, create the frame from the pixel data .. */
	fr = frame_create(FRAME_RGBA, surf->w, surf->h, surf->pixels, NULL);
	fr->pixel.rshift = 0;
	fr->pixel.gshift = 8;
	fr->pixel.bshift = 16;
	fr->pixel.ashift = 24;

	/* last, free the sdl surfaces used! */
	SDL_UnlockSurface(surf);
	SDL_FreeSurface(surf);

	/* and done !*/
	return fr;

}
