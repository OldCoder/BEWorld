#include <stdio.h>
#include <stdlib.h>
#include "common.h"
#include "misc.h"







/*
 * alloc wrappers that check for failure and quit the program on failure
 */
void *ck_malloc(size_t size)
{
	void *m;

	if( !size )
		return NULL;

	m = malloc(size);
	if( !m )
		fatal("malloc failed!",99);

	return m;

}

void *ck_calloc(int ct, size_t size)
{
	void *m;

	if( !ct || !size )
		return NULL;

	m = calloc(ct, size);
	if( !m )
		fatal("calloc failed!",99);

	return m;

}

void *ck_realloc(void *orig, size_t size)
{
	void *m;

	if( !size )
		return orig;

	m = realloc(orig, size);
	if( !m )
		fatal("realloc failed!",99);

	return m;

}






/*
 * use this to sudden exit
 */
void fatal(char *msg,int code)
{
	printf("Fatal error: %s!\n",msg);
	exit(code);
}
