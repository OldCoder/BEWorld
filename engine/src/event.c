#include <stdio.h>
#include "SDL.h"
#include "SDL_thread.h"
#include "SDL_mutex.h"
#include "common.h"
#include "event.h"



/* a list of messages to pass to events */
static list *event_msgs;
static SDL_mutex *event_msgs_lock;




/*
 * prepare the container and mutex for event signals
 */
void init_events()
{
	DEBUG( "Initializing event manager...");
	event_msgs = list_create();
	event_msgs_lock = SDL_CreateMutex();
	DEBUGF;
}




void quit_events()
{
	DEBUG( "Quitting event manager...");
	SDL_DestroyMutex(event_msgs_lock);
	list_delete(event_msgs);
	event_msgs = NULL;
	DEBUGF;
}







/*
 * add a scheduled event:
 * - the delay is in milliseconds.
 * - the count indicates the # of times the event should run,
 *   where -1 indicates an indefinite lifetime.
 * - the event is a pointer to a function that takes a void
 *   ptr and returns nothing.
 * - the void ptr (can be null) is passed into the event each
 *   time it's called
 *
 * each scheduled event runs in its own thread.
 */
int event_add(int delay, int ct, event ev, void *evdata)
{
	/* the event scheduling data */
	struct event_schedule *my_ev;

	/* load up the struct */
	my_ev = ck_malloc(sizeof(struct event_schedule));
	my_ev->delay = delay;
	my_ev->ct = ct;
	my_ev->ev = ev;
	my_ev->data = evdata;

	/* and spin the event off into a new thread! */
	return SDL_GetThreadID(SDL_CreateThread(event_loop, my_ev));

}






/*
 * send a message (e.g. halt, continue ..) to an event
 */
void event_message(int id, int msg)
{
	struct event_msg *e;

	/* prepare the message struct */
	e = ck_malloc(sizeof(struct event_msg));
	e->id = id;
	e->msg = msg;

	/* lock the message queue for writing */
	SDL_mutexP(event_msgs_lock);
	list_add(event_msgs, e);

	/* and done! */
	SDL_mutexV(event_msgs_lock);

}









/*
 * a container/scheduler for the specific event .. this is what
 * is spawned into separate threads.
 */
static int event_loop(void *data)
{
	/* to the event scheduler information */
	struct event_schedule *my_ev;

	/* current event thread id and event scheduling status */
	int my_id, status;
	int len;

	/* list-walking within the event schedule loop */
	iterator iter;
	struct event_msg *my_msg;


	/* grab the event schedule and set an initial status .. */
	my_ev = data;
	status = EVENT_GO;

	/* and save the thread ID, so we don't need to look it up later. */
	my_id = SDL_ThreadID();


	while( 1 )
		{
			/*
			 * the order of operations is:
			 * - sleep until the event is ready to fire
			 * - check for messages specific to this event
			 * - if there is a message, act on it.
			 * - run the event.
			 * - if it's an infinitely-recurring event, sleep.
			 * - if it has a finite lifetime, decrement its counter and exit if it's finished running.
			 */
			SDL_Delay(my_ev->delay);


			/* lock access to the list */
			SDL_mutexP(event_msgs_lock);

			/* any messages waiting? */
			len = list_length(event_msgs);
			if( len == ERR )
				/*
				 * if the list itself no longer exists, then the event manager has shut down
				 * and we ought to exit immediately.
				 */
				status = EVENT_STOP;
			else if( len > 0 )
				{

					/* there is possibly an event waiting for us */
					iterator_start(iter, event_msgs);
					while( (my_msg = iterator_data(iter)) )
						{
							/* is this message to this thread? */
							if( my_id == my_msg->id )
								{
									/* yes, save the status .. */
									status = my_msg->msg;

									/* .. and remove the message */
									list_remove(event_msgs, my_msg, LIST_HEAD);
									free(my_msg);

								}

							/* next message .. */
							iterator_next(iter);

						}

				}

			/* remove the list lock */
			SDL_mutexV(event_msgs_lock);


			/* is there an event message that changes execution? */
			switch(status)
				{
					case EVENT_GO:
						my_ev->ev(my_ev->data);    /* fire the event! */
						break;

					case EVENT_PAUSE:            /* don't run the event, and don't count down its lifetime */
						continue;

					case EVENT_SKIP1:
						status = EVENT_GO;         /* consume one event cycle without doing anything */
						break;

					case EVENT_STOP:
						my_ev->ct = 0;
						break;

				}



			/*
			 * if the event lifetime is zero, quit the event loop now.  if it's
			 * greater than zero, decrement it and continue.  if it's less than
			 * zero, do nothing to the lifetime because it's an indefinite event.
			 */
			if( !my_ev->ct )
				break;
			else if( my_ev->ct > 0 )
				my_ev->ct--;


		}

	/* and, done */
	free(my_ev);
	return 0;

}
