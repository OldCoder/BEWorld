#include <stdio.h>
#include <stdlib.h>
#include "common.h"
#include "inspect.h"





/*
 * inspect the tiles around a given sprite
 */
void inspect_adjacent_tiles(map *m, sprite *s, int dir, map_fragment *res)
{
	int i;

	/* the tiles examined within the map, and a directional increment */
	box span;
	point tpos, inc;

	/* set a default result, in case of various errors */
	res->w = 0;
	res->h = 0;
	res->tiles = NULL;


	/* failsafe */
	if( !s || !m )
		return;

	if( s->collides == COLLISION_OFF )
		return;

	if( !m->tw || !m->th )
		return;


	/* they start out zero .. */
	inc.x = inc.y = 0;
	span = s->bc;

	switch(dir)
		{
			case INSPECT_NW:
				tpos.x = libdivide_s32_do(span.x1, m->tw_div) - 1;
				tpos.y = libdivide_s32_do(span.y1, m->th_div) - 1;
				res->w = 1;
				res->h = 1;
				break;
			case INSPECT_N:
				tpos.x = libdivide_s32_do(span.x1, m->tw_div);
				tpos.y = libdivide_s32_do(span.y1, m->th_div) - 1;
				res->w = libdivide_s32_do(span.x2, m->tw_div) - libdivide_s32_do(span.x1, m->tw_div) + 1;
				res->h = 1;
				inc.x = 1;
				break;
			case INSPECT_NE:
				tpos.x = libdivide_s32_do(span.x2, m->tw_div) + 1;
				tpos.y = libdivide_s32_do(span.y1, m->th_div) - 1;
				res->w = 1;
				res->h = 1;
				break;
			case INSPECT_E:
				tpos.x = libdivide_s32_do(span.x2, m->tw_div) + 1;
				tpos.y = libdivide_s32_do(span.y1, m->th_div);
				res->w = 1;
				res->h = libdivide_s32_do(span.y2, m->th_div) - libdivide_s32_do(span.y1, m->th_div) + 1;
				inc.y = 1;
				break;
			case INSPECT_SE:
				tpos.x = libdivide_s32_do(span.x2, m->tw_div) + 1;
				tpos.y = libdivide_s32_do(span.y2, m->th_div) + 1;
				res->w = 1;
				res->h = 1;
				break;
			case INSPECT_S:
				tpos.x = libdivide_s32_do(span.x1, m->tw_div);
				tpos.y = libdivide_s32_do(span.y2, m->th_div) + 1;
				res->w = libdivide_s32_do(span.x2, m->tw_div) - libdivide_s32_do(span.x1, m->tw_div) + 1;
				res->h = 1;
				inc.x = 1;
				break;
			case INSPECT_SW:
				tpos.x = libdivide_s32_do(span.x1, m->tw_div) - 1;
				tpos.y = libdivide_s32_do(span.y2, m->th_div) + 1;
				res->w = 1;
				res->h = 1;
				break;
			case INSPECT_W:
				tpos.x = libdivide_s32_do(span.x1, m->tw_div) - 1;
				tpos.y = libdivide_s32_do(span.y1, m->th_div);
				res->w = 1;
				res->h = libdivide_s32_do(span.y2, m->th_div) - libdivide_s32_do(span.y1, m->th_div) + 1;
				inc.y = 1;
				break;
		}


	/* in the event that there are no tiles to check .. */
	if( !res->w || !res->h )
		return;


	/* now, malloc the appropriate amount of space for the tiles */
	res->tiles = ck_malloc(res->w * res->h * sizeof(short));

	/* and loop for the length of the span, copying out the tiles into the result-array */
	for( i=0; i < res->w * res->h; i++ )
		{
			if( tpos.x >= 0 && tpos.x < m->w && tpos.y >= 0 && tpos.y < m->h )
			  *(res->tiles + i) = *(m->data + tpos.x + tpos.y * m->w);
			else
			  *(res->tiles + i) = -1;

			tpos.x += inc.x;
			tpos.y += inc.y;

		}


}









/*
 * inspect the tiles underneath a given sprite
 */
