#include <stdio.h>
#include <tcl.h>
#include "SDL.h"
#include "SDL_mixer.h"
#include "brick.h"
#include "tcl-mod.h"







/* these are the tcl init/exit routines */
int DLLEXPORT Br_Init(Tcl_Interp *interp)
{

   /* initialize stubs and create the exit handler */
   if( !Tcl_InitStubs(interp, TCL_VERSION, 0) )
     return TCL_ERROR;

   Tcl_CreateExitHandler(Br_Atexit, NULL);


   /* prepare environment and load functions into tcl */
   init_brick();
   load_routines(interp);

   return TCL_OK;
}



int DLLEXPORT Br_Unload(Tcl_Interp *interp, int flags)
{
   /* remove the tcl commands from the interp and shut down sdl */
   Tcl_DeleteNamespace(ns);
   Tcl_DeleteExitHandler(Br_Atexit, NULL);
   quit_brick();

   return TCL_OK;
}



static void Br_Atexit(ClientData cData)
{
   /* at application exit, shut down sdl */
   quit_brick();
}
