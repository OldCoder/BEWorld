#include <stdio.h>
#include <stdlib.h>
#include "SDL.h"
#include "common.h"
#include "pixel.h"




/*
 * the rendering dispatcher, and a buffer for the displacement
 * and convolution frames
 */
pixel_fmt system_pixel = { 0, 8, 16, 24, 1 };
renderer system_frame;


unsigned char *scratchpad = NULL;
dimensions scratchpad_size = { 0, 0 };




/*
 * initialize the pixel-order-specific renderer
 */
void set_pixel_order(int r, int g, int b)
{
	/* save the pixel order */
	system_pixel.rshift = r;
	system_pixel.gshift = g;
	system_pixel.bshift = b;
	system_pixel.ashift = 48 - r - g - b;

	/*
	 * for now, we only distinguish between the little-endian (bgra) and
	 * big-endian (argb) pixel formats.
	 */
	if( system_pixel.ashift == 0 )
		{
			system_frame.rgb = rgb_frame_be;
			system_frame.rgba = rgba_frame_be;
			system_frame.hl = hl_frame_be;
			system_frame.sl = sl_frame_be;
			system_frame.br = br_frame_be;
			system_frame.ct = ct_frame_be;
			system_frame.sat = sat_frame_be;
			system_frame.displ = displ_frame_be;
			system_frame.convo = convo_frame_be;
			system_frame.lut = lut_frame_be;
			system_frame.xor = xor_frame_be;

			system_frame.rgb_scaled = rgb_frame_be_scaled;
			system_frame.rgba_scaled = rgba_frame_be_scaled;
			system_frame.hl_scaled = hl_frame_be_scaled;
			system_frame.sl_scaled = sl_frame_be_scaled;
			system_frame.br_scaled = br_frame_be_scaled;
			system_frame.ct_scaled = ct_frame_be_scaled;
			system_frame.sat_scaled = sat_frame_be_scaled;
			system_frame.displ_scaled = displ_frame_be_scaled;
			system_frame.convo_scaled = convo_frame_be_scaled;
			system_frame.lut_scaled = lut_frame_be_scaled;
			system_frame.xor_scaled = xor_frame_be_scaled;
		}
	else
		{
			system_frame.rgb = rgb_frame_le;
			system_frame.rgba = rgba_frame_le;
			system_frame.hl = hl_frame_le;
			system_frame.sl = sl_frame_le;
			system_frame.br = br_frame_le;
			system_frame.ct = ct_frame_le;
			system_frame.sat = sat_frame_le;
			system_frame.displ = displ_frame_le;
			system_frame.convo = convo_frame_le;
			system_frame.lut = lut_frame_le;
			system_frame.xor = xor_frame_le;

			system_frame.rgb_scaled = rgb_frame_le_scaled;
			system_frame.rgba_scaled = rgba_frame_le_scaled;
			system_frame.hl_scaled = hl_frame_le_scaled;
			system_frame.sl_scaled = sl_frame_le_scaled;
			system_frame.br_scaled = br_frame_le_scaled;
			system_frame.ct_scaled = ct_frame_le_scaled;
			system_frame.sat_scaled = sat_frame_le_scaled;
			system_frame.displ_scaled = displ_frame_le_scaled;
			system_frame.convo_scaled = convo_frame_le_scaled;
			system_frame.lut_scaled = lut_frame_le_scaled;
			system_frame.xor_scaled = xor_frame_le_scaled;
		}

	/* and make sure that future pixel operations adjust to this order */
	system_pixel.epoch++;

}








/*
 * convert an rgb buffer to rgba, setting the alpha component to max
 */
void unpack_rgb(int len, const unsigned char *src, unsigned char *dest)
{
	while( len-- )
		{
			*dest = *src;
			*(dest+1) = *(src+1);
			*(dest+2) = *(src+2);
			*(dest+3) = 0xff;

			dest += RGBA_BYTES;
			src += RGB_BYTES;
		}
}





/*
 * a pair of simple pixel-manipulation routines
 */
unsigned char desaturate_pixel(const unsigned char *src, pixel_fmt p)
{
	return (*(src + (p.rshift>>3) ) * R_WGT + *(src + (p.gshift>>3)) * G_WGT + *(src + (p.bshift>>3)) * B_WGT) >> WGT_DIV;
}









/*
 * swizzle the contents of the given frame to match the system pixel format
 */
void swizzle_pixels(frame *f)
{
	int i;

	/* the pixel buffer */
	unsigned char *buf;
	uint32_t pix;

	/* now, rearrange the pixel component order */
	buf = f->data;
	i = f->w * f->h;
	while( i-- )
		{
			pix = *(uint32_t *)buf;
			*(uint32_t *)buf = \
				(((pix >> f->pixel.rshift) & 0xff) << system_pixel.rshift) | \
				(((pix >> f->pixel.gshift) & 0xff) << system_pixel.gshift) | \
				(((pix >> f->pixel.bshift) & 0xff) << system_pixel.bshift) | \
				(((pix >> f->pixel.ashift) & 0xff) << system_pixel.ashift);

			buf += RGBA_BYTES;

		}

	/* and last, update the pixel epoch and orientation */
	f->pixel = system_pixel;

}







/*
 * adjust the scratchpad buffer
 */
void adjust_scratchpad(int w, int h)
{
	/* only resize the buffer up */
	if( w > scratchpad_size.w || h > scratchpad_size.h )
		{
			/* resize and save the new limits */
			scratchpad = ck_realloc(scratchpad, w * h * RGBA_BYTES);
			scratchpad_size.w = w;
			scratchpad_size.h = h;
		}

}
