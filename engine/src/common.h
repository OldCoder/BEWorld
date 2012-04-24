
/*
 * accessory libraries
 */
#include "libdivide.h"


/*
 * local compilation setting and engine-wide definitions
 */
#include "config.h"
#include "defines.h"
#include "types.h"
#include "private.h"



/*
 * debugging-output macros
 */
#define DEBUG(a)      do { fprintf(stderr,a); } while(0)
#define DEBUG_N(a, b) do { fprintf(stderr,a,b); } while(0)
#define DEBUGF        do { fprintf(stderr,"success!\n"); } while(0)
#define DEBUGNF       do { fprintf(stderr,"failure.\n"); } while(0)
