/*
 * big-endian, unscaled pixel routines
 */
#define A_ADJ 0
#define R_ADJ 1
#define G_ADJ 2
#define B_ADJ 3


void rgb_frame_be(frame *, frame *, point *);
void rgba_frame_be(frame *, frame *, point *);
void hl_frame_be(frame *, frame *, point *);
void sl_frame_be(frame *, frame *, point *);
void br_frame_be(frame *, frame *, point *);
void ct_frame_be(frame *, frame *, point *);
void sat_frame_be(frame *, frame *, point *);
void displ_frame_be(frame *, frame *, point *);
void convo_frame_be(frame *, frame *, point *);
void lut_frame_be(frame *, frame *, point *);
void xor_frame_be(frame *, frame *, point *);

static void rgb_line(int, unsigned char *, unsigned char *);
static void rgba_line(int, unsigned char *, unsigned char *);
static void hl_line(int, unsigned char *, unsigned char *);
static void sl_line(int, unsigned char *, unsigned char *);
static void br_line(int, unsigned char *, unsigned char *);
static void ct_line(int, unsigned char *, unsigned char *);
static void sat_line(int, unsigned char *, unsigned char *);
static void lut_line(int, unsigned char *, lut *, unsigned char *);
static void xor_line(int, unsigned char *, unsigned char *);

void rgb_frame_be_scaled(frame *, frame *, point *, dimensions *);
void rgba_frame_be_scaled(frame *, frame *, point *, dimensions *);
void hl_frame_be_scaled(frame *, frame *, point *, dimensions *);
void sl_frame_be_scaled(frame *, frame *, point *, dimensions *);
void br_frame_be_scaled(frame *, frame *, point *, dimensions *);
void ct_frame_be_scaled(frame *, frame *, point *, dimensions *);
void sat_frame_be_scaled(frame *, frame *, point *, dimensions *);
void displ_frame_be_scaled(frame *, frame *, point *, dimensions *);
void convo_frame_be_scaled(frame *, frame *, point *, dimensions *);
void lut_frame_be_scaled(frame *, frame *, point *, dimensions *);
void xor_frame_be_scaled(frame *, frame *, point *, dimensions *);

static void rgb_line_scaled(int, int, int, unsigned char *, unsigned char *);
static void rgba_line_scaled(int, int, int, unsigned char *, unsigned char *);
static void hl_line_scaled(int, int, int, unsigned char *, unsigned char *);
static void sl_line_scaled(int, int, int, unsigned char *, unsigned char *);
static void br_line_scaled(int, int, int, unsigned char *, unsigned char *);
static void ct_line_scaled(int, int, int, unsigned char *, unsigned char *);
static void sat_line_scaled(int, int, int, unsigned char *, unsigned char *);
static void lut_line_scaled(int, int, int, unsigned char *, lut *, unsigned char *);
static void xor_line_scaled(int, int, int, unsigned char *, unsigned char *);

static int clip_to_frame(point *, int, int, box *, struct clip *);

/* from pixel.c */
extern pixel_fmt system_pixel;
extern unsigned char *scratchpad;

extern void adjust_scratchpad(int, int);
extern void swizzle_pixels(frame *);
