#include <stdio.h>
#include <stdlib.h>
#include "common.h"
#include "collision.h"




/*
 * check the given sprite for collision against the given map
 * and store the result in *res ..
 */
void collision_with_map(sprite *s, map *m, int slip, map_collision *res)
{
	point ofs;               /* the offset for the sprite as we trace its motion */
	point mot;               /* motion-adders, most useful with slip engaged */
	point d, inc;            /* for bresenham */
	int p,dpr,dpru;          /* .. also */
	int flag;                /* collision-detection flag */


	/* failsafe - no sprite, sprite frame, map, or map data? */
	if( !s || !m || !m->data )
		{
			res->mode = ERR;
			return;
		}


	/* preload the result */
	res->mode = COLLISION_NEVER;
	res->stop.x = res->stop.y = 0;
	res->go.x = res->go.y = 0;

	/* zero out the flags */
	ofs.x = ofs.y = 0;


	/*
	 * if sprite collision is off, or the magic (i.e. inactive) frame is selected, or the
	 * frame has no collision mode set, then the sprite will never hit the map.
	 */
	if( s->collides == COLLISION_OFF || !s->frame_ct || s->cur_frame < 0 )
		{
			res->stop.x = s->vel.x;
			res->stop.y = s->vel.y;
			return;
		}



	/* first, check if we're already in-collision */
	if( map_sprite_test(m, s, ofs.x, ofs.y) )
		res->mode = COLLISION_ATSTART;
	else {


		/*
		 * ok!  now set up the motion-tracing (note that this is bresenham's algo .. thank you, mr bresenham!)
		 */


		/* change in x and y of the motion-line endpoints */
		d.x = abs(s->vel.x);
		d.y = abs(s->vel.y);

		/* set up the components of the motion */
		inc.x = sign(s->vel.x);
		inc.y = sign(s->vel.y);



		/*
		 * now begin the line-trace
		 */
		if( d.x >= d.y )
			{
				/* if x changes more than y ... */
				dpr = d.y << 1;
				dpru = dpr - (d.x<<1);
				p = dpr - d.x;

				while( d.x-- )
					{

						ofs.x += inc.x;
						mot.x = inc.x;

						/* and changes in y */
						if( p > 0 )
							{
								p += dpru;
								mot.y = inc.y;
								ofs.y += inc.y;
							}
						else
							{
								p += dpr;
								mot.y = 0;
							}


						/*
						 * check to see if we have a collision at all.
						 */
						if( map_sprite_test(m, s, ofs.x, ofs.y) )
							{

								/* first, check to see if this is the first collision .. */
								if( res->mode == COLLISION_NEVER )
									res->mode = COLLISION_INMOTION;


								/*
								 * now, since we have had a collision at (x,y), let's
								 * check to see if there is any slip allowed ..
								 */
								if( slip )
									{
										/*
										 * yes, slip is allowed.  so, depending on whether
										 * or not we have both directions of motion (in this
										 * block, mot.x is always present, but mot.y is only
										 * sometimes present), let's check for slip allowed
										 * either at 45' angles to the current (mot.x,mot.y)
										 * motion or at 90' angles to the current (mot.x,0)
										 * motion.
										 *
										 * so, we use a single flag to make an accumulator
										 * of whether or not motion is allowed.  if the flag
										 * is set to either -1 or 1, it means that motion
										 * passed in one direction but not the other, so let's
										 * slip in that direction.  if it is set to 0, it
										 * means that either motion is allowed in both
										 * directions or in neither direction, but in both
										 * cases the motion stops here.
										 */
										flag = 0;

										if( mot.y )
											{
												flag = -map_sprite_test(m, s, ofs.x - inc.x, ofs.y);
												flag += map_sprite_test(m, s, ofs.x, ofs.y - inc.y);

												/*
												 * if neither slip-adjustment of angular motion is
												 * permitted (or they both are), then we're in a
												 *  corner and won't escape, so here we must return.
												 */
												if( flag < 0 )
													ofs.y -= inc.y, mot.y = 0;
												else if( flag > 0 )
													ofs.x -= inc.x, mot.x = 0;
												else
													return;

											}
										else
											{
												flag = -map_sprite_test(m, s, ofs.x, ofs.y+1);
												flag += map_sprite_test(m, s, ofs.x, ofs.y-1);


												if( flag < 0 )
													ofs.y--, mot.y = -1;
												else if( flag > 0 )
													ofs.y++, mot.y = 1;
												else
													{
														/*
														 * but here note that if neither motion-adjustment
														 * was permitted, we don't return yet, because the
														 * sprite's natural motion may eventually slip past
														 * the current tile-collision.
														 */
														mot.x = 0;
														mot.y = 0;
														ofs.x -= inc.x;
													}


											}

										slip--;

									}
								else
									return;

							}



						/*
						 * lastly, account for the motion in either the stop or the go results vector
						 */
						if( res->mode == COLLISION_NEVER )   /* in phase one, add to the motion-til-stopping */
							{
								res->stop.x += inc.x;
								res->stop.y += mot.y;
							}
						else                                 /* in phase two, add to the motion-after-stopping */
							{
								res->go.x += mot.x;
								res->go.y += mot.y;
							}


					}


			}
		else
			{
				/*
				 * y changes more than x
				 */
				dpr = d.x<<1;
				dpru = dpr - (d.y<<1);
				p = dpr - d.y;

				/* and loop across vertical movement */
				while( d.y-- )
					{

						ofs.y += inc.y;	  /* add the y offset */
						mot.y = inc.y;

						/* and changes in x */
						if( p > 0 )
							{
								p += dpru;
								mot.x = inc.x;
								ofs.x += inc.x;		 /* and sometimes the x offset */
							}
						else
							{
								p += dpr;
								mot.x = 0;
							}



						/*
						 * check to see if we have a collision at all.
						 */
						if( map_sprite_test(m, s, ofs.x, ofs.y) )
							{

								/* first, check to see if this is the first collision .. */
								if( res->mode == COLLISION_NEVER )
									res->mode = COLLISION_INMOTION;


								/*
								 * now, since we have had a collision, let's check
								 * for slipped motion in the following block ..
								 */
								if( slip )
									{
										/*
										 * the slipped-motion detection code is very well-
										 * documented above.  please consult the preceding
										 * lengthy comment if you're reading this code for
										 * the first time.
										 */
										flag = 0;

										if( mot.x )
											{
												flag = -map_sprite_test(m, s, ofs.x, ofs.y - inc.y);
												flag += map_sprite_test(m, s, ofs.x - inc.x, ofs.y);

												if( flag < 0 )
													ofs.x -= inc.x, mot.x = 0;
												else if( flag > 0 )
													ofs.y -= inc.y, mot.y = 0;
												else
													return;

											}
										else
											{
												flag = -map_sprite_test(m, s, ofs.x-1, ofs.y);
												flag += map_sprite_test(m, s, ofs.x+1, ofs.y);

												if( flag < 0 )
													ofs.x++, mot.x = 1;
												else if( flag > 0 )
													ofs.x--, mot.x = -1;
												else
													{
														ofs.y -= inc.y;
														mot.x = 0;
														mot.y = 0;
													}


											}



										slip--;

									}
								else
									return;

							}



						/*
						 * lastly, account for the motion in either the stop or the go results vector
						 */
						if( res->mode == COLLISION_NEVER )	/* before collision, add to the motion-til-stopping */
							{
								res->stop.x += mot.x;
								res->stop.y += inc.y;
							}
						else							  /* after collision, add to the motion-after-stopping */
							{
								res->go.x += mot.x;
								res->go.y += mot.y;
							}

					}


			}

	}



}
















