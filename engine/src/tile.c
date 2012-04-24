#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"
#include "tile.h"










/*
 * create a tile
 */
tile *tile_create()
{
	return ck_calloc(1,sizeof(tile));
}













/*
 * delete a tile
 */
void tile_delete(tile *t)
{
	int i;

	/* failsafe */
	if( !t )
		return;

	/* free the tile data */
	for( i=0; i < t->frame_ct; i++ )
		frame_delete(t->frames[i]);

	/* and the tile */
	free(t);

}











/*
 * load an already-defined frame into the tile
 */
int tile_add_frame(tile *t, frame *fr)
{
	/* failsafe */
	if( !t )
		return ERR;

	/* extend the frame array by way of realloc, assign the frame, and increase the frame count */
	t->frames = ck_realloc(t->frames, (t->frame_ct+1) * sizeof(frame *));
	t->frames[t->frame_ct] = fr;
	t->frame_ct++;

	return t->frame_ct - 1;

}




/*
 * load the given frame data into the tile
 */
int tile_add_frame_data(tile *t, int type, int w, int h, const void *data, const void *aux)
{
	frame *fr;

	/* failsafe */
	if( !t )
		return ERR;

	/* load the frame */
	fr = frame_create(type, w, h, data, aux);
	if( !fr )
		return ERR;

	/* now add the frame as usual */
	return tile_add_frame(t, fr);

}

















/*
 * get/set routines
 */
int tile_get_collides(tile *t, int *collides)
{
	/* failsafe */
	if( !t )
		return ERR;

	*collides = t->collides;
	return 0;

}



void tile_set_collides(tile *t, int collides)
{
	/* failsafe */
	if( !t )
		return;

	t->collides = collides;

}




int tile_get_anim_type(tile *t, int *type)
{
	/* failsafe */
	if( !t )
		return ERR;

	*type = t->anim_type;
	return 0;

}



void tile_set_anim_type(tile *t, int type)
{
	/* failsafe */
	if( !t )
		return;

	t->anim_type = type;

}



void tile_set_pixel_mask(tile *t, int idx, const unsigned char *data)
{
	/* failsafe */
	if( !t || !data )
		return;

	if( idx < 0 || idx >= t->frame_ct )
		return;

	/* and .. set the tile frame's pixel mask */
	frame_set_mask(t->frames[idx], data);

}



void tile_set_pixel_mask_from(tile *t, int idx, frame *src)
{
	/* failsafe */
	if( !t || !src )
		return;

	if( idx < 0 || idx >= t->frame_ct )
		return;

	/* and .. set the tile frame's pixel mask */
	frame_set_mask_from(t->frames[idx], src);

}















void tile_animate(tile *t)
{
	/* failsafe */
	if( !t )
		return;


	/* also skip indices with fewer than two tiles .. */
	if( t->frame_ct < 2 )
		return;


	switch( t->anim_type )
		{

			case ANIMATE_FWD:      /* increment the displayed-tile index and loop if necessary */
				t->cur_frame++;

				if( t->cur_frame == t->frame_ct )
					t->cur_frame = 0;

				break;


			case ANIMATE_REV:      /* decrement the displayed-tile index and loop if necessary */
				t->cur_frame--;

				if( t->cur_frame == -1 )
					t->cur_frame = t->frame_ct - 1;

				break;


			case ANIMATE_PP:       /* ping-pong animation, forward motion */
				if( t->cur_frame == (t->frame_ct - 1) )
					{
						t->cur_frame--;
						t->anim_type = ANIMATE_PP_REV;
					}
				else
					t->cur_frame++;

				break;

			case ANIMATE_PP_REV:  /* ping-pong animation, reverse motion */
				if( t->cur_frame == 0 )
					{
						t->cur_frame++;
						t->anim_type = ANIMATE_PP;
					}
				else
					t->cur_frame--;

				break;

		}

}







/*
 * reset a tile to animation starting point
 */
void tile_reset(tile *t)
{
	/* failsafe */
	if( !t )
		return;

	t->cur_frame = 0;

}
