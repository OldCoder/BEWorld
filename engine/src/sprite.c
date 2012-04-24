#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"
#include "sprite.h"







/*
 * create a new sprite
 */
sprite *sprite_create()
{
	sprite *s;

	s = ck_calloc(1,sizeof(sprite));
	s->scale.x = fp_set(1);
	s->scale.y = fp_set(1);

	return s;
}










/*
 * this will create a copy of a sprite
 */
sprite *sprite_copy(sprite *s)
{
	int i, j;
	sprite *new; /* current and new sprite pointers */


	/* failsafe */
	if( !s )
		return NULL;


	/* first, allocate the new sprite */
	new = sprite_create();
	*new = *s;

	/* and then, copy the frame sets */
	new->frames = ck_malloc(s->frame_ct * sizeof(struct framestack));
	new->bound = ck_calloc(1, s->frame_ct * sizeof(box));
	for( i=0; i < s->frame_ct; i++ )
		{
			/* initialize the frame array for each frame */
			new->frames[i].len = s->frames[i].len;
			new->frames[i].stack = ck_malloc(s->frames[i].len * sizeof(frame *));

			/* copy the frames */
			for( j=0; j < s->frames[i].len; j++ )
				new->frames[i].stack[j] = frame_copy(s->frames[i].stack[j], 1);

			/* copy the bounding box */
			new->bound[i] = s->bound[i];

		}

	/* copy the motion control program */
	if( s->motion.code )
		{
			new->motion.tick = 0;
			new->motion.code = ck_malloc(MAX_MCP_LENGTH);
			memcpy(new->motion.code, s->motion.code, MAX_MCP_LENGTH);
		}

	return new;

}










/*
 * remove an sprite from the world
 */
void sprite_delete(sprite *s)
{
	int i, j;

	/* failsafe */
	if( !s )
		return;

	/* remove the specific data for each frame */
	for( i=0; i < s->frame_ct; i++ )
		{
			/* free the frame set */
			for( j=0; j < s->frames[i].len; j++ )
				frame_delete(s->frames[i].stack[j]);

			/* and the frame set */
			free(s->frames[i].stack);
		}


	/* and the frame array */
	if( s->frame_ct )
		{
			free(s->frames);
			free(s->bound);
		}

	/* last, the sprite itself */
	free(s);

}









/*
 * some get-routines for the various sprite pieces
 */
int sprite_get_frame(sprite *s, int *idx)
{
	/* failsafe */
	if( !s )
		return ERR;

	*idx = s->cur_frame;
	return 0;
}



int sprite_get_collides(sprite *s, int *collides)
{
	/* failsafe */
	if( !s )
		return ERR;

	*collides = s->collides;
	return 0;
}



int sprite_get_z_hint(sprite *s, int *z_hint)
{
	/* failsafe */
	if( !s )
		return ERR;

	*z_hint = s->z_hint;
	return 0;
}



int sprite_get_position(sprite *s, int *x, int *y)
{
	/* failsafe */
	if( !s )
		return ERR;

	*x = s->pos.x;
	*y = s->pos.y;
	return 0;
}



int sprite_get_velocity(sprite *s, int *x, int *y)
{
	/* failsafe */
	if( !s )
		return ERR;

	*x = s->vel.x;
	*y = s->vel.y;
	return 0;
}



int sprite_get_scale(sprite *s, int *sx, int *sy)
{
	/* failsafe */
	if( !s )
		return ERR;

	*sx = s->scale.x;
	*sy = s->scale.y;
	return 0;
}








/*
 * a series of simple functions to set sprite pieces now follows
 */
void sprite_set_frame(sprite *s, int idx)
{
	/* failsafe */
	if( !s )
		return;

	/* bounds-check - note that -1 is an allowed frame setting here */
	if( idx < -1 || idx >= s->frame_ct )
		return;

	/* set the current frame, update bounds cache */
	s->cur_frame = idx;
	update_bound_cache(s);

}