/*
 * determine if the sprite's pixel mask intersects with the map
 */
static int map_sprite_test(map *map, sprite *s, int xofs, int yofs)
{
	/* the position within the map of the current sprite-tile test */
	point loc;

	/* the span of the sprite across the map and clipping rects for the sprite and tile */
	box range;
	box clip, sbox, tbox;
	vector clip_adj;

	/* pointers into the map and to the current sprite frame */
	tile *t;
	frame *f;
	dimensions span, tspan;


	/* set the range for the sprite bounding box, for the simple bounds test */
	range.x1 = s->bc.x1 + xofs;
	range.y1 = s->bc.y1 + yofs;
	range.x2 = s->bc.x2 + xofs;
	range.y2 = s->bc.y2 + yofs;

   if( s->collides == COLLISION_PIXEL )
		{
			/*
			 * and set the pixel-mask clipping rectangle for any tiles
			 * that collide by bounding box
			 */
			clip.x1 = -(s->bc.x1 + xofs) % map->tw;
			clip.y1 = -(s->bc.y1 + yofs) % map->th;
			clip.x2 = clip.x1 + map->tw;
			clip.y2 = clip.y1 + map->th;

			clip_adj.x = map->tw;
			clip_adj.y = map->th;
		}
	else if( s->collides == COLLISION_BOX )
		{
			/*
			 * and, because the sprite uses bounding box collision rather than
			 * pixel-accurate, the clipping rectangle will be set up to do region
			 * tests on any pixel-accurate tiles instead
			 */
			clip.x1 = (range.x1 < 0 ) ? (map->tw + range.x1 % map->tw ) : range.x1 % map->tw;
			clip.y1 = (range.y1 < 0 ) ? (map->th + range.y1 % map->th ) : range.y1 % map->th;
			clip.x2 = clip.x1 + (s->bound[s->cur_frame].x2 - s->bound[s->cur_frame].x1);
			clip.y2 = clip.y1 + (s->bound[s->cur_frame].y2 - s->bound[s->cur_frame].y1);

			clip_adj.x = -map->tw;
			clip_adj.y = -map->th;
		}
	else
		return 0;

	/*
	 * divide the sprite's position by the map's tile dimensions, to
	 * get the range of tiles that must be checked for collisions.  note
	 * that if the sprite is positioned in the negative, the range must
	 * be adjusted down by one ..
	 */
	range.x1 = (range.x1 < 0 ) ? libdivide_s32_do(range.x1, map->tw_div) - 1 : libdivide_s32_do(range.x1, map->tw_div);
	range.y1 = (range.y1 < 0 ) ? libdivide_s32_do(range.y1, map->th_div) - 1 : libdivide_s32_do(range.y1, map->th_div);
	range.x2 = (range.x2 < 0 ) ? libdivide_s32_do(range.x2, map->tw_div) : libdivide_s32_do(range.x2, map->tw_div) + 1;
	range.y2 = (range.y2 < 0 ) ? libdivide_s32_do(range.y2, map->th_div) : libdivide_s32_do(range.y2, map->th_div) + 1;

	/* set the initial conditions for sprite and tile frame bounds, for pixel-accurate collisions */
	sbox = s->bc;

	tbox.x1 = range.x1 * map->tw;
	tbox.y1 = range.y1 * map->th;
	tbox.x2 = tbox.x1 + map->tw;
	tbox.y2 = tbox.y1 + map->th;


	/* iterate across the given range of tiles */
	for( loc.y = range.y1; loc.y < range.y2; loc.y++ )
		{
			for( loc.x = range.x1; loc.x < range.x2; loc.x++ )
				{
					/*
					 * the collision test has the following checks:
					 * - verify that this tile we're checking is in range.
					 * - check if there is a tile at the location.
					 * - check if the tile matches the given collision mask
					 * - check if the tile and the sprite intersect
					 */
					if( loc.x >= 0 && loc.x < map->w && loc.y >= 0 && loc.y < map->h )
						{

							t = map->tiles[ *(map->data + loc.x + loc.y * map->w) ];
							f = s->frames[s->cur_frame].stack[0];

							if( t )
								{
									/* check tile-sprite intersection based on collision modes of each */
									if( t->collides == COLLISION_BOX && s->collides == COLLISION_BOX )
										return 1;
									else if( t->collides == COLLISION_PIXEL && s->collides == COLLISION_BOX )
										{
											if( pixel_region_test( t->frames[t->cur_frame], clip ) )
												return 1;
										}
									else if( t->collides == COLLISION_BOX && s->collides == COLLISION_PIXEL )
										{

											/* is the sprite scaled in either direction? */
											if( s->scale.x != fp_set(1) || s->scale.y != fp_set(1) )
												{
													/* calculate the new frame span */
													span.w = fp_int(f->w * s->scale.x);
													span.h = fp_int(f->h * s->scale.y);

													if( pixel_region_test_scaled( f, &span, clip ) )
														return 1;

												}
											else if( pixel_region_test( f, clip ) )
												return 1;

										}
									else if( t->collides == COLLISION_PIXEL && s->collides == COLLISION_PIXEL )
										{

											/* is the sprite scaled in either direction? */
											if( s->scale.x != fp_set(1) || s->scale.y != fp_set(1) )
												{
													/* calculate the new frame span */
													span.w = fp_int(f->w * s->scale.x);
													span.h = fp_int(f->h * s->scale.y);

													/* tiles cannot be resized, so the tile span is fixed to the actual tile size */
													tspan.w = t->frames[t->cur_frame]->w;
													tspan.h = t->frames[t->cur_frame]->h;

													if( pixel_intersect_test_scaled( f, &span, sbox, t->frames[t->cur_frame], &tspan, tbox ) )
														return 1;

												}
											else if( pixel_intersect_test( f, sbox, t->frames[t->cur_frame], tbox) )
												return 1;


										}

								}

						}


					/* update the clipping rect x component */
					clip.x1 += clip_adj.x;
					clip.x2 += clip_adj.x;

					/* and update the tile pixel-accurate clip range */
					tbox.x1 += map->tw;
					tbox.x2 += map->tw;

				}

			/*
			 * again, if the sprite is being checked for pixel-accurate
			 * collision, restore the clipping rectangle x component and
			 * adjust the y component
			 */
			clip.x1 -= (range.x2 - range.x1) * clip_adj.x;
			clip.x2 -= (range.x2 - range.x1) * clip_adj.x;
			clip.y1 += clip_adj.y;
			clip.y2 += clip_adj.y;

			/* and for the tile, reset the x clip range and adjust the y */
			tbox.x1 -= (range.x2 - range.x1) * map->tw;
			tbox.x2 -= (range.x2 - range.x1) * map->tw;
			tbox.y1 += map->th;
			tbox.y2 += map->th;

		}



	/* otherwise, we hit nothing */
	return 0;

}













