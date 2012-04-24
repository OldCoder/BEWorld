/*
 * Pixel-manipulation routines
 */
void set_pixel_order(int, int, int);
void unpack_rgb(int, const unsigned char *, unsigned char *);
char unsigned desaturate_pixel(const unsigned char *, pixel_fmt);

/* these are more for internal-use .. */
void swizzle_pixels(frame *);
void adjust_scratchpad(int, int);



/* from pixel-le.c */
extern void rgb_frame_le(frame *, frame *, point *);
extern void rgba_frame_le(frame *, frame *, point *);
extern void hl_frame_le(frame *, frame *, point *);
extern void sl_frame_le(frame *, frame *, point *);
extern void br_frame_le(frame *, frame *, point *);
extern void ct_frame_le(frame *, frame *, point *);
extern void sat_frame_le(frame *, frame *, point *);
extern void displ_frame_le(frame *, frame *, point *);
extern void convo_frame_le(frame *, frame *, point *);
extern void lut_frame_le(frame *, frame *, point *);
extern void xor_frame_le(frame *, frame *, point *);

extern void rgb_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void rgba_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void hl_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void sl_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void br_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void ct_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void sat_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void displ_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void convo_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void lut_frame_le_scaled(frame *, frame *, point *, dimensions *);
extern void xor_frame_le_scaled(frame *, frame *, point *, dimensions *);

/* from pixel-be.c */
extern void rgb_frame_be(frame *, frame *, point *);
extern void rgba_frame_be(frame *, frame *, point *);
extern void hl_frame_be(frame *, frame *, point *);
extern void sl_frame_be(frame *, frame *, point *);
extern void br_frame_be(frame *, frame *, point *);
extern void ct_frame_be(frame *, frame *, point *);
extern void sat_frame_be(frame *, frame *, point *);
extern void displ_frame_be(frame *, frame *, point *);
extern void convo_frame_be(frame *, frame *, point *);
extern void lut_frame_be(frame *, frame *, point *);
extern void xor_frame_be(frame *, frame *, point *);

extern void rgb_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void rgba_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void hl_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void sl_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void br_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void ct_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void sat_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void displ_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void convo_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void lut_frame_be_scaled(frame *, frame *, point *, dimensions *);
extern void xor_frame_be_scaled(frame *, frame *, point *, dimensions *);


/* from graphics.c */
extern int display_rotation;

/* from misc.c */
extern void *ck_malloc(size_t);
extern void *ck_realloc(void *, size_t);