void adjust_sprite_frame(sprite *s, int adj)
{
	/* failsafe */
	if( !s )
		return;

	if( !s->frame_ct )  /* another failsafe */
		return;

	/* adjust the current frame and update bounds cache as needed */
	s->cur_frame = (s->cur_frame + adj) % s->frame_ct;
	update_bound_cache(s);

}



void sprite_set_z_hint(sprite *s, int z_hint)
{
	/* failsafe */
	if( !s )
		return;

	s->z_hint = z_hint;

}



void sprite_set_collides(sprite *s, int mode)
{
	/* failsafe */
	if( !s )
		return;

	s->collides = mode;

	/* update the sprite bound cache, if needed */
	update_bound_cache(s);

}



void sprite_set_position(sprite *s, int x, int y)
{
	/* failsafe */
	if( !s )
		return;

	s->pos.x = x;
	s->pos.y = y;

	/* update the sprite bound cache, if needed */
	update_bound_cache(s);

}



void sprite_set_velocity(sprite *s, int x, int y)
{
	/* failsafe */
	if( !s )
		return;

	s->vel.x = x;
	s->vel.y = y;

}



void sprite_set_scale(sprite *s, int sx, int sy)
{
	int i, j;

	/* failsafe */
	if( !s )
		return;

	/* set the scale for the sprite */
	if( sx > 0 && sy > 0 )
		{
			s->scale.x = sx;
			s->scale.y = sy;
		}

	/* update the sprite bounds cache */
	update_bound_cache(s);

}






void sprite_set_bounding_box(sprite *s, int idx, box *b)
{
	/* failsafe */
	if( !s )
		return;

	/* bounds-check */
	if( idx < 0 || idx >= s->frame_ct )
		return;

	/* assign the box */
	s->bound[idx] = *b;

	/* update the sprite bound cache, if needed */
	if( idx == s->cur_frame )
		update_bound_cache(s);

}





void sprite_set_pixel_mask(sprite *s, int idx, const unsigned char *data)
{
	/* failsafe */
	if( !s || !data )
		return;

	/* failsafe */
	if( idx < 0 || idx >= s->frame_ct )
		return;

	/* load the pixel mask for the given sprite frame */
	if( frame_set_mask(*s->frames[idx].stack, data) == ERR )
		return;

	/* update the pixel bounds for this frame */
	find_pixel_bounds(*s->frames[idx].stack, &s->bound[idx]);

	/* update the sprite bound cache, if needed */
	if( idx == s->cur_frame )
		update_bound_cache(s);

}




void sprite_set_pixel_mask_from(sprite *s, int idx, frame *src)
{
	/* failsafe */
	if( !s || !src )
		return;

	/* failsafe */
	if( idx < 0 || idx >= s->frame_ct )
		return;

	/* load the pixel mask for the given sprite frame */
	if( frame_set_mask_from(*s->frames[idx].stack, src) == ERR )
		return;

	/* update the pixel bounds for this frame */
	find_pixel_bounds(*s->frames[idx].stack, &s->bound[idx]);

	/* update the sprite bound cache, if needed */
	if( idx == s->cur_frame )
		update_bound_cache(s);

}










/*
 * load a motion-control program
 */
int sprite_load_program(sprite *s, const char *pgm)
{
	/* failsafe */
	if( !s )
		return ERR;

	return parse_mcp(pgm, &s->motion);
}












/*
 * add the already-defined frame to the given sprite
 */
