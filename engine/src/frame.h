/*
 * routines to load and delete various frame type
 */
int frame_info(frame *, int *, int *, int *);
frame *frame_create(int, int, int, const void *, const void *);
frame *frame_copy(frame *);
void frame_delete(frame *);
void frame_set_offset(frame *, int, int);
int frame_set_mask(frame *, const unsigned char *);
int frame_set_mask_from(frame *, frame *);
frame *frame_slice(frame *, int, int, int, int);
frame *frame_convert(frame *, int, const void *);
frame *frame_effect(frame *, int, ...);

frame *frame_from_disk(const char *);
frame *frame_from_buffer(int, const unsigned char *);

static frame *img_unpack(SDL_Surface *);

/* from misc.c */
extern void fatal(char *,int);


/* from pixel.c */
extern pixel_fmt system_pixel;
extern renderer system_frame;

extern void unpack_rgb(int, const unsigned char *, unsigned char *);
extern unsigned char desaturate_pixel(const unsigned char *, pixel_fmt);

/* from misc.c */
extern void *ck_calloc(int, size_t);
extern void *ck_malloc(size_t);
extern void *ck_realloc(void *, size_t);
