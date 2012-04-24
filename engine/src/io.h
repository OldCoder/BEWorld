
/*
 * header file for io.c
 */

#define THRESH 3200
#define LIMIT 32000


/*
 * the joystick analog inputs range -32768 to 32767.
 * these map the analog results onto a smaller range.
 */
#define RANGE 127
#define SHIFT 8

/* a direction-specifier */
struct dir { int horiz, vert; };

/* a struct to hold a set of keys mapped onto an axis */
struct akey { int l,r; };

/* a struct to hold a set of keys mapped onto a hat */
struct hkey { int u,r,d,l; };

/* keyboard mappings for the axes, hats, and buttons */
struct input_def
{
	struct akey axis[MAX_AXES];
	struct hkey hat[MAX_HATS];
	int button[MAX_BUTTONS];

	int axis_flag[MAX_AXES];
	struct dir hat_flag[MAX_HATS];

};


/* io's routines */
void init_io();

int io_fetch(int, input *);
int io_mouse(int, mouse *);
void io_grab(int);
int io_has_quit();
int io_wait(int);

void io_assign( int, int, ... );
int io_read_key();

/* from clock.c */
extern int clock_wait(int);

/* from misc.c */
extern void fatal(char *,int);
