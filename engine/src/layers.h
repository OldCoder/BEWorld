
/*
 * our functions for layers
 */


/* a layer is a camera position, sprite list, map, string list, and some flags. */
struct layer
{
	/* layer view settings */
	point camera;
	box view;

	/* layer flags */
	int visible, sorted;

	/* layer contents */
	list *sprites;
	map *map;
	list *strings;

};




void init_layers();
void quit_layers();

int layer_count();
int layer_add();
void layer_reorder(int, int);
void layer_remove(int);
int layer_copy(int);

list *layer_get_sprite_list(int);
map *layer_get_map(int);
list *layer_get_string_list(int);
int layer_get_visible(int);
int layer_get_sorting(int);
int layer_get_view(int, box *);

void layer_set_sprite_list(int, list *);
void layer_set_map(int, map *);
void layer_set_string_list(int, list *);
void layer_set_visible(int, int);
void layer_set_sorting(int, int);
void layer_set_view(int, box *);

int layer_get_camera(int, int *, int *);
void layer_set_camera(int, int, int);
void layer_adjust_camera(int, int, int);


/* from list.c */
extern list *list_create();
extern void list_delete(list *);

/* from map.c */
extern map *map_create();
extern void map_delete(map *);

/* from misc.c */
extern void *ck_realloc(void *, size_t);