/*
 * given the sprite and a layer against which we're testing, find
 * all collisions and store the results in the result array ..
 */
int collision_with_sprites(sprite *s, list *l, int limit, sprite_collision *res)
{
	/* pointers to the target sprites etc */
	sprite *tgt;
	iterator iter;

	/* how many results? */
	int resct;

	/* fetch the pointer and verify */
	if( !s || !l )
		return 0;

	/* and double-check .. */
	if( s->collides == COLLISION_OFF || !s->frame_ct || s->cur_frame < 0 )
		return 0;


	/* now, start walking the list .. */
	iterator_start(iter, l);
	resct = 0;

	while( (tgt = iterator_data(iter)) && resct < limit )
		{
			/*
			 * only test for collision if the origin is not the target
			 */
			if( s != tgt )
				{
					/*
					 * if some collision occurred, store the target id into the result
					 */
					sprite_collision_with_result(s, tgt, &res[resct]);
					if( res[resct].mode != COLLISION_NEVER )
						{
							res[resct].target = tgt;
							resct++;  /* increment the counter. */
						}

				}

			/* advance to the next list item */
			iterator_next(iter);

		}


	/* ok!  return the results .. */
	return resct;

}

















/*
 * check to see if two sprites collide.
 */
static void sprite_collision_with_result(sprite *spr, sprite *tgt, sprite_collision *res)
{
	point ofs;          /* the offsets for the sprite as we trace its motion */
	point d;            /* for bresenham */
	int p,dpr,dpru;     /* .. also */
	int mot,flag;       /* bresenham motion-adder and collision flag */



	/* a failsafe check on the target */
	if( tgt->collides == COLLISION_OFF || !tgt->frame_ct || tgt->cur_frame < 0 )
		{
			res->mode = COLLISION_NEVER;
			return;
		}



	/* zero out the flags */
	ofs.x = ofs.y = 0;
	flag = 0;

	/* and results */
	res->mode = COLLISION_NEVER;
	res->stop.x = res->stop.y = 0;
	res->dir.x = res->dir.y = 0;


	/* first, let's see if our motion-guided bounding box prevents collision entirely */
	if( !sprite_sweep_test(spr, tgt) )
		return;


	/* now, let's see if we're already colliding ... */
	if( sprite_sprite_test(spr, 0, 0, tgt) )
		res->mode = COLLISION_ATSTART;
	else
		{

			/*
			 * ok!  now set up the motion-tracing (note that this is bresenham's algo .. thank you, mr bresenham!)
			 *
			 * (special note: in this function, res->dir has replaced inc as our motion-increment struct.
			 *  this is only to simplify the post-collision code.)
			 */


			/* change in x and y of the motion-line endpoints */
			d.x = abs(spr->vel.x - tgt->vel.x);
			d.y = abs(spr->vel.y - tgt->vel.y);

			/* set up the components of the motion */
			res->dir.x = sign(spr->vel.x - tgt->vel.x);
			res->dir.y = sign(spr->vel.y - tgt->vel.y);



			/*
			 * now begin the line-trace
			 */
			if( d.x >= d.y )
				{
					/* if x changes more than y ... */
					dpr = d.y << 1;
					dpru = dpr - (d.x<<1);
					p = dpr - d.x;

					while( d.x-- )
						{

							ofs.x += res->dir.x;

							/* and changes in y */
							if( p > 0 )
								{
									p += dpru;
									mot = res->dir.y;
									ofs.y += res->dir.y;
								}
							else
								{
									p += dpr;
									mot = 0;
								}



							/* check for collision here */
							if( sprite_sprite_test(spr, ofs.x, ofs.y, tgt) )
								{
									/* we have collided, so set the mode and target */
									res->mode = COLLISION_INMOTION;

									/* now let's check the collision direction */
									if( mot )
										{

											/*
											 * if we had y-motion in the last step, we must
											 * perform two additional checks:  one with y-
											 * motion removed and one with x-motion removed.
											 */
											flag = -sprite_sprite_test(spr, ofs.x - res->dir.x, ofs.y, tgt);
											flag += sprite_sprite_test(spr, ofs.x, ofs.y - res->dir.y, tgt);

											/* so, if the flag is -1, it indicates a collision in y direction only */
											if( flag < 0 )
												res->dir.x = 0;
											else if( flag > 0 )   /* if it's 1, collision happened in x dir only */
												res->dir.y = 0;
											                      /* otherwise, collision happened in both dirs */

									 }
									else   /* othwrise, we had no y-motion, so the collision had to be in the x dir */
										res->dir.y = 0;

									return;							/* and we're done! */
								}

							/* otherwise, add to the sprite motion */
							res->stop.x += res->dir.x;
							res->stop.y += mot;

						}

				}
			else
			  {

					/*
					 * y changes more than x
					 */
					dpr = d.x<<1;
					dpru = dpr - (d.y<<1);
					p = dpr - d.y;

					/* and loop across vertical movement */
					while( d.y-- )
						{

							ofs.y += res->dir.y;	  /* add the y offset */

							/* and changes in x */
							if( p > 0 )
								{
									p += dpru;
									mot = res->dir.x;
									ofs.x += res->dir.x;		 /* and sometimes the x offset */
								}
							else
								{
									p += dpr;
									mot = 0;
								}



							/* check for collision here */
							if( sprite_sprite_test(spr, ofs.x, ofs.y, tgt) )
								{
									/* we have collided, so set the mode and target */
									res->mode = COLLISION_INMOTION;

									/* now let's check the collision direction */
									if( mot )
										{

											/*
											 * if we had x-motion in the last step, we must
											 * perform two additional checks:  one with x-
											 * motion removed and one with y-motion removed.
											 */
											flag = -sprite_sprite_test(spr, ofs.x, ofs.y - res->dir.y, tgt);
											flag += sprite_sprite_test(spr, ofs.x - res->dir.x, ofs.y, tgt);

											/* so, if the flag is -1, it indicates a collision in y direction only */
											if( flag < 0 )
												res->dir.y = 0;
											else if( flag > 0 )   /* if it's 1, collision happened in x dir only */
												res->dir.x = 0;
											                      /* otherwise, collision happened in both dirs */

										}
									else   /* othwrise, we had no x-motion, so the collision had to be in the y dir */
										res->dir.x = 0;

									/* and we're done! */
									return;
								}

							/* otherwise, add to the sprite motion */
							res->stop.x += mot;
							res->stop.y += res->dir.y;


						}


				}


		}


}












