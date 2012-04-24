/*
 * brick.h
 *
 * Copyright (c) 2006, 2007, 2008, 2009, 2010, 2011 Stephen M. Havelka
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please visit the project web site:
 * http://rs.tc/br/
 *
 */
#ifndef BRICK_H
#define BRICK_H


#ifdef __cplusplus
extern "C" {
#endif


#define BRICK_VERSION "${brick_version}"


/* Compile-time options */
#cmakedefine WITH_GL 1
#cmakedefine WITH_SIMD 1
#cmakedefine WITH_IMAGE 1


#define MAX_WIDTH ${DISPLAY_MAX_WIDTH}
#define MAX_HEIGHT ${DISPLAY_MAX_HEIGHT}

${pub-defines}
${pub-types}


/*
 * The Brick API
 */
extern int graphics_open(int, int, int, int, int);
extern void graphics_close();


extern int audio_open(int);
extern void audio_close();


extern int io_fetch(int, input *);
extern int io_mouse(int, mouse *);
extern void io_grab(int);
extern int io_has_quit();
extern int io_wait(int);
extern void io_assign(int, int, ...);
extern int io_read_key();


extern void render_set_bg_fill(int);
extern void render_set_bg_color(char, char, char);
extern void render_set_overdraw(int, int);
extern void render_display();
extern int render_to_disk(const char *);


extern void font_add(const char *, int, int, const unsigned char *, int *);
extern void font_from_disk(const char *, const char *, int *);
extern void font_from_buffer(const char *, int, const unsigned char *, int *);


extern sound *sound_load_from_disk(const char *);
extern sound *sound_load_from_buffer(int, const unsigned char *);
extern sound *sound_load_raw(int, const unsigned char *);
extern int sound_play(sound *, int);
extern void sound_halt(int);
extern void sound_adjust_vol(int, int);
extern void sound_adjust_pan(int, int);


extern void song_play_from_disk(const char *, int);
extern void song_play_from_buffer(int, const unsigned char *, int);
extern void song_stop(int);
extern void song_pause();
extern void song_resume();
extern void song_set_position(int);
extern void song_adjust_vol(int);


extern list *list_create();
extern void list_empty(list *);
extern void list_delete(list *);
extern void list_add(list *, void *);
extern void list_prepend(list *, void *);
extern void *list_shift(list *);
extern void *list_pop(list *);
extern void list_remove(list *, void *, int);
extern int list_length(list *);
extern int list_find(list *, void *);
extern void list_sort(list *, int (*)(void *, void *));


extern int layer_count();
extern int layer_add();
extern void layer_reorder(int, int);
extern void layer_remove(int);
extern int layer_copy(int);
extern list *layer_get_sprite_list(int);
extern map *layer_get_map(int);
extern list *layer_get_string_list(int);
extern int layer_get_visible(int);
extern int layer_get_sorting(int);
extern int layer_get_view(int, box *);
extern void layer_set_sprite_list(int, list *);
extern void layer_set_map(int, map *);
extern void layer_set_string_list(int, list *);
extern void layer_set_visible(int, int);
extern void layer_set_sorting(int, int);
extern void layer_set_view(int, box *);
extern int layer_get_camera(int, int *, int *);
extern void layer_set_camera(int, int, int);
extern void layer_adjust_camera(int, int, int);


extern int frame_info(frame *, int *, int *, int *);
extern frame *frame_create(int, int, int, const void *, const void *);
extern frame *frame_copy(frame *);
extern void frame_delete(frame *);
extern void frame_set_offset(frame *, int, int);
extern int frame_set_mask(frame *, const unsigned char *);
extern int frame_set_mask_from(frame *, frame *);
extern frame *frame_slice(frame *, int, int, int, int);
extern frame *frame_convert(frame *, int, const void *);
extern frame *frame_effect(frame *, int, ...);
extern frame *frame_from_disk(const char *);
extern frame *frame_from_buffer(int, const unsigned char *);


extern map *map_create();
extern void map_empty(map *, int);
extern void map_delete(map *);
extern int map_get_tile_size(map *, int *, int *);
extern int map_get_size(map *, int *, int *);
extern int map_get_tile(map *, int, tile **);
extern void map_set_tile_size(map *, int, int);
extern void map_set_size(map *, int, int);
extern void map_set_tile(map *, int, tile *);
extern void map_set_data(map *, const short *);
extern void map_set_single(map *, int, int, short);
extern void map_animate_tiles(map *);
extern void map_reset_tiles(map *);


extern tile *tile_create();
extern void tile_delete(tile *);
extern int tile_add_frame(tile *, frame *);
extern int tile_add_frame_data(tile *, int, int, int, const void *, const void *);
extern int tile_get_collides(tile *, int *);
extern int tile_get_anim_type(tile *, int *);
extern void tile_set_collides(tile *, int);
extern void tile_set_anim_type(tile *, int);
extern void tile_set_pixel_mask(tile *, int, const unsigned char *);
extern void tile_set_pixel_mask_from(tile *, int, frame *);
extern void tile_animate(tile *);
extern void tile_reset(tile *);


extern sprite *sprite_create();
extern sprite *sprite_copy(sprite *);
extern void sprite_delete(sprite *);
extern int sprite_get_frame(sprite *, int *);
extern int sprite_get_z_hint(sprite *, int *);
extern int sprite_get_collides(sprite *, int *);
extern int sprite_get_position(sprite *, int *, int *);
extern int sprite_get_velocity(sprite *, int *, int *);
extern int sprite_get_scale(sprite *, int *, int *);
extern void sprite_set_frame(sprite *, int);
extern void sprite_set_z_hint(sprite *, int);
extern void sprite_set_collides(sprite *, int);
extern void sprite_set_position(sprite *, int, int);
extern void sprite_set_velocity(sprite *, int, int);
extern void sprite_set_scale(sprite *, int, int);
extern void sprite_set_bounding_box(sprite *, int, box *);
extern void sprite_set_pixel_mask(sprite *, int, const unsigned char *);
extern void sprite_set_pixel_mask_from(sprite *, int, frame *);
extern int sprite_add_frame(sprite *, frame *);
extern int sprite_add_frame_data(sprite *, int, int, int, const void *, const void *);
extern int sprite_add_subframe(sprite *, int, frame *);
extern int sprite_load_program(sprite *, const char *);

#define sprite_set_scalei(s, x, y) sprite_set_scale(s, (x) * 65536, (y) * 65536)
#define sprite_set_scalef(s, x, y) sprite_set_scale(s, (int)((x) * 65536), (int)((y) * 65536))



extern string *string_create();
extern void string_delete(string *);
extern int string_get_box(string *, int *, int *);
extern void string_set_font(string *, const char *);
extern void string_set_position(string *, int, int);
extern void string_set_text(string *, const char *);


extern void inspect_adjacent_tiles(map *, sprite *, int, map_fragment *);
extern void inspect_obscured_tiles(map *, sprite *, map_fragment *);
extern int inspect_line_of_sight(map *, sprite *, int, int, int, sprite *);
extern list *inspect_in_frame(list *, box *);
extern list *inspect_near_point(list *, int, int, int);


extern void collision_with_map(sprite *, map *, int, map_collision *);
extern int collision_with_sprites(sprite *, list *, int, sprite_collision *);

extern int motion_exec_single(sprite *);
extern int motion_exec_list(list *);


extern int clock_ms();
extern int clock_wait(int);


extern int event_add(int, int, event, void *);
extern void event_message(int, int);


extern void init_brick();
extern void quit_brick();


#ifdef __cplusplus
}
#endif


#endif
