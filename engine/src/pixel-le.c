#include <stdio.h>
#include <stdlib.h>
#include "SDL.h"
#include "common.h"
#include "pixel-le.h"
#include "pixel-common.h"





/*
 * rgb frame
 */
void rgb_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *tgt;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set dest and filter pointers */
			src = f->data + (cres.sx + f->w * cres.sy) * RGBA_BYTES;
			tgt = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			while( cres.dh-- )
				{
					rgb_line(cres.dw, src, tgt);
					src += f->w * RGBA_BYTES;
					tgt += dest->w * RGBA_BYTES;
				}

		}

}

void rgb_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *mask, *tgt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set source and target pointers */
			src = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w) * RGBA_BYTES;
			tgt = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;

			/* draw the scaled rgb data */
			while( cres.dh-- )
				{
					rgb_line_scaled(cres.dw, scan.x, inc.x, src, tgt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							src += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					tgt += dest->w * RGBA_BYTES;

				}

		}

}


static void rgb_line(int len, unsigned char *src, unsigned char *tgt)
{
	while( len-- )
		{
			rgb_pixel(src, tgt);
			src += RGBA_BYTES;
			tgt += RGBA_BYTES;
		}
}

static void rgb_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *tgt)
{
	while( len-- )
		{
			rgb_pixel(src, tgt);

			/* adjust the source according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					src += fp_int(xi) * RGBA_BYTES;
					xi = fp_frac(xi);
				}

			/* and adjust the target */
			tgt += RGBA_BYTES;
		}

}













/*
 * rgba frame
 */
void rgba_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *tgt;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set dest and filter pointers */
			src = f->data + (cres.sx + f->w * cres.sy) * RGBA_BYTES;
			tgt = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			while( cres.dh-- )
				{
					rgba_line(cres.dw, src, tgt);
					src += f->w * RGBA_BYTES;
					tgt += dest->w * RGBA_BYTES;
				}

			SIMD_ADJ;

		}

}

void rgba_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *mask, *tgt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set source and target pointers */
			src = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w) * RGBA_BYTES;
			tgt = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;

			/* draw the scaled rgb data */
			while( cres.dh-- )
				{
					rgba_line_scaled(cres.dw, scan.x, inc.x, src, tgt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							src += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					tgt += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void rgba_line(int len, unsigned char *src, unsigned char *tgt)
{
	while( len-- )
		{
			rgba_pixel(src, tgt);
			src += RGBA_BYTES;
			tgt += RGBA_BYTES;
		}
}

static void rgba_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *tgt)
{
	while( len-- )
		{
			rgba_pixel(src, tgt);

			/* adjust the source according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					src += fp_int(xi) * RGBA_BYTES;
					xi = fp_frac(xi);
				}

			/* and adjust the target */
			tgt += RGBA_BYTES;
		}

}















/*
 * hard-lighting frame - for filter pixels < 128, darken the source
 * pixel.  for filter pixels >= 128, lighten the source pixel.
 */
void hl_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the render frame and the filter data */
	unsigned char *src, *flt;


	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* load pointers into pixel data */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (cres.sx + f->w * cres.sy) * RGBA_BYTES;
			while( cres.dh-- )
				{
					hl_line(cres.dw, src, flt);
					src += dest->w * RGBA_BYTES;
					flt += f->w * RGBA_BYTES;
				}

			SIMD_ADJ;

		}

}

void hl_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *flt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set dest and filter pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w) * RGBA_BYTES;

			while( cres.dh-- )
				{
					hl_line_scaled(cres.dw, scan.x, inc.x, src, flt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							flt += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					src += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void hl_line(int len, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			hl_pixel(src, flt);
			src += RGBA_BYTES;
			flt += RGBA_BYTES;
		}
}

static void hl_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			hl_pixel(src, flt);

			/* adjust the filter according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					flt += fp_int(xi) * RGBA_BYTES;
					xi = fp_frac(xi);
				}

			/* and adjust the source */
			src += RGBA_BYTES;
		}

}









/*
 * sl_frame:
 *
 * soft-lighting frame - for filter pixels < 128, lighten the source
 * pixel.  for filter pixels >= 128, darken the source pixel.
 */
