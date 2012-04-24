
/*
 * rendering functions
 */

#define draw(dest, f, ofs) \
	do \
		{ \
			switch((f)->tag) \
				{ \
					case FRAME_RGB: system_frame.rgb((dest), (f), (ofs)); break; \
					case FRAME_RGBA: system_frame.rgba((dest), (f), (ofs)); break; \
					case FRAME_HL: system_frame.hl((dest), (f), (ofs)); break; \
					case FRAME_SL: system_frame.sl((dest), (f), (ofs)); break; \
					case FRAME_BR: system_frame.br((dest), (f), (ofs)); break; \
					case FRAME_CT: system_frame.ct((dest), (f), (ofs)); break; \
					case FRAME_SAT: system_frame.sat((dest), (f), (ofs)); break; \
					case FRAME_DISPL: system_frame.displ((dest), (f), (ofs)); break; \
					case FRAME_CONVO: system_frame.convo((dest), (f), (ofs)); break; \
					case FRAME_LUT: system_frame.lut((dest), (f), (ofs)); break; \
					case FRAME_XOR: system_frame.xor((dest), (f), (ofs)); break; \
				} \
			} \
	while(0)

#define draw_scaled(dest, f, ofs, span) \
	do \
		{ \
			switch((f)->tag) \
				{ \
					case FRAME_RGB: system_frame.rgb_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_RGBA: system_frame.rgba_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_HL: system_frame.hl_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_SL: system_frame.sl_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_BR: system_frame.br_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_CT: system_frame.ct_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_SAT: system_frame.sat_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_DISPL: system_frame.displ_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_CONVO: system_frame.convo_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_LUT: system_frame.lut_scaled((dest), (f), (ofs), (span)); break; \
					case FRAME_XOR: system_frame.xor_scaled((dest), (f), (ofs), (span)); break; \
				} \
			} \
	while(0)




void init_renderer();

void render_set_overdraw(int, int);
void render_set_bg_fill(int);
void render_set_bg_color(char, char, char);
void render_display();
int render_to_disk(const char *);

static void render_scene();
static void render_layer(int);
static int compare_by_z_hint(void *, void *);


/* from pixel.c */
extern renderer system_frame;

/* from list.c */
extern void list_sort(list *, int (*)(void *, void *));

/* from layers.c */
extern int layer_count();
extern list *layer_get_sprite_list(int);
extern map *layer_get_map(int);
extern list *layer_get_string_list(int);
extern int layer_get_visible(int);
extern int layer_get_sorting(int);
extern int layer_get_view(int, box *);
extern int layer_get_camera(int, int *, int *);

/* from graphics.c */
extern void activate_canvas(int, int);
extern void deactivate_canvas();
extern void show_rendered();

extern pixel_fmt system_pixel;
extern frame *canvas;
extern dimensions canvas_overdraw;


/* from font.c */
extern font *get_font_by_name(const char *);

/* from misc.h */
extern void fatal(char *,int);
