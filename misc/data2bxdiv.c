// data2bxdiv.c - Simple lossy compression tool
// License:  BSD-style (for this file only)
// Revision: 101009

//--------------------------------------------------------------------
// Documentation.

// 1. This is a highly-lossy data compression tool. It's only suitable
// for use with 8-bit sound data and other types of data that can tol-
// erate highly-lossy compression.

// 2. To compile this program under Linux:
//
//    cc -o data2bxdiv data2bxdiv.c

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

    int b;                      // Output byte
    int c;                      // Input  byte
    int d;                      // Divisor
    int i;                      // Counter

//--------------------------------------------------------------------
// Handle usage errors.

    if ((argc != 3) || isatty (fileno (stdout)))
    {
puts ("");
printf ("data2bxdiv %s - Simple lossy compression tool\n", PROGREV);
puts ("");
puts ("Usage: data2bxdiv MULTIPLIER INPUT > OUTPUT\n");
puts ("MULTIPLIER = An integer from 2 to 15");
puts ("INPUT      = Input  -file name");
puts ("OUTPUT     = Output -file name");
puts ("");
puts ("This is a highly-lossy data compression tool. It's only suit-");
puts ("able for use with 8-bit sound  data and  other types  of data");
puts ("that can tolerate highly-lossy compression.");
puts ("");
puts ("For an explanation of the bxdiv data format,  see the BEWorld");
puts ("source code.");
puts ("");

exit (ONE);
    }

//--------------------------------------------------------------------
// Get the divisor and check it.

    if (((d = atoi (cp = argv [ONE])) < ONE) || (d > 15))
    {
        fprintf (stderr, "Error: Invalid divisor setting %s\n", cp);
        exit (ONE);
    }

//--------------------------------------------------------------------
// Open the input file.

    if ((ifp = fopen (cp = argv [2], "r")) == NULL)
    {
        fprintf (stderr, "Error: Can't open input file %s\n", cp);
        exit (ONE);
    }

//--------------------------------------------------------------------
// Generate output header.

    printf ("%s%s", MAGIC, FMTREV);
    putchar (d);

//--------------------------------------------------------------------
// Main loop.

    while (TRUE)
    {
        double bsum = 0.0;

        for (i = ZERO; i < d; i++)
        {
            if ((c = getc (ifp)) == EOF) break;
            bsum += (c & 0xFF);
        }

        if (i > ZERO)
        {
            b =  (int) ((bsum / i) + 0.5);
            b &= 0xFF;
            putchar (b);
        }

        if (c == EOF) break;
    }

//--------------------------------------------------------------------
// Wrap it up.

    return (ZERO);
}
