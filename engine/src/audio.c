#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#define USE_RWOPS 1
#include "SDL.h"
#include "SDL_mixer.h"
#include "SDL_rwops.h"
#include "common.h"
#include "audio.h"




/* audio mode */
static int active_audio_mode = AUDIO_OFF;

/* the music buffers */
static Mix_Music *music;
static unsigned char *music_buf;









/*
 * open the specified audio output
 */
int audio_open(int mode)
{

	/* already open audio? */
	if( active_audio_mode )
		return ERR_CANT_REOPEN;
	else
		{
			/*
			 * no, not already open .. identify the desired audio mode
			 */
			switch(mode)
				{
					case AUDIO_SPEAKER:
						active_audio_mode = AUDIO_SPEAKER;
						break;

					default:
						return ERR_BAD_MODE;

				}


			/*
			 * ok!  so now we might have an audio mode set.  if so,
			 * let's try to open the audio device.
			 */
			if( active_audio_mode )
				{
					DEBUG( "Initializing SDL audio..." );
					if( SDL_InitSubSystem(SDL_INIT_AUDIO) < 0 )
						{
							DEBUGNF;
							active_audio_mode = AUDIO_OFF;
							return ERR_SDL_FAILED;
						}
					DEBUGF;

					DEBUG( "Starting mixer..." );
					if( Mix_OpenAudio(AUDIO_RATE, AUDIO_FORMAT, AUDIO_CHANNELS, AUDIO_BUFFERS) < 0 )
						{
							DEBUG_N("failed: %s\n",Mix_GetError());
							active_audio_mode = AUDIO_OFF;
							return ERR_SDL_MIXER_FAILED;
						}
					DEBUGF;

				}


		}

	/* ok, done */
	return 0;


}












/*
 * stop sounds and music and shut down audio subsystem
 */
void audio_close()
{


	/* we have not one thing to do if sound is not enabled */
	if( active_audio_mode )
		{

			if( music )
				{
					DEBUG("Halting music...");
					Mix_HaltMusic();
					Mix_FreeMusic(music);
					music = NULL;
					DEBUGF;
				}

			if( Mix_Playing(-1) )
				{
					DEBUG("Halting sound...");
					Mix_HaltChannel(-1);
					DEBUGF;
				}

			DEBUG("Shutting down audio...");
			Mix_CloseAudio();
			DEBUGF;

			/* and turn off the active audio mode */
			active_audio_mode = AUDIO_OFF;

		}


}












/*
 * load a sound from disk
 */
sound *sound_load_from_disk(const char *file)
{
	sound *s;

	/* allocate the sound struct */
	s = ck_malloc(sizeof(sound));

	/* we have an rw buffer!  let's try to load the sound data */
	s->wave = Mix_LoadWAV(file);
	if( !s->wave )
		{
			free(s);
			return NULL;
		}

	/* we've got a wav!  let's add it to list */
	return s;

}










/*
 * add a sound to the sound list
 */
sound *sound_load_from_buffer(int len, const unsigned char *data)
{
	sound *s;
	SDL_RWops *rw_buf;

	if( !len || !data )	 /* failsafe */
		return NULL;


	/* allocate the sound struct */
	s = ck_malloc(sizeof(sound));

	/* and the RWops buffer .. */
	rw_buf = SDL_RWFromConstMem(data, len);
	if( !rw_buf )
		fatal("RWops buffer alloc failed!",99);

	/* we have an rw buffer!  let's try to load the sound data */
	s->wave = Mix_LoadWAV_RW(rw_buf, 1);
	if( !s->wave )  /* invalid wav?  free the allocated wav struct .. */
		free(s);

	/* and return the result */
	return s;

}










/*
 * add a sound to the soundlist
 */
sound *sound_load_raw(int len, const unsigned char *data)
{
	sound *s;

	if( !len || !data )	 /* failsafe */
		return NULL;



	/* allocate the sound struct and the buffer to hold the raw data */
	s = ck_malloc(sizeof(sound));
	s->buf = ck_malloc(len);

	/* SDL_mixer does not make its own copy for raw-loaded data, so we must save it */
	memcpy(s->buf, data, len);

	/* and load the raw data */
	s->wave = Mix_QuickLoad_RAW(s->buf, len);
	if( !s->wave )
		{
			/* did it fail to load anything? */
			free(s);
			return NULL;
		}


	/* add it to the system sound list */
	return s;

}









