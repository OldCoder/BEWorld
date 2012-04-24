#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "SDL.h"
#include "common.h"
#include "render.h"





/* do we draw in the bg?  .. if so, use this color */
static int bg_fill;
static color bg_color;




/*
 * basic rendering setup
 */
void init_renderer()
{
	/* set background color to white */
	DEBUG( "Setting default render options...");
	render_set_bg_fill(1);
	render_set_bg_color( 0xff, 0xff, 0xff);
	DEBUGF;

}










/*
 * set the size of rendering surface
 */
void render_set_overdraw(int w, int h)
{
	/* prevent stupidity */
	if( w <= 0 || h <= 0 )
		return;


	/* save the overdraw dimensions .. */
	canvas_overdraw.w = w;
	canvas_overdraw.h = h;


	/* .. and reinitialize the render canvas */
	if( canvas )
		activate_canvas(canvas->w, canvas->h);

}



/*
 * set the background-fill mode
 */
void render_set_bg_fill(int mode)
{
	bg_fill = mode;
}




/*
 * set the background-fill color
 */
void render_set_bg_color(char r, char g, char b)
{
	bg_color.r = r;
	bg_color.g = g;
	bg_color.b = b;
}





/*
 * render all active layers and display
 */
void render_display()
{
	render_scene();
	show_rendered();
}





/*
 * render one frame to disk
 */
int render_to_disk(const char *file)
{
	int i,j;

	/* the pointer into the rendering buffer and output file handle */
	unsigned char *src;
	FILE *out_fh;


	/* open the file for writing */
	out_fh = fopen(file, "w");
	if( !out_fh )
		return ERR_BAD_FILE;


	/* render the scene */
	render_scene();

	/* set the pointer into the rendering buffer */
	src = canvas->data + (canvas_overdraw.w + canvas_overdraw.h * canvas->w) * RGBA_BYTES;

	for( i=0; i < canvas->h - canvas_overdraw.h * 2; i++ )
		{
			for( j=0; j < canvas->w - canvas_overdraw.w * 2; j++ )
				{
					/* skip the alpha, then write out red, green, blue:  canvas is ARGB */
					fwrite(src + (system_pixel.rshift >> 3), 1, 1, out_fh);
					fwrite(src + (system_pixel.gshift >> 3), 1, 1, out_fh);
					fwrite(src + (system_pixel.bshift >> 3), 1, 1, out_fh);
					src += RGBA_BYTES;
				}

			src += (canvas_overdraw.w * 2) * RGBA_BYTES;

		}

	/* and close the output file */
	fclose(out_fh);

	/* all ok */
	return 0;

}










/*
 * render all active layers
 */
static void render_scene()
{
	int i, layer_ct;

	/* for the background fill */
	int32_t packed_c;
	unsigned char *tgt;


	/* failsafe */
	if( !canvas )
		return;


	/* fill the background if necessary */
	if( bg_fill )
		{
			/* set the pixel for the appropriate system endianness */
			packed_c = \
				(bg_color.r << system_pixel.rshift) | \
				(bg_color.g << system_pixel.gshift) | \
				(bg_color.b << system_pixel.bshift) | \
				(0xff << system_pixel.ashift);

			/* prepare memory for copy */
			tgt = canvas->data;
			for( i=0; i < canvas->w * canvas->h; i++ )
				{
					*(int32_t *)tgt = packed_c;
					tgt += RGBA_BYTES;
				}

		}


	/* now render each layer in succession */
	layer_ct = layer_count();

	for( i=0; i < layer_ct; i++ )
		if( layer_get_visible(i) > 0 )
			render_layer(i);

}








/*
 * pass in a sprite list - this routine draws it
 */
