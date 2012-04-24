#include <stdio.h>
#include <tcl.h>
#include "SDL.h"
#include "brick.h"
#include "tcl-common.h"

/* the default brick namespace */
#define NS "br"
Tcl_Namespace *ns;

/* Some shortcuts */
#define Add_cmd(my_cmd, my_func) Tcl_CreateObjCommand(interp, NS "::" my_cmd, my_func, (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL)
#define Ensemble(name) \
	do \
		{ \
			Tcl_Eval(interp, \
				"namespace eval " NS "::" name " {\n" \
					"namespace export *\n" \
					"namespace ensemble create\n" \
				"}"); \
		} \
	while(0)

/* register brick routines into the given tcl interp */
void load_routines(Tcl_Interp *interp)
{
	/* here we go! */
	DEBUG("Registering C functions into tcl...");

	/* create the namespace for the brick engine commands */
	Tcl_Eval(interp, "namespace eval " NS " { namespace export * }");

	/* and now create a namespace for each command */
	Ensemble("graphics");
	Add_cmd("graphics::open", wrap_graphics_open);
	Add_cmd("graphics::close", wrap_graphics_close);
	Add_cmd("graphics::window-title", wrap_graphics_window_title);

	Ensemble("audio");
	Add_cmd("audio::modes", wrap_audio_modes);
	Add_cmd("audio::open", wrap_audio_open);
	Add_cmd("audio::close", wrap_audio_close);

	Ensemble("io");
	Add_cmd("io::fetch", wrap_io_fetch);
	Add_cmd("io::mouse", wrap_io_mouse);
	Add_cmd("io::has-quit", wrap_io_has_quit);
	Add_cmd("io::grab", wrap_io_grab);
	Add_cmd("io::wait", wrap_io_wait);
	Add_cmd("io::assign", wrap_io_assign);
	Add_cmd("io::read-key", wrap_io_read_key);

	Ensemble("render");
	Add_cmd("render::bg-fill", wrap_render_bg_fill);
	Add_cmd("render::bg-color", wrap_render_bg_color);
	Add_cmd("render::set-overdraw", wrap_render_set_overdraw);
	Add_cmd("render::display", wrap_render_display);
	Add_cmd("render::to-disk", wrap_render_to_disk);

	Ensemble("font");
	Add_cmd("font::add", wrap_font_add);
	Add_cmd("font::from-disk", wrap_font_from_disk);
	Add_cmd("font::from-buffer", wrap_font_from_buffer);

	Ensemble("sound");
	Add_cmd("sound::load-file", wrap_sound_load_file);
	Add_cmd("sound::load-buffer", wrap_sound_load_buffer);
	Add_cmd("sound::load-raw", wrap_sound_load_raw);
	Add_cmd("sound::play", wrap_sound_play);
	Add_cmd("sound::halt", wrap_sound_halt);
	Add_cmd("sound::adj-vol", wrap_sound_adj_vol);
	Add_cmd("sound::adj-pan", wrap_sound_adj_pan);

	Ensemble("song");
	Add_cmd("song::play-file", wrap_song_play_file);
	Add_cmd("song::play-buffer", wrap_song_play_buffer);
	Add_cmd("song::pause", wrap_song_pause);
	Add_cmd("song::resume", wrap_song_resume);
	Add_cmd("song::halt", wrap_song_halt);
	Add_cmd("song::set-position", wrap_song_set_position);
	Add_cmd("song::adj-vol", wrap_song_adj_vol);

	Ensemble("list");
	Add_cmd("list::create", wrap_list_create);
	Add_cmd("list::empty", wrap_list_empty);
	Add_cmd("list::delete", wrap_list_delete);
	Add_cmd("list::add", wrap_list_add);
	Add_cmd("list::prepend", wrap_list_prepend);
	Add_cmd("list::shift", wrap_list_shift);
	Add_cmd("list::pop", wrap_list_pop);
	Add_cmd("list::remove", wrap_list_remove);
	Add_cmd("list::length", wrap_list_length);
	Add_cmd("list::find", wrap_list_find);

	Ensemble("layer");
	Add_cmd("layer::add", wrap_layer_add);
	Add_cmd("layer::swap", wrap_layer_swap);
	Add_cmd("layer::remove", wrap_layer_remove);
	Add_cmd("layer::copy", wrap_layer_copy);
	Add_cmd("layer::sprite-list", wrap_layer_sprite_list);
	Add_cmd("layer::map", wrap_layer_map);
	Add_cmd("layer::string-list", wrap_layer_string_list);
	Add_cmd("layer::visible", wrap_layer_visible);
	Add_cmd("layer::sorted", wrap_layer_sorted);
	Add_cmd("layer::camera", wrap_layer_camera);
	Add_cmd("layer::view", wrap_layer_view);

	Ensemble("frame");
	Add_cmd("frame::info", wrap_frame_info);
	Add_cmd("frame::create", wrap_frame_create);
	Add_cmd("frame::delete", wrap_frame_delete);
	Add_cmd("frame::copy", wrap_frame_copy);
	Add_cmd("frame::offset", wrap_frame_offset);
	Add_cmd("frame::mask", wrap_frame_mask);
	Add_cmd("frame::mask-from", wrap_frame_mask_from);
	Add_cmd("frame::slice", wrap_frame_slice);
	Add_cmd("frame::convert", wrap_frame_convert);
	Add_cmd("frame::effect", wrap_frame_effect);
	Add_cmd("frame::from-disk", wrap_frame_from_disk);
	Add_cmd("frame::from-buffer", wrap_frame_from_buffer);

	Ensemble("map");
	Add_cmd("map::create", wrap_map_create);
	Add_cmd("map::empty", wrap_map_empty);
	Add_cmd("map::delete", wrap_map_delete);
	Add_cmd("map::size", wrap_map_size);
	Add_cmd("map::tile-size", wrap_map_tile_size);
	Add_cmd("map::tile", wrap_map_tile);
	Add_cmd("map::set-data", wrap_map_set_data);
	Add_cmd("map::set-single", wrap_map_set_single);
	Add_cmd("map::animate-tiles", wrap_map_animate_tiles);
	Add_cmd("map::reset-tiles", wrap_map_reset_tiles);

	Ensemble("tile");
	Add_cmd("tile::create", wrap_tile_create);
	Add_cmd("tile::delete", wrap_tile_delete);
	Add_cmd("tile::anim-type", wrap_tile_anim_type);
	Add_cmd("tile::collides", wrap_tile_collides);
	Add_cmd("tile::add-frame", wrap_tile_add_frame);
	Add_cmd("tile::add-frame-data", wrap_tile_add_frame_data);
	Add_cmd("tile::pixel-mask", wrap_tile_pixel_mask);
	Add_cmd("tile::pixel-mask-from", wrap_tile_pixel_mask_from);
	Add_cmd("tile::animate", wrap_tile_animate);
	Add_cmd("tile::reset", wrap_tile_reset);

	Ensemble("sprite");
	Add_cmd("sprite::create", wrap_sprite_create);
	Add_cmd("sprite::copy", wrap_sprite_copy);
	Add_cmd("sprite::delete", wrap_sprite_delete);
	Add_cmd("sprite::frame", wrap_sprite_frame);
	Add_cmd("sprite::z-hint", wrap_sprite_z_hint);
	Add_cmd("sprite::scale", wrap_sprite_scale);
	Add_cmd("sprite::collides", wrap_sprite_collides);
	Add_cmd("sprite::bounding-box", wrap_sprite_bounding_box);
	Add_cmd("sprite::pixel-mask", wrap_sprite_pixel_mask);
	Add_cmd("sprite::pixel-mask-from", wrap_sprite_pixel_mask_from);
	Add_cmd("sprite::position", wrap_sprite_position);
	Add_cmd("sprite::velocity", wrap_sprite_velocity);
	Add_cmd("sprite::add-frame", wrap_sprite_add_frame);
	Add_cmd("sprite::add-frame-data", wrap_sprite_add_frame_data);
	Add_cmd("sprite::add-subframe", wrap_sprite_add_subframe);
	Add_cmd("sprite::load-program", wrap_sprite_load_program);

	Ensemble("string");
	Add_cmd("string::create", wrap_string_create);
	Add_cmd("string::delete", wrap_string_delete);
	Add_cmd("string::box", wrap_string_box);
	Add_cmd("string::font", wrap_string_font);
	Add_cmd("string::position", wrap_string_position);
	Add_cmd("string::text", wrap_string_text);

	Ensemble("inspect");
	Add_cmd("inspect::adjacent-tiles", wrap_inspect_adjacent_tiles);
	Add_cmd("inspect::obscured-tiles", wrap_inspect_obscured_tiles);
	Add_cmd("inspect::line-of-sight", wrap_inspect_line_of_sight);
	Add_cmd("inspect::in-frame", wrap_inspect_in_frame);
	Add_cmd("inspect::near-point", wrap_inspect_near_point);

	Ensemble("collision");
	Add_cmd("collision::map", wrap_collision_map);
	Add_cmd("collision::sprites", wrap_collision_sprites);

	Ensemble("motion");
	Add_cmd("motion::list", wrap_motion_list);
	Add_cmd("motion::single", wrap_motion_single);

	Ensemble("clock");
	Add_cmd("clock::ms", wrap_clock_ms);
	Add_cmd("clock::wait", wrap_clock_wait);

	/* set up package-stuff */
	Tcl_ResetResult(interp);
	Tcl_PkgProvide(interp, "brick", BRICK_VERSION);
	DEBUGF;
}

/*
 * The following defines assume that interp,
 * objc, and objv are defined as expected.
 */
#define FETCH_INT(pos, var) \
	do { \
		if( Tcl_GetIntFromObj(interp, objv[pos], &var) == TCL_ERROR ) \
			return TCL_ERROR; \
	} while(0)

#define FETCH_FLOAT(pos, var) \
	do { \
		if( Tcl_GetDoubleFromObj(interp, objv[pos], &var) == TCL_ERROR ) \
			return TCL_ERROR; \
	} while(0)

#define FETCH_PTR(pos, var) \
	do { \
		char *__src; \
		void *__res; \
		__src = Tcl_GetString(objv[pos]); \
		sscanf(__src, "%p", &__res); \
		var = __res; \
	} while(0)

#define FETCH_INT_FROM(obj, pos, var) \
	do { \
		Tcl_Obj *__my_obj; \
		if( Tcl_ListObjIndex(interp, obj, pos, &__my_obj) == TCL_ERROR ) \
			return TCL_ERROR; \
		else { \
			if( Tcl_GetIntFromObj(interp, __my_obj, &var) == TCL_ERROR ) \
				return TCL_ERROR; \
		} \
	} while(0)

#define FETCH_BOOL(pos, var) \
	do { \
		if( Tcl_GetBooleanFromObj(interp, objv[pos], &var) == TCL_ERROR ) \
			return TCL_ERROR; \
	} while(0)

#define FETCH_STRING(pos, var) \
	do { \
		var = Tcl_GetString(objv[pos]); \
	} while(0)

#define FETCH_STRING_FROM(obj, pos, var, len) \
	do { \
		Tcl_Obj *__my_obj; \
		if( Tcl_ListObjIndex(interp, obj, pos, &__my_obj) == TCL_ERROR ) \
			return TCL_ERROR; \
		else \
			var = Tcl_GetStringFromObj(__my_obj, &len); \
	} while(0)

#define FETCH_DATA(pos, lengthvar, datavar) \
	do { \
		datavar = Tcl_GetByteArrayFromObj(objv[pos], &lengthvar); \
	} while(0)