void sl_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the render frame and the filter data */
	unsigned char *src, *flt;


	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* load pointers into pixel data */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (cres.sx + f->w * cres.sy) * RGBA_BYTES;
			while( cres.dh-- )
				{
					sl_line(cres.dw, src, flt);
					src += dest->w * RGBA_BYTES;
					flt += f->w * RGBA_BYTES;
				}

			SIMD_ADJ;

		}

}

void sl_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *flt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set dest and filter pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w) * RGBA_BYTES;

			while( cres.dh-- )
				{
					sl_line_scaled(cres.dw, scan.x, inc.x, src, flt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							flt += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					src += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void sl_line(int len, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			sl_pixel(src, flt);
			src += RGBA_BYTES;
			flt += RGBA_BYTES;
		}
}

static void sl_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			sl_pixel(src, flt);

			/* adjust the filter according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					flt += fp_int(xi) * RGBA_BYTES;
					xi = fp_frac(xi);
				}

			/* and adjust the source */
			src += RGBA_BYTES;
		}

}













/*
 * brightness-adjustment frame:
 * 0 = black
 * 64 = neutral
 * 128 = twice as bright
 * 255 = almost four times as bright
 */
void br_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the render frame and the filter data */
	unsigned char *src, *flt;


	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* load pointers into pixel data */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (cres.sx + f->w * cres.sy) * RGBA_BYTES;
			while( cres.dh-- )
				{
					br_line(cres.dw, src, flt);
					src += dest->w * RGBA_BYTES;
					flt += f->w * RGBA_BYTES;
				}

			SIMD_ADJ;

		}

}

void br_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *flt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set dest and filter pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w) * RGBA_BYTES;

			while( cres.dh-- )
				{
					br_line_scaled(cres.dw, scan.x, inc.x, src, flt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							flt += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					src += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void br_line(int len, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			br_pixel(src, flt);
			src += RGBA_BYTES;
			flt += RGBA_BYTES;
		}
}

static void br_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			br_pixel(src, flt);

			/* adjust the filter according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					flt += fp_int(xi) * RGBA_BYTES;
					xi = fp_frac(xi);
				}

			/* and adjust the source */
			src += RGBA_BYTES;
		}

}















/*
 * contrast-adjustment frame:
 * 0 = reduced to neutral grey
 * 64 = half-contrast
 * 128 = no adjustment
 * 192 = double-contrast
 * 255 = four times contrast
 */
void ct_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the render frame and the filter data */
	unsigned char *src, *flt;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* load pointers into pixel data */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + cres.sx + f->w * cres.sy;

			while( cres.dh-- )
				{
					ct_line(cres.dw, src, flt);
					src += dest->w * RGBA_BYTES;
					flt += f->w;
				}

			SIMD_ADJ;

		}

}

void ct_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *flt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set dest and filter pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w);

			while( cres.dh-- )
				{
					ct_line_scaled(cres.dw, scan.x, inc.x, src, flt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							flt += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					src += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void ct_line(int len, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			ct_pixel(src, flt);
			src += RGBA_BYTES;
			flt++;
		}
}

static void ct_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			ct_pixel(src, flt);

			/* adjust the filter according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					flt += fp_int(xi);
					xi = fp_frac(xi);
				}

			/* and adjust the source */
			src += RGBA_BYTES;
		}

}















/*
 * adjust image saturation values:
 * 0 = hue inversion
 * 64 = desaturation
 * 128 = no adjustment
 * 192 = double saturation
 * 255 = four times saturation
 */
void sat_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the render frame and the filter data */
	unsigned char *src, *flt;


	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* load pointers into pixel data */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + cres.sx + f->w * cres.sy;
			while( cres.dh-- )
				{
					sat_line(cres.dw, src, flt);
					src += dest->w * RGBA_BYTES;
					flt += f->w;
				}

			SIMD_ADJ;

		}

}

void sat_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *flt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set dest and filter pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w);

			while( cres.dh-- )
				{
					sat_line_scaled(cres.dw, scan.x, inc.x, src, flt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							flt += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					src += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void sat_line(int len, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			sat_pixel(src, flt);
			src += RGBA_BYTES;
			flt++;
		}
}

static void sat_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			sat_pixel(src, flt);

			/* adjust the filter according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					flt += fp_int(xi);
					xi = fp_frac(xi);
				}

			/* and adjust the source */
			src += RGBA_BYTES;
		}

}














