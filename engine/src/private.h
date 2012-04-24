/*
 * macros and types for internal use only
 */
#define sign(A)    ((A) < 0 ? -1 : ((A) > 0 ? 1 : 0))
#define min(A, B)  ((A) < (B) ? (A) : (B))
#define max(A, B)  ((A) > (B) ? (A) : (B))

#define fp_set(a) ((int)((a) << 16))
#define fp_int(a) ((a) >> 16)
#define fp_frac(a) ((a) & 0xffff)



/* pixel defines */
#define A_MID 128
#define A_DIV 8

#define LT_DIV 7
#define LT_MID 128
#define LT_MAX 255

#define BR_DIV 6

#define CT_ADJ 128
#define CT_DIV 7

#define SAT_ADJ0 128
#define SAT_ADJ1 64
#define SAT_DIV 6

#define WGT_DIV 8
#define R_WGT ((int)(0.3086 * (1<<WGT_DIV)))
#define G_WGT ((int)(0.6094 * (1<<WGT_DIV)))
#define B_WGT ((int)(0.0820 * (1<<WGT_DIV)))



/*
 * some rendering-related structures that don't need to be
 * in the public-facing api.
 */
struct clip { int sx, sy, dx, dy, dw, dh; };

typedef struct renderer {
	void (*rgb)(frame *, frame *, point *);
	void (*rgba)(frame *, frame *, point *);
	void (*hl)(frame *, frame *, point *);
	void (*sl)(frame *, frame *, point *);
	void (*br)(frame *, frame *, point *);
	void (*ct)(frame *, frame *, point *);
	void (*sat)(frame *, frame *, point *);
	void (*displ)(frame *, frame *, point *);
	void (*convo)(frame *, frame *, point *);
	void (*lut)(frame *, frame *, point *);
	void (*xor)(frame *, frame *, point *);

	void (*rgb_scaled)(frame *, frame *, point *, dimensions *);
	void (*rgba_scaled)(frame *, frame *, point *, dimensions *);
	void (*hl_scaled)(frame *, frame *, point *, dimensions *);
	void (*sl_scaled)(frame *, frame *, point *, dimensions *);
	void (*br_scaled)(frame *, frame *, point *, dimensions *);
	void (*ct_scaled)(frame *, frame *, point *, dimensions *);
	void (*sat_scaled)(frame *, frame *, point *, dimensions *);
	void (*displ_scaled)(frame *, frame *, point *, dimensions *);
	void (*convo_scaled)(frame *, frame *, point *, dimensions *);
	void (*lut_scaled)(frame *, frame *, point *, dimensions *);
	void (*xor_scaled)(frame *, frame *, point *, dimensions *);
} renderer;