#define FETCH_LEN(obj, var) \
	do { \
		if( Tcl_ListObjLength(interp, obj, &var) == TCL_ERROR ) \
			return TCL_ERROR; \
	} while(0)

#define FETCH_INDEXED(pos, table, msg, flags, var) \
	do { \
		if( Tcl_GetIndexFromObj(interp, objv[pos], table, msg, flags, &var) == TCL_ERROR ) \
			return TCL_ERROR; \
	} while(0)

#define RET_ERROR(msg) \
	do { \
		Tcl_Obj *tcl_result = Tcl_NewObj(); \
		Tcl_SetStringObj(tcl_result, msg, -1); \
		Tcl_SetObjResult(interp, tcl_result); \
		return TCL_ERROR; \
	} while(0)

#define RET_INT(var) \
	do { \
		Tcl_Obj *tcl_result = Tcl_NewObj(); \
		Tcl_SetIntObj(tcl_result, var); \
		Tcl_SetObjResult(interp, tcl_result); \
		return TCL_OK; \
	} while(0)

#define RET_STG(stg) \
	do { \
		Tcl_Obj *tcl_result = Tcl_NewObj(); \
		Tcl_SetObjResult(interp, Tcl_NewStringObj(stg, -1)); \
		return TCL_OK; \
	} while(0)

#define RET_PTR(var) \
	do { \
		char buf[PTR_LEN+1]; \
		snprintf(buf, PTR_LEN, "%p", var); \
		Tcl_Obj *tcl_result = Tcl_NewObj(); \
		Tcl_SetStringObj(tcl_result, buf, -1); \
		Tcl_SetObjResult(interp, tcl_result); \
		return TCL_OK; \
	} while(0)

#define APPEND_PTR(list, ptr) \
	do { \
		char buf[PTR_LEN+1]; \
		snprintf(buf, PTR_LEN, "%p", ptr); \
		Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(buf, -1)); \
	} while(0)

#define APPEND_STG(list, stg) \
	do { \
		Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(stg, -1)); \
	} while(0)

#define APPEND_INT(list, val) \
	do { \
		Tcl_ListObjAppendElement(interp, list, Tcl_NewIntObj(val)); \
	} while(0)

#define APPEND_FLOAT(list, val) \
	do { \
		Tcl_ListObjAppendElement(interp, list, Tcl_NewDoubleObj(val)); \
	} while(0)

#define HAS_ARGS(ac, msg) \
	do { \
		if( objc != ac ) \
			{ \
				Tcl_WrongNumArgs(interp, 1, objv, msg); \
				return TCL_ERROR; \
			} \
	} while(0)

#define HAS_ARGS_2(ac1, ac2, msg) \
	do { \
		if( (objc != ac1) && (objc != ac2) ) \
			{ \
				Tcl_WrongNumArgs(interp, 1, objv, msg); \
				return TCL_ERROR; \
			} \
	} while(0)

#define HAS_ENOUGH_ARGS(ll, msg) \
	do { \
		if( objc < ll ) \
			{ \
				Tcl_WrongNumArgs(interp, 1, objv, msg); \
				return TCL_ERROR; \
			} \
	} while(0)

#define HAS_ITEMS(obj, ac, msg) \
	do { \
		int lc; \
		if( Tcl_ListObjLength(interp, obj, &lc) == TCL_ERROR ) \
			return TCL_ERROR; \
		if( lc != ac ) \
			RET_ERROR(msg); \
	} while(0)











/* process the request to open a graphics mode .. */
static int wrap_graphics_open(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* screen dimensions, flags for full-screen, output filter, zoom factor */
	char *orient, *opt;
	int opt_len;

	int w, h, zf, rot, flags;
	int res;

	int i, list_len;



	HAS_ARGS_2(5, 6, "w h zf rot ?flags? ");
	FETCH_INT(1, w);
	FETCH_INT(2, h);
	FETCH_INT(3, zf);
	FETCH_STRING(4, orient);
	flags = 0;

	if( !strcmp(orient, "90"))
		rot = GRAPHICS_90;
	else if( !strcmp(orient, "180"))
		rot = GRAPHICS_180;
	else if( !strcmp(orient, "270"))
		rot = GRAPHICS_270;
	else
		rot = GRAPHICS_0;

	/* list of opts? */
	if( objc == 6 )
		{
			FETCH_LEN(objv[5], list_len);

			/* and retrieve the values */
			for( i=0; i < list_len; i++ )
				{
					FETCH_STRING_FROM(objv[5], i, opt, opt_len);

					/* parse out the options */
					if( !strcmp(opt, "sdl") )
						flags |= GRAPHICS_SDL;
					else if( !strcmp(opt, "accel") )
						flags |= GRAPHICS_ACCEL;
					else if( !strcmp(opt, "windowed") )
						flags |= GRAPHICS_WINDOWED;
					else if( !strcmp(opt, "fs") )
						flags |= GRAPHICS_FS;
					else
						RET_ERROR("Unknown graphics option ");
				}

		}


	/* ok!  open the graphics mode */
	res = graphics_open(w, h, zf, rot, flags);


	/* if the result was an error, pass back an error code to tcl */
	if( res < 0)
		{
			switch(res)
				{
					case ERR_CANT_REOPEN: RET_ERROR("A graphics mode is already active ");
					case ERR_BAD_MODE: RET_ERROR("No valid mode specified ");
					case ERR_SDL_FAILED: RET_ERROR("Could not initialize SDL video subsystem ");
					case ERR_SDL_VIDEO_FAILED: RET_ERROR("Could not open the video display ");
				}

		}

	/* otherwise, we have had success! */
	return TCL_OK;

}

/* they are requesting to open a graphics mode .. */
static int wrap_graphics_close(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	graphics_close();
	return TCL_OK;
}

/* a request to set the window title */
static int wrap_graphics_window_title(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	char *title;
	HAS_ARGS(2, "title ");
	FETCH_STRING(1, title);
	SDL_WM_SetCaption(title,NULL);
	return TCL_OK;
}



/* they requested audio-mode info, so return the list: { none speaker .. } */
static int wrap_audio_modes(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	Tcl_Obj *info;
	HAS_ARGS(1, NULL);

	/* stick the audio modes here - it's all we'll need to know about */
	info = Tcl_NewObj();
	APPEND_STG(info, "speaker");
	Tcl_SetObjResult(interp, info);
	return TCL_OK;

}

/* they requested to open the audio .. */
static int wrap_audio_open(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the requested mode, and the result */
	char *mode;
	int res;

	HAS_ARGS(2, "mode ");
	FETCH_STRING(1, mode);

	if( !strcmp(mode, "speaker") )
		res = audio_open(AUDIO_SPEAKER);
	else
		res = ERR_BAD_MODE;

	/* if the result was an error, pass back an error code to tcl */
	if( res < 0 )
		{
			switch(res)
				{
					case ERR_CANT_REOPEN: RET_ERROR("Audio already open ");
					case ERR_BAD_MODE: RET_ERROR("Unknown audio mode requested ");
					case ERR_SDL_FAILED: RET_ERROR("SDL could not open audio device ");
					case ERR_SDL_MIXER_FAILED: RET_ERROR("SDL_Mixer could not start ");
				}

		}

	/* otherwise, we're ok! */
	return TCL_OK;

}

/* closing the audio .. */
static int wrap_audio_close(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	audio_close();
	return TCL_OK;
}



/* fetch the current io status and return the big list */
static int wrap_io_fetch(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/*
	 * the list returned to tcl:
	 *	{ { axes } { hats } { buttons } space tab sel pause esc }
	 *       0        1         2         3    4   5    6    7
	 */
	int num;

	/* the result vars */
	int i;
	input io;
	Tcl_Obj *io_result;
	Tcl_Obj *axes, *hats, *buttons;

	/* fetch the input to read */
	HAS_ARGS(2, "input-num ");
	FETCH_INT(1, num);


	/* here, note that we offset the input by one from the tcl-side */
	if( !io_fetch(num, &io) )
		{
			/* make the results */
			axes = Tcl_NewObj();
			for(i=0; i < MAX_AXES; i++)
				APPEND_INT(axes, io.axis[i]);

			hats = Tcl_NewObj();
			for(i=0; i < MAX_HATS; i++)
				{
					APPEND_INT(hats, io.hat[i].x);
					APPEND_INT(hats, io.hat[i].y);
				}

			buttons = Tcl_NewObj();
			for(i=0; i < MAX_BUTTONS; i++)
				APPEND_INT(buttons, io.button[i]);

			io_result = Tcl_NewObj();
			Tcl_ListObjAppendElement(interp, io_result, axes);
			Tcl_ListObjAppendElement(interp, io_result, hats);
			Tcl_ListObjAppendElement(interp, io_result, buttons);
			APPEND_INT(io_result, io.space);
			APPEND_INT(io_result, io.tab);
			APPEND_INT(io_result, io.sel);
			APPEND_INT(io_result, io.pause);
			APPEND_INT(io_result, io.esc);
			Tcl_SetObjResult(interp, io_result);
			return TCL_OK;

		}
	else
		RET_ERROR("Not valid input ");

}

/* fetch the mouse input */
static int wrap_io_mouse(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/*
	 * the list returned to tcl:
	 *	{ x y { buttons .. } }
	 *		0 1		2
	 */
	int num;

	/* the result vars */
	int i;
	mouse m;
	Tcl_Obj *mouse_res;
	Tcl_Obj *buttons;


	/* fetch the input to read */
	HAS_ARGS(2, "mouse-num ");
	FETCH_INT(1, num);

	/* here, note that we offset the input by one from the tcl-side */
	if( !io_mouse(num, &m))
		{
			buttons = Tcl_NewObj();
			for(i=0; i < MAX_MOUSE_BUTTONS; i++)
				APPEND_INT(buttons, m.button[i]);

			mouse_res = Tcl_NewObj();
			APPEND_INT(mouse_res, m.x);
			APPEND_INT(mouse_res, m.y);
			Tcl_ListObjAppendElement(interp, mouse_res, buttons);
			Tcl_SetObjResult(interp, mouse_res);
			return TCL_OK;

		}
	else
		RET_ERROR("Not valid mouse ");

}

/* return the status of the application-quit button */
static int wrap_io_has_quit(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_INT(io_has_quit());
}

/* enable or disable the input-grab */
static int wrap_io_grab(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int mode;
	HAS_ARGS(2, "mode ");
	FETCH_BOOL(1, mode);
	io_grab(mode);
	return TCL_OK;
}

/* wait for the input buffer to be cleared, and then set */
static int wrap_io_wait(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int delay;
	HAS_ARGS(2, "delay ");
	FETCH_INT(1, delay);
	io_wait(delay);
	return TCL_OK;
}