int sprite_add_frame(sprite *s, frame *fr)
{
	/* failsafe */
	if( !s )
		return ERR;

	/* resize the arrays .. */
	s->frames = ck_realloc(s->frames, (s->frame_ct+1) * sizeof(struct framestack));
	s->bound = ck_realloc(s->bound, (s->frame_ct+1) * sizeof(box));

	/* store the frame .. */
	s->frames[s->frame_ct].len = 1;
	s->frames[s->frame_ct].stack = ck_malloc(sizeof(frame *));
	s->frames[s->frame_ct].stack[0] = fr;

	/* and set a default bounding box */
	s->bound[s->frame_ct].x1 = 0;
	s->bound[s->frame_ct].y1 = 0;
	s->bound[s->frame_ct].x2 = fr->w;
	s->bound[s->frame_ct].y2 = fr->h;

	/* update the frame count and return the id of the last-added frame */
	s->frame_ct++;
	return s->frame_ct-1;

}





/*
 * add the frame data to the given sprite
 */
int sprite_add_frame_data(sprite *s, int type, int w, int h, const void *data, const void *aux)
{
	frame *fr;

	/* failsafe */
	if( !s )
		return ERR;

	/* load the frame */
	fr = frame_create(type, w, h, data, aux);
	if( !fr )
		return ERR;

	/* and add the frame */
	return sprite_add_frame(s, fr);

}









/*
 * stack a frame beneath an already-set frame
 */
int sprite_add_subframe(sprite *s, int idx, frame *fr)
{
	/* failsafe */
	if( !s )
		return ERR;

	/* failsafe */
	if( idx < 0 || idx >= s->frame_ct )
		return ERR;


	/* store the frame .. */
	s->frames[idx].stack = ck_realloc(s->frames[idx].stack, (s->frames[idx].len + 1) * sizeof(frame *));
	s->frames[idx].stack[s->frames[idx].len] = fr;
	s->frames[idx].len++;

	/* return the frame idx */
	return idx;

}










/*
 * update the sprite's bounding region cache, based on collision mode
 */
void update_bound_cache(sprite *s)
{
	int cx, cy;

	if( !s->frame_ct || s->cur_frame == -1 || s->collides == COLLISION_OFF )
		s->bc.x1 = s->bc.y1 = s->bc.x2 = s->bc.y2 = 0;
	else
		{
			/* compute the bounds cache based on the sprite's scale dimensions */
			if( s->scale.x == fp_set(1) )
				{
					s->bc.x1 = s->pos.x + s->bound[s->cur_frame].x1;
					s->bc.x2 = s->pos.x + s->bound[s->cur_frame].x2 - 1;
				}
			else
				{
					s->bc.x1 = s->pos.x + fp_int(s->bound[s->cur_frame].x1 * s->scale.x);
					s->bc.x2 = s->pos.x + fp_int(s->bound[s->cur_frame].x2 * s->scale.x) - 1;
				}

			if( s->scale.y == fp_set(1) )
				{
					s->bc.y1 = s->pos.y + s->bound[s->cur_frame].y1;
					s->bc.y2 = s->pos.y + s->bound[s->cur_frame].y2 - 1;
				}
			else
				{
					s->bc.y1 = s->pos.y + fp_int(s->bound[s->cur_frame].y1 * s->scale.y);
					s->bc.y2 = s->pos.y + fp_int(s->bound[s->cur_frame].y2 * s->scale.y) - 1;
				}

		}

}







/*
 * find the outer edges of a pixel mask
 */
static void find_pixel_bounds(frame *fr, box *bound)
{
	int px, py;

	/* find the pixel mask boundary */
	bound->x1 = fr->w;
	bound->y1 = fr->h;
	bound->x2 = 0;
	bound->y2 = 0;

	for( px=0; px < fr->w; px++ )
		for( py=0; py < fr->h; py++ )
			{

				/* if there is a pel set here, check to see if the boundary must be adjusted. */
				if( *(fr->mask + px + py * fr->w) )
					{
						if( px < bound->x1 )
							bound->x1 = px;
						if( px > bound->x2 )
							bound->x2 = px;
						if( py < bound->y1 )
							bound->y1 = py;
						if( py > bound->y2 )
							bound->y2 = py;
					}

			}

	/* adjust the lower and right bounds by one to enclose the pixel area .. */
	bound->x2++;
	bound->y2++;

}