/*
 * sprite with offset overlaps target?  let's see ..
 */
static int sprite_sprite_test(sprite *s, int xofs, int yofs, sprite *tgt)
{
	box sbox,tbox;      /* the sprite's and target's ranges */
	frame *sfr, *tfr;   /* the colliding sprite frames */
	dimensions sspan, tspan;

	/* make a local copy of the origin sprite's bounds cache and adjust by the given offset */
	sbox = s->bc;
	sbox.x1 += xofs;
	sbox.y1 += yofs;
	sbox.x2 += xofs;
	sbox.y2 += yofs;


	/* first, compare the bounding region */
	if( sbox.x2 < tgt->bc.x1 || sbox.x1 > tgt->bc.x2 || sbox.y2 < tgt->bc.y1 || sbox.y1 > tgt->bc.y2 )
		return 0;
	else
		{
			/* now copy the target sprite's bounds cache */
			tbox = tgt->bc;

			sfr = s->frames[s->cur_frame].stack[0];
			tfr = tgt->frames[tgt->cur_frame].stack[0];
			/*
			 * perform the correct test, of the three possible combinations
			 * of collision tests
			 */
			if( s->collides == COLLISION_BOX && tgt->collides == COLLISION_BOX )
				return 1;
			else if( s->collides == COLLISION_PIXEL && tgt->collides == COLLISION_BOX )
				{
					tbox.x1 -= sbox.x1 + xofs;
					tbox.y1 -= sbox.y1 + yofs;
					tbox.x2 -= sbox.x1 + xofs;
					tbox.y2 -= sbox.y1 + yofs;

					/* is the sprite scaled in either direction? */
					if( s->scale.x != fp_set(1) || s->scale.y != fp_set(1) )
						{
							/* calculate the new frame span */
							sspan.w = fp_int(sfr->w * s->scale.x);
							sspan.h = fp_int(sfr->h * s->scale.y);

							return( pixel_region_test_scaled( sfr, &sspan, tbox ) );

						}
					else
						return pixel_region_test( sfr, tbox );

				}
			else if( s->collides == COLLISION_BOX && tgt->collides == COLLISION_PIXEL )
				{
					sbox.x1 -= tbox.x1 - xofs;
					sbox.y1 -= tbox.y1 - yofs;
					sbox.x2 -= tbox.x1 - xofs;
					sbox.y2 -= tbox.y1 - yofs;

					/* is the sprite scaled in either direction? */
					if( tgt->scale.x != fp_set(1) || tgt->scale.y != fp_set(1) )
						{
							/* calculate the new frame span */
							tspan.w = fp_int(tfr->w * tgt->scale.x);
							tspan.h = fp_int(tfr->h * tgt->scale.y);

							return( pixel_region_test_scaled( tfr, &tspan, sbox ) );

						}
					else
						return pixel_region_test( tfr, sbox );

				}
			else
				{

					/* is either sprite scaled in either direction? */
					if( s->scale.x != fp_set(1) || s->scale.y != fp_set(1) || tgt->scale.x != fp_set(1) || tgt->scale.y != fp_set(1) )
						{
							/* calculate the new frame spans */
							sspan.w = fp_int(sfr->w * s->scale.x);
							sspan.h = fp_int(sfr->h * s->scale.y);

							tspan.w = fp_int(tfr->w * tgt->scale.x);
							tspan.h = fp_int(tfr->h * tgt->scale.y);

							return( pixel_intersect_test_scaled( sfr, &sspan, sbox, tfr, &tspan, tbox ) );

						}
					else
						return pixel_intersect_test( sfr, sbox, tfr, tbox );

				}

		}


}