/* assign a keypress to an input action */
static int wrap_io_assign(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/*
	 * the various user-provided options:
	 * - input number
	 * - type of input (axis, hat, button)
	 * - which one of that input type
	 * - if axis or hat, the direction to reassign
	 * - the new key to reassign
	 */
	int num,type,idx,dir,key;

	/* the options for input and direction */
	const char *types[] = { "axis", "hat", "button", (char *) NULL };
	const char *axis_dirs[] = { "left", "right", (char *) NULL };
	const char *hat_dirs[] = { "up", "right", "down", "left", (char *) NULL };

	HAS_ENOUGH_ARGS(5, "input-number ?options ..? ");
	FETCH_INT(1, num);
	FETCH_INDEXED(2, types, "input-type", TCL_EXACT, type);

	/* fetch the args appropriate to the type */
	if( type == IO_AXIS )
		{
			HAS_ARGS(6, "input-number input-type index direction key-id ");
			FETCH_INT(3, idx);
			FETCH_INDEXED(4, axis_dirs, "direction", TCL_EXACT, dir);
			FETCH_INT(5, key);

			/* map the direction from the string-array onto the C constants */
			switch(dir)
				{
					case 0: dir = IO_LEFT; break;
					case 1: dir = IO_RIGHT; break;
				}
			io_assign(num, type, idx, dir, key);

		}
	else if( type == IO_HAT )
		{
			/* retrieve the hat-index, the direction to adjust, and the key to map */
			HAS_ARGS(6, "input-number input-type index direction key-id ");
			FETCH_INT(3, idx);
			FETCH_INDEXED(4, hat_dirs, "direction", TCL_EXACT, dir);
			FETCH_INT(5, key);

			/* map the direction from the string-array onto the C constants */
			switch(dir)
				{
					case 0: dir = IO_UP; break;
					case 1: dir = IO_RIGHT; break;
					case 2: dir = IO_DOWN; break;
					case 3: dir = IO_LEFT; break;
				}
			io_assign(num, type, idx, dir, key);

		}
	else if( type == IO_BUTTON )
		{
			/* retrieve the button-index and the key to map */
			HAS_ARGS(5, "input-number input-type index key-id ");
			FETCH_INT(3, idx);
			FETCH_INT(4, key);
			io_assign(num, type, idx, key);
		}

	return TCL_OK;

}

/* read one key and return the keycode, for use with ::io::assign */
static int wrap_io_read_key(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_INT(io_read_key());
}



/* request to adjust the background-fill mode */
static int wrap_render_bg_fill(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int mode;
	HAS_ARGS(2, "mode ");
	FETCH_BOOL(1, mode);
	render_set_bg_fill(mode);
	return TCL_OK;
}

/* request to set the background fill color */
static int wrap_render_bg_color(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int r,g,b;
	HAS_ARGS(4, "r g b ");
	FETCH_INT(1, r);
	FETCH_INT(2, g);
	FETCH_INT(3, b);
	render_set_bg_color((char)r, (char)g, (char)b);
	return TCL_OK;
}

/* a request to adjust the size of the internal render canvas */
static int wrap_render_set_overdraw(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int w,h;
	HAS_ARGS(3, "w h ");
	FETCH_INT(1, w);
	FETCH_INT(2, h);
	render_set_overdraw(w, h);
	return TCL_OK;
}

/* render! */
static int wrap_render_display(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	render_display();
	return TCL_OK;
}

/* render to disk */
static int wrap_render_to_disk(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the filename */
	char *file;

	/* and the result */
	int res;

	HAS_ARGS(2, "filename ");
	FETCH_STRING(1, file);

	/* attempt to write the frame to disk */
	res = render_to_disk(file);

	/* check for errors */
	if( res < 0 )
		{
			switch(res)
				{
					case ERR_BAD_FILE: RET_ERROR("Could not write to file ");
				}
		}

	return TCL_OK;
}



/* add a new font */
static int wrap_font_add(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	char *name;
	int w, h, len;           /* char width, height, and count of bytes in the bytearray */
	unsigned char *data;     /* the bytearray */

	/* for an optional character-width list */
	int i, list_len, widths[FONT_CT];

	HAS_ARGS_2(5, 6, "font-name w h rgb-data ?{ list-of-character-widths }? ");
	FETCH_STRING(1, name);
	FETCH_INT(2, w);
	FETCH_INT(3, h);
	FETCH_DATA(4, len, data);

	/* verify length of given map data */
	if( len != w * h * FONT_CT * RGB_BYTES )
		RET_ERROR("Amount of font data doesn't match font character dimensions ");

	/* retrieve the character-width list if it is present */
	if( objc == 6 )
		{
			FETCH_LEN(objv[5], list_len);

			if( list_len != FONT_CT )
				RET_ERROR("Incorrect amount of character widths provided ");

			/* and retrieve the values */
			for( i=0; i < list_len; i++ )
				FETCH_INT_FROM(objv[5], i, widths[i]);

			font_add(name, w, h, data, widths);
		}
	else
		font_add(name, w, h, data, NULL);

	return TCL_OK;

}

/* we have been requested to load a font from a file */
static int wrap_font_from_disk(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* source filename */
	char *name, *file;

	/* for an optional character-width list */
	int i, list_len, widths[FONT_CT];

	HAS_ARGS_2(3, 6, "font-name file ?r g b? ");
	FETCH_STRING(1, name);
	FETCH_STRING(2, file);

	/* retrieve the character-width list if it is present */
	if( objc == 6 )
		{
			FETCH_LEN(objv[5], list_len);

			if( list_len != FONT_CT )
				RET_ERROR("Incorrect amount of character widths provided ");

			/* and retrieve the values */
			for( i=0; i < list_len; i++ )
				FETCH_INT_FROM(objv[5], i, widths[i]);

			font_from_disk(name, file, widths);
		}
	else
		font_from_disk(name, file, NULL);

	return TCL_OK;
}

/* we have been requested to load a font from a memory buffer */
static int wrap_font_from_buffer(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* source buffer */
	char *name;

	int len;
	unsigned char *data;

	/* for an optional character-width list */
	int i, list_len, widths[FONT_CT];

	HAS_ARGS_2(3, 6, "font-name data ?r g b? ");
	FETCH_STRING(1, name);
	FETCH_DATA(2, len, data);

	/* retrieve the character-width list if it is present */
	if( objc == 6 )
		{
			FETCH_LEN(objv[5], list_len);

			if( list_len != FONT_CT )
				RET_ERROR("Incorrect amount of character widths provided ");

			/* and retrieve the values */
			for( i=0; i < list_len; i++ )
				FETCH_INT_FROM(objv[5], i, widths[i]);

			font_from_buffer(name, len, data, widths);
		}
	else
		font_from_buffer(name, len, data, NULL);

	return TCL_OK;
}



/* we have been requested to load a sound from a file */
static int wrap_sound_load_file(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	char *file;
	HAS_ARGS(2, "filename ");
	FETCH_STRING(1, file);
	RET_PTR(sound_load_from_disk(file));
}

/* we have been requested to load a sound from a memory buffer */
static int wrap_sound_load_buffer(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	unsigned char *data;
	int len;
	HAS_ARGS(2, "data ");
	FETCH_DATA(1, len, data);
	RET_PTR(sound_load_from_buffer(len, data));
}

/*
 * we have been requested to load raw sound data.  note that
 * the sound must consist of unsigned 8-bit samples!
 */
static int wrap_sound_load_raw(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* buffer data */
	unsigned char *data;
	int len;
	HAS_ARGS(2, "data ");
	FETCH_DATA(1, len, data);
	RET_PTR(sound_load_raw(len, data));
}

/* play the named sound */
static int wrap_sound_play(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sound *sound;   /* ptr to name of sound */
	int vol;       /* volume to use */
	int ch;        /* the channel to return */

	HAS_ARGS_2(2, 3, "sound-id ?volume? ");
	FETCH_PTR(1, sound);
	if( objc == 3 )
		FETCH_INT(2, vol);
	else
		vol = MIX_MAX_VOLUME;

	ch = sound_play(sound, vol);
	RET_INT(ch);

}

/* halt the requested audio channel */
static int wrap_sound_halt(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int chan;
	HAS_ARGS(2, "channel-id ");
	FETCH_INT(1, chan);
	sound_halt(chan);
	return TCL_OK;
}

/* adjust the volume on the requested audio channel */
static int wrap_sound_adj_vol(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int chan, vol;
	HAS_ARGS(3, "channel-id vol ");
	FETCH_INT(1, chan);
	FETCH_INT(2, vol);
	sound_adjust_vol(chan, vol);
	return TCL_OK;
}

/* adjust the panning on the requested audio channel */
static int wrap_sound_adj_pan(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int chan, panning;
	HAS_ARGS(3, "channel-id panning ");
	FETCH_INT(1, chan);
	FETCH_INT(2, panning);
	sound_adjust_pan(chan, panning);
	return TCL_OK;
}



/* play a song from a named file */
static int wrap_song_play_file(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	char *file;
	int delay;

	HAS_ARGS_2(2, 3, "filename ?fade-in-delay? ");
	FETCH_STRING(1, file);

	/* fetch the optional delay argument */
	if( objc == 3 )
		FETCH_INT(2, delay);
	else
		delay = 0;

	song_play_from_disk(file, delay);
	return TCL_OK;
}

/* play a song from a buffer */
static int wrap_song_play_buffer(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* buffer containing song data */
	int len;
	unsigned char *data;

	int delay;

	HAS_ARGS_2(2, 3, "buffer ?fade-in-delay? ");
	FETCH_DATA(1, len, data);

	/* fetch the optional delay argument */
	if( objc == 3 )
		FETCH_INT(2, delay);
	else
		delay = 0;

	song_play_from_buffer(len, data, delay);
	return TCL_OK;

}

/* pause the song */
static int wrap_song_pause(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	song_pause();
	return TCL_OK;
}

/* resume the song */
static int wrap_song_resume(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	song_resume();
	return TCL_OK;
}

/* stop the song, with optional fade-out delay */
static int wrap_song_halt(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int delay;

	HAS_ARGS_2(1, 2, "?fade-out-delay? ");
	if( objc == 2 )
		FETCH_INT(1, delay);
	else
		delay = 0;

	song_stop(delay);
	return TCL_OK;
}

/* set the position of the currently-playing song */
static int wrap_song_set_position(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int pos;
	HAS_ARGS(2, "position ");
	FETCH_INT(1, pos);
	song_set_position(pos);
	return TCL_OK;
}

/* adjust volume of currently-playing song */
static int wrap_song_adj_vol(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int vol;
	HAS_ARGS(2, "vol ");
	FETCH_INT(1, vol);
	song_adjust_vol(vol);
	return TCL_OK;
}



/* creating a new list .. */
static int wrap_list_create(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_PTR(list_create());
}

/* emptying a list. */
static int wrap_list_empty(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	HAS_ARGS(2, "list-id ");
	FETCH_PTR(1, l);
	list_empty(l);
	return TCL_OK;
}

/* deleting a list. */
static int wrap_list_delete(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	HAS_ARGS(2, "list-id ");
	FETCH_PTR(1, l);
	list_delete(l);
	return TCL_OK;
}

/* adding to a list. */
static int wrap_list_add(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	void *item;
	HAS_ARGS(3, "list-id item-id ");
	FETCH_PTR(1, l);
	FETCH_PTR(2, item);
	list_add(l, item);
	return TCL_OK;
}

/* prepending to a list. */
static int wrap_list_prepend(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	void *item;
	HAS_ARGS(3, "list-id item-id ");
	FETCH_PTR(1, l);
	FETCH_PTR(2, item);
	list_prepend(l, item);
	return TCL_OK;
}

/* shift from a list. */
static int wrap_list_shift(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	HAS_ARGS(2, "list-id ");
	FETCH_PTR(1, l);
	RET_PTR(list_shift(l));
}

/* pop from a list. */
static int wrap_list_pop(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	HAS_ARGS(2, "list-id ");
	FETCH_PTR(1, l);
	RET_PTR(list_pop(l));
}

