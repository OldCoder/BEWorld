#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include "common.h"
#include "motion.h"




/*
 * the motion-control instructions:
 * set var, var/imm     - put var/imm into var
 * add var, var/imm     - add var/imm to var
 * stc var, var/imm     - stochastic alter var, range of -var/imm and var/imm
 * trk var, ptr         - track the var contents of the other sprite in this sprite
 * avg var, ptr         - average the var contents of the other sprite with this sprite
 *
 * beq var, var/imm  - break if var equals imm
 * bne var, var/imm  - break if var does not equal imm
 * blt var, var/imm  - break if var is less than imm
 * bgt var, var/imm  - break if var is greater than imm
 * bmp ptr           - break if the sprite has hit the map
 * bnm ptr           - break if the sprite has NOT hit the map
 * bcs ptr           - break if the sprite has hit any sprites in the given list
 * bnc ptr           - break if the sprite has NOT hit any sprites in the given list
 * bst var/imm       - stochastic break, if random value between 0 and imm is zero
 *
 * copy ptr  - copy sprite-id given by ptr and alias the copied sprite onto self
 * ladd ptr  - add self to the list given by ptr
 * lrem ptr  - remove self from the list given by ptr
 * del       - delete self
 *
 * loadp ptr - load motion control program from another sprite
 * xchgp ptr - exchange motion control program with another sprite
 *
 * sound - play a sound
 *
 * eoc	- end of code (null)
 *
 *
 * the motion-control arguments:
 * - xpos, ypos, xvel, yvel, frame, tick, integer immediate value
 *
 *
 *
 * bytecode storage:
 * [inst] - 1 byte
 * [args] - 1 byte for each argument the instruction requires
 *        - the byte contains either the variable type or a marker
 *          that an immediate value follows
 * [imm]  - 4 bytes for an immediate
 * [ptr]  - sufficient bytes to hold a void *
 *
 */







/*
 * this routine parses a string into bytecode.  a string must have
 * each line separated by \n or \r.  arguments are separated by a
 * comma or a space.  extra whitespace is ignored.
 */
