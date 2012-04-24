
/*
 * some function prototypes
 */


/* how many sprite collisions will the module accept? */
#define MAX_SPRITE_COLLISIONS 40

/* how long is pointer, when converted to text? */
#define PTR_LEN 20

/* pulled from SDL_mixer.h */
#define MIX_MAX_VOLUME 128

void load_routines(Tcl_Interp *);


/* debugging-output macros */
#define DEBUG(a)      do { fprintf(stderr,a); } while(0)
#define DEBUG_N(a, b) do { fprintf(stderr,a,b); } while(0)
#define DEBUGF        do { fprintf(stderr,"success!\n"); } while(0)
#define DEBUGNF       do { fprintf(stderr,"failure.\n"); } while(0)



/* all our stuff for making the C and tcl interact... */
static int wrap_graphics_open(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_graphics_close(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_graphics_window_title(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);

static int wrap_audio_modes(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_audio_open(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_audio_close(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);

static int wrap_io_fetch(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_io_mouse(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_io_has_quit(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_io_grab(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_io_wait(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_io_assign(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_io_read_key(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_render_bg_fill(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_render_bg_color(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_render_set_overdraw(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_render_display(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);
static int wrap_render_to_disk(ClientData, Tcl_Interp *, int, Tcl_Obj* CONST []);

static int wrap_font_add(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_font_from_disk(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_font_from_buffer(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_sound_load_file(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sound_load_buffer(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sound_load_raw(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sound_play(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sound_halt(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sound_adj_vol(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sound_adj_pan(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_song_play_file(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_song_play_buffer(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_song_pause(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_song_resume(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_song_halt(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_song_set_position(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_song_adj_vol(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_list_create(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_empty(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_delete(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_add(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_prepend(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_shift(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_pop(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_remove(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_length(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_list_find(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_layer_add(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_swap(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_remove(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_copy(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_sprite_list(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_map(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_string_list(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_visible(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_sorted(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_camera(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_layer_view(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_frame_info(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_create(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_delete(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_copy(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_offset(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_mask(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_mask_from(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_slice(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_convert(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_effect(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_from_disk(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_frame_from_buffer(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_map_create(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_empty(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_delete(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_size(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_tile_size(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_tile(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_set_data(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_set_single(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_animate_tiles(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_map_reset_tiles(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_tile_create(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_delete(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_anim_type(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_collides(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_add_frame(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_add_frame_data(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_pixel_mask(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_pixel_mask_from(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_animate(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_tile_reset(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_sprite_create(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_copy(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_delete(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_frame(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_z_hint(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_scale(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_collides(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_bounding_box(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_pixel_mask(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_pixel_mask_from(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_position(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_velocity(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_add_frame(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_add_frame_data(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_add_subframe(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_sprite_load_program(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_string_create(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_string_delete(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_string_box(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_string_font(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_string_position(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_string_text(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_inspect_adjacent_tiles(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_inspect_obscured_tiles(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_inspect_line_of_sight(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_inspect_in_frame(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_inspect_near_point(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_collision_map(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_collision_sprites(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_motion_list(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_motion_single(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);

static int wrap_clock_ms(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
static int wrap_clock_wait(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
