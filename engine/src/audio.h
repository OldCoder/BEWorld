
/*
 * some function prototypes
 */

void init_audio();

int audio_open(int);
void audio_close();

sound *sound_load_from_disk(const char *);
sound *sound_load_from_buffer(int, const unsigned char *);
sound *sound_load_raw(int, const unsigned char *);
int sound_play(sound *, int);
void sound_halt(int);
void sound_adjust_vol(int, int);
void sound_adjust_pan(int, int);

void song_play_from_disk(const char *, int);
void song_play_from_buffer(int, const unsigned char *, int);
void song_stop(int);
void song_pause();
void song_resume();
void song_set_position(int);
void song_adjust_vol(int);


/* from misc.c */
extern void fatal(char *,int);
extern void *ck_malloc(size_t);