/*
 * play a so-named sound, returning the channel of this sound, so
 * that the volume can be adjusted later
 */
int sound_play(sound *s, int vol)
{
	int ch;  /* the channel that this sound has been played onto */

	/* failsafe */
	if( !s )
		return ERR;

	if( active_audio_mode )
		{
			/* play the sound, set the volume as necessary, and return the channel */
			ch = Mix_PlayChannel(-1, s->wave, 0);
			Mix_Volume(ch, vol);
			return ch;
		}

	/* if we're here, for any reason, we played no sound, so return no channel */
	return ERR;

}





/*
 * halt currently playing sounds
 */
void sound_halt(int ch)
{
	if( active_audio_mode )
		Mix_HaltChannel(ch);
}




/*
 * adjust volume on given channel
 */
void sound_adjust_vol(int ch, int vol)
{
	if( active_audio_mode )
		Mix_Volume(ch, vol);
}


/*
 * adjust panning on given channel
 */
void sound_adjust_pan(int ch, int pan)
{
	if( active_audio_mode )
		if( pan >= 0 && pan <= 254 )
			Mix_SetPanning(ch, pan, 254 - pan);
}











/*
 * play a song from the named file on disk
 */
void song_play_from_disk(const char *song, int delay) {

	if( !song )	 /* failsafe */
		return;


	/* only play a song if sound is enabled */
	if( active_audio_mode ) {

		/* stop the currently-playing song */
		if( music )
			{
				Mix_HaltMusic();
				Mix_FreeMusic(music);
			}


		music=Mix_LoadMUS(song);
		if( music )
			Mix_FadeInMusic(music,-1,delay);  /* 1 means looping */

	}

}









/*
 * play a song from the given memory buffer
 */
void song_play_from_buffer(int len, const unsigned char *data, int delay)
{
	SDL_RWops *rw_buf;

	if( !len || !data )	 /* failsafe */
		return;


	/* only play a song if sound is enabled */
	if( active_audio_mode ) {


		/* stop the currently-playing song */
		if( music )
			{
				Mix_HaltMusic();
				Mix_FreeMusic(music);

				if( music_buf )
					free(music_buf);

			}


		/* copy the song into the temporary buffer, because SDL_mixer does not make its own copy */
		music_buf = ck_malloc(len);
		memcpy(music_buf,data,len);


		/* init the RWops buffer .. */
		rw_buf = SDL_RWFromMem(music_buf, len);
		if( !rw_buf )
			fatal("RWops buffer alloc failed!",99);


		music=Mix_LoadMUS_RW(rw_buf);
		if( music )
			Mix_FadeInMusic(music,-1,delay);  /* 1 means looping */
		else
			free(music_buf);		 /* did not play music?  free the temp buffer */


		/* free the RWops buffer */
		SDL_FreeRW(rw_buf);

	}

}











/*
 * stop currently-playing song
 */
void song_stop(int delay)
{

	if( active_audio_mode )	/* only stop if we have sound support */
		if( music )
			{

				if( delay )
					Mix_FadeOutMusic(delay);
				else
					Mix_HaltMusic();

				/* if necessary, free the music buffer */
				if( music_buf )
					{
						free(music_buf);
						music_buf = NULL;
					}

			}

}














/*
 * pause song
 */
void song_pause()
{
	if( active_audio_mode )
		if( music )
			Mix_PauseMusic();
}




/*
 * resume song
 */
void song_resume()
{
	if( active_audio_mode )
		if( music )
			Mix_ResumeMusic();
}




/*
 * set song position
 */
void song_set_position(int pos)
{
	if( active_audio_mode )
		Mix_SetMusicPosition(pos);
}




/*
 * adjust song volume
 */
void song_adjust_vol(int vol)
{
	if( active_audio_mode )
		Mix_VolumeMusic(vol);
}
