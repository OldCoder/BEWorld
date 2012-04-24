
/*
 * collision-detection ..
 */
#define SPRITE_DIV 16


/* the two public-facing routines */
void collision_with_map(sprite *, map *, int, map_collision *);
int collision_with_sprites(sprite *, list *, int, sprite_collision *);


/* the rest are for internal computations */
static int map_sprite_test(map *, sprite *, int, int);

static void sprite_collision_with_result(sprite *, sprite *, sprite_collision *);
static int sprite_sweep_test(sprite *, sprite *);
static int sprite_sprite_test(sprite *, int, int, sprite *);

static int pixel_region_test(frame *, box);
static int pixel_region_test_scaled(frame *, dimensions *, box);
static int pixel_intersect_test(frame *, box, frame *, box);
static int pixel_intersect_test_scaled(frame *, dimensions *, box, frame *, dimensions *, box);

static int pixel_region_line(int, unsigned char *);
static int pixel_region_line_scaled(int, int, int, unsigned char *);

static int pixel_intersect_line(int, unsigned char *, unsigned char *);
static int pixel_intersect_line_scaled(int, int, int, unsigned char *, int, int, unsigned char *);