int parse_mcp(const char *in, mcp *m)
{
	int i, j;

	/* the instructions that the parser accepts */
	struct inst insts[] = {
		{ { "set", BC_SET }, 2, { TYPES_VAR, TYPES_ALL } },
		{ { "add", BC_ADD }, 2, { TYPES_VAR, TYPES_ALL } },
		{ { "stc", BC_STC }, 2, { TYPES_VAR, TYPES_ALL } },
		{ { "trk", BC_TRK }, 2, { TYPES_VAR, TYPES_PTR } },
		{ { "avg", BC_AVG }, 2, { TYPES_VAR, TYPES_PTR } },
		{ { "beq", BC_BEQ }, 2, { TYPES_VAR, TYPES_ALL } },
		{ { "bne", BC_BNE }, 2, { TYPES_VAR, TYPES_ALL } },
		{ { "blt", BC_BLT }, 2, { TYPES_VAR, TYPES_ALL } },
		{ { "bgt", BC_BGT }, 2, { TYPES_VAR, TYPES_ALL } },
		{ { "bmp", BC_BMP }, 1, { TYPES_PTR, 0 } },
		{ { "bnm", BC_BNM }, 1, { TYPES_PTR, 0 } },
		{ { "bcs", BC_BCS }, 1, { TYPES_PTR, 0 } },
		{ { "bnc", BC_BNC }, 1, { TYPES_PTR, 0 } },
		{ { "bst", BC_BST }, 1, { TYPES_ALL, 0 } },
		{ { "copy", BC_COPY }, 1, { TYPES_PTR, 0 } },
		{ { "ladd", BC_LADD }, 1, { TYPES_PTR, 0 } },
		{ { "lrem", BC_LREM }, 1, { TYPES_PTR, 0 } },
		{ { "del", BC_DEL }, 0, { 0, 0 } },
		{ { "loadp", BC_LOADP }, 1, { TYPES_PTR, 0 } },
		{ { "xchgp", BC_XCHGP }, 1, { TYPES_PTR, 0 } },
		{ { "sound", BC_SND }, 1, { TYPES_PTR, 0 } },
		{ { "eoc", BC_EOC }, 0, { 0, 0 } },
		{ { NULL, 0 }, 0, { 0, 0 } }
	};
	struct inst *this_i;


	/* the arguments that the parser accepts */
	struct token args[] = {
		{ "xpos", ARG_XPOS },
		{ "ypos", ARG_YPOS },
		{ "xvel", ARG_XVEL },
		{ "yvel", ARG_YVEL },
		{ "frame", ARG_FRAME },
		{ "tick", ARG_TICK },
		{ NULL, 0 }
	};
	struct token *this_a;



	/* placheolders for tokenization */
	char *in_buf;
	char *lines[200];
	char *s[3];
	int lc;



	/* container for parsed args */
	struct arg p_arg[2];


	/* a bytecode output buffer */
	int ct;
	char buf[255];

	int res;




	/* a failsafe */
	if( !in || !m )
		return ERR;


	/* initializing */
	in_buf = NULL;

	/* if the motion-control program is empty, just blank it out */
	if( !strlen(in) )
		m->code[0] = BC_EOC;

	else
		{

			/* allocate a temp buffer for the input */
			in_buf = strdup(in);

			/* initialization */
			ct = 0;
			lc = 0;


			/* first, break up input into lines */
			lines[lc] = strtok( in_buf, "\r\n");
			while( lines[lc] && lc < 199 )
				{
					lc++;
					lines[lc] = strtok( NULL, "\r\n");
				}

			lines[lc+1] = NULL;	 /* properly terminate the line array */



			/* parse words within the line */
			lc = 0;
			while( lines[lc] )
				{

					s[0] = strtok( lines[lc], " \t,");
					s[1] = strtok( NULL, " \t,");
					s[2] = strtok( NULL, " \t,");

					/* skip empty lines */
					if( !s[0] )
						{
							lc++;
							continue;
						}


					/* try to match a known instruction */
					for( i=0, this_i = NULL; insts[i].tok.str; i++ )
						if( !strcasecmp(s[0], insts[i].tok.str) )  /* match?  save the instruction */
							this_i = &insts[i];

					if( !this_i )    /* no valid instruction?? */
						{
							res = ERR_BAD_INST;
							goto parse_quit;
						}


					/* now, check the arguments */
					for( i=0; i < this_i->argc; i++ )
						{

							/*
							 * for this instruction, determine the types of argument it wants
							 * and attempt to parse those
							 */
							if( this_i->args[i] == TYPES_IMM )
								{
									/* an immediate-value arg */
									p_arg[i].type = ARG_IMM;
									p_arg[i].val = atoi(s[i+1]);
								}
							else if( this_i->args[i] == TYPES_PTR )
								{
									/* an immediate-value arg which is a pointer */
									p_arg[i].type = ARG_PTR;
									sscanf(s[i+1], "%p", &p_arg[i].ptr);
								}
							else if( this_i->args[i] == TYPES_VAR )
								{
									/* a variable-name arg - scan for valid names */
									for( j=0, this_a = NULL; args[j].str; j++ )
										if( !strcasecmp(s[i+1], args[j].str) )
											this_a = &args[j];

									if( !this_a )
										{
											res = ERR_BAD_VAR;
											goto parse_quit;
										}

									p_arg[i].type = ARG_VAR;
									p_arg[i].val = this_a->bc;

								}
							else if( this_i->args[i] == TYPES_ALL )
								{
									/* could be either a variable name or an integer immediate, so check if it is a var first */
									for( j=0, this_a = NULL; args[j].str; j++ )
										if( !strcasecmp(s[i+1], args[j].str) )
											this_a = &args[j];

									/* if no arg matched, it must be an int val, otherwise, it is a named variable */
									if( !this_a )
										{
											p_arg[i].type = ARG_IMM;
											p_arg[i].val = atoi(s[i+1]);
										}
									else
										{
											p_arg[i].type = ARG_VAR;
											p_arg[i].val = this_a->bc;
										}

								}
							else
								{
									res = ERR_BAD_ARG;
									goto parse_quit;
								}


						}


					/*
					 * we've got our arguments!  so let's pack the bytecode ..
					 */
					buf[ct++] = this_i->tok.bc;
					for( i=0; i < this_i->argc; i++)
						{
							/* store the type */
							buf[ct++] = p_arg[i].type;

							/* ensure dword-alignment for the arguments */
							ct = (ct+3) & -4;

							/* now pack the argument or arguments .. */
							switch(p_arg[i].type)
								{

									/* immediate values and named vars are packed simply */
									case ARG_IMM:
									case ARG_VAR:
										*((int *)&buf[ct]) = p_arg[i].val;
										ct += sizeof(int);
										break;

									/* and last, store pointers as void pointers. */
									case ARG_PTR:
										*((void **)&buf[ct]) = p_arg[i].ptr;
										ct += sizeof(void *);
										break;
								}

						}


					/* check for length */
					if( ct >= MAX_MCP_LENGTH )
						{
							res = ERR_TOO_LONG;
							goto parse_quit;
						}



					/* fetch the next line */
					lc++;

				}


			/*
			 * ok!  we're done parsing the program!  be sure to add an end-of-code
			 * marker, and copy it to the buffer
			 */
			if( !m->code )
				m->code = ck_malloc(MAX_MCP_LENGTH);

			buf[ct++] = BC_EOC;
			memcpy(m->code, buf, ct);

		}


	/* success! */
	res = 0;

	/* and we are done .. */
	parse_quit:

	/* if the input buffer was allocated .. */
	if(in_buf)
		free(in_buf);

	return res;

}
