/* remove from a list. */
static int wrap_list_remove(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the list and item pointer */
	list *l;
	void *item;

	/* the direction */
	char *dir_stg;
	int dir;

	HAS_ARGS_2(3, 4, "list-id item-id ?direction? ");
	FETCH_PTR(1, l);
	FETCH_PTR(2, item);

	/* if the optional direction argument is given, parse it out */
	if( objc == 4 )
		{
			FETCH_STRING(3, dir_stg);
			if( !strcmp(dir_stg, "head") )
				dir = LIST_HEAD;
			else if( !strcmp(dir_stg, "tail") )
				dir = LIST_TAIL;
			else if( !strcmp(dir_stg, "all") )
				dir = LIST_ALL;
			else
				RET_ERROR("Unknown direction ");
		}
	else
		dir = LIST_ALL;

	/* remove the item and done */
	list_remove(l, item, dir);
	return TCL_OK;
}

/* get the length of a list. */
static int wrap_list_length(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	HAS_ARGS(2, "list-id ");
	FETCH_PTR(1, l);
	RET_INT(list_length(l));
}

/* is an item in a list? */
static int wrap_list_find(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	list *l;
	void *item;
	HAS_ARGS(3, "list-id item-id ");
	FETCH_PTR(1, l);
	FETCH_PTR(2, item);
	RET_INT(list_find(l, item));
}



/* adding a new layer .. */
static int wrap_layer_add(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_INT(layer_add());
}

/* swapping two layers */
static int wrap_layer_swap(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int old, new;
	HAS_ARGS(3, "old-id new-id ");
	FETCH_INT(1, old);
	FETCH_INT(2, new);
	layer_reorder(old, new);
	return TCL_OK;
}

/* removing a layer */
static int wrap_layer_remove(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id;
	HAS_ARGS(2, "layer-id ");
	FETCH_INT(1, id);
	layer_remove(id);
	return TCL_OK;
}

/* making a copy of a layer */
static int wrap_layer_copy(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id, new;

	HAS_ARGS(2, "layer-id ");
	FETCH_INT(1, id);

	/* make the copy and catch potential errors */
	new = layer_copy(id);
	if( new == ERR )
		RET_ERROR("Not a valid layer ");

	RET_INT(new);
}

/* set the layer's sprite list */
static int wrap_layer_sprite_list(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id;
	list *l;

	HAS_ARGS_2(2, 3, "layer-id ?sprite-list-id? ");
	FETCH_INT(1, id);

	/* reading or setting the sprite list? */
	if( objc == 2 )
		{
			l = layer_get_sprite_list(id);
			RET_PTR(l);
		}
	else
		{
			FETCH_PTR(2, l);
			layer_set_sprite_list(id, l);
			return TCL_OK;
		}

}

/* set the layer's map */
static int wrap_layer_map(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id;
	map *map;

	HAS_ARGS_2(2, 3, "layer-id ?map-id? ");
	FETCH_INT(1, id);

	/* reading or setting the map? */
	if( objc == 2 )
		{
			map = layer_get_map(id);
			RET_PTR(map);
		}
	else
		{
			FETCH_PTR(2, map);
			layer_set_map(id, map);
			return TCL_OK;
		}

}

/* set the layer's string list */
static int wrap_layer_string_list(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id;
	list *l;

	HAS_ARGS_2(2, 3, "layer-id ?string-list-id? ");
	FETCH_INT(1, id);

	/* reading or setting the string list? */
	if( objc == 2 )
		{
			l = layer_get_string_list(id);
			RET_PTR(l);
		}
	else
		{
			FETCH_PTR(2, l);
			layer_set_string_list(id, l);
			return TCL_OK;
		}

}

/* set the layer visibility */
static int wrap_layer_visible(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id, vis;

	HAS_ARGS_2(2, 3, "layer-id ?visible? ");
	FETCH_INT(1, id);

	/* reading or setting the visibility? */
	if( objc == 2 )
		{
			vis = layer_get_visible(id);
			if( vis == ERR )
				RET_ERROR("Invalid layer ");
			else
				RET_INT(vis);
		}
	else
		{
			FETCH_BOOL(2, vis);
			layer_set_visible(id, vis);
			return TCL_OK;
		}

}

/* set the layer sorting */
static int wrap_layer_sorted(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id, sorted;

	HAS_ARGS_2(2, 3, "layer-id ?sorted? ");
	FETCH_INT(1, id);

	/* reading or setting the sorting? */
	if( objc == 2 )
		{
			sorted = layer_get_sorting(id);
			if( sorted == ERR )
				RET_ERROR("Invalid layer ");
			else
				RET_INT(sorted);
		}
	else
		{
			FETCH_BOOL(2, sorted);
			layer_set_sorting(id, sorted);
			return TCL_OK;
		}

}

/* set the camera */
static int wrap_layer_camera(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id, x, y;
	Tcl_Obj *res;

	HAS_ARGS_2(2, 4, "layer-id ?x y? ");
	FETCH_INT(1, id);

	if( objc == 2 )
		{
			/* read the camera .. */
			if( layer_get_camera(id, &x, &y) == ERR )
				RET_ERROR("Invalid layer ");
			else
				{
					/* and return the result */
					res = Tcl_NewObj();
					APPEND_INT(res, x);
					APPEND_INT(res, y);
					Tcl_SetObjResult(interp, res);
				}

		}
	else
		{
			/* or set the camera. */
			FETCH_INT(2, x);
			FETCH_INT(3, y);
			layer_set_camera(id, x, y);
		}

	return TCL_OK;

}

/* set the layer viewport */
static int wrap_layer_view(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int id;
	box view;
	Tcl_Obj *res;

	HAS_ARGS_2(2, 6, "layer-id ?x1 y1 x2 y2? ");
	FETCH_INT(1, id);


	if( objc == 2 )
		{
			/* read the view .. */
			if( layer_get_view(id, &view) == ERR )
				RET_ERROR("Invalid layer ");
			else
				{
					/* and return the result */
					res = Tcl_NewObj();
					APPEND_INT(res, view.x1);
					APPEND_INT(res, view.y1);
					APPEND_INT(res, view.x2);
					APPEND_INT(res, view.y2);
					Tcl_SetObjResult(interp, res);
				}

		}
	else
		{
			/* or set the view! */
			FETCH_INT(2, view.x1);
			FETCH_INT(3, view.y1);
			FETCH_INT(4, view.x2);
			FETCH_INT(5, view.y2);
			layer_set_view(id, &view);
		}

	return TCL_OK;

}



/* retrieve frame info .. */
static int wrap_frame_info(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	frame *frame;

	/* a lookup table, to give us the actual named mode .. */
	const char *modes[] = { "none", "rgba", "rgb", "hl", "sl", "br", "ct", "sat", "displ", "convo", "lut", "xor" };

	/* .. and the results! */
	int mode, w, h;
	Tcl_Obj *res;


	HAS_ARGS(2, "frame-id ");
	FETCH_PTR(1, frame);

	/* get the frame info */
	if( frame_info(frame, &w, &h, &mode) == ERR )
		RET_ERROR("Invalid frame id ");
	else
		{
			/* and prepare the result list */
			res = Tcl_NewObj();
			APPEND_INT(res, w);
			APPEND_INT(res, h);
			APPEND_STG(res, modes[mode]);

			/* and return the result */
			Tcl_SetObjResult(interp, res);
			return TCL_OK;
		}

}

/* create a frame */
static int wrap_frame_create(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int i;

	/* data to retrieve from tcl and load */
	char *mode;
	int w,h;
	unsigned char *data; /* tcl bytearray */
	int len;             /* bytes in tcl bytearray */

	/* also cumbersome - variables to read and parse convolution kernel or lookup table */
	convolution ck;
	lut l;

	Tcl_Obj *list;
	int list_len, list_val;

	/* frame pointer */
	frame *frame;


	/* check for some args */
	HAS_ENOUGH_ARGS(4, "type w h ?options ..? ");
	FETCH_STRING(1, mode);
	FETCH_INT(2, w);
	FETCH_INT(3, h);

	/* and parse out based on mode */
	if( !strcmp(mode, "none") )
		{
			/* the empty sprite type */
			HAS_ARGS(4, "type w h ");
			frame = frame_create(FRAME_NONE, w, h, NULL, NULL);
		}
	else
		{
			/* one of the non-null sprite types */
			HAS_ENOUGH_ARGS(5, "type w h frame-data ?options ..? ");
			FETCH_DATA(4, len, data);

			if( !strcmp(mode, "rgba") )
			  {
					HAS_ARGS(5,"type w h frame-data ");
				  frame = frame_create(FRAME_RGBA, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "rgb") )
			  {
					HAS_ARGS(5, "type w h frame-data ");
					frame = frame_create(FRAME_RGB, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "hl") )
			  {
					HAS_ARGS(5, "type w h frame-data ");
					frame = frame_create(FRAME_HL, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "sl") )
			  {
					HAS_ARGS(5, "type w h frame-data ");
					frame = frame_create(FRAME_SL, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "br") )
			  {
					HAS_ARGS(5, "type w h frame-data ");
					frame = frame_create(FRAME_BR, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "ct") )
			  {
					HAS_ARGS(5, "type w h frame-data ");
					frame = frame_create(FRAME_CT, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "sat") )
			  {
					HAS_ARGS(5, "type w h frame-data ");
					frame = frame_create(FRAME_SAT, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "displ") )
			  {
					HAS_ARGS(5, "type w h displacement-data ");
					frame = frame_create(FRAME_DISPL, w, h, (short *)data, NULL);
			  }
			else if( !strcmp(mode, "convo") )
			  {
					/*
					 * retrieve the convolution-kernel data from the list thus:
					 * { w h { k1 k2 k3 .. kn } divisor offset }
					 */
					HAS_ARGS(6, "type w h frame-data kernel ");
					HAS_ITEMS(objv[5], 5, "Convolution kernel list must contain five elements ");

					/* first fetch the kernel width and height */
					FETCH_INT_FROM(objv[5], 0, ck.kw);
					FETCH_INT_FROM(objv[5], 1, ck.kh);
					FETCH_INT_FROM(objv[5], 3, ck.divisor);
					FETCH_INT_FROM(objv[5], 4, ck.offset);

					if( ck.kw > MAX_CK_SIZE || ck.kh > MAX_CK_SIZE )
						RET_ERROR( "Convolution kernel too large ");

					/* next, the kernel sublist itself */
					Tcl_ListObjIndex(interp, objv[5], 2, &list);
					FETCH_LEN(list, list_len);

					if( list_len != ck.kw * ck.kh )
					  RET_ERROR("Incorrect amount of kernel data provided ");

					/* and retrieve the values */
					for( i=0; i < list_len; i++ )
					  {
							FETCH_INT_FROM(list, i, list_val);
						  ck.kernel[i] = (char)list_val;
					  }

					/* at last, add the convolution kernel */
					frame = frame_create(FRAME_CONVO, w, h, data, &ck);

			  }
			else if( !strcmp(mode, "lut") )
			  {
					/* retrieve the lookup table data from the list */
					HAS_ARGS(6, "type w h frame-data lut-data ");
					HAS_ITEMS(objv[5], RGB_RANGE * 3, "Lookup table list must contain 768 elements ");

					/* retrieve the lut sublist */
					Tcl_ListObjIndex(interp, objv[5], 0, &list);
					for(i=0; i < 256; i++)
						{
							/* fetch red, green, blue */
							FETCH_INT_FROM(list, i*3, list_val);
							l.r[i] = (unsigned char)list_val;

							FETCH_INT_FROM(list, i+256, list_val);
							l.g[i] = (unsigned char)list_val;

							FETCH_INT_FROM(list, i+512, list_val);
							l.b[i] = (unsigned char)list_val;
						}

					/* at last, add the convolution kernel */
					frame = frame_create(FRAME_LUT, w, h, data, &l);
			  }
			else if( !strcmp(mode, "xor") )
			  {
					HAS_ARGS(5, "type w h frame-data ");
					frame = frame_create(FRAME_XOR, w, h, data, NULL);
			  }
			else
			  RET_ERROR("Unknown frame type ");
		}


	/* and finished */
	if( !frame )
		RET_ERROR("Invalid frame ");
	else
		RET_PTR(frame);

}