void inspect_obscured_tiles(map *m, sprite *s, map_fragment *res)
{
	int i, j;

	/* the tile(s) that the sprite is covering */
	box span;
	point tpos;
	int ofs;

	/* set a default result, in case of various errors */
	res->w = 0;
	res->h = 0;
	res->tiles = NULL;


	/* failsafes */
	if( !s || !m )
		return;

	if( s->collides == COLLISION_OFF )
		return;

	if( !m->tw || !m->th )
		return;


	/* get the tiles and span */
	span = s->bc;
	tpos.x = libdivide_s32_do(span.x1, m->tw_div);
	tpos.y = libdivide_s32_do(span.y1, m->th_div);
	res->w = libdivide_s32_do(span.x2, m->tw_div) - libdivide_s32_do(span.x1, m->tw_div) + 1;
	res->h = libdivide_s32_do(span.y2, m->th_div) - libdivide_s32_do(span.y1, m->th_div) + 1;


	/* in the event that there are no tiles to check .. */
	if( !res->w || !res->h )
		return;


	/* now, malloc the appropriate amount of space for the tiles */
	res->tiles = ck_malloc(res->w * res->h * sizeof(short));

	/*
	 * set the result-set offset ptr, and loop for the length and
	 * height of the span, copying out the tiles into the results
	 */
	ofs = 0;

	for( i=0; i < res->h; i++, tpos.y++, tpos.x -= res->w )
		for( j=0; j < res->w; j++, tpos.x++, ofs++ )
			{
				if( tpos.x >= 0 && tpos.x < m->w && tpos.y >= 0 && tpos.y < m->h )
					*(res->tiles + ofs) = *(m->data + tpos.x + tpos.y * m->w);
				else
					*(res->tiles + ofs) = -1;
			}


}












/*
 * perform a line-of-sight test from the given sprite + offset to
 * to the target sprite on the given map
 */
int inspect_line_of_sight(map *m, sprite *s, int xofs, int yofs, int dist, sprite *tgt)
{
	int i;

	/* the sprite's offset-adjusted starting point and the target's given range-box */
	point pt, tpts[4];

	/* failsafe */
	if( !s || !m || !tgt )
		return 0;

	/* .. and check to see if the target is collidable */
	if( tgt->collides == COLLISION_OFF )
		return 0;


	/* first, load the target sprite bounding box */
	tpts[0].x = tpts[2].x = tgt->bc.x1;
	tpts[0].y = tpts[1].y = tgt->bc.y1;
	tpts[1].x = tpts[3].x = tgt->bc.x2;
	tpts[2].y = tpts[3].y = tgt->bc.y2;

	/* calculate the sprite offset point */
	pt.x = s->pos.x + xofs;
	pt.y = s->pos.y + yofs;

	/*
	 * now cast a ray from the sprite point to each target point within range ..
	 */
	for( i=0; i < 4; i++ )
		if( (pt.x - tpts[i].x) * (pt.x - tpts[i].x) + (pt.y - tpts[i].y) * (pt.y - tpts[i].y) <= dist * dist )
			if( cast_ray( &pt, &tpts[i], m ) )
				 return 1;


	/* none of the rays which were cast succeeded */
	return 0;

}








/*
 * cast a ray from point a to point b across the given map
 */