/*
 * displacement - each pixel in the frame is obtained from the
 * pixel's x,y + the offset x,y
 */
void displ_frame_le(frame *dest, frame *f, point *ofs)
{
	int i, j;

	/* for frame clipping */
	struct clip cres;

	/* pointers into the source and target render frames, and into the displacement data */
	unsigned char *src, *tgt;
	short *dis;


	/* set the clip on the displacement-frame.  note that if it fails, frame is not visible! */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* check the scratchpad buffer */
			adjust_scratchpad(f->w, f->h);

			/* set surface pointers */
			dis = (short *)f->data + (cres.sx + f->w * cres.sy) * DISPL_SPAN;
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			tgt = scratchpad;

			/* render the repositioned pixels onto the scratchpad frame */
			for( i=0; i < cres.dh; i++ )
				{
					for( j=0; j < cres.dw; j++ )
						{
							/* only if the source pixel is within the render frame boundaries, copy */
							if( (cres.dx + *dis) < 0 || (cres.dx + *dis) >= dest->w || (cres.dy + *(dis+1)) < 0 || (cres.dy + *(dis+1)) >= dest->h )
								*(int32_t *)tgt = *(int32_t *)src;
							else
								*(int32_t *)tgt = *(int32_t *)(src + (*dis + dest->w * *(dis+1)) * RGBA_BYTES);

							cres.dx++;
							dis += DISPL_SPAN;
							src += RGBA_BYTES;
							tgt += RGBA_BYTES;

						}

					dis += (f->w - cres.dw) * DISPL_SPAN;
					src += (dest->w - cres.dw) * RGBA_BYTES;
					cres.dx -= cres.dw;
					cres.dy++;

				}

			cres.dy -= cres.dh;

			/* copy the scratchpad back onto the canvas */
			src = scratchpad;
			tgt = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;

			for( i=0; i < cres.dh; i++ )
				{
					memcpy( tgt, src, cres.dw * RGBA_BYTES );
					src += cres.dw * RGBA_BYTES;
					tgt += dest->w * RGBA_BYTES;
				}

		}

}

void displ_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	int i, j;

	/* for frame clipping */
	struct clip cres;

	/* pointers into the source and target render frames, and into the displacement data */
	unsigned char *src, *tgt;
	point scan, inc;
	short *dis, *dis_rewind;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* set the clip on the displacement-frame.  note that if it fails, frame is not visible! */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* check the scratchpad buffer */
			adjust_scratchpad(cres.dw, cres.dh);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);


			/* set surface pointers */
			dis = (short *)f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w) * DISPL_SPAN;
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			tgt = scratchpad;


			/* render the repositioned pixels onto the scratchpad frame */
			for( i=0; i < cres.dh; i++ )
				{
					for( j=0, dis_rewind = dis; j < cres.dw; j++ )
						{
							/* only if the source pixel is within the render frame boundaries, copy */
							if( (cres.dx + *dis) < 0 || (cres.dx + *dis) >= dest->w || (cres.dy + *(dis+1)) < 0 || (cres.dy + *(dis+1)) >= dest->h )
								*(int32_t *)tgt = *(int32_t *)src;
							else
								*(int32_t *)tgt = *(int32_t *)(src + (*dis + dest->w * *(dis+1)) * RGBA_BYTES);

							cres.dx++;
							src += RGBA_BYTES;
							tgt += RGBA_BYTES;

							/* adjust the filter according to the fixed-point increment */
							scan.x += inc.x;
							if( scan.x >= fp_set(1) )
								{
									dis += fp_int(scan.x) * DISPL_SPAN;
									scan.x = fp_frac(scan.x);
								}

						}

					/* rewind the pointers */
					dis = dis_rewind;
					src += (dest->w - cres.dw) * RGBA_BYTES;
					cres.dx -= cres.dw;
					cres.dy++;
					scan.x = fp_frac(cres.sx * inc.x);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							dis += fp_int(scan.y) * f->w * DISPL_SPAN;
							scan.y = fp_frac(scan.y);
						}


				}

			cres.dy -= cres.dh;

			/* copy the scratchpad back onto the canvas */
			src = scratchpad;
			tgt = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;

			for( i=0; i < cres.dh; i++ )
				{
					memcpy( tgt, src, cres.dw * RGBA_BYTES );
					src += cres.dw * RGBA_BYTES;
					tgt += dest->w * RGBA_BYTES;
				}

		}

}














