#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"
#include "string.h"


/*
 * create a new string
 */
string *string_create()
{
	string *st;

	/* initialize the new string */
	st = ck_calloc(1,sizeof(string));
	strcpy(st->font,"default");

	return st;

}




/*
 * remove a string
 */
void string_delete(string *st)
{
	/* get the string pointer and verify */
	if( !st )
		return;

	free(st);

}





/*
 * find the bounding region of the given text string
 */
int string_get_box(string *st, int *w, int *h)
{
	int i, len, line_w;
	font *f;


	/* failsafe */
	if( !st )
		return ERR;


	/* initialize the box dimensions */
	*w = 0;
	*h = 0;


	/* check the font ptr */
	f = get_font_by_name(st->font);
	if( f )
		{
			/* find and calculate the string length */
			len = strlen(st->text);

			if( len )
				{
					/* initialize the line height */
					*h = f->chars['\n']->h;
					line_w = 0;

					for( i=0; i < len; i++ )
						{
							/* .. and the switch handles our specific control characters */
							switch( *(st->text + i) )
								{
									case '\t':
										line_w += f->chars[32]->w * 8;
										break;

									case '\n':
										/* check to see if this is the longest line yet */
										if( *w < line_w )
											*w = line_w;

										/* add a new line */
										line_w = 0;
										*h += f->chars['\n']->h;
										break;

									case '\r':
										break;

									default:
										line_w += f->chars[*(st->text + i)]->w;
										break;

								}

						}

					/* check to see if we've saved the length of the longest line */
					if( *w < line_w )
						*w = line_w;


				}

		}

	/* ok, done */
	return 0;

}







/*
 * a series of simple functions to set string bits now follows
 */
void string_set_font(string *st, const char *font)
{
	/* get the string pointer and verify */
	if( !st )
		return;

	strncpy(st->font, font, 49);

}



void string_set_position(string *st, int x, int y)
{
	/* get the string pointer and verify */
	if( !st )
		return;

	/* set the position for the specified string */
	st->x = x;
	st->y = y;

}



void string_set_text(string *st, const char *text)
{
	/* get the string pointer and verify */
	if( !st )
		return;

	/* set the text contents of the specified string */
	strncpy(st->text, text, MAX_STRING_LENGTH-1);

}
