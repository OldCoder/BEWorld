#include <stdio.h>
#include <string.h>
#include "common.h"
#include "layers.h"




/* a resizeable array of layers */
static int layer_ct;
static struct layer *layers;




/* initialize the layer list */
void init_layers()
{
	DEBUG( "Preparing layer list...");
	layer_ct=0;
	layers = NULL;
	DEBUGF;
}




void quit_layers()
{
	DEBUG( "Freeing layer list...");
	while( layer_ct )
		layer_remove(0);

	layers = NULL;
	DEBUGF;
}






/* return the layer count */
int layer_count()
{
	return layer_ct;
}






/* call this to make a layer */
int layer_add()
{
	/* reallocate the layer array */
	layers = ck_realloc(layers, (layer_ct+1) * sizeof(struct layer));

	layers[layer_ct].camera.x = 0;
	layers[layer_ct].camera.y = 0;

	layers[layer_ct].view.x1 = 0;
	layers[layer_ct].view.y1 = 0;
	layers[layer_ct].view.x2 = MAX_WIDTH;
	layers[layer_ct].view.y2 = MAX_HEIGHT;

	layers[layer_ct].sprites = list_create();
	layers[layer_ct].map = map_create();
	layers[layer_ct].strings = list_create();

	layers[layer_ct].visible = 1;
	layers[layer_ct].sorted = 0;

	layer_ct++;
	return layer_ct-1;

}









/* move the so-named layer to a new position */
void layer_reorder(int old, int new)
{
	struct layer ltmp;

	/* failsafe */
	if( old < 0 || old > (layer_ct-1) || new < 0 || new > (layer_ct-1) || old == new )
		return;

	/* now swap */
	ltmp = layers[new];
	layers[new] = layers[old];
	layers[old] = ltmp;

}










/* call this to remove a layer by id */
void layer_remove(int id)
{
	/* failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	/* remove the list items */
	list_delete(layers[id].sprites);
	map_delete(layers[id].map);
	list_delete(layers[id].strings);

	/* decrement the layer count and slide the remaining layers down */
	layer_ct--;

	for(; id < layer_ct; id++)
		layers[id] = layers[id+1];

	/* resize the layer array down */
	layers = ck_realloc(layers, (layer_ct+1) * sizeof(struct layer));

}








/*
 * make a copy of the given layer
 */
int layer_copy(int id)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return ERR;

	/* create a new layer */
	layers = ck_realloc(layers, (layer_ct+1) * sizeof(struct layer));

	/* ok, it worked - copy the old layer contents into this new layer */
	layers[layer_ct] = layers[id];

	/* update the layer count and return the new layer id */
	layer_ct++;
	return layer_ct-1;

}









/*
 * retrieve/adjust the layer pointers - sprite list, map, string list
 */
list *layer_get_sprite_list(int id)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return NULL;

	return layers[id].sprites;
}


void layer_set_sprite_list(int id, list *l)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	layers[id].sprites = l;

}




/*
 * get/set the layer map pointer
 */
map *layer_get_map(int id)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return NULL;

	return layers[id].map;
}



void layer_set_map(int id, map *m)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	layers[id].map = m;

}






/*
 * get/set the layer string list pointer
 */
list *layer_get_string_list(int id)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return NULL;

	return layers[id].strings;

}


void layer_set_string_list(int id, list *l)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	layers[id].strings = l;

}











/*
 * some little things to tweak the camera view and control per-layer rendering
 */
int layer_get_camera(int id, int *x, int *y)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return ERR;

	*x = layers[id].camera.x;
	*y = layers[id].camera.y;
	return 0;

}




void layer_set_camera(int id, int x, int y)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	layers[id].camera.x = x;
	layers[id].camera.y = y;

}




/* adjust the camera by the given # of pixels */
void layer_adjust_camera(int id, int x, int y)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	layers[id].camera.x += x;
	layers[id].camera.y += y;

}







/*
 * layer visibility determines whether or not the layer is drawn at all
 */
int layer_get_visible(int id)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return ERR;

	return layers[id].visible;

}




void layer_set_visible(int id, int vis)
{
	/* failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	layers[id].visible = vis;

}





/*
 * adjust the per-layer z-hint sorting
 */
int layer_get_sorting(int id)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return ERR;

	return layers[id].sorted;

}




void layer_set_sorting(int id, int sorted)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	layers[id].sorted = sorted;

}







/*
 * get and set a layer viewport
 */
int layer_get_view(int id, box *view)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return ERR;

	*view = layers[id].view;
	return 0;

}




void layer_set_view(int id, box *view)
{
	/* a failsafe */
	if( id < 0 || id > (layer_ct-1) )
		return;

	/* set the clipping box on the layer */
	layers[id].view = *view;

}