static int cast_ray(point *a, point *b, map *map)
{
	point d;          /* for bresenham (delta) */
	int p,dpr,dpru;   /* .. also */
	int ck;           /* and a flag to indicate when the tile boundary is crossed */

	point ray_m, ray_t;  /* ray offset into the map and into the current tile */
	point inc;           /* increment for map/tile offset */
	point ct;            /* counter to mark tile boundary */

	frame *fr;       /* ptr to the frame of the tile */
	tile *tptr;      /* ptr to the tile within the map */

	/* change in x and y of the motion-line endpoints */
	d.x = abs(b->x - a->x) + 1;
	d.y = abs(b->y - a->y) + 1;

	/* set up the components of the motion */
	inc.x = sign(b->x - a->x);
	inc.y = sign(b->y - a->y);

	/* prepare the map and tile offsets */
	ray_m.x = (a->x < 0) ? libdivide_s32_do(a->x, map->tw_div) - 1 : libdivide_s32_do(a->x, map->tw_div);
	ray_m.y = (a->y < 0) ? libdivide_s32_do(a->y, map->th_div) - 1 : libdivide_s32_do(a->y, map->th_div);

	ray_t.x = a->x < 0 ? map->tw + a->x % map->tw : a->x % map->tw;
	ray_t.y = a->y < 0 ? map->th + a->y % map->th : a->y % map->th;

	/* prepare the tile boundary limit, initialized to one beyond the tile dimensions */
	ct.x = inc.x < 0 ? 0 : map->tw - 1;
	ct.y = inc.y < 0 ? 0 : map->th - 1;

	/* initialize the collision check */
	ck = COLLISION_CK;

	/*
	 * now begin the line-trace
	 */
	if( d.x >= d.y )
		{

			/* bresenham setup */
			dpr = d.y << 1;
			dpru = dpr - (d.x<<1);
			p = dpr - d.x;

			/* loop across horizontal movement */
			while( d.x-- )
				{

					/* decrement the within-tile offset .. if zero, a tile boundary has been passed */
					if( ray_t.x == ct.x )
						{
							ray_m.x += inc.x;
							ray_t.x = (inc.x < 0) ? map->tw - 1 : 0;
							ck = COLLISION_CK;
						}
					else
						ray_t.x += inc.x;


					/* now account for y-movement according to the bresenham */
					if( p > 0 )
						{
							p += dpru;

							/* decrement the offset likewise in the y-direction */
							if( ray_t.y == ct.y )
								{
									ray_m.y += inc.y;
									ray_t.y = (inc.y < 0) ? map->th - 1 : 0;
									ck = COLLISION_CK;
								}
							else
							 ray_t.y += inc.y;

						}
					else
						p += dpr;

					/*
					 * if ck is set to COLLISION_CK, it means that the ray cast has crossed
					 * a tile boundary.  so, now we:
					 *
					 * - verify that we're within map bounds.
					 * - check that there is a tile assigned to this coordinate of the map
					 * - check the collision mode of the tile at this coordinate and:
					 *	- if there is a tile and it has box-collision enabled, the
					 *		ray cast has failed and we can immediately return a 0
					 *	- if there is a tile and it has a pixel-accurate mask, then set
					 *		up the char * for testing each pixel of the mask, and set
					 *		the collision-check mode
					 *
					 */
					if( ck == COLLISION_CK )
						{
							if( ray_m.x >= 0 && ray_m.x < map->w && ray_m.y >= 0 && ray_m.y < map->h )
								{

									tptr = map->tiles[ *(map->data + ray_m.x + ray_m.y * map->w) ];
									if( tptr )
										{
											/* does this tile collide by bounding box?  if so, return immediately */
											if( tptr->collides == COLLISION_BOX )
												return 0;
											else if( tptr->collides == COLLISION_PIXEL )
												{
													/* set up the pixel-accurate mask pointer */
													fr = tptr->frames[tptr->cur_frame];

													/* a simple failsafe */
													if( !fr->mask )
														ck = 0;
													else
														ck = COLLISION_PIXEL;

												}

										}

								}

							/* if we are off map bounds, if there is no tile, or if the tile doesn't collide, reset the check */
							if( ck == COLLISION_CK )
								ck = 0;

						}



						/* now, if ck is set to pixel-accurate, test the pixel within the current tile */
						if( ck == COLLISION_PIXEL )
							if( ray_t.x < fr->w && ray_t.y < fr->h )
								 if( *( fr->mask + ray_t.x + ray_t.y * fr->w ) )
									return 0;

				  }


		}
	else
		{

			/* bresenham setup */
			dpr = d.x<<1;
			dpru = dpr - (d.y<<1);
			p = dpr - d.y;

			/* loop across vertical movement */
			while( d.y-- )
				{

					/* decrement the offset .. if zero, a tile boundary has been passed */
					if( ray_t.y == ct.y )
						{
							ray_m.y += inc.y;
							ray_t.y = (inc.y < 0) ? map->th - 1 : 0;
							ck = COLLISION_CK;
						}
					else
						ray_t.y += inc.y;

					/* now account for x-movement according to the bresenham */
					if( p > 0 )
						{
							p += dpru;

							/* likewise, the tile-offset in the x-direction */
							if( ray_t.x == ct.x )
								{
									ray_m.x += inc.x;
									ray_t.x = (inc.x < 0) ? map->tw - 1 : 0;
									ck = COLLISION_CK;
								}
							else
								ray_t.x += inc.x;

						}
					else
						p += dpr;

					/*
					 * please see detailed notes above for a full description of this code!
					 * it is a copy of the ray-tile intersect tests as written above, for the
					 * y-direction of the bresenham algorithm
					 */
					if( ck == COLLISION_CK )
						{
							if( ray_m.x >= 0 && ray_m.x < map->w && ray_m.y >= 0 && ray_m.y < map->h )
								{

									tptr = map->tiles[ *(map->data + ray_m.x + ray_m.y * map->w) ];
									if( tptr )
										{

											/* does this tile collide by bounding box?  if so, return immediately */
											if( tptr->collides == COLLISION_BOX )
												return 0;
											else if( tptr->collides == COLLISION_PIXEL )
												{

													/* set up the pixel-accurate mask pointer */
													fr = tptr->frames[tptr->cur_frame];

													/* a simple failsafe */
													if( !fr->mask )
														ck = 0;
													else
														ck = COLLISION_PIXEL;

												}

										}

								}

							/* if we are off map bounds, if there is no tile, or if the tile doesn't collide, reset the check */
							if( ck == COLLISION_CK )
								ck = 0;

						}

					/* now, if ck is set to pixel-accurate, test the pixel within the current tile */
					if( ck == COLLISION_PIXEL )
						if( ray_t.x < fr->w && ray_t.y < fr->h )
							if( *( fr->mask + ray_t.x + ray_t.y * fr->w ) )
								return 0;

				}

		}


	/* if we made it to the end, the ray-cast was successful */
	return 1;


}










