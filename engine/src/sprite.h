
/*
 * sprite-specific functions
 */
#define SPRITE_DIV 16


sprite *sprite_create();
sprite *sprite_copy(sprite *);
void sprite_delete(sprite *);

int sprite_get_frame(sprite *, int *);
int sprite_get_z_hint(sprite *, int *);
int sprite_get_collides(sprite *, int *);
int sprite_get_position(sprite *, int *, int *);
int sprite_get_velocity(sprite *, int *, int *);
int sprite_get_scale(sprite *, int *, int *);

void sprite_set_frame(sprite *, int);
void sprite_set_z_hint(sprite *, int);
void sprite_set_collides(sprite *, int);
void sprite_set_position(sprite *, int, int);
void sprite_set_velocity(sprite *, int, int);
void sprite_set_scale(sprite *, int, int);
void sprite_set_bounding_box(sprite *, int, box *);
void sprite_set_pixel_mask(sprite *, int, const unsigned char *);
void sprite_set_pixel_mask_from(sprite *, int, frame *);
int sprite_add_frame(sprite *, frame *);
int sprite_add_frame_data(sprite *, int, int, int, const void *, const void *);
int sprite_add_subframe(sprite *, int, frame *);
int sprite_load_program(sprite *, const char *);

void adjust_sprite_frame(sprite *, int);
void update_bound_cache(sprite *);

static void find_pixel_bounds(frame *, box *);


/* from misc.c */
extern void *ck_calloc(int, size_t);
extern void *ck_malloc(size_t);
extern void *ck_realloc(void *, size_t);
extern void fatal(char *,int);

/* from motion.c */
extern int parse_mcp(const char *, mcp *);

/* from frame.c */
extern frame *frame_create(int, int, int, const void *, const void *);
extern frame *frame_copy(frame *, int);
extern void frame_set_scale(frame *, int);
extern int frame_set_mask(frame *, const unsigned char *);
extern int frame_set_mask_from(frame *, frame *);
extern void frame_delete(frame *);
