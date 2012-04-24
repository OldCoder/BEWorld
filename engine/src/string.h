/*
 * string.h
 */

string *string_create();
void string_delete(string *);

int string_get_box(string *, int *, int *);
void string_set_font(string *, const char *);
void string_set_position(string *, int, int);
void string_set_text(string *, const char *);


/* from font.c */
extern font *get_font_by_name(const char *);

/* from misc.c */
extern void *ck_calloc(int, size_t);
