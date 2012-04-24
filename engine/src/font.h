
/*
 * string.h
 */

void init_fonts();
void quit_fonts();

void font_add(const char *, int, int, const unsigned char *, int *);
void font_from_disk(const char *, const char *, int *);
void font_from_buffer(const char *, int, const unsigned char *, int *);

font *get_font_by_name(const char *);
static font *prepare_font(frame *, int *);

/* from frame.c */
frame *frame_from_disk(const char *);
frame *frame_from_buffer(int, const unsigned char *);

/* from list.c */
extern list *list_create();
extern void list_add(list *, void *);

/* from frame.c */
extern frame *frame_create(int, int, int, const void *, const void *);
extern frame *frame_slice(frame *, int, int, int, int);
extern void frame_delete(frame *);

/* from misc.c */
extern void *ck_malloc(size_t);
extern void *ck_calloc(int, size_t);
extern void fatal(char *, int);