/*
 * execute the bytecode of a given sprite
 */
int motion_exec_single(sprite *s)
{
	int i;

	/* a working copy of the motion-control code */
	unsigned char buf[MAX_MCP_LENGTH];


	/*
	 * the bytecode program counter, argument counter, decoded
	 * instruction and arguments
	 */
	int inst, pc;
	struct arg a[2];

	/* result buffers */
	unsigned char *xchg;
	map_collision map_res;
	sprite_collision sprite_res;


	/* a failsafe */
	if( !s )
		return ERR;

	/* skip if no program */
	if( !s->motion.code )
		return 0;


	/* initialize */
	pc = 0;
	memcpy(buf, s->motion.code, MAX_MCP_LENGTH);


	for(;;)
		{

			/*
			 * get the instruction and decode its arguments.  note that the low two
			 * bits of the instruction encode each instruction's argument count.  also
			 * note that, after decoding, the argument type is adjusted a bit so that
			 * named arguments (as opposed to immediate-value or pointer arguments) are
			 * pulled from the "value" field in the bytecode and placed into the
			 * argument-type placeholder.
			 */
			inst = buf[pc++];
			switch(inst & 0x3)
				{
					case 0:
						break;
					case 1:
						decode(a[0], buf);
						break;
					case 2:
						decode(a[0], buf);
						decode(a[1], buf);
						break;
					default:
						return ERR_BAD_INST_BC;
				}

			/*
			 * the two sprite-following instructions are a special case:
			 * the second argument is a pointer to another sprite, with
			 * its named-variable (vptr) taken from the first argument
			 */
			if( inst == BC_TRK || inst == BC_AVG )
				{
					a[1].type = a[0].type;
					setvptr(a[0], s);
					setvptr(a[1], a[1].ptr);
				}
			else
				{
					/* set the argument pointers based on the byte-coded types */
					for(i=0; i < (inst & 0x3); i++)
						setvptr(a[i], s);
				}


			/* now, take action */
			switch(inst)
				{

					case BC_SET:
					case BC_TRK:
						*a[0].vptr = *a[1].vptr;
						if( a[0].type == ARG_FRAME )        /* make sure any frame-adjustment is bounded to range */
							adjust_sprite_frame(s, 0);
						break;

					case BC_ADD:
						*a[0].vptr += *a[1].vptr;
						if( a[0].type == ARG_FRAME )        /* make sure any frame-adjustment is bounded to range */
							adjust_sprite_frame(s, 0);
						break;

					case BC_STC:
						if( *a[1].vptr )                    /* avoid odd behavior if jitter is zero */
							{
								*a[0].vptr += rand() % (*a[1].vptr * 2 + 1) - *a[1].vptr;
								if( a[0].type == ARG_FRAME )    /* make sure any frame-adjustment is bounded to range */
									adjust_sprite_frame(s, 0);
							}
						break;

					case BC_AVG:
						*a[0].vptr = (*a[0].vptr + *a[1].vptr) / 2;
						if( a[0].type == ARG_FRAME )        /* make sure any frame-adjustment is bounded to range */
							adjust_sprite_frame(s, 0);
						break;


					case BC_BEQ:
						if( *a[0].vptr == *a[1].vptr )
							goto mcp_quit;
						break;

					case BC_BNE:
						if( *a[0].vptr != *a[1].vptr )
							goto mcp_quit;
						break;

					case BC_BLT:
						if( *a[0].vptr < *a[1].vptr )
							goto mcp_quit;
						break;

					case BC_BGT:
						if( *a[0].vptr > *a[1].vptr )
							goto mcp_quit;
						break;

					case BC_BST:
						if( *a[0].vptr )                    /* avoid odd behavior if jitter is zero */
							if( rand() % *a[0].vptr )
								goto mcp_quit;
						break;

					case BC_BMP:
						collision_with_map(s, a[0].ptr, 0, &map_res);
						if( map_res.mode != COLLISION_NEVER )
							goto mcp_quit;
						break;

					case BC_BNM:
						collision_with_map(s, a[0].ptr, 0, &map_res);
						if( map_res.mode == COLLISION_NEVER )
							goto mcp_quit;
						break;

					case BC_BCS:
						if( collision_with_sprites(s, a[0].ptr, 1, &sprite_res) )
							goto mcp_quit;
						break;

					case BC_BNC:
						if( !collision_with_sprites(s, a[0].ptr, 1, &sprite_res) )
							goto mcp_quit;
						break;

					case BC_COPY:
						s = sprite_copy(a[0].ptr);
						break;

					case BC_LADD:
						list_add(a[0].ptr, s);
						break;

					case BC_LREM:
						list_remove(a[0].ptr, s, LIST_HEAD);
						break;

					case BC_DEL:
						sprite_delete(s);
						return 0;                  /* once the sprite is deleted, there is little we can do */

					case BC_SND:
						sound_play(a[0].ptr, MIX_MAX_VOLUME);
						break;

					case BC_LOADP:
						memcpy(s->motion.code, ((sprite *)a[0].ptr)->motion.code, MAX_MCP_LENGTH);
						return 0;                  /* if we've loaded a new program, better jump out of this one now */

					case BC_XCHGP:
						xchg = s->motion.code;
						s->motion.code = ((sprite *)a[0].ptr)->motion.code;
						((sprite *)a[0].ptr)->motion.code = xchg;
						break;

					case BC_EOC:
						goto mcp_quit;

				}


		}


	/* success! */
	mcp_quit:
	s->motion.tick++;

	/* likely that the sprite has moved, so update the bounds cache */
	update_bound_cache(s);

	return 0;

}





















/*
 * execute the bytecode of a every sprite in the given list
 */
int motion_exec_list(list *l)
{
	iterator iter;
	sprite *s;

	/* the results */
	int res;

	/* fetch the list pointer and verify */
	if( !l )
		return ERR_BAD_LIST;


	/* and step through the list */
	iterator_start(iter, l);
	while( (s = iterator_data(iter)) )
		{
			/* run the code, and check the result */
			res = motion_exec_single(s);
			if( res < 0 )
				return res;

			iterator_next(iter);
		}


	/* success! */
	return 0;

}