/* deleting a frame .. */
static int wrap_frame_delete(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	frame *frame;
	HAS_ARGS(2, "frame-id ");
	FETCH_PTR(1, frame);
	frame_delete(frame);
	return TCL_OK;
}

/* copying a frame .. */
static int wrap_frame_copy(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	frame *frame;
	HAS_ARGS(2, "frame-id ");
	FETCH_PTR(1, frame);
	RET_PTR(frame_copy(frame));
}

/* set frame offset .. */
static int wrap_frame_offset(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	frame *frame;
	int x, y;
	HAS_ARGS(4, "frame-id x y ");
	FETCH_PTR(1, frame);
	FETCH_INT(2, x);
	FETCH_INT(3, y);
	frame_set_offset(frame, x, y);
	return TCL_OK;
}

/* set the pixel mask */
static int wrap_frame_mask(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the frame in question .. */
	frame *frame;

	/* pixel data buffer */
	unsigned char *data;
	int len;

	HAS_ARGS(3, "frame-id data ");
	FETCH_PTR(1, frame);
	FETCH_DATA(2, len, data);
	if( len != frame->w * frame->h )
		RET_ERROR("Amount of pixel mask data doesn't match frame size ");

	frame_set_mask(frame, data);
	return TCL_OK;
}

/* set the pixel mask from a source frame */
static int wrap_frame_mask_from(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	frame *frame, *src;
	HAS_ARGS(3, "frame-id source-id ");
	FETCH_PTR(1, frame);
	FETCH_PTR(2, src);
	frame_set_mask_from(frame, src);
	return TCL_OK;
}

/* slice up a frame */
static int wrap_frame_slice(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	frame *frame, *res;
	int x, y, w, h;

	HAS_ARGS(6, "frame-id x y w h ");
	FETCH_PTR(1, frame);
	FETCH_INT(2, x);
	FETCH_INT(3, y);
	FETCH_INT(4, w);
	FETCH_INT(5, h);

	res = frame_slice(frame, x, y, w, h);
	if( !res )
		RET_ERROR("Invalid frame ");
	else
		RET_PTR(res);

}

/* convert a frame */
static int wrap_frame_convert(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the source frame and requested mode */
	frame *frame, *res;
	char *mode;

	/* variables to read and parse convolution kernel or lookup table */
	convolution ck;
	lut l;

	Tcl_Obj *list;
	int i, list_len, list_val;

	HAS_ARGS_2(3, 4, "frame-id mode ?auxiliary? ");
	FETCH_PTR(1, frame);
	FETCH_STRING(2, mode);

	if( !strcmp(mode, "rgba") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_RGBA, NULL);
		}
	else if( !strcmp(mode, "rgb") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_RGB, NULL);
		}
	else if( !strcmp(mode, "hl") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_HL, NULL);
		}
	else if( !strcmp(mode, "sl") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_SL, NULL);
		}
	else if( !strcmp(mode, "br") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_BR, NULL);
		}
	else if( !strcmp(mode, "ct") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_CT, NULL);
		}
	else if( !strcmp(mode, "sat") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_SAT, NULL);
		}
	else if( !strcmp(mode, "convo") )
		{
			/*
			 * retrieve the convolution-kernel data from the list thus:
			 * { w h { k1 k2 k3 .. kn } divisor offset }
			 */
			HAS_ARGS(4, "frame-id mode kernel ");
			HAS_ITEMS(objv[3], 5, "Convolution kernel list must contain five elements ");

			/* first fetch the kernel width and height */
			FETCH_INT_FROM(objv[3], 0, ck.kw);
			FETCH_INT_FROM(objv[3], 1, ck.kh);
			FETCH_INT_FROM(objv[3], 3, ck.divisor);
			FETCH_INT_FROM(objv[3], 4, ck.offset);

			if( ck.kw > MAX_CK_SIZE || ck.kh > MAX_CK_SIZE )
				RET_ERROR( "Convolution kernel too large ");

			/* next, the kernel sublist itself */
			Tcl_ListObjIndex(interp, objv[3], 2, &list);
			FETCH_LEN(list, list_len);

			if( list_len != ck.kw * ck.kh )
				RET_ERROR("Incorrect amount of kernel data provided ");

			/* and retrieve the values */
			for( i=0; i < list_len; i++ )
				{
					FETCH_INT_FROM(list, i, list_val);
					ck.kernel[i] = (char)list_val;
				}

			/* at last, add the convolution kernel */
			res = frame_convert(frame, FRAME_CONVO, &ck);

		}
	else if( !strcmp(mode, "lut") )
		{
			/* retrieve the lookup table data from the list */
			HAS_ARGS(4, "frame-id mode lut-data ");
			HAS_ITEMS(objv[3], RGB_RANGE * 3, "Lookup table list must contain 768 elements ");

			/* retrieve the lut sublist */
			Tcl_ListObjIndex(interp, objv[3], 0, &list);
			for(i=0; i < 256; i++)
				{
					/* fetch red, green, blue */
					FETCH_INT_FROM(list, i*3, list_val);
					l.r[i] = (unsigned char)list_val;

					FETCH_INT_FROM(list, i+256, list_val);
					l.g[i] = (unsigned char)list_val;

					FETCH_INT_FROM(list, i+512, list_val);
					l.b[i] = (unsigned char)list_val;
				}

			/* at last, add the convolution kernel */
			res = frame_convert(frame, FRAME_LUT, &l);
		}
	else if( !strcmp(mode, "xor") )
		{
			HAS_ARGS(3, "frame-id mode ");
			res = frame_convert(frame, FRAME_XOR, NULL);
		}
	else
		RET_ERROR("Unknown frame type ");

	/* error checking .. */
	if( !res )
		RET_ERROR("Invalid frame or requested new type ");
	else
		RET_PTR(frame);

}

/* create an effect frame .. */
static int wrap_frame_effect(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the source frame and requested mode */
	frame *frame;
	char *mode;

	/* options for drop shadow */
	int x, y, blur;
	int r, g, b;
	color c;

	HAS_ENOUGH_ARGS(3, "frame-id mode ?options? ");
	FETCH_PTR(1, frame);
	FETCH_STRING(2, mode);

	if( !strcmp(mode, "dropshadow") )
		{
			HAS_ARGS(9, "frame-id mode x y blur r g b ");

			/* fetch the position and blur options */
			FETCH_INT(3, x);
			FETCH_INT(4, y);
			FETCH_INT(5, blur);

			/* and the drop shadow color */
			FETCH_INT(6, r); c.r = (unsigned char)r;
			FETCH_INT(7, g); c.g = (unsigned char)g;
			FETCH_INT(8, b); c.b = (unsigned char)b;

			/* and create the drop shadow */
			RET_PTR(frame_effect(frame, FRAME_EFFECT_DROP_SHADOW, x, y, blur, &c));

		}
	else
		RET_ERROR("Unknown frame effect ");


}

/* we have been requested to load a frame from a file */
static int wrap_frame_from_disk(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* source filename */
	char *file;

	/* result */
	frame *res;

	HAS_ARGS(2, "filename ");
	FETCH_STRING(1, file);

	res = frame_from_disk(file);

	/* check return code */
	if( !res )
		RET_ERROR("Bad file ");
	else
		RET_PTR(res);

}

/* we have been requested to load a frame from a memory buffer */
static int wrap_frame_from_buffer(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* source buffer */
	int len;
	unsigned char *data;

	/* result */
	frame *res;

	HAS_ARGS(2, "data ");
	FETCH_DATA(1, len, data);

	res = frame_from_buffer(len, data);

	/* check return code */
	if( !res )
		RET_ERROR("Bad file ");
	else
		RET_PTR(res);

}



/* creating a new map .. */
static int wrap_map_create(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_PTR(map_create());
}

/* emptying a map .. */
static int wrap_map_empty(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	map *map;
	int delete_tiles;

	HAS_ARGS_2(2, 3, "map-id ?delete-tiles?");
	FETCH_PTR(1, map);

	if( objc == 2 )
		delete_tiles = 0;
	else
		FETCH_BOOL(2, delete_tiles);

	map_empty(map, delete_tiles);
	return TCL_OK;
}

/* deleting a map .. */
static int wrap_map_delete(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	map *map;
	HAS_ARGS(2, "map-id ");
	FETCH_PTR(1, map);
	map_delete(map);
	return TCL_OK;
}

/* set the map dimensions */
static int wrap_map_size(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	map *map;
	int w,h;
	Tcl_Obj *res;

	HAS_ARGS_2(2, 4, "map-id ?width height? ");
	FETCH_PTR(1, map);

	if( objc == 2 )
		{
			/* read the map size .. */
			if( map_get_size(map, &w, &h) == ERR )
				RET_ERROR("Invalid map id ");
			else
				{
					/* and return the result */
					res = Tcl_NewObj();
					APPEND_INT(res, w);
					APPEND_INT(res, h);
					Tcl_SetObjResult(interp, res);
				}

		}
	else
		{
			/* set the map dimensions */
			FETCH_INT(2, w);
			FETCH_INT(3, h);
			map_set_size(map, w, h);
		}

	return TCL_OK;
}

/* set the map tile size */
static int wrap_map_tile_size(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	map *map;
	int tw,th;
	Tcl_Obj *res;

	HAS_ARGS_2(2, 4, "map-id ?tile-width tile-height? ");
	FETCH_PTR(1, map);

	if( objc == 2 )
		{
			/* read the map tile size .. */
			if( map_get_tile_size(map, &tw, &th) == ERR )
				RET_ERROR("Invalid map id ");
			else
				{
					/* and return the result */
					res = Tcl_NewObj();
					APPEND_INT(res, tw);
					APPEND_INT(res, th);
					Tcl_SetObjResult(interp, res);
				}

		}
	else
		{
			/* set the map tile dimensions */
			FETCH_INT(2, tw);
			FETCH_INT(3, th);
			map_set_tile_size(map, tw, th);
		}

	return TCL_OK;
}

/* set the tile for the given index */
static int wrap_map_tile(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	map *map;
	tile *tile;
	int index;

	HAS_ARGS_2(3, 4, "map-id index ?tile-id? ");
	FETCH_PTR(1, map);
	FETCH_INT(2, index);

	if( objc == 2 )
		{
			/* read the tile .. */
			if( map_get_tile(map, index, &tile) == ERR )
				RET_ERROR("Invalid map id ");
			else
				RET_PTR(tile);
		}
	else
		{
			/* or set the tile in the map's tile index */
			FETCH_PTR(3, tile);
			map_set_tile(map, index, tile);
			return TCL_OK;
		}

}

/* set the map data itself */
static int wrap_map_set_data(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* map pointer */
	map *map;

	/* the length of the map-data word-array and the word-array itself */
	int len;
	unsigned char *data;

	/* to verify the map dimensions */
	int w,h;

	HAS_ARGS(3, "map-id map-data ");
	FETCH_PTR(1, map);
	FETCH_DATA(2, len, data);

	/* check the map dimensions */
	if( map_get_size(map, &w, &h) == ERR )
		RET_ERROR("Invalid map id ");

	/* verify the length of the wordarray */
	if( len != w * h * sizeof(short) )
		RET_ERROR("Amount of data doesn't match map dimensions ");

	/* now add the map data */
	map_set_data(map, (short *)data);
	return TCL_OK;

}