/*
 * expand each sprite + motion out into a great big box and check for overlap
 */
static int sprite_sweep_test(sprite *spr, sprite *tgt)
{
	/* the sprite's and target's ranges */
	box sbox,tbox;

	/*
	 * make a local copy of the bounding region cache
	 */
	sbox = spr->bc;
	tbox = tgt->bc;

	/*
	 * now account for velocity of sprite
	 */
	if( spr->vel.x < 0 )
		sbox.x1 += spr->vel.x;
	else if( spr->vel.x > 0 )
		sbox.x2 += spr->vel.x;

	if( spr->vel.y < 0 )
		sbox.y1 += spr->vel.y;
	else if( spr->vel.y > 0 )
		sbox.y2 += spr->vel.y;


	/*
	 * and last, compare
	 */
	if( sbox.x2 < tbox.x1 || sbox.x1 > tbox.x2 || sbox.y2 < tbox.y1 || sbox.y1 > tbox.y2 )
		return 0;
	else
		return 1;

}












/*
 * pass in a pixel-mask frame and a clipping box, and this
 * will return true if any pixel in the mask is on
 */
static int pixel_region_test(frame *fr, box rect)
{
	/* pointer to pixel buffer data */
	unsigned char *ptr;

	/* failsafe */
	if( !fr->mask )
		return 0;


	/* impossible positions and dimensions .. */
	if( rect.x1 >= fr->w || rect.x2 <= 0 || rect.y1 >= fr->h || rect.y2 <= 0 )
		return 0;

	/* set the corners of the clipping rect */
	if( rect.x1 < 0 )
		rect.x1 = 0;
	if( rect.y1 < 0 )
		rect.y1 = 0;
	if( rect.x2 > fr->w )
		rect.x2 = fr->w;
	if( rect.y2 > fr->h )
		rect.y2 = fr->h;


	/* set up the pointer into the pixel data and check each pixel for 1 */
	ptr = fr->mask + rect.x1 + rect.y1 * fr->w;
	while( rect.y1 < rect.y2 )
		{
			/* scan the line for set pixels */
			if( pixel_region_line(rect.x2 - rect.x1, ptr) )
				return 1;

			ptr += fr->w;
			rect.y1++;

		}

	return 0;

}



