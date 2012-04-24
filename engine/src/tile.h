
/*
 * tile-related routines
 */

tile *tile_create();
void tile_delete(tile *);
int tile_add_frame(tile *, frame *);
int tile_add_frame_data(tile *, int, int, int, const void *, const void *);
int tile_get_collides(tile *, int *);
int tile_get_anim_type(tile *, int *);
void tile_set_collides(tile *, int);
void tile_set_anim_type(tile *, int);
void tile_set_pixel_mask(tile *, int, const unsigned char *);
void tile_set_pixel_mask_from(tile *, int, frame *);

void tile_animate(tile *);
void tile_reset(tile *);


/* from frame.c */
extern frame *frame_create(int, int, int, const void *, const void *);
extern int frame_set_mask(frame *, const unsigned char *);
extern int frame_set_mask_from(frame *, frame *);
extern void frame_delete(frame *);

/* from misc.c */
extern void *ck_calloc(int, size_t);
extern void *ck_realloc(void *, size_t);
extern void fatal(char *, int);
