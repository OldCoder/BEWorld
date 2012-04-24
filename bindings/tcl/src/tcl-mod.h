
/*
 * some function prototypes
 */




int DLLEXPORT Br_Init(Tcl_Interp *);
int DLLEXPORT Br_Unload(Tcl_Interp *, int);
static void Br_Atexit(ClientData);

extern void load_routines(Tcl_Interp *);



/* from tcl-common.c */
extern Tcl_Namespace *ns;
