
/*
 * map-specific functions
 */


map *map_create();
void map_empty(map *, int);
void map_delete(map *);

int map_get_tile_size(map *, int *, int *);
int map_get_size(map *, int *, int *);
int map_get_tile(map *, int, tile **);

void map_set_tile_size(map *, int, int);
void map_set_size(map *, int, int);
void map_set_tile(map *, int, tile *);

void map_set_data(map *, const short *);
void map_set_single(map *, int, int, short);

void map_animate_tiles(map *);
void map_reset_tiles(map *);


/* from tile.c */
extern void tile_delete(tile *);
extern void tile_animate(tile *);
extern void tile_reset(tile *);

/* from misc.c */
extern void *ck_malloc(size_t);
extern void *ck_calloc(int, size_t);
extern void *ck_realloc(void *, size_t);
extern void fatal(char *,int);