static void render_layer(int layer_id)
{
	/* general-use */
	int i,j;
	point camera;

	/* to set up the clipping boundaries */
	box view;

	/* for walking the lists, drawing sprites, drawing text */
	iterator iter;
	map *m;
	list *l;
	sprite *sp;
	font *f;
	string *st;
	frame *fr;

	/* for rendering the tilemap */
	dimensions ct;     /* how many tiles to draw horiz and vert */
	point mpos, ofs;   /* two offsets: into the tilemap, of the tiles relative to the screen */
	dimensions span;   /* the size of the target rendered frame */
	tile *tptr;        /* ptr into the tilemap */

	/* specific to the text strings */
	int reset, len;



	/*
	 * first, get the clipping rectangle on the canvas for the given layer ..
	 *
	 * if the viewport hits the top or left border, nudge it to the left-most
	 * edge of the overdraw area, and likewise if it hits the lower or right
	 * border .. then set the clipping rect for the canvas
	 */
	layer_get_view(layer_id, &view);

	canvas->clip_rect.x1 = view.x1 > 0 ? view.x1 + canvas_overdraw.w : 0;
	canvas->clip_rect.y1 = view.y1 > 0 ? view.y1 + canvas_overdraw.h : 0;
	canvas->clip_rect.x2 = view.x2 < (canvas->w - canvas_overdraw.w * 2) ? view.x2 + canvas_overdraw.w : canvas->w;
	canvas->clip_rect.y2 = view.y2 < (canvas->h - canvas_overdraw.h * 2) ? view.y2 + canvas_overdraw.h : canvas->h;

	/* retrieve and offset the layer camera */
	layer_get_camera(layer_id, &camera.x, &camera.y);
	camera.x -= canvas_overdraw.w;
	camera.y -= canvas_overdraw.h;


	/*
	 * only draw the map for this layer if we have a map with map data
	 */
	m = layer_get_map(layer_id);
	if( m && m->data )
		{

			/* get the number of tiles across and down that are actually displayed */
			ct.w = libdivide_s32_do(canvas->clip_rect.x2 - canvas->clip_rect.x1 + m->tw - 1, m->tw_div) + 1;
			ct.h = libdivide_s32_do(canvas->clip_rect.y2 - canvas->clip_rect.y1 + m->th - 1, m->th_div) + 1;

			/* find the offset into the tiledata array for our upper-leftmost tile */
			mpos.x = libdivide_s32_do(camera.x, m->tw_div);
			mpos.y = libdivide_s32_do(camera.y, m->th_div);

			/* set the offset of the tiles to the screen based on the camera-position */
			ofs.x = view.x1 + -camera.x % m->tw;
			ofs.y = view.y1 + -camera.y % m->th;

			span.w = m->tw;
			span.h = m->th;

			for( i=0; i < ct.h; i++ )
				{
					for( j=0; j < ct.w; j++ )
						{

							/* check that the map is positioned fully on-screen */
							if( mpos.x >= 0 && mpos.x < m->w && mpos.y >= 0 && mpos.y < m->h )
								{

									/* set the tile ptr */
									tptr = m->tiles[ *(m->data + mpos.x + mpos.y * m->w) ];

									/* blit! */
									if( tptr )              /* does the tile exist .. */
										if( tptr->frame_ct )  /* and have image data ? */
											draw(canvas, tptr->frames[tptr->cur_frame], &ofs);

								}

							/* update the x-offset for the blit and the ptr into the tilemap */
							ofs.x += m->tw;
							mpos.x++;

						}

					/* now reset the tile ptr and destination rectangle back to the next line down */
					mpos.x -= ct.w;
					mpos.y++;
					ofs.x -= m->tw * ct.w;
					ofs.y += m->th;

				}


		}





	/*
	 * okay!  now, the easy part.  let's draw the sprites
	 */
	l = layer_get_sprite_list(layer_id);
	if( l )
		{

			/* sort the list by z-hint */
			if( layer_get_sorting(layer_id) > 0 )
				list_sort( l, compare_by_z_hint );


			/* and render all */
			iterator_start(iter, l);
			while( (sp = iterator_data(iter)) )
				{

					/* check to make sure it is visible, i.e. doesn't have special frame -1 set */
					if( sp->frame_ct && sp->cur_frame >= 0 )
						{

							/* and draw the frame stack, last to first */
							i = sp->frames[sp->cur_frame].len;
							while( i-- )
								{

									fr = sp->frames[sp->cur_frame].stack[i];

									/* set the destination x, y with camera adjustment */
									if( sp->scale.x == fp_set(1) && sp->scale.y == fp_set(1) )
										{
											/* unscaled */
											ofs.x = sp->pos.x - camera.x + view.x1 + fr->offset.x;
											ofs.y = sp->pos.y - camera.y + view.y1 + fr->offset.y;

											/* and draw the appropriate frame */
											draw(canvas, fr, &ofs);

										}
									else
										{
											/* scaled */
											ofs.x = sp->pos.x - camera.x + view.x1 + fp_int(fr->offset.x * sp->scale.x);
											ofs.y = sp->pos.y - camera.y + view.y1 + fp_int(fr->offset.y * sp->scale.y);
											span.w = fp_int(sp->frames[sp->cur_frame].stack[i]->w * sp->scale.x);
											span.h = fp_int(sp->frames[sp->cur_frame].stack[i]->h * sp->scale.y);

											/* and draw the appropriate frame */
											draw_scaled(canvas, fr, &ofs, &span);

										}


								}

						}

					/* advance to next item in list */
					iterator_next(iter);

				}

		}





	/*
	 * at last, the easiest part of all
	 */
	l = layer_get_string_list(layer_id);
	if( l )
		{

			/* render all osd strings */
			iterator_start(iter, l);
			while( (st = iterator_data(iter)) )
				{

					/* do we have text to draw? */
					len = strlen(st->text);
					if( len )
						{

							/* yes!  get the font ptr */
							f = get_font_by_name(st->font);
							if( f )
								{

									/* set the destination x, y with camera adjustment */
									ofs.x = st->x + canvas_overdraw.w;
									ofs.y = st->y + canvas_overdraw.h;
									reset = ofs.x;

									/* loop through the strings, drawing each letter .. */
									for( i=0; i<len; i++ )
										{
											fr = f->chars[(int)*(st->text+i)];

											/* in a proportional-width font, there can be a null frame, so check the frame now */
											if( fr )
												{
													switch( *(st->text + i) )
														{
															case '\t':
																/* tab stop uses 8 spaces */
																ofs.x += f->chars[32]->w * 8;
																break;
															case '\n':
																ofs.y += fr->h;
																break;
															case '\r':
																ofs.x = reset;
																break;
															default:
																system_frame.rgba(canvas, fr, &ofs);
																ofs.x += fr->w;
																break;
														}

												}

										}

								}

						}

					/* advance to next item in list */
					iterator_next(iter);

				}

		}



}









/*
 * a comparison function for the z_hint sorting
 */
static int compare_by_z_hint(void *a, void *b)
{
	sprite *s1, *s2;

	s1 = a;
	s2 = b;

	if( s1->z_hint == s2->z_hint )
		return 0;
	else
		return ( s1->z_hint < s2->z_hint ) ? -1 : 1;

}
