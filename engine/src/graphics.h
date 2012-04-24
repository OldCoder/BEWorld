/*
 * our functions for graphics
 */
int graphics_open(int, int, int, int, int);
void graphics_close();

void show_rendered();
void activate_canvas(int, int);
void deactivate_canvas();


static void blit_line(int, int, unsigned char *, unsigned char *);

static void blit_90(int, int, int, unsigned char *, unsigned char *);
static void blit_180(int, int, int, unsigned char *, unsigned char *);
static void blit_270(int, int, int, unsigned char *, unsigned char *);
static void blit_strip(int, int, int, unsigned char *, unsigned char *);



/* and auxiliary defines for opengl-based output */
#ifdef WITH_GL

/* the size of the gl texture used in blitting */
#if GL_BLIT
#define TEXTURE_W 256
#define TEXTURE_H 256
#endif

/* some extra stuff needed only on OS X .. */
#ifdef OSX_BLIT
#define GL_TEXTURE_RECTANGLE_EXT           0x84F5
#define GL_TEXTURE_STORAGE_HINT_APPLE      0x85BC
extern void glTextureRangeAPPLE(GLenum target, GLsizei length, const GLvoid *pointer);
#endif

#endif


/* from pixel.c */
extern void set_pixel_order(int, int, int);

/* from render.c */
extern void activate_canvas(int, int);
extern void deactivate_canvas();

/* from frame.c */
extern frame *frame_create(int, int, int, const void *, const void *);
extern frame *frame_copy(frame *);
extern void frame_delete(frame *);
