
/*
 * functions for list.c
 */

list *list_create();
void list_empty(list *);
void list_delete(list *);

void list_add(list *, void *);
void list_prepend(list *, void *);
void *list_shift(list *);
void *list_pop(list *);
void list_remove(list *, void *, int);
int list_length(list *);
int list_find(list *, void *);

void list_sort(list *, int (*)(void *, void *));


/* from misc.h */
extern void *ck_malloc(size_t);
extern void *ck_calloc(int, size_t);
extern void fatal(char *, int);