/*
 * generic convolution kernel - each non-zero pixel in the bit mask
 * runs the convolution on the underlying image data
 */
void convo_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	point adjusted_ofs;
	struct clip cres;

	int i, j, k, l;  /* counters for the render action */
	int ac[4];       /* accumulators for pixel-calculations */
	box kofs;          /* offsets from pixel to edge of kernel */
	int idx;           /* index to the active kernel value */
	unsigned char *src, *mask, *tgt;  /* pointers into the source and target render frames */
	convolution *convo;

	struct libdivide_s32_t fast_divisor;  /* the libdivide divisor struct */


	/* let's begin */
	convo = f->aux;

	/*
	 * set the clip on the convolve bitmask.  note that it is offset by the adjusted
	 * size of the kernel to ensure enough pixel data and is different for even or
	 * odd kernel dimensions
	 */
	if( convo->kw & 1 )
		kofs.x1 = kofs.x2 = (convo->kw-1) / 2;
	else
		{
			kofs.x1 = convo->kw / 2 - 1;
			kofs.x2 = convo->kw / 2;
		}

	if( convo->kh & 1 )
		kofs.y1 = kofs.y2 = (convo->kh-1) / 2;
	else
		{
			kofs.y1 = convo->kh / 2 - 1;
			kofs.y2 = convo->kh / 2;
		}


	/* update the offset point */
	adjusted_ofs = *ofs;
	adjusted_ofs.x -= kofs.x1;
	adjusted_ofs.y -= kofs.y1;

	if( clip_to_frame( &adjusted_ofs, f->w + kofs.x1 + kofs.x2, f->h + kofs.y1 + kofs.y2, &dest->clip_rect, &cres ) )
		{

			/* check to see if the clipped frame can provide enough data for the kernel */
			if( cres.dw < convo->kw || cres.dh < convo->kh )
				return;

			/* check the scratchpad buffer */
			adjust_scratchpad(f->w, f->h);


			/* set surface pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			mask = f->data + cres.sx + f->w * cres.sy;
			tgt = scratchpad;

			/* calculate the pregenerated divisor for libdivide */
			fast_divisor = libdivide_s32_gen(convo->divisor);

			/* render the convolved pixels onto the scratchpad frame */
			for( i=0; i < cres.dh - convo->kh + 1; i++ )
				{
					for( j=0; j < cres.dw - convo->kw + 1; j++ )
						{

							/* if the pixel-mask is set for this pixel, operate */
							if( *mask )
								{
									/* zero the integer accumulators */
									memset(ac, 0, sizeof(int) * 4);

									/* loop for each pixel in the kernel - height */
									for( k=0, idx=0; k < convo->kh; k++ )
										{
											/* loop for each pixel in the kernel - width */
											for( l=0; l < convo->kw; l++ )
												{
													/* for each pixel component in the source, multiply by the current kernel value */
													ac[0] += *src     * convo->kernel[idx];
													ac[1] += *(src+1) * convo->kernel[idx];
													ac[2] += *(src+2) * convo->kernel[idx];
													ac[3] += *(src+3) * convo->kernel[idx];
													src += RGBA_BYTES;
													idx++;
												}

											/* back and down a line */
											src += (dest->w - convo->kw) * RGBA_BYTES;

										}

									/* apply the divisor and offset */
									ac[0] = libdivide_s32_do(ac[0], &fast_divisor) + convo->offset;
									ac[1] = libdivide_s32_do(ac[1], &fast_divisor) + convo->offset;
									ac[2] = libdivide_s32_do(ac[2], &fast_divisor) + convo->offset;
									ac[3] = libdivide_s32_do(ac[3], &fast_divisor) + convo->offset;

									/* set the result pixel, pinned to 0..255 range */
									*tgt     = ac[0] < 0 ? 0 : (ac[0] > RGB_MAX) ? RGB_MAX : ac[0];
									*(tgt+1) = ac[1] < 0 ? 0 : (ac[1] > RGB_MAX) ? RGB_MAX : ac[1];
									*(tgt+2) = ac[2] < 0 ? 0 : (ac[2] > RGB_MAX) ? RGB_MAX : ac[2];
									*(tgt+3) = ac[3] < 0 ? 0 : (ac[3] > RGB_MAX) ? RGB_MAX : ac[3];
									tgt += RGBA_BYTES;

									/* adjust back up several lines, minus one pixel */
									src -= (dest->w * convo->kh - 1) * RGBA_BYTES;

								}
							else
								{
									/* pixel mask is blank, copy the pixel */
									*(int32_t *)tgt = *(int32_t *)(src + (1 + dest->w) * RGBA_BYTES);
									src += RGBA_BYTES;
									tgt += RGBA_BYTES;
								}

							mask++;

						}

					src += (dest->w - (cres.dw - convo->kw + 1)) * RGBA_BYTES;
					mask += f->w - (cres.dw - convo->kw + 1);

				}


			/* copy the scratchpad back onto the canvas */
			src = scratchpad;
			tgt = dest->data + (cres.dx + kofs.x1 + dest->w * (cres.dy + kofs.y1)) * RGBA_BYTES;

			for( i=0; i < cres.dh - convo->kh + 1; i++ )
				{
					memcpy( tgt, src, (cres.dw - convo->kw + 1) * RGBA_BYTES );
					src += (cres.dw - convo->kw + 1) * RGBA_BYTES;
					tgt += dest->w * RGBA_BYTES;
				}

		}

}

