#include <stdio.h>
#include <stdlib.h>
#include "common.h"
#include "list.h"





/*
 * create and free lists
  */
list *list_create()
{
	return ck_calloc(1,sizeof(list));
}




void list_delete(list *l)
{
	/* failsafe */
	if( !l )
		return;

	/* free the list and id */
	list_empty(l);
	free(l);

}




/*
 * empties out a list
 */
void list_empty(list *l)
{
	element *el;

	/* failsafe */
	if( !l )
		return;

	/* eat the list head-first, one element at a time */
	while( l->head )
		{
			/* save the element ptr and advance the head */
			el = l->head;
			l->head = l->head->next;

			/* and, free the element */
			free(el);

		}

}














/*
 * add an item to the end of the given list
 */
void list_add(list *l, void *data)
{
	element *el;

	/* failsafe */
	if( !l )
		return;

	/* allocate the list element */
	el = ck_malloc(sizeof(element));
	el->data = data;

	/* append item to list */
	el->next = NULL;
	el->prev = l->tail;

	/* note that empty lists need to be handled slightly differently .. */
	if( l->tail )
		l->tail->next = el;
	else
		l->head = el;

	l->tail = el;

	return;

}




/*
 * add an item to the start of the given list
 */
void list_prepend(list *l, void *data)
{
	element *el;

	/* fetch the pointer and verify */
	if( !l )
		return;

	/* allocate the list element */
	el = ck_malloc(sizeof(element));
	el->data = data;

	/* append to list */
	el->prev = NULL;
	el->next = l->head;

	/* note that empty lists need to be handled slightly differently .. */
	if( l->head )
		l->head->prev = el;
	else
		l->tail = el;

	l->head = el;

	return;

}




/*
 * return the first item from the list and remove it
 */
void *list_shift(list *l)
{
	element *el;
	void *data;

	/* failsafe */
	if( !l )
		return NULL;

	/* grab the lead element and shift the list beyond it */
	if( l->head )
		{
			el = l->head;
			l->head = el->next;

			/* fetch the id and free the element */
			data = el->data;
			free(el);

			/* and return the id */
			return data;

		}
	else
		return NULL;

}




/*
 * return the last item from the list and remove it
 */
void *list_pop(list *l)
{
	element *el;
	void *data;

	/* failsafe */
	if( !l )
		return NULL;

	/* grab the lead element and shift the list beyond it */
	if( l->tail )
		{
			el = l->tail;
			l->tail = el->prev;

			/* preserve the id and free the element */
			data = el->data;
			free(el);

			/* and return the id */
			return data;

		}
	else
		return NULL;

}




/*
 * remove one or all of an item from a list
 */
void list_remove(list *l, void *data, int dir)
{
	element *el, *el2;

	/* failsafe */
	if( !l )
		return;

	/* remove first matching element (and remove all) */
	if( dir == LIST_HEAD || dir == LIST_ALL )
		{
			/* start at the top */
			el = l->head;
			while( el )
				{
					/* if it matches .. */
					if( el->data == data )
						{
							/* preserve the next ptr */
							el2 = el->next;

							/* remove it .. */
							if( el->next )
								el->next->prev = el->prev;
							else
								l->tail = el->prev;

							if( el->prev )
								el->prev->next = el->next;
							else
								l->head = el->next;

							free(el);

							/* and return */
							if( dir != LIST_ALL )
								return;

							/* and restore the next ptr */
							el = el2;

						}
					else
						el = el->next;

				}

		}
	else if( dir == LIST_TAIL )
		{
			/* start at the end */
			el = l->tail;
			while( el )
				{
					/* if it matches .. */
					if( el->data == data )
						{
							/* remove it .. */
							if( el->prev )
								el->prev->next = el->next;
							else
								l->head = el->next;

							if( el->next )
								el->next->prev = el->prev;
							else
								l->tail = el->prev;

							free(el);

							/* and return */
							return;

						}

					el = el->prev;

				}

		}

}






/*
 * get the list *length
 */
int list_length(list *l)
{
	element *el;
	int ct;

	/* failsafe */
	if( !l )
		return ERR;

	ct = 0;

	/* count the elements */
	el = l->head;
	while( el )
		{
			ct++;
			el = el->next;
		}

	/* and done! */
	return ct;

}




/*
 * is this item in the given list?
 */
int list_find(list *l, void *data)
{
	int ct;
	element *el;

	/* failsafe */
	if( !l )
		return ERR;

	ct = 0;

	/* count the elements */
	el = l->head;
	while( el )
		{
			if( el->data == data )
				ct++;

			el = el->next;

		}

	/* and done! */
	return ct;

}









/*
 * sort a linked list using the 'insertion' sort algorithm, which
 * works well on mostly-sorted lists.  comparisons are done by
 * the (*compare)() function.
 */
void list_sort(list *l, int (*compare)(void *, void *))
{
	element *el1, *el2, *elmin;
	void *swap;

	/*
	 * for i from 1 to N
	 *   min = i
	 *   for j from i + 1 to N
	 *     if a[j] < a[min]
	 *       min = j
	 *   swap( a[i], a[min] )
	 */
	if( !l )
		return;

	el1 = l->head;

	while( el1 )
		{
			/* start the list */
			elmin = el1;
			el2 = el1->next;

			/* find the smallest item */
			while( el2 )
				{
					/* if j is smaller than min, move it to the front of the list */
					if( compare(el2->data, elmin->data) < 0 )
						elmin = el2;

					el2 = el2->next;

				}


			/* and swap if necessary */
			if( el1 != elmin )
				{
					/* swap position of l and lmin */
					swap = el1->data;
					el1->data = elmin->data;
					elmin->data = swap;

				}

			/* and move to the next starting point */
			el1 = el1->next;

	}

}