static int pixel_region_test_scaled(frame *fr, dimensions *span, box rect)
{
	/* pointer to pixel buffer data */
	unsigned char *ptr;
	point scan, inc;

	/* failsafe */
	if( !fr->mask )
		return 0;

	/* failsafe */
	if( span->w < 1 || span->h < 1 )
		return 0;


	/* impossible positions and dimensions .. */
	if( rect.x1 >= span->w || rect.x2 <= 0 || rect.y1 >= span->h || rect.y2 <= 0 )
		return 0;

	/* set the corners of the clipping rect */
	if( rect.x1 < 0 )
		rect.x1 = 0;
	if( rect.y1 < 0 )
		rect.y1 = 0;
	if( rect.x2 > span->w )
		rect.x2 = span->w;
	if( rect.y2 > span->h )
		rect.y2 = span->h;


	/* set up scalar increments */
	inc.x = fp_set(fr->w) / span->w;
	inc.y = fp_set(fr->h) / span->h;
	scan.x = fp_frac(rect.x1 * inc.x);
	scan.y = fp_frac(rect.y1 * inc.y);

	/* set up the pointer into the pixel data and check each pixel for 1 */
	ptr = fr->mask + fp_int(rect.x1 * inc.x) + fp_int(rect.y1 * inc.y) * fr->w;
	while( rect.y1 < rect.y2 )
		{
			/* scan the scaled line for set pixels */
			if( pixel_region_line_scaled(rect.x2 - rect.x1, scan.x, inc.x, ptr) )
				return 1;

			/* and adjust the y-increment */
			scan.y += inc.y;
			if( scan.y >= fp_set(1) )
				{
					ptr += fp_int(scan.y) * fr->w;
					scan.y = fp_frac(scan.y);
				}

			rect.y1++;

		}

	return 0;

}