void convo_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span) {
	/* for frame clipping */
	point adjusted_ofs;
	struct clip cres;

	int i, j, k, l;  /* counters for the render action */
	int ac[4];       /* accumulators for pixel-calculations */
	box kofs;          /* offsets from pixel to edge of kernel */
	int idx;           /* index to the active kernel value */
	unsigned char *src, *mask, *tgt;  /* pointers into the source and target render frames */
	unsigned char *mask_rewind;
	point scan, inc;
	convolution *convo;

	struct libdivide_s32_t fast_divisor;  /* the libdivide divisor struct */


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;


	/* let's begin */
	convo = f->aux;

	/*
	 * set the clip on the convolve bitmask.  note that it is offset by the adjusted
	 * size of the kernel to ensure enough pixel data and is different for even or
	 * odd kernel dimensions
	 */
	if( convo->kw & 1 )
		kofs.x1 = kofs.x2 = (convo->kw-1) / 2;
	else
		{
			kofs.x1 = convo->kw / 2 - 1;
			kofs.x2 = convo->kw / 2;
		}

	if( convo->kh & 1 )
		kofs.y1 = kofs.y2 = (convo->kh-1) / 2;
	else
		{
			kofs.y1 = convo->kh / 2 - 1;
			kofs.y2 = convo->kh / 2;
		}


	/* update the offset point */
	adjusted_ofs = *ofs;
	adjusted_ofs.x -= kofs.x1;
	adjusted_ofs.y -= kofs.y1;

	if( clip_to_frame( &adjusted_ofs, span->w + kofs.x1 + kofs.x2, span->h + kofs.y1 + kofs.y2, &dest->clip_rect, &cres ) )
		{

			/* check to see if the clipped frame can provide enough data for the kernel */
			if( cres.dw < convo->kw || cres.dh < convo->kh )
				return;

			/* check the scratchpad buffer */
			adjust_scratchpad(cres.dw, cres.dh);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);


			/* set surface pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			mask = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w);
			tgt = scratchpad;

			/* calculate the pregenerated divisor for libdivide */
			fast_divisor = libdivide_s32_gen(convo->divisor);

			/* render the convolved pixels onto the scratchpad frame */
			for( i=0; i < cres.dh - convo->kh + 1; i++ )
				{
					for( j=0, mask_rewind = mask; j < cres.dw - convo->kw + 1; j++ )
						{

							/* if the pixel-mask is set for this pixel, operate */
							if( *mask )
								{
									/* zero the integer accumulators */
									memset(ac, 0, sizeof(int) * 4);

									/* loop for each pixel in the kernel - height */
									for( k=0, idx=0; k < convo->kh; k++ )
										{
											/* loop for each pixel in the kernel - width */
											for( l=0; l < convo->kw; l++ )
												{
													/* for each pixel component in the source, multiply by the current kernel value */
													ac[0] += *src     * convo->kernel[idx];
													ac[1] += *(src+1) * convo->kernel[idx];
													ac[2] += *(src+2) * convo->kernel[idx];
													ac[3] += *(src+3) * convo->kernel[idx];
													src += RGBA_BYTES;
													idx++;
												}

											/* back and down a line */
											src += (dest->w - convo->kw) * RGBA_BYTES;

										}

									/* apply the divisor and offset */
									ac[0] = libdivide_s32_do(ac[0], &fast_divisor) + convo->offset;
									ac[1] = libdivide_s32_do(ac[1], &fast_divisor) + convo->offset;
									ac[2] = libdivide_s32_do(ac[2], &fast_divisor) + convo->offset;
									ac[3] = libdivide_s32_do(ac[3], &fast_divisor) + convo->offset;

									/* set the result pixel, pinned to 0..255 range */
									*tgt     = ac[0] < 0 ? 0 : (ac[0] > RGB_MAX) ? RGB_MAX : ac[0];
									*(tgt+1) = ac[1] < 0 ? 0 : (ac[1] > RGB_MAX) ? RGB_MAX : ac[1];
									*(tgt+2) = ac[2] < 0 ? 0 : (ac[2] > RGB_MAX) ? RGB_MAX : ac[2];
									*(tgt+3) = ac[3] < 0 ? 0 : (ac[3] > RGB_MAX) ? RGB_MAX : ac[3];
									tgt += RGBA_BYTES;

									/* adjust back up several lines, minus one pixel */
									src -= (dest->w * convo->kh - 1) * RGBA_BYTES;

								}
							else
								{
									/* pixel mask is blank, copy the pixel */
									*(int32_t *)tgt = *(int32_t *)(src + (1 + dest->w) * RGBA_BYTES);
									src += RGBA_BYTES;
									tgt += RGBA_BYTES;
								}



							/* adjust the filter according to the fixed-point increment */
							scan.x += inc.x;
							if( scan.x >= fp_set(1) )
								{
									mask += fp_int(scan.x);
									scan.x = fp_frac(scan.x);
								}

						}

					/* advance the source pointer */
					src += (dest->w - (cres.dw - convo->kw + 1)) * RGBA_BYTES;

					/* rewind the mask */
					mask = mask_rewind;
					scan.x = fp_frac(cres.sx * inc.x);


					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							mask += fp_int(scan.y) * f->w;
							scan.y = fp_frac(scan.y);
						}


				}


			/* copy the scratchpad back onto the canvas */
			src = scratchpad;
			tgt = dest->data + (cres.dx + kofs.x1 + dest->w * (cres.dy + kofs.y1)) * RGBA_BYTES;

			for( i=0; i < cres.dh - convo->kh + 1; i++ )
				{
					memcpy( tgt, src, (cres.dw - convo->kw + 1) * RGBA_BYTES );
					src += (cres.dw - convo->kw + 1) * RGBA_BYTES;
					tgt += dest->w * RGBA_BYTES;
				}

		}

}













