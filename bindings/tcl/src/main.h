
/*
 * main.h
 */

void init_tcl(char *);
void fatal(char *, int);
char *read_file(char *);

extern void load_routines(Tcl_Interp *);