static int pixel_region_line(int len, unsigned char *buf)
{
	while( len-- )
		{
			/* is it set? */
			if( *buf )
				return 1;

			buf++;
		}

	/* if none set, return 0 */
	return 0;
}

static int pixel_region_line_scaled(int len, int xi, int xf, unsigned char *buf)
{
	while( len-- )
		{
			/* is it set? */
			if( *buf )
				return 1;

			xi += xf;
			if( xi >= fp_set(1) )
				{
					buf += fp_int(xi);
					xi = fp_frac(xi);
				}

		}

	/* if none set, return 0 */
	return 0;
}











/*
 * pass in a pair of clipping rectangles and frames and determine
 * if there are any collided pixels in the intersecting area
 */
static int pixel_intersect_test(frame *sfr, box sbox, frame *tfr, box tbox)
{
	/* the intersecting box */
	box ibox;

	/* pointers into the source and target pixel buffers */
	unsigned char *sptr, *tptr;

	/* failsafe */
	if( !sfr->mask || !tfr->mask )
		return 0;

	/* first, set up the intersect rectangle */
	ibox.x1 = max(sbox.x1, tbox.x1);
	ibox.y1 = max(sbox.y1, tbox.y1);
	ibox.x2 = min(sbox.x2, tbox.x2);
	ibox.y2 = min(sbox.y2, tbox.y2);

	/* now assign the pointers into the pixel mask */
	sptr = sfr->mask + sfr->w * (ibox.y1 - sbox.y1) + (ibox.x1 - sbox.x1);
	tptr = tfr->mask + tfr->w * (ibox.y1 - tbox.y1) + (ibox.x1 - tbox.x1);

	/* and check for overlapping pixels */
	while( ibox.y1 <= ibox.y2 )
		{
			/* scan the line intersect for set pixels */
			if( pixel_intersect_line(ibox.x2 - ibox.x1 + 1, sptr, tptr) )
				return 1;

			sptr += sfr->w;
			tptr += tfr->w;
			ibox.y1++;
		}


	return 0;

}



