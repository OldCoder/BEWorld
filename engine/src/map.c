#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"
#include "map.h"







/*
 * create a map
 */
map *map_create()
{
	map *m;

	m = ck_calloc(1,sizeof(map));
	m->tw_div = ck_calloc(1, sizeof(struct libdivide_s32_t));
	m->th_div = ck_calloc(1, sizeof(struct libdivide_s32_t));

	return m;
}






/*
 * empty out a map
 */
void map_empty(map *m, int delete_tiles)
{
	int i;
	tile *t;

	/* failsafe */
	if( !m )
		return;

	/* free the map data */
	if( m->data )
		{
			free(m->data);
			m->data = NULL;
		}

	/* empty the tile list */
	for( i=0; i < MAX_TILES; i++ )
		{
			/* also delete the tiles? */
			if( delete_tiles )
				tile_delete(m->tiles[i]);

			m->tiles[i] = NULL;
		}

	/* and reset the attributes */
	m->tw = 0;
	m->th = 0;
	m->w = 0;
	m->h = 0;

}








/*
 * remove a map
 */
void map_delete(map *m)
{
	/* failsafe */
	if( !m )
		return;

	/* free the map data */
	if( m->data )
		free(m->data);

	free(m->tw_div);
	free(m->th_div);

	/* and the map */
	free(m);

}











/*
 * a few get- and set-routines for the map
 */
int map_get_size(map *m, int *w, int *h)
{
	/* failsafe */
	if( !m || !m->data )
		return ERR;

	*w = m->w;
	*h = m->h;
	return 0;
}


int map_get_tile_size(map *m, int *tw, int *th)
{
	/* failsafe */
	if( !m )
		return ERR;

	*tw = m->tw;
	*th = m->th;
	return 0;
}


int map_get_tile(map *m, int idx, tile **t)
{
	/* failsafe */
	if( !m )
		return ERR;

	if( idx < 0 || idx >= MAX_TILES )
		return ERR;

	/* retrieve the tile and return success */
	*t = m->tiles[idx];
	return 0;

}





void map_set_size(map *m, int w, int h)
{
	/* failsafe */
	if( !m )
		return;

	/* allocate enough memory for the map */
	m->data = ck_realloc(m->data, w * h * sizeof(short));
	m->w = w;
	m->h = h;

}



void map_set_tile_size(map *m, int tw, int th)
{
	/* failsafe */
	if( !m )
		return;

	m->tw = tw;
	m->th = th;

	/* prepare the divison precomputations */
	*m->tw_div = libdivide_s32_gen(tw);
	*m->th_div = libdivide_s32_gen(th);

}



void map_set_tile(map *m, int idx, tile *t)
{
	/* failsafe */
	if( !m )
		return;

	if( idx < 0 || idx >= MAX_TILES )
		return;

	/* and set the tile */
	m->tiles[idx] = t;

}












/*
 * a routine to load map data into the map
 */
void map_set_data(map *m, const short *data)
{
	/* failsafe */
	if( !m || !m->data || !data )
		return;

	if( !m->w || !m->h )
		return;

	/* copy the given frame data to temp surface */
	memcpy(m->data, data, m->w * m->h * sizeof(short));

}






/*
 * set a single tile within the map
 */
void map_set_single(map *m, int x, int y, short data)
{
	/* failsafe */
	if( !m )
		return;

	/* and check for valid coords */
	if( x < 0 || x >= m->w || y < 0 || y >= m->h )
		return;

	*(m->data + x + y * m->w) = data;

}












/*
 * routines to deal with tile animation
 */
void map_animate_tiles(map *m)
{
	int i;

	/* failsafe */
	if( !m )
		return;

	/* only call this routine for the tiles that can animate .. */
	for(i=0; i < MAX_TILES; i++)
		if( m->tiles[i] )
			tile_animate(m->tiles[i]);

}





void map_reset_tiles(map *m)
{
	int i;

	/* failsafe */
	if( !m )
		return;

	/* only call this routine for the tiles that can animate .. */
	for(i=0; i < MAX_TILES; i++)
		if( m->tiles[i] )
			tile_reset(m->tiles[i]);


}
