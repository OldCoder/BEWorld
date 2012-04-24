
/*
 * Header for inspect.c
 */

#define sign(A)    ((A) < 0 ? -1 : ((A) > 0 ? 1 : 0))


void inspect_adjacent_tiles(map *, sprite *, int, map_fragment *);
void inspect_obscured_tiles(map *, sprite *, map_fragment *);
int inspect_line_of_sight(map *, sprite *, int, int, int, sprite *);
list *inspect_in_frame(list *, box *);
list *inspect_near_point(list *, int, int, int);

static int cast_ray(point *, point *, map *);


/* from list.c */
extern list *list_create();
extern void list_add(list *, void *);


/* from misc.c */
extern void *ck_malloc(size_t);