/* set a single element of map data */
static int wrap_map_set_single(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* map pointer, tile position */
	map *map;
	int x, y;

	/* the data itself, which will be truncated to short */
	int data;

	HAS_ARGS(5, "map-id x-pos y-pos data ");
	FETCH_PTR(1, map);
	FETCH_INT(2, x);
	FETCH_INT(3, y);
	FETCH_INT(4, data);

	/* now add the map data */
	map_set_single(map, x, y, (short)data);
	return TCL_OK;

}

/* animate all tiles */
static int wrap_map_animate_tiles(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	map *map;
	HAS_ARGS(2, "map-id ");
	FETCH_PTR(1, map);
	map_animate_tiles(map);
	return TCL_OK;
}

/* reset all tile animations */
static int wrap_map_reset_tiles(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	map *map;
	HAS_ARGS(2, "map-id ");
	FETCH_PTR(1, map);
	map_reset_tiles(map);
	return TCL_OK;
}



/* creating a new tile .. */
static int wrap_tile_create(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_PTR(tile_create());
}

/* deleting a tile .. */
static int wrap_tile_delete(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	tile *tile;
	HAS_ARGS(2, "tile-id ");
	FETCH_PTR(1, tile);
	tile_delete(tile);
	return TCL_OK;
}

/* set the animation type for the given tile */
static int wrap_tile_anim_type(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	tile *tile;

	/* possible types */
	const char *types[] = { "still", "fwd", "rev", "pp", (char *) NULL };
	int types_map[] = { ANIMATE_OFF, ANIMATE_FWD, ANIMATE_REV, ANIMATE_PP };
	int types_idx;

	HAS_ARGS_2(2, 3, "tile-id ?animation-type? ");
	FETCH_PTR(1, tile);

	if( objc == 2 )
		{
			/* read and return the name of the animation type */
			if( tile_get_anim_type(tile, &types_idx) == ERR )
				RET_ERROR("Invalid tile id ");
			else
				RET_STG(types[types_idx]);
		}
	else
		{
			/* just set the animation type */
			FETCH_INDEXED(2, types, "animation-type", 0, types_idx);
			tile_set_anim_type(tile, types_map[types_idx]);
			return TCL_OK;
		}

}

/* set the collision mode for the given tile */
static int wrap_tile_collides(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	tile *tile;

	/* collision modes */
	const char *modes[] = { "off", "box", "pixel", (char *) NULL };
	int modes_idx;

	HAS_ARGS_2(2, 3, "tile-id ?collision-mode? ");
	FETCH_PTR(1, tile);

	if( objc == 2 )
		{
			/* read and return the name of the animation type */
			if( tile_get_collides(tile, &modes_idx) == ERR )
				RET_ERROR("Invalid tile id ");
			else
				RET_STG(modes[modes_idx]);
		}
	else
		{
			/* set the collision type */
			FETCH_INDEXED(2, modes, "collision-mode", 0, modes_idx);
			if( !strcmp(modes[modes_idx], "box"))
				tile_set_collides(tile, COLLISION_BOX);
			else if( !strcmp(modes[modes_idx], "pixel"))
				tile_set_collides(tile, COLLISION_PIXEL);
			else
				tile_set_collides(tile, COLLISION_OFF);

			return TCL_OK;

		}

}

/* set a tile frame .. */
static int wrap_tile_add_frame(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	tile *tile;
	frame *frame;
	HAS_ARGS(3, "tile-id frame-id ");
	FETCH_PTR(1, tile);
	FETCH_PTR(2, frame);
	RET_INT(tile_add_frame(tile, frame));
}

/* add a frame to a tile */
static int wrap_tile_add_frame_data(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int i;

	/* tile pointer */
	tile *tile;

	/* data to retrieve from tcl and load */
	char *mode;
	int w,h;
	unsigned char *data; /* tcl bytearray */
	int len;             /* bytes in tcl bytearray */

	/* variables to read and parse convolution kernel or lookup table */
	convolution ck;
	lut l;

	Tcl_Obj *list;
	int list_len, list_val;

	/* the result */
	int res;

	/* check for some args */
	HAS_ENOUGH_ARGS(5, "tile-id type w h ?options ..? ");
	FETCH_PTR(1, tile);
	FETCH_STRING(2, mode);
	FETCH_INT(3, w);
	FETCH_INT(4, h);

	/* and parse out based on mode */
	if( !strcmp(mode, "none") )
		{
			/* the empty sprite type */
			HAS_ARGS(5, "tile-id type w h ");
			res = tile_add_frame_data(tile, FRAME_NONE, w, h, NULL, NULL);
		}
	else
		{
			/* one of the non-null sprite types */
			HAS_ENOUGH_ARGS(6, "tile-id type w h frame-data ?options ..? ");
			FETCH_DATA(5, len, data);

			if( !strcmp(mode, "rgba") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_RGBA, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "rgb") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_RGB, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "hl") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_HL, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "sl") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_SL, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "br") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_BR, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "ct") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_CT, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "sat") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_SAT, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "displ") )
			  {
					HAS_ARGS(6, "tile-id type w h displacement-data ");
					res = tile_add_frame_data(tile, FRAME_DISPL, w, h, (short *)data, NULL);
			  }
			else if( !strcmp(mode, "convo") )
			  {
					/*
					 * retrieve the convolution-kernel data from the list thus:
					 * { w h { k1 k2 k3 .. kn } divisor offset }
					 */
					HAS_ARGS(7, "tile-id type w h frame-data kernel ");
					HAS_ITEMS(objv[6], 5, "Convolution kernel list must contain five elements ");

					/* first fetch the kernel width and height */
					FETCH_INT_FROM(objv[6], 0, ck.kw);
					FETCH_INT_FROM(objv[6], 1, ck.kh);
					FETCH_INT_FROM(objv[6], 3, ck.divisor);
					FETCH_INT_FROM(objv[6], 4, ck.offset);

					if( ck.kw > MAX_CK_SIZE || ck.kh > MAX_CK_SIZE )
						RET_ERROR( "Convolution kernel too large ");

					/* next, the kernel sublist itself */
					Tcl_ListObjIndex(interp, objv[6], 2, &list);
					FETCH_LEN(list, list_len);

					if( list_len != ck.kw * ck.kh )
					  RET_ERROR("Incorrect amount of kernel data provided ");

					/* and retrieve the values */
					for( i=0; i < list_len; i++ )
					  {
							FETCH_INT_FROM(list, i, list_val);
						  ck.kernel[i] = (char)list_val;
					  }

					/* at last, add the convolution kernel */
					res = tile_add_frame_data(tile, FRAME_CONVO, w, h, data, &ck);

			  }
			else if( !strcmp(mode, "lut") )
			  {
					/* retrieve the lookup table data from the list */
					HAS_ARGS(7, "tile-id type w h frame-data lut-data ");
					HAS_ITEMS(objv[6], RGB_RANGE * 3, "Lookup table list must contain 768 elements ");

					/* retrieve the lut sublist */
					Tcl_ListObjIndex(interp, objv[6], 0, &list);
					for(i=0; i < 256; i++)
						{
							/* fetch red, green, blue */
							FETCH_INT_FROM(list, i*3, list_val);
							l.r[i] = (unsigned char)list_val;

							FETCH_INT_FROM(list, i+256, list_val);
							l.g[i] = (unsigned char)list_val;

							FETCH_INT_FROM(list, i+512, list_val);
							l.b[i] = (unsigned char)list_val;
						}

					/* at last, add the convolution kernel */
					res = tile_add_frame_data(tile, FRAME_LUT, w, h, data, &l);
			  }
			else if( !strcmp(mode, "xor") )
			  {
					HAS_ARGS(6, "tile-id type w h frame-data ");
					res = tile_add_frame_data(tile, FRAME_XOR, w, h, data, NULL);
			  }
			else
			  RET_ERROR("Unknown frame type ");
		}


	/* and finished */
	if( res < 0 )
		{
			switch(res)
				{
					case ERR: RET_ERROR("Invalid tile id ");
					case ERR_BAD_FRAME_TYPE: RET_ERROR("Unknown frame type ");
					default: RET_ERROR("Unknown error ");
				}
		}
	else
		RET_INT(res);

}

/* set the tile pixel mask */
static int wrap_tile_pixel_mask(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* tile pointer and frame index */
	tile *tile;
	int index;

	/* pixel data buffer */
	unsigned char *data;
	int len;

	HAS_ARGS(4, "tile-id index data ");
	FETCH_PTR(1, tile);
	FETCH_INT(2, index);
	FETCH_DATA(3, len, data);
	tile_set_pixel_mask(tile, index, data);
	return TCL_OK;
}

/* set the tile pixel mask from a source frame */
static int wrap_tile_pixel_mask_from(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* tile pointer and frame index */
	tile *tile;
	int index;
	frame *frame;

	HAS_ARGS(4, "tile-id index frame-id ");
	FETCH_PTR(1, tile);
	FETCH_INT(2, index);
	FETCH_PTR(3, frame);
	tile_set_pixel_mask_from(tile, index, frame);
	return TCL_OK;
}

/* animate one tile */
static int wrap_tile_animate(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	tile *tile;
	HAS_ARGS(2, "tile-id ");
	FETCH_PTR(1, tile);
	tile_animate(tile);
	return TCL_OK;
}

/* reset one tile */
static int wrap_tile_reset(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	tile *tile;
	HAS_ARGS(2, "tile-id ");
	FETCH_PTR(1, tile);
	tile_reset(tile);
	return TCL_OK;
}



/* create a new sprite */
static int wrap_sprite_create(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_PTR(sprite_create());
}

/* clone the sprite */
static int wrap_sprite_copy(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	HAS_ARGS(2, "sprite-id ");
	FETCH_PTR(1, sprite);
	RET_PTR(sprite_copy(sprite));
}

/* delete the given sprite */
static int wrap_sprite_delete(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	HAS_ARGS(2, "sprite-id ");
	FETCH_PTR(1, sprite);
	sprite_delete(sprite);
	return TCL_OK;
}

/* set the visible sprite frame */
static int wrap_sprite_frame(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	int index;
	Tcl_Obj *res;

	HAS_ARGS_2(2, 3, "sprite-id ?index? ");
	FETCH_PTR(1, sprite);

	if( objc == 2 )
		{
			if( sprite_get_frame(sprite, &index) == ERR )
				RET_ERROR("Invalid sprite id ");
			else
				RET_INT(index);
		}
	else
		{
			FETCH_INT(2, index);
			sprite_set_frame(sprite, index);
			return TCL_OK;
		}

}

/* the sprite's z hint */
static int wrap_sprite_z_hint(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	int z_hint;
	Tcl_Obj *res;

	HAS_ARGS_2(2, 3, "sprite-id ?z-hint? ");
	FETCH_PTR(1, sprite);

	if( objc == 2 )
		{
			if( sprite_get_z_hint(sprite, &z_hint) == ERR )
				RET_ERROR("Invalid sprite id ");
			else
				RET_INT(z_hint);
		}
	else
		{
			FETCH_INT(2, z_hint);
			sprite_set_z_hint(sprite, z_hint);
			return TCL_OK;
		}

}

