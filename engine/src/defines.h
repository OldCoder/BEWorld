/* maximum motion-control code length */
#define MAX_MCP_LENGTH 384

/* maximum on-screen display text length */
#define MAX_STRING_LENGTH 240

/* additional frame definitions */
#define DISPL_SPAN 2

/* how many characters in a font? */
#define FONT_CT 128

/*  how many tiles per map? */
#define MAX_TILES 4096

/* maximum convolution-kernel size */
#define MAX_CK_SIZE 7

/* how many joysticks?  axes, hats, and buttons perjoystick? */
#define MAX_JOY 8
#define MAX_AXES 8
#define MAX_HATS 4
#define MAX_BUTTONS 20

/* how many mice?  mouse buttons? */
#define MAX_MOUSE 1
#define MAX_MOUSE_BUTTONS 8

/* list defines */
#define LIST_HEAD 0
#define LIST_TAIL 1
#define LIST_ALL 2

/* audio and video defines */
#define GRAPHICS_SDL 0
#define GRAPHICS_ACCEL 1
#define GRAPHICS_WINDOWED 0
#define GRAPHICS_FS 2

#define GRAPHICS_0 0
#define GRAPHICS_90 1
#define GRAPHICS_180 2
#define GRAPHICS_270 3

#define AUDIO_OFF 0
#define AUDIO_SPEAKER 1

#define AUDIO_RATE 22050
#define AUDIO_FORMAT 0x0008  /**< Unsigned 8-bit samples, defined as AUDIO_U8 in SDL_audio.h */
#define AUDIO_CHANNELS 2
#define AUDIO_BUFFERS 512

/* frame types */
#define FRAME_NONE 0
#define FRAME_RGBA 1
#define FRAME_RGB 2
#define FRAME_HL 3
#define FRAME_SL 4
#define FRAME_BR 5
#define FRAME_CT 6
#define FRAME_SAT 7
#define FRAME_DISPL 8
#define FRAME_CONVO 9
#define FRAME_LUT 10
#define FRAME_XOR 11

#define FRAME_EFFECT_DROP_SHADOW 1


/* animation modes */
#define ANIMATE_OFF 0
#define ANIMATE_FWD 1
#define ANIMATE_REV 2
#define ANIMATE_PP 3
#define ANIMATE_PP_REV 4

/* collision types */
#define COLLISION_OFF 0
#define COLLISION_BOX 1
#define COLLISION_PIXEL 2

#define COLLISION_CK -1

/* collision-related defines */
#define COLLISION_ATSTART -1
#define COLLISION_NEVER 0
#define COLLISION_INMOTION 1

/* inspection-related defines */
#define INSPECT_NW 0
#define INSPECT_N 1
#define INSPECT_NE 2
#define INSPECT_E 3
#define INSPECT_SE 4
#define INSPECT_S 5
#define INSPECT_SW 6
#define INSPECT_W 7

/* constants used by the input routines */
#define IO_UP 0
#define IO_RIGHT 1
#define IO_DOWN 2
#define IO_LEFT 3

#define IO_AXIS 0
#define IO_HAT 1
#define IO_BUTTON 2

/* event-handling constants */
#define EVENT_GO 0
#define EVENT_STOP 1
#define EVENT_PAUSE 2
#define EVENT_SKIP1 3

/* graphics-related defines. */
#define RGB_BITS 24
#define RGB_BYTES 3

#define RGBA_BITS 32
#define RGBA_BYTES 4

#define RGB_RANGE 256
#define RGB_MAX (RGB_RANGE-1)


/* error codes - generic */
#define ERR -1

/* error codes - graphics and audio */
#define ERR_CANT_REOPEN -10
#define ERR_BAD_MODE -11
#define ERR_BAD_FILE -12
#define ERR_SDL_FAILED -13
#define ERR_SDL_VIDEO_FAILED -14
#define ERR_SDL_MIXER_FAILED -15

/* error codes - sprites */
#define ERR_BAD_FRAME_TYPE -30

/* error codes - loading external data */
#define ERR_INVALID_FILE -40

/* error codes - motion control programs */
#define ERR_BAD_INST -51
#define ERR_BAD_VAR -52
#define ERR_BAD_ARG -53
#define ERR_TOO_LONG -54

#define ERR_BAD_LIST -60
#define ERR_BAD_INST_BC -61
#define ERR_BAD_ARG_BC -62