/*
 * reassign colors according to user-defined lookup table
 */
void lut_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the render frame and the filter data */
	unsigned char *src;
	char *flt;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* load pointers into pixel data */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + cres.sx + f->w * cres.sy;
			while( cres.dh-- )
				{
					lut_line(cres.dw, src, f->aux, flt);
					src += dest->w * RGBA_BYTES;
					flt += f->w;
				}

		}

}

void lut_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *flt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set dest and filter pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w);

			while( cres.dh-- )
				{
					lut_line_scaled(cres.dw, scan.x, inc.x, src, f->aux, flt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							flt += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					src += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void lut_line(int len, unsigned char *src, lut *l, unsigned char *flt)
{
	while( len-- )
		{
			lut_pixel(src, l, flt);
			src += RGBA_BYTES;
			flt++;
		}
}

static void lut_line_scaled(int len, int xi, int xf, unsigned char *src, lut *l, unsigned char *flt)
{
	while( len-- )
		{
			lut_pixel(src, l, flt);

			/* adjust the filter according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					flt += fp_int(xi);
					xi = fp_frac(xi);
				}

			/* and adjust the source */
			src += RGBA_BYTES;
		}

}







/*
 * xor frame
 */
void xor_frame_le(frame *dest, frame *f, point *ofs)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *flt;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, f->w, f->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set dest and filter pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (cres.sx + f->w * cres.sy) * RGBA_BYTES;
			while( cres.dh-- )
				{
					xor_line(cres.dw, src, flt);
					src += dest->w * RGBA_BYTES;
					flt += f->w * RGBA_BYTES;
				}

			SIMD_ADJ;

		}

}