/* the sprite scale */
static int wrap_sprite_scale(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	int sx, sy;
	double sx_float, sy_float;
	Tcl_Obj *res;

	HAS_ARGS_2(2, 4, "sprite-id ?x y? ");
	FETCH_PTR(1, sprite);

	if( objc == 2 )
		{
			if( sprite_get_scale(sprite, &sx, &sy) == ERR )
				RET_ERROR("Invalid sprite id ");
			else
				{
					/* and return a Tcl-list */
					res = Tcl_NewObj();
					APPEND_FLOAT(res, (float)sx/65536);
					APPEND_FLOAT(res, (float)sy/65536);
					Tcl_SetObjResult(interp, res);
				}
		}
	else
		{
			FETCH_FLOAT(2, sx_float);
			FETCH_FLOAT(3, sy_float);
			sprite_set_scale(sprite, (int)(sx_float * 65536), (int)(sy_float * 65536));
			return TCL_OK;
		}

}

/* the sprite's collision mode */
static int wrap_sprite_collides(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	Tcl_Obj *res;

	/* collision modes */
	const char *modes[] = { "off", "box", "pixel", (char *) NULL };
	int modes_idx;

	HAS_ARGS_2(2, 3, "sprite-id ?collision-mode? ");
	FETCH_PTR(1, sprite);

	if( objc == 2 )
		{
			if( sprite_get_collides(sprite, &modes_idx) == ERR )
				RET_ERROR("Invalid sprite id ");
			else
				RET_STG(modes[modes_idx]);
		}
	else
		{
			/* set the collision mode */
			FETCH_INDEXED(2, modes, "collision-mode", 0, modes_idx);

			if( !strcmp(modes[modes_idx], "box"))
				sprite_set_collides(sprite, COLLISION_BOX);
			else if( !strcmp(modes[modes_idx], "pixel"))
				sprite_set_collides(sprite, COLLISION_PIXEL);
			else
				sprite_set_collides(sprite, COLLISION_OFF);

			return TCL_OK;

		}

}

/* set the sprite frame bounding box */
static int wrap_sprite_bounding_box(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	int index;
	box b;
	HAS_ARGS(7, "sprite-id index x1 y1 x2 y2 ");
	FETCH_PTR(1, sprite);
	FETCH_INT(2, index);
	FETCH_INT(3, b.x1);
	FETCH_INT(4, b.y1);
	FETCH_INT(5, b.x2);
	FETCH_INT(6, b.y2);
	sprite_set_bounding_box(sprite, index, &b);
	return TCL_OK;
}

/* set the pixel mask */
static int wrap_sprite_pixel_mask(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* sprite pointer and frame index */
	sprite *sprite;
	int index;

	/* pixel data buffer */
	unsigned char *data;
	int len;

	HAS_ARGS(4, "sprite-id index data ");
	FETCH_PTR(1, sprite);
	FETCH_INT(2, index);
	FETCH_DATA(3, len, data);
	sprite_set_pixel_mask(sprite, index, data);
	return TCL_OK;
}

/* set the sprite pixel mask from a source frame */
static int wrap_sprite_pixel_mask_from(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* sprite pointer and frame index */
	sprite *sprite;
	int index;
	frame *frame;

	HAS_ARGS(4, "sprite-id index frame-id ");
	FETCH_PTR(1, sprite);
	FETCH_INT(2, index);
	FETCH_PTR(3, frame);
	sprite_set_pixel_mask_from(sprite, index, frame);
	return TCL_OK;
}

/* set the sprite position */
static int wrap_sprite_position(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	int x, y;
	Tcl_Obj *res;

	/* if there are only two args (command name, sprite id), they're requesting the position */
	HAS_ARGS_2(2, 4, "sprite-id ?x y? ");
	FETCH_PTR(1, sprite);

	if( objc == 2 )
		{
			/* get the position? */
			if( sprite_get_position(sprite, &x, &y) == ERR )
				RET_ERROR("Invalid sprite id ");
			else
				{
					/* and return a Tcl-list */
					res = Tcl_NewObj();
					APPEND_INT(res, x);
					APPEND_INT(res, y);
					Tcl_SetObjResult(interp, res);
				}

		}
	else
		{
			/* set the position */
			FETCH_INT(2, x);
			FETCH_INT(3, y);
			sprite_set_position(sprite, x, y);
		}

	return TCL_OK;
}

/* set the sprite velocity */
static int wrap_sprite_velocity(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	int x, y;
	Tcl_Obj *res;

	/* if there are only two args (command name, sprite id), they're requesting the velocity */
	HAS_ARGS_2(2, 4, "sprite-id ?x y? ");
	FETCH_PTR(1, sprite);

	if( objc == 2 )
		{
			/* get the velocity */
			if( sprite_get_velocity(sprite, &x, &y) == ERR )
				RET_ERROR("Invalid sprite id ");
			else
				{
					/* and return a Tcl-list */
					res = Tcl_NewObj();
					APPEND_INT(res, x);
					APPEND_INT(res, y);
					Tcl_SetObjResult(interp, res);
				}

		}
	else
		{
			/* set the velocity */
			FETCH_INT(2, x);
			FETCH_INT(3, y);
			sprite_set_velocity(sprite, x, y);
		}

	return TCL_OK;
}

/* set a sprite frame .. */
static int wrap_sprite_add_frame(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	frame *frame;
	HAS_ARGS(3, "sprite-id frame-id ");
	FETCH_PTR(1, sprite);
	FETCH_PTR(2, frame);
	RET_INT(sprite_add_frame(sprite, frame));
}

/* add frame data to a sprite */
static int wrap_sprite_add_frame_data(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int i;

	/* sprite pointer */
	sprite *sprite;

	/* data to retrieve from tcl and load */
	char *mode;
	int w,h;
	unsigned char *data; /* tcl bytearray */
	int len;             /* bytes in tcl bytearray */

	/* also cumbersome - variables to read and parse convolution kernel or lookup table */
	convolution ck;
	lut l;

	Tcl_Obj *list;
	int list_len, list_val;

	/* the result */
	int res;

	/* check for some args */
	HAS_ENOUGH_ARGS(5, "sprite-id type w h ?options ..? ");
	FETCH_PTR(1, sprite);
	FETCH_STRING(2, mode);
	FETCH_INT(3, w);
	FETCH_INT(4, h);

	/* and parse out based on mode */
	if( !strcmp(mode, "none") )
		{
			/* the empty sprite type */
			HAS_ARGS(5, "sprite-id type w h ");
			res = sprite_add_frame_data(sprite, FRAME_NONE, w, h, NULL, NULL);
		}
	else
		{
			/* one of the non-null sprite types */
			HAS_ENOUGH_ARGS(6, "sprite-id type w h frame-data ?options ..? ");
			FETCH_DATA(5, len, data);

			if( !strcmp(mode, "rgba") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
				  res = sprite_add_frame_data(sprite, FRAME_RGBA, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "rgb") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
					res = sprite_add_frame_data(sprite, FRAME_RGB, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "hl") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
					res = sprite_add_frame_data(sprite, FRAME_HL, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "sl") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
					res = sprite_add_frame_data(sprite, FRAME_SL, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "br") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
					res = sprite_add_frame_data(sprite, FRAME_BR, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "ct") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
					res = sprite_add_frame_data(sprite, FRAME_CT, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "sat") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
					res = sprite_add_frame_data(sprite, FRAME_SAT, w, h, data, NULL);
			  }
			else if( !strcmp(mode, "displ") )
			  {
					HAS_ARGS(6, "sprite-id type w h displacement-data ");
					res = sprite_add_frame_data(sprite, FRAME_DISPL, w, h, (short *)data, NULL);
			  }
			else if( !strcmp(mode, "convo") )
			  {
					/*
					 * retrieve the convolution-kernel data from the list thus:
					 * { w h { k1 k2 k3 .. kn } divisor offset }
					 */
					HAS_ARGS(7, "sprite-id type w h frame-data kernel ");
					HAS_ITEMS(objv[6], 5, "Convolution kernel list must contain five elements ");

					/* first fetch the kernel width and height */
					FETCH_INT_FROM(objv[6], 0, ck.kw);
					FETCH_INT_FROM(objv[6], 1, ck.kh);
					FETCH_INT_FROM(objv[6], 3, ck.divisor);
					FETCH_INT_FROM(objv[6], 4, ck.offset);

					if( ck.kw > MAX_CK_SIZE || ck.kh > MAX_CK_SIZE )
						RET_ERROR( "Convolution kernel too large ");

					/* next, the kernel sublist itself */
					Tcl_ListObjIndex(interp, objv[6], 2, &list);
					FETCH_LEN(list, list_len);

					if( list_len != ck.kw * ck.kh )
					  RET_ERROR("Incorrect amount of kernel data provided ");

					/* and retrieve the values */
					for( i=0; i < list_len; i++ )
					  {
							FETCH_INT_FROM(list, i, list_val);
						  ck.kernel[i] = (char)list_val;
					  }

					/* at last, add the convolution kernel */
					res = sprite_add_frame_data(sprite, FRAME_CONVO, w, h, data, &ck);

			  }
			else if( !strcmp(mode, "lut") )
			  {
					/* retrieve the lookup table data from the list */
					HAS_ARGS(7, "sprite-id type w h frame-data lut-data ");
					HAS_ITEMS(objv[6], RGB_RANGE * 3, "Lookup table list must contain 768 elements ");

					/* retrieve the lut sublist */
					Tcl_ListObjIndex(interp, objv[6], 0, &list);
					for(i=0; i < 256; i++)
						{
							/* fetch red, green, blue */
							FETCH_INT_FROM(list, i*3, list_val);
							l.r[i] = (unsigned char)list_val;

							FETCH_INT_FROM(list, i+256, list_val);
							l.g[i] = (unsigned char)list_val;

							FETCH_INT_FROM(list, i+512, list_val);
							l.b[i] = (unsigned char)list_val;
						}

					/* at last, add the convolution kernel */
					res = sprite_add_frame_data(sprite, FRAME_LUT, w, h, data, &l);
			  }
			else if( !strcmp(mode, "xor") )
			  {
					HAS_ARGS(6, "sprite-id type w h frame-data ");
					res = sprite_add_frame_data(sprite, FRAME_XOR, w, h, data, NULL);
			  }
			else
			  RET_ERROR("Unknown frame type ");
		}


	/* and finished */
	if( res < 0 )
		{
			switch(res)
				{
					case ERR: RET_ERROR("Invalid sprite id ");
					case ERR_BAD_FRAME_TYPE: RET_ERROR("Unknown frame type ");
					default: RET_ERROR("Unknown error ");
				}
		}
	else
		RET_INT(res);

}

/* add a sprite subframe .. */
static int wrap_sprite_add_subframe(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	int index;
	frame *frame;
	HAS_ARGS(4, "sprite-id index frame-id ");
	FETCH_PTR(1, sprite);
	FETCH_INT(2, index);
	FETCH_PTR(3, frame);
	RET_INT(sprite_add_subframe(sprite, index, frame));
}

/* set the sprite's motion-control code */
static int wrap_sprite_load_program(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* sprite pointer */
	sprite *sprite;

	/* motion-control input */
	char *mcp;

	/* result */
	int res;

	HAS_ARGS(3, "sprite-id mcp ");
	FETCH_PTR(1, sprite);
	FETCH_STRING(2, mcp);

	/* load the program */
	res = sprite_load_program(sprite, mcp);

	/* was there an error? */
	if( res < 0 )
		{
			/* oh no!  an error! */
			switch(res)
				{
					case ERR: RET_ERROR("Invalid sprite id ");
					case ERR_BAD_INST: RET_ERROR("Unknown instruction ");
					case ERR_BAD_VAR: RET_ERROR("Unknown variable ");
					case ERR_BAD_ARG: RET_ERROR("Unknown argument ");
					case ERR_TOO_LONG: RET_ERROR("Motion-control program is too long ");
					default: RET_ERROR("Unknown error ");
				}
		}

	/* success! */
	return TCL_OK;

}