static int pixel_intersect_test_scaled(frame *sfr, dimensions *sspan, box sbox, frame *tfr, dimensions *tspan, box tbox)
{
	/* the intersecting box */
	box ibox;

	/* pointers into the source and target pixel buffers */
	unsigned char *sptr, *tptr;
	point sscan, sinc, tscan, tinc;

	/* failsafe */
	if( !sfr->mask || !tfr->mask )
		return 0;

	/* failsafe */
	if( sspan->w < 1 || sspan->h < 1 || tspan->w < 1 || tspan->h < 1 )
		return;


	/* first, set up the intersect rectangle */
	ibox.x1 = max(sbox.x1, tbox.x1);
	ibox.y1 = max(sbox.y1, tbox.y1);
	ibox.x2 = min(sbox.x2, tbox.x2);
	ibox.y2 = min(sbox.y2, tbox.y2);


	/* set up scalar increments */
	sinc.x = fp_set(sfr->w) / sspan->w;
	sinc.y = fp_set(sfr->h) / sspan->h;
	sscan.x = fp_frac((ibox.x1 - sbox.x1) * sinc.x);
	sscan.y = fp_frac((ibox.y1 - sbox.y1) * sinc.y);

	tinc.x = fp_set(tfr->w) / tspan->w;
	tinc.y = fp_set(tfr->h) / tspan->h;
	tscan.x = fp_frac((ibox.x1 - tbox.x1) * tinc.x);
	tscan.y = fp_frac((ibox.y1 - tbox.y1) * tinc.y);

	/* now assign the pointers into the pixel mask */
	sptr = sfr->mask + sfr->w * fp_int((ibox.y1 - sbox.y1) * sinc.y) + fp_int((ibox.x1 - sbox.x1) * sinc.x);
	tptr = tfr->mask + tfr->w * fp_int((ibox.y1 - tbox.y1) * tinc.y) + fp_int((ibox.x1 - tbox.x1) * tinc.x);

	/* and check for overlapping pixels */
	while( ibox.y1 <= ibox.y2 )
		{
			/* scan the scaled line intersect for set pixels */
			if( pixel_intersect_line_scaled(ibox.x2 - ibox.x1 + 1, sscan.x, sinc.x, sptr, tscan.x, tinc.x, tptr) )
				return 1;

			/* and adjust the y-increments */
			sscan.y += sinc.y;
			if( sscan.y >= fp_set(1) )
				{
					sptr += fp_int(sscan.y) * sfr->w;
					sscan.y = fp_frac(sscan.y);
				}

			tscan.y += tinc.y;
			if( tscan.y >= fp_set(1) )
				{
					tptr += fp_int(tscan.y) * tfr->w;
					tscan.y = fp_frac(tscan.y);
				}

			ibox.y1++;

		}



	return 0;

}


static int pixel_intersect_line(int len, unsigned char *src, unsigned char *tgt)
{
	while( len-- )
		{
			/* is it set? */
			if( *src && *tgt )
				return 1;

			src++;
			tgt++;
		}

	/* if none set, return 0 */
	return 0;
}

static int pixel_intersect_line_scaled(int len, int sxi, int sxf, unsigned char *src, int txi, int txf, unsigned char *tgt)
{
	while( len-- )
		{
			/* is it set? */
			if( *src && *tgt )
				return 1;

			sxi += sxf;
			if( sxi >= fp_set(1) )
				{
					src += fp_int(sxi);
					sxi = fp_frac(sxi);
				}

			txi += txf;
			if( txi >= fp_set(1) )
				{
					tgt += fp_int(txi);
					txi = fp_frac(txi);
				}

		}

	/* if none set, return 0 */
	return 0;
}