/*
 * given a sprite list and a pixel range, identifies which sprites fall
 * within the pixel range.  returns a list.
 */
list *inspect_in_frame(list *l, box *r)
{
	/* the sprite and list pointers */
	iterator iter;
	sprite *s;
	list *res_l;

	/* failsafe */
	if( !l )
		return NULL;

	/*
	 * step through the list and check each item to see if it is in range.
	 * if it is in range, add it to the list.
	 */
	res_l = list_create();

	iterator_start(iter, l);
	while( (s = iterator_data(iter)) )
		{

			/* in bounds? */
			if( !(s->bc.x2 < r->x1 || s->bc.x1 > r->x2 || s->bc.y2 < r->y1 || s->bc.y1 > r->y2) )
				list_add(res_l, s);

			iterator_next(iter);

		}

	/* when the list has been exhausted, return the list id */
	return res_l;

}









/*
 * given a list and a single sprite, identifies which sprites
 * are within a certain distance from it.  returns a list.
 */
list *inspect_near_point(list *l, int x, int y, int dist)
{
	/* the sprite and list pointers, and the sprite center points */
	iterator iter;
	sprite *s;
	list *res_l;

	int cx, cy;


	/* failsafe */
	if( !l )
		return NULL;


	/*
	 * step through the list and check each item to see if it is in range.
	 * if it is in range, add it to the list.
	 */
	res_l = list_create();

	iterator_start(iter, l);
	while( (s = iterator_data(iter)) )
		{
			/* precompute the center of the sprite's frame */
			cx = s->pos.x + (s->bc.x2 - s->bc.x1) / 2;
			cy = s->pos.y + (s->bc.y2 - s->bc.y1) / 2;

			/* if we're within the requested distance, return the sprite pointer */
			if( (cx - x) * (cx - x) + (cy - y) * (cy - y) <= dist * dist )
				list_add(res_l, s);

			iterator_next(iter);

		}

	/* when the list has been exhausted, return the list id */
	return res_l;

}
