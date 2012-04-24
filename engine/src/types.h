/*
 * the data structures used throughout the brick engine,
 * starting with lists
 */
typedef struct element { void *data; struct element *next, *prev; } element;
typedef struct list { element *head, *tail; } list;


/* next, some basic building block structs */
typedef struct point { int x, y; } point;
typedef struct vector { int x, y; } vector;
typedef struct dimensions { int w, h; } dimensions;
typedef struct box { int x1, y1, x2, y2; } box;
typedef struct color { unsigned char r, g, b, a; } color;

/* a couple of oddball data structures */
typedef struct convolution { int kw, kh; char kernel[MAX_CK_SIZE*MAX_CK_SIZE]; int divisor; int offset; } convolution;
typedef struct lut { unsigned char r[RGB_RANGE], g[RGB_RANGE], b[RGB_RANGE]; } lut;
typedef struct mcp { unsigned char *code; int tick; } mcp;
typedef void (*event)(void *);

typedef struct pixel_fmt { char rshift, gshift, bshift, ashift; int epoch; } pixel_fmt;



/*
 * a set of list iteration types and macros
 */
typedef struct iterator { list *my_l; element *my_el; int ct; } iterator;

/* initialize a list iterator: pass in an iterator struct and the list to iterate */
#define iterator_start(i, l) do { (i).my_l = (l); (i).my_el = (l)->head; (i).ct = 0; } while(0)

/* advance to the next element, get the current data, get the iteration count */
#define iterator_next(i) do { if( (i).my_el ) { (i).my_el = (i).my_el->next; (i).ct++; } } while(0)
#define iterator_data(i) ((i).my_el ? (i).my_el->data : NULL)
#define iterator_ct(i) ((i).ct)





/* the image frame struct, as seen in sprites and map tiles */
typedef struct frame
{
	/* frame type, dimensions */
	int tag;
	int w, h;

	pixel_fmt pixel;

	/* a seldom-used rendering offset */
	point offset;

	/* the frame internal clipping rectangle */
	box clip_rect;

	/* pointers to frame/auxiliary data and scratchpad surface */
	void *data, *aux;

	/* a pixel mask, typically used for pixel-accurate collisions */
	unsigned char *mask;
} frame;




/* the sprite struct itself */
typedef struct sprite
{
	/* general sprite settings */
	int frame_ct;                 /* total frame ct */
	int cur_frame;                /* active frame */
	int collides;                 /* does the sprite collide? */
	int z_hint;                   /* a rendering-order hint */
	point pos;                    /* current position */
	vector vel;                   /* the current velocity */

	/* the scale factor of the rendered sprite */
	point scale;

	/* the sprite's composited frames */
	struct framestack { int len; frame **stack; } *frames;

	/* collision detection: frame-specific bounding boxes, current bounding region (cached) */
	box *bound;
	box bc;

	/* motion-control code */
	mcp motion;

} sprite;





/*
 * map-related structures
 */
typedef struct tile
{
	/* the tile animation type, count, current animation index, and collision mode */
	int anim_type;
	int frame_ct, cur_frame;
	int collides;

	/* the tile's frame array */
	struct frame **frames;
} tile;


typedef struct map
{
	/* tile data etc */
	int tw,th;
	tile *tiles[MAX_TILES];

	/* map data allocated to width times height - each short a ptr to the tile num to use */
	int w,h;            /* map width, height */
	short *data;

	/* structures to hold the division precomputation */
	struct libdivide_s32_t *tw_div, *th_div;
} map;





/*
 * on-screen display
 */
typedef struct font
{
	char name[50];
	int w,h;
	struct frame *chars[FONT_CT];  /* the character slices */
} font;

typedef struct string
{
	char font[50];                        /* which font to use */
	int x,y;                              /* the position of this string */
	char text[MAX_STRING_LENGTH];         /* 240 character limit */
} string;







/*
 * collision- and introspection-related structures
 */
typedef struct map_collision
{
	int mode;                  /* did we start in a collision, etc */
	vector stop;        /* how far we can go before we stop */
	vector go;          /* after collision, how much farther we can travel .. */
} map_collision;

typedef struct sprite_collision                /* sprite-to-sprite collision */
{
	int mode;                    /* did we start in a collision? */
	vector dir;           /* the direction in which this collision occurred */
	vector stop;          /* the distance to the target */
	void *target;       /* which sprite we have hit */
} sprite_collision;

typedef struct map_fragment
{
	int w,h;
	short *tiles;
} map_fragment;



/*
 * sound
 */
typedef struct sound
{
	/* two buffers - one for the mixer, and one to hold the sound if it is loaded as raw data */
	void *wave;
	unsigned char *buf;
} sound;



/*
 * input-related structs:  axes are analog (or mapped keys) and are
 * always read in pairs, e.g. analog stick 0 will be read on axes 0
 * and 1.  hats are digital and are read singly.  buttons are digital.
 * a few system keys are hard-wired into the input struct.
 */
typedef struct input
{
	int axis[MAX_AXES];
	vector hat[MAX_HATS];
	int button[MAX_BUTTONS];
	int space,tab,sel,pause,esc;
} input;

typedef struct mouse
{
	int x,y;
	int button[7];
} mouse;