/* create a new string */
static int wrap_string_create(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	HAS_ARGS(1, NULL);
	RET_PTR(string_create());
}

/* delete a string */
static int wrap_string_delete(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	string *string;
	HAS_ARGS(2, "string-id ");
	FETCH_PTR(1, string);
	string_delete(string);
	return TCL_OK;
}

/* get the bounding region for a string */
static int wrap_string_box(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	string *string;
	int w, h;
	Tcl_Obj *res;

	HAS_ARGS(2, "string-id ");
	FETCH_PTR(1, string);

	if( string_get_box(string, &w, &h) == ERR )
		RET_ERROR("Invalid string id ");
	else
		{
			/* and return a Tcl-list */
			res = Tcl_NewObj();
			APPEND_INT(res, w);
			APPEND_INT(res, h);
			Tcl_SetObjResult(interp, res);
			return TCL_OK;
		}

}

/* set the font for a string */
static int wrap_string_font(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	string *string;
	char *name;
	HAS_ARGS(3, "string-id font-name ");
	FETCH_PTR(1, string);
	FETCH_STRING(2, name);
	string_set_font(string, name);
	return TCL_OK;
}

/* set string position */
static int wrap_string_position(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	string *string;
	int x,y;
	HAS_ARGS(4, "string-id x y ");
	FETCH_PTR(1, string);
	FETCH_INT(2, x);
	FETCH_INT(3, y);
	string_set_position(string, x, y);
	return TCL_OK;
}

/* set the contents of a string */
static int wrap_string_text(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	string *string;
	char *text;
	HAS_ARGS(3, "string-id text ");
	FETCH_PTR(1, string);
	FETCH_STRING(2, text);
	string_set_text(string, text);
	return TCL_OK;
}



/* inspect the map tiles surrounding the given sprite */
static int wrap_inspect_adjacent_tiles(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the possible directions */
	const char *dirs[] = { "nw", "n", "ne", "e", "se", "s", "sw", "w", NULL };
	int dir_vals[] = { INSPECT_NW, INSPECT_N, INSPECT_NE, INSPECT_E, INSPECT_SE, INSPECT_S, INSPECT_SW, INSPECT_W };
	int dir_idx;

	/* the sprite and map */
	sprite *sprite;
	map *map;

	/* results */
	map_fragment res;
	Tcl_Obj *tcl_result;

	int i;

	HAS_ARGS(4, "sprite-id direction map-id ");
	FETCH_PTR(1, sprite);
	FETCH_INDEXED(2, dirs, "direction", TCL_EXACT, dir_idx);
	FETCH_PTR(3, map);

	/* call the c function */
	inspect_adjacent_tiles(map, sprite, dir_vals[dir_idx], &res);

	/* build the tiles-list */
	tcl_result = Tcl_NewObj();

	/* and prepare the results-list */
	for( i=0; i < res.w * res.h; i++ )
		APPEND_INT(tcl_result, *(res.tiles + i));

	/* important!  only free it if we actually got a result .. */
	if( res.tiles)
		free(res.tiles);

	Tcl_SetObjResult(interp, tcl_result);
	return TCL_OK;

}

/* inspect the map tiles obscured by the given sprite */
static int wrap_inspect_obscured_tiles(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the sprite and map */
	sprite *sprite;
	map *map;

	/* results */
	map_fragment res;
	Tcl_Obj *list, *sublist;

	int i, j, ofs;


	HAS_ARGS(3, "sprite-id map-id ");
	FETCH_PTR(1, sprite);
	FETCH_PTR(2, map);

	/* call the c function */
	inspect_obscured_tiles(map, sprite, &res);

	/* prepare the results-list */
	list = Tcl_NewObj();
	ofs = 0;

	for(i=0; i < res.h; i++)
		{
			/* initialize the sublist */
			sublist = Tcl_NewObj();

			/* generate the sublist */
			for(j=0; j < res.w; j++, ofs++)
				APPEND_INT(sublist, *(res.tiles + ofs));

			/* and append it to the main list */
			Tcl_ListObjAppendElement(interp, list, sublist);

		}

	/* important!  only free it if we actually got a result .. */
	if( res.tiles)
		free(res.tiles);

	Tcl_SetObjResult(interp, list);
	return TCL_OK;

}

/* check line-of-sight visibility between two sprites on the given map */
static int wrap_inspect_line_of_sight(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite, *target;
	map *map;
	int xofs, yofs, dist;

	HAS_ARGS(7, "sprite-id x-ofs y-ofs dist target-id map-id ");
	FETCH_PTR(1, sprite);
	FETCH_INT(2, xofs);
	FETCH_INT(3, yofs);
	FETCH_INT(4, dist);
	FETCH_PTR(5, target);
	FETCH_PTR(6, map);
	RET_INT(inspect_line_of_sight(map, sprite, xofs, yofs, dist, target));
}

/* return a list of sprites, drawn from the given list, within the given frame */
static int wrap_inspect_in_frame(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the sprite list pointer and frame */
	list *l;
	box range;

	/* results */
	list *res;
	iterator iter;
	Tcl_Obj *tcl_result;

	HAS_ARGS(6, "list-id x1 y1 x2 y2 ");
	FETCH_PTR(1, l);
	FETCH_INT(2, range.x1);
	FETCH_INT(3, range.y1);
	FETCH_INT(4, range.x2);
	FETCH_INT(5, range.y2);
	res = inspect_in_frame(l, &range);

	/* initialize the Tcl result list */
	tcl_result = Tcl_NewObj();

	/* and copy the brick result list into the Tcl result list */
	iterator_start(iter, res);
	while( iterator_data(iter) )
		{
			APPEND_PTR(tcl_result, iterator_data(iter));
			iterator_next(iter);
		}

	/* free the result list */
	list_delete(res);

	/* and set the result */
	Tcl_SetObjResult(interp, tcl_result);
	return TCL_OK;

}

/* return a list of sprites, drawn from the given list, within the specified distance of the given point */
static int wrap_inspect_near_point(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* the sprite list, location, and distance */
	list *l;
	int x, y, dist;

	/* results */
	list *res;
	iterator iter;
	Tcl_Obj *tcl_result;

	HAS_ARGS(5, "list-id x y dist ");
	FETCH_PTR(1, l);
	FETCH_INT(2, x);
	FETCH_INT(3, y);
	FETCH_INT(4, dist);

	/* get the results */
	res = inspect_near_point(l, x, y, dist);

	/* initialize the Tcl result list */
	tcl_result = Tcl_NewObj();

	/* and copy the brick result list into the Tcl result list */
	iterator_start(iter, res);
	while( iterator_data(iter) )
		{
			APPEND_PTR(tcl_result, iterator_data(iter));
			iterator_next(iter);
		}

	/* free the result list */
	list_delete(res);

	/* and set the result */
	Tcl_SetObjResult(interp, tcl_result);
	return TCL_OK;

}



/* find map collisions */
static int wrap_collision_map(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	sprite *sprite;
	map *map;
	int slip;

	/* the results */
	map_collision res;

	/* the result list:  { mode stop.x stop.y go.x go.y } */
	Tcl_Obj *tcl_result;

	HAS_ARGS_2(3, 4, "sprite-id map-id ?slip? ");
	FETCH_PTR(1, sprite);
	FETCH_PTR(2, map);
	if( objc == 4 )
		FETCH_INT(3, slip);
	else
		slip = 0;

	/* call the c function */
	collision_with_map(sprite, map, slip, &res);

	/* and prepare the results-list */
	tcl_result = Tcl_NewObj();
	APPEND_INT(tcl_result, res.mode);
	APPEND_INT(tcl_result, res.stop.x);
	APPEND_INT(tcl_result, res.stop.y);
	APPEND_INT(tcl_result, res.go.x);
	APPEND_INT(tcl_result, res.go.y);
	Tcl_SetObjResult(interp, tcl_result);
	return TCL_OK;

}

/* find sprite collisions: { { target mode dir.x dir.y stop.x stop.y } .. } */
static int wrap_collision_sprites(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* sprite pointer, sprite list pointer */
	sprite *sprite;
	list *l;

	/* results */
	int i, ct;
	sprite_collision cols[MAX_SPRITE_COLLISIONS];
	Tcl_Obj *res, *tcl_result;

	HAS_ARGS(3, "sprite-id list-id ");
	FETCH_PTR(1, sprite);
	FETCH_PTR(2, l);

	/* call the c function */
	ct = collision_with_sprites(sprite, l, MAX_SPRITE_COLLISIONS, cols);

	/* produce the results list */
	tcl_result = Tcl_NewObj();
	for(i=0; i < ct; i++)
		{
			/* build the list of result vectors and the target */
			res = Tcl_NewListObj(0, NULL);
			APPEND_INT(res, cols[i].mode);
			APPEND_PTR(res, cols[i].target);
			APPEND_INT(res, cols[i].dir.x);
			APPEND_INT(res, cols[i].dir.y);
			APPEND_INT(res, cols[i].stop.x);
			APPEND_INT(res, cols[i].stop.y);
			Tcl_ListObjAppendElement(interp, tcl_result, res);
		}

	/* return the results */
	Tcl_SetObjResult(interp, tcl_result);
	return TCL_OK;

}



/* execute the motion-control code for each item in the given list */
static int wrap_motion_list(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* sprite list pointer */
	list *l;

	/* results */
	int res;

	HAS_ARGS(2, "list-id ");
	FETCH_PTR(1, l);

	/* walk a list, running each sprite's motion-control code */
	res = motion_exec_list(l);

	/* check for errors */
	if( res < 0)
		{
			switch(res)
				{
					case ERR: RET_ERROR("Invalid sprite in list ");
					case ERR_BAD_INST_BC: RET_ERROR("Unknown instruction in bytecode ");
					case ERR_BAD_ARG_BC: RET_ERROR("Unknown argument in bytecode ");
					default: RET_ERROR("Unknown error ");
				}
		}

	return TCL_OK;

}

/* execute the motion-control code for a single item */
static int wrap_motion_single(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	/* sprite pointer */
	sprite *sprite;

	/* results */
	int res;

	HAS_ARGS(2, "sprite-id ");
	FETCH_PTR(1, sprite);

	/* run one sprite's motion-control code */
	res = motion_exec_single(sprite);

	/* check for errors */
	if( res < 0)
		{
			switch(res)
				{
					case ERR: RET_ERROR("Invalid sprite ");
					case ERR_BAD_INST_BC: RET_ERROR("Unknown instruction in bytecode ");
					case ERR_BAD_ARG_BC: RET_ERROR("Unknown argument in bytecode ");
					default: RET_ERROR("Unknown error ");
				}
		}

	return TCL_OK;

}

/* a variable-speed delay loop, that tries to keep frames-per-second steady */
static int wrap_clock_ms(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int fps;
	HAS_ARGS(1, NULL);
	RET_INT(clock_ms());
}

/* a variable-speed delay loop, that tries to keep frames-per-second steady */
static int wrap_clock_wait(ClientData cData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	int fps;
	HAS_ARGS(2, "fps ");
	FETCH_INT(1, fps);
	RET_INT(clock_wait(fps));
}
