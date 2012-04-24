/*
 * a timed-events scheduler
 */

struct event_schedule
{
	int delay;
	int ct;
	event ev;
	void *data;
};

struct event_msg
{
	int id;
	int msg;
};



void init_events();
void quit_events();

int event_add(int, int, event, void *);
void event_message(int, int);

static int event_loop(void *);


/* from list.c */
extern list *list_create();
extern void list_add(list *, void *);
extern int list_length(list *);
extern void list_remove(list *, void *, int);


/* from misc.h */
extern void *ck_malloc(size_t);
