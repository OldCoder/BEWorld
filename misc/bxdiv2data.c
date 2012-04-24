// bxdiv2data.c - Decompressor for "data2bxdiv" output
// License:  BSD-style (for this file only)
// Revision: 101009

//--------------------------------------------------------------------
// Documentation.

// 1. This program may be used to decompress output produced previous-
// ly by "data2bxdiv". Warning: The "bxdiv" format is highly lossy, so
// the output will only be useful in a limited number of contexts.

// 2. To compile this program under Linux:
//
//    cc -o bxdiv2data bxdiv2data.c

// 3. For usage instructions, see the usage-text section.

// 4. For more information about the "bxdiv" format, see the "beworld"
// source code.

//--------------------------------------------------------------------
// Global setup.

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define FMTREV  "101009"        // Six-digit format  revision string
#define PROGREV "101009"        // Six-digit program revision string
#define MAGIC   "bxdiv"         // File-type string

#define ZERO    0               // zero
#define ONE     1               // one

#define FALSE   0               // Boolean false
#define TRUE    1               // Boolean true

//--------------------------------------------------------------------
// Main program.

int main (int argc, char **argv)
{
    char *ifname;               // Input-file name
    FILE *ifp;                  // Input-stream pointer
    char *cp;                   // Scratch
    char xbuf [128];            // Input buffer

    int b;                      // Output byte
    int c;                      // Input  byte
    int d;                      // Divisor
    int i;                      // Counter

//--------------------------------------------------------------------
// Handle usage errors.

    if ((argc != 2) || isatty (fileno (stdout)))
    {
puts ("");
printf ("data2bxdiv %s - Decompressor for bxdiv2data output\n",
    PROGREV);
puts ("");
puts ("Usage: bxdiv2data INPUT > OUTPUT\n");
puts ("INPUT      = Input  -file name");
puts ("OUTPUT     = Output -file name");
puts ("");
puts ("If INPUT was produced by data2bxdiv, this program decompress-");
puts ("decompresses the  data that  it contains and  puts the output");
puts ("in OUTPUT.  Warning:  The bxdiv format is highly lossy and so");
puts ("the output  will only be  useful in a  limited number of con-");
puts ("texts.");
puts ("");
puts ("For an explanation of the bxdiv data format,  see the BEWorld");
puts ("source code.");
puts ("");

exit (ONE);
    }

//--------------------------------------------------------------------
// Open the input file.

    if ((ifp = fopen (cp = argv [1], "r")) == NULL)
    {
        fprintf (stderr, "Error: Can't open input file %s\n", 
cp);
        exit (ONE);
    }

//--------------------------------------------------------------------
// Process the input-file header.

    for (i = ZERO; i < 12; i++)
    {
        if ((c = getc (ifp)) == EOF)
        {
            fprintf (stderr, "%s\n", "Error: Invalid file");
            exit (ONE);
        }

        xbuf [i] = c;
    }

    xbuf [11] = '\0';
    d         = c;

//--------------------------------------------------------------------
// Main loop.

    while ((c = getc (ifp)) != EOF)
    {
        for (i = ZERO; i < d; i++)
        {
            putchar (c);
        }
    }

//--------------------------------------------------------------------
// Wrap it up.

    return (ZERO);
}
