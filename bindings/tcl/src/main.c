#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <tcl.h>
#include "SDL.h"
#include "SDL_main.h"
#include "SDL_mixer.h"
#include "brick.h"
#include "main.h"






/* the tcl interp */
Tcl_Interp *main_tcl;







int main(int argc, char *argv[]) {

	/* our game script, defaults to main.tcl */
	char *script_name = "main.tcl";
	char *script;

	/* tcl return code vars */
	int tcl_ret;
	CONST char *tcl_res;

	/* init the environment and prepare the tcl interpreter */
	init_brick();
	init_tcl(argv[0]);

	atexit(quit_brick);


	/* is there a command-line argument for a new script name? */
	if( argc == 2 )
		script_name = argv[1];


	/* ok!  load the script! */
	script = read_file(script_name);
	if( !script )
		fatal("Oh no!  the game script could not be read for some reason!",1);


	/* run the tcl program */
	tcl_ret = Tcl_Eval(main_tcl,script);
	if( tcl_ret == TCL_ERROR )
		{
			tcl_res = Tcl_GetStringResult(main_tcl);
			printf( "Tcl quit with an error: %s\n", tcl_res);
		}

	/* return the results of the tcl script */
	return tcl_ret;

}











/*
 * create the tcl interp and load the brick routines
 */
void init_tcl(char *argv0)
{
	/* initialize Tcl */
	Tcl_FindExecutable(argv0);
	main_tcl = Tcl_CreateInterp();
	if( !main_tcl )
		fatal("Could not initialize tcl!",4);

	Tcl_Init(main_tcl);

	/* and load the functions into tcl */
	load_routines(main_tcl);

}








/*
 * use this to sudden exit
 */
void xfatal(char *msg,int code)
{
	printf("Fatal error: %s!\n",msg);
	exit(code);
}













/*
 * read a file into a buffer
 */
char *read_file(char *path)
{

	FILE *fh;
	struct stat *info;
	int size = 0;
	char *buf;


	/* get the file size */
	info = malloc(sizeof(struct stat));
	if( !info )
		fatal("malloc failed!",99);


	if( !stat(path,info) )      /* success! */
		size = info->st_size;
	else
		size = 0;

	free(info);



	if( size )
		{

			/* allocate our array for tcl commands */
			buf = (char *)calloc(size+1, 1);
			if( !buf )
				fatal("calloc failed!",99);

			/* open and read the script */
			fh = fopen(path,"r");
			if( fh )          /* ok, it's open */
				{
					fread(buf, 1, size, fh);
					fclose(fh);
				}

			/* ok now did we get anything? */
			if( strlen(buf) )
				return buf;     /* ret:  OK (ptr to buffer) */
			else
				{
					free(buf);
					return NULL;  /* ret:  ERR */
				}

		}
	else
		return NULL;    /* ret:  ERR */

}