void xor_frame_le_scaled(frame *dest, frame *f, point *ofs, dimensions *span)
{
	/* for frame clipping */
	struct clip cres;

	/* pointers into the rgb data, mask, and render surface */
	unsigned char *src, *mask, *flt;
	point scan, inc;


	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return;

	/* clip the frame, checking if frame is at least partially on-screen */
	if( clip_to_frame( ofs, span->w, span->h, &dest->clip_rect, &cres ) )
		{
			/* update the frame pixel order if necessary */
			if( f->pixel.epoch < system_pixel.epoch )
				swizzle_pixels(f);

			/* set up scalar increments */
			inc.x = fp_set(f->w) / span->w;
			inc.y = fp_set(f->h) / span->h;
			scan.x = fp_frac(cres.sx * inc.x);
			scan.y = fp_frac(cres.sy * inc.y);

			/* set source and target pointers */
			src = dest->data + (cres.dx + dest->w * cres.dy) * RGBA_BYTES;
			flt = f->data + (fp_int(cres.sx * inc.x) + fp_int(cres.sy * inc.y) * f->w) * RGBA_BYTES;

			/* draw the scaled xor data */
			while( cres.dh-- )
				{
					xor_line_scaled(cres.dw, scan.x, inc.x, src, flt);

					/* and adjust the y-increment */
					scan.y += inc.y;
					if( scan.y >= fp_set(1) )
						{
							flt += fp_int(scan.y) * f->w * RGBA_BYTES;
							scan.y = fp_frac(scan.y);
						}

					/* update the destination pointer */
					src += dest->w * RGBA_BYTES;

				}

			SIMD_ADJ;

		}

}


static void xor_line(int len, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			xor_pixel(src, flt);
			src += RGBA_BYTES;
			flt += RGBA_BYTES;
		}
}

static void xor_line_scaled(int len, int xi, int xf, unsigned char *src, unsigned char *flt)
{
	while( len-- )
		{
			xor_pixel(src, flt);

			/* adjust the source according to the fixed-point increment */
			xi += xf;
			if( xi >= fp_set(1) )
				{
					flt += fp_int(xi) * RGBA_BYTES;
					xi = fp_frac(xi);
				}

			/* and adjust the target */
			src += RGBA_BYTES;
		}

}












/*
 * clip the source frame given in (src, w, h) to the destination,
 * storing the results in the result struct
 */
static int clip_to_frame(point *src, int w, int h, box *dest, struct clip *res)
{
	/* impossible positions and dimensions .. */
	if( src->x >= dest->x2 || (src->x + w) < dest->x1 || src->y >= dest->y2 || (src->y + h) < dest->y1 )
		return 0;


	/* first, set the render dimensions */
	res->dw = w;
	res->dh = h;

	/* now adjust the frame/render offsets according to frame/dest relative positions */
	if( src->x < dest->x1 )
		{
			res->sx = dest->x1 - src->x;
			res->dw -= res->sx;
			res->dx = dest->x1;
		}
	else
		{
			res->sx = 0;
			res->dx = src->x;
		}

	if( src->y < dest->y1 )
		{
			res->sy = dest->y1 - src->y;
			res->dh -= res->sy;
			res->dy = dest->y1;
		}
	else
		{
			res->sy = 0;
			res->dy = src->y;
		}

	/* last, if the frame runs past the right/lower boundary, clip thus */
	if( (src->x + w) > dest->x2 )
		res->dw -= (src->x + w) - dest->x2;
	if( (src->y + h) > dest->y2 )
		res->dh -= (src->y + h) - dest->y2;


	/* return 1 if there is something to be drawn */
	return 1;

}
