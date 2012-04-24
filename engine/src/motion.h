
/*
 * the sprite motion-control system
 */


/* an argument-decoder */
#define decode(tgt, src) \
	do \
		{ \
			tgt.type = src[pc++]; \
			pc = (pc+3) & -4; /* ensure dword-alignment for the arguments */ \
			switch(tgt.type) \
				{ \
					case ARG_IMM: \
						tgt.val = *((int *)&src[pc]); \
						pc += sizeof(int); \
						break; \
					case ARG_VAR: \
						tgt.type = *((int *)&src[pc]); \
						pc += sizeof(int); \
						break; \
					case ARG_PTR: \
						tgt.ptr = *((void **)&src[pc]); \
						pc += sizeof(void *); \
						break; \
				} \
		} \
	while(0)


/* a vptr assignment statement */
#define setvptr(arg, src) \
	do \
		{ \
			switch((arg).type) { \
				case ARG_IMM: \
					(arg).vptr = &(arg).val; \
					break; \
				case ARG_PTR: \
					break; \
				case ARG_XPOS: \
					(arg).vptr = &((sprite *)src)->pos.x; \
					break; \
				case ARG_YPOS: \
					(arg).vptr = &((sprite *)src)->pos.y; \
					break; \
				case ARG_XVEL: \
					(arg).vptr = &((sprite *)src)->vel.x; \
					break; \
				case ARG_YVEL: \
					(arg).vptr = &((sprite *)src)->vel.y; \
					break; \
				case ARG_FRAME: \
					(arg).vptr = &((sprite *)src)->cur_frame; \
					break; \
				case ARG_TICK: \
					(arg).vptr = &((sprite *)src)->motion.tick; \
					break; \
				default: \
					return ERR_BAD_ARG_BC; \
			} \
		} \
	while(0)



/* a platform-specific workaround */
#ifdef __WIN32
#define strtok_r(s,d,p) strtok(s,d)
#endif


struct token
{
	char *str;
	int bc;
};


struct inst
{
	struct token tok;
	int argc;
	int args[2];
};


struct arg
{
	int type;
	int *vptr;
	union
		{
			int val;
			void *ptr;
		};
};


/* instructions */
#define BC_EOC 0

/* the # of arguments that an instruction takes is coded in the low two bits */
#define mkbc(a, x) (((a)<<2) | x)

#define BC_SET mkbc(1, 2)
#define BC_ADD mkbc(2, 2)
#define BC_STC mkbc(3, 2)
#define BC_TRK mkbc(4, 2)
#define BC_AVG mkbc(5, 2)

#define BC_BEQ mkbc(10, 2)
#define BC_BNE mkbc(11, 2)
#define BC_BLT mkbc(12, 2)
#define BC_BGT mkbc(13, 2)
#define BC_BMP mkbc(14, 1)
#define BC_BNM mkbc(15, 1)
#define BC_BST mkbc(16, 1)
#define BC_BCS mkbc(17, 1)
#define BC_BNC mkbc(18, 1)

#define BC_COPY mkbc(20, 1)
#define BC_LADD mkbc(21, 1)
#define BC_LREM mkbc(22, 1)
#define BC_DEL mkbc(23, 0)

#define BC_SND mkbc(30, 1)

#define BC_LOADP mkbc(40, 1)
#define BC_XCHGP mkbc(41, 1)



/* arg types */
#define TYPES_IMM 1
#define TYPES_PTR 2
#define TYPES_VAR 3
#define TYPES_ALL 4

/* arguments */
#define ARG_IMM 1
#define ARG_VAR 2
#define ARG_PTR 3
#define ARG_XPOS 10
#define ARG_YPOS 11
#define ARG_XVEL 12
#define ARG_YVEL 13
#define ARG_FRAME 14
#define ARG_TICK 15



/* pulled from SDL_mixer.h */
#define MIX_MAX_VOLUME 128

/* parse a motion-control-code string into bytecode */
int parse_mcp(const char *, mcp *);
int motion_exec_single(sprite *);
int motion_exec_list(list *);


/* from sprite.c */
extern sprite *sprite_copy(sprite *);
extern void sprite_delete(sprite *);
extern void adjust_sprite_frame(sprite *, int);
extern void update_bound_cache(sprite *);

/* from collision.c */
extern void collision_with_map(sprite *, map *, int, map_collision *);

/* from audio.c */
extern int sound_play(sound *, int);

/* from list.c */
extern void list_add(list *, void *);
extern void list_remove(list *, void *, int);

/* from misc.c */
extern void *ck_malloc(size_t);
