
/*
 * the initialization routine
 */

void init_brick();
void quit_brick();


/* from various source files .. */
extern void init_renderer();
extern void init_layers();
extern void init_fonts();
extern void init_io();
extern void init_events();

extern void io_grab(int);
extern void audio_close();
extern void graphics_close();

extern void quit_layers();
extern void quit_fonts();
extern void quit_events();

extern void set_pixel_order(int, int, int);
