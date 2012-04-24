#!/usr/bin/env brick-tcl
# beworld - Prototype Brick Engine game
# License:  Creative Commons Attribution-NonCommercial-ShareAlike 3.0
# Revision: 120422

#---------------------------------------------------------------------
# Documentation: External files.

# For changelog see external file CHANGELOG
# For license   see external file LICENSE

#---------------------------------------------------------------------
# Documentation: Terminology.

# This isn't an object-oriented program in the standard sense,  but it
# uses objects and classes in a manner of speaking.

# A object class is  something for which  two routines "new_NAME"  and
# "run_NAME" exist (NAME being the name of the class). "new_NAME" cre-
# ates an instance of  the class.  "run_NAME" is  called  subsequently
# (and repeatedly) for each instance to initiate and/or direct actions
# by the instance.

# An object-class parameter is any  program parameter that's tied to a
# particular object class.

#---------------------------------------------------------------------
# Documentation: Object-class parameters.

# 1. Most object-class parameters may be set either as global defaults
# or on a per-world basis.

# 2. Global defaults are defined as follows:
#
#     set gdata(Default_CLASS_PARAM)  ...
#
# where CLASS is an object-class  name  (ocbullet,  ocscroll,  octree,
# etc.) and PARAM is a parameter name (divmin, frequency, etc.).

# 3. To override a given parameter  for a given world, add a statement
# similar to the following at the appropriate location in  the world's
# definition section:
#
#     set gdata($World.CLASS_PARAM)   ...
#
# where, again, CLASS is an object-class name and PARAM is a parameter
# name.

# For example,  there are  no cows in  Caspak.  For cows,  the object-
# class name "occow" is used.  Therefore, to keep cows out of  Caspak,
# the following statement has been added to Caspak's world-definitions
# section:
#
#     set gdata($World.occow_maxnum)   0

# 4. Some of the most frequently used object-class parameters are dis-
# cussed in the following sections.

#---------------------------------------------------------------------
# Documentation: Object-creation modes.

# From  an  object-creation perspective, object classes are classified
# as "periodic", "upfront", or "unique".

# For "periodic" classes,  the  associated  "new_" routines are called
# directly  by the main loop in "main_routine".  The routines may also
# be called elsewhere.

# For "upfront"  classes,  the  associated  "new_" routines are called
# indirectly by "make_world"  when  a world is created;  specifically,
# through the loop in "make_world" that  invokes  "make_upfront".  The
# routines may also be called elsewhere.

# For "unique" objects,  the  associated  "new_" routines  are  called
# neither by the main loop in "main_routine" nor by the "make_upfront"
# loop in "make_world".

#---------------------------------------------------------------------
# Documentation: More about "periodic" classes.

# If an object class falls into the  "periodic" category,  the associ-
# ated "new_" routine adds new  instances  periodically  (on a  random
# basis).  Additionally,  when a world is  created,  "make_world"  may
# preload a specified number of instances.

# New instances of "periodic" classes may also be  created due to spe-
# cial-case operations.

# There's  a per-class  parameter  for  classes  of  this  type  named
# "preload".  This parameter may be set for a  given class on a global
# and/or per-world  basis. It specifies the number of instances of the
# class which should be added initially when a world is created.

# There's also a  per-class parameter named "frequency" which controls
# the rate at which  new instances are added by a given class's "new_"
# routine.  This parameter  should  be a  real number from  0.00000 to
# 0.10000.  Use  smaller  numbers  to decrease the  creation rate  and
# larger numbers to increase it.

# Additionally,  there's a  per-class parameter  named  "maxnum" which
# limits the  maximum number of  instances  per world.  Note: "maxnum"
# takes precedence over "preload".

# For some periodic-generation routines,  setting the following global
# flag to one will override "frequency" once  (after that, the flag is
# reset):
#
#     gdata(force_create)
#
# Note: This flag overrides "frequency", but not "maxnum".

# "periodic" class names should be added to the following list:
#
#     list_classes_periodic

# Examples of "periodic" classes include:
#
#     occow, ockarkinos, ocmedical

#---------------------------------------------------------------------
# Documentation: More about "upfront" classes.

# If an object class falls  into the "upfront" category,  "make_world"
# adds zero or more instances to  a  world  when the world is created.
# Subsequently, new instances are added  only as the result of special
# circumstances.

# For this category, the per-class parameters  "minnum"  and  "maxnum"
# specify the minimum and  maximum number of instances per world,  re-
# spectively.

# To disable a given "upfront" class for a  given world,  set "maxnum"
# to zero for the class in that world. To make the number of instances
# a fixed  value,  set  both  "minnum" and "maxnum"  to  the  value in
# question.

# To let the program choose the number of instances from a range,  set
# "minnum" to the  first  number in the range and set  "maxnum" to the
# last number.

# "upfront" class names should be added to the following list:
#
#     list_classes_upfront

# Examples of "upfront" classes include:
#
#     ocintra, ocscroll, octree

#---------------------------------------------------------------------
# Documentation: More about special-case creation.

# Object classes that fall into the special-case creation category in-
# clude:
#
#     ocbullet - bullets
#     ocinter  - inter-world portals
#     ocplayer - player
#
# These are neither "periodic" nor "upfront" classes.

#---------------------------------------------------------------------
# Documentation: Bullets.

# Class name: ocbullet
# Sprite prototype(s): ocbullet
# Creation mode: Special

# "maxnum"  shouldn't be  set  much  higher than 30 for the "ocbullet"
# class.  If it's set too high, problems may occur in Limbo or similar
# special-case levels.

#---------------------------------------------------------------------
# Documentation: Object speed.

# For  mobile objects,  "divmin" and "divmax"  usually  affect  object
# speed.  These two parameters set minimum and maximum  "speed  divis-
# ors", respectively.

# Smaller speed divisors result in faster sprites.  Larger speed divi-
# sors reduce sprite speed.  Values of  about  3 to 5  produce average
# speeds. Presently, the minimum value supported is 1. This value pro-
# duces the maximum speed.

#---------------------------------------------------------------------
# Documentation: Inter-world portals.

# Class name: ocinter
# Sprite prototype(s): forward, reverse
# Creation mode: Special

# 1. There's  two  types of  inter-world  portals:  "forward" and "re-
# verse".  These are similar  to Nethack-style "down" and "up" stairs,
# respectively,  and games derived from  this one may use them  in the
# same way.  However,  this interpretation  is an  oversimplification;
# "forward" and/or "reverse" portals  may lead to  either  "higher" or
# "lower" levels, or to different worlds located on the same level.

# Each  "forward" portal is associated with a  destination  world name
# and a "reverse" portal located in the specified world.

# Each  "reverse" portal is associated with a  destination  world name
# and a "forward" portal located in the specified world.

# When  a world is  created (by "make_world"),  a sprite is  added for
# each  "forward" portal  that  it contains.  No "reverse" portals are
# created, initially.

# When the player enters  a  "forward" portal, the associated destina-
# tion  world is created  (unless  it  already exists)  and  he/she is
# transported to the world  in question.  The transport process adds a
# "reverse" portal  to the  destination world that is connected to the
# "forward" portal  used,  unless this was done previously (as part of
# an earlier transport).

# When the player arrives at a destination portal, the portal is lock-
# ed until he/she steps  off of it.  This prevents  infinite transport
# loops.

# 2. Each  world-definition  section  includes a block  similar to the
# following. The block defines a "to_worlds" list:
#
#     set gdata($World.to_worlds) [list \
#         $gdata(WorldElysian) \
#         $gdata(WorldEternia) \
#     ]

# To define the "forward" portals associated  with a given world,  set
# the  contents of  "to_worlds" to the names of  the  worlds  that the
# world in question connects to. Use $gdata(World...) strings as shown
# here.

# If a  given world  doesn't have any  "forward" connections to  other
# worlds, use:
#
#     set gdata($World.to_worlds) [list]

# 3. There's  no need to define  "reverse" portals  (or  any way to do
# so explicitly).  The program creates "reverse" portals automatically
# as necessary.

#---------------------------------------------------------------------
# Documentation: Intra-world portals.

# Class name: ocintra
# Sprite prototype(s): ocintra
# Creation mode: upfront

# The number of intra-world portals in a given world  may be set using
# either global defaults or per-world values.  The relevant parameters
# are:
#
#     ocintra_minnum = Minimum number of intra-world portals
#     ocintra_maxnum = Maximum number of intra-world portals

# For an explanation of how parameters such as these are set (globally
# or per world), see the preceding sections.

#---------------------------------------------------------------------
# Documentation: Scrolls.

# Class name: ocscroll
# Sprite prototype(s): ocscroll
# Creation mode: upfront

# 1. The number of ocscrolls in a given world  may be set using either
# global defaults or per-world values. The relevant parameters are:
#
#     ocscroll_minnum = Minimum number of ocscrolls
#     ocscroll_maxnum = Maximum number of ocscrolls

# For an explanation of how parameters such as these are set (globally
# or per world), see the preceding sections.

# 2. To change the contents of the ocscrolls,  replace the contents of
# "wisdom_lz77_base64". The item  in question should contain a base64-
# encoded  text version  of an  LZ77-compressed  copy  of a "fortunes"
# file. The "fortunes" file should be structured as follows:
#
#     Text for a fortune (may be multi-line)
#     %%
#     Text for another fortune
#     %%
#
# etc.  In other words, the file should contain  one or more blocks of
# text, and each block should end with a line that contains just "%%".
# Lines should  be  no longer than  36 characters,  excluding  newline
# characters.

# Note: To LZ77-compress the file, use the "lzbetool" program mention-
# ed previously.

#---------------------------------------------------------------------
# Documentation: Trees.

# Class name: octree
# Sprite prototype(s): octree
# Creation mode: upfront

# 1. The number of octrees in a given world  may  be set  using either
# global defaults or per-world values. The relevant parameters are:
#
#     octree_minnum = Minimum number of octrees
#     octree_maxnum = Maximum number of octrees

# For an explanation of how parameters such as these are set (globally
# or per world), see the preceding sections.

# 2. A player can hide  behind an octree,  but only  once per  octree.
# Leaving the octree or firing a weapon breaks cover.

# Assume:
#
#     # $lv          = Current world name
#     # $octree_id   = Sprite ID for an octree   in world $lv
#     # $ocplayer_id = Sprite ID for an ocplayer in world $lv
#
# If the following variable exists,  it contains the  sprite ID for an
# octree that the given ocplayer is presently hiding behind:
#
#     gdata($lv,$ocplayer_id.octreehide_id)
#
# If the following variable exists, the given ocplayer has used (or is
# using) the given octree for hiding:
#
#     gdata($lv,$octree_id,$ocplayer_id.octreehide_flag)

#---------------------------------------------------------------------
# Documentation: General tips.

# Destroying an object:  If instances of a  given object class  can be
# destroyed by an ocbullet or other means,  make calls similar  to the
# following in the code where this occurs:
#
#     set objclass ..         ; # Set to object-class name
#     set id ...              ; # Set to sprite I.D.
#     destroy_sprite $objclass $id

# Collisions:  If a "run_" routine checks for collisions  between  ob-
# jects, and does something when a collision occurs, but  doesn't  de-
# stroy or move either of the objects involved in a collision,  a col-
# lision lock may be required.  The  collision lock will be a variable
# used to prevent repeated processing of the same collision. For exam-
# ples of possible approaches,  see  the source code for  "run_octree"
# and/or "run_occow".

#---------------------------------------------------------------------
# Documentation: bxdiv data format.

# This program  supports (and uses)  a simple  data compression format
# that we'll call "bxdiv".

# A "bxdiv"  data block consists  of a  sequence of  8-bit bytes.  The
# block  consists of a  header  followed  by a segment  that  contains
# compressed data.

# The header starts with "bxdiv" followed by six decimal digits, which
# specify the format revision.  Presently,  the only  supported format
# revision is "101009".

# For format "101009",  the header  includes  one additional byte. The
# byte contains an integer from zero to 255.  This is a "divisor".  If
# the  divisor is  zero or one,  the data represented is  equal to the
# data segment;  i.e.,  there is  no translation.  If  the  divisor is
# greater than one, the data represented  may be  decoded  as follows:
# Take each byte in the data segment  and replace it with  N copies of
# the same byte, where N is the divisor.

#---------------------------------------------------------------------
# Documentation: Raw-sound operations: Simple hex-data version.

# If you're got a  copy of Linux that has "sox",  you can  prepare and
# use raw-sound data as follows:
#
#     (a) Start with a WAV file.  We'll assume that the  WAV-file name
#         is "foo.wav".
#
#     (b) Execute a Linux command similar to this:
#
#         sox -V foo.wav -t ub -r 44100 -c 1 foo.ub
#
#         If the volume needs to be adjusted, add a switch  similar to
#         -v 0.5 (lower-case "v") after "-V". Use  lower  numbers  for
#         lower volume and higher numbers for higher volume.
#
#     (c) Produce a  hex dump of "foo.ub"  (with exactly two hex char-
#         acters per byte). To do so under Linux, use commands similar
#         to this:
#
#         hexdump -v -e '34/1 "%02x"' -e '"\n"' foo.ub > foo.hex
#
#     (d) To load the hex dump into a Tcl variable, use Tcl code simi-
#         lar to this:
#
#         set    foo_hex ""
#         append foo_hex \
#         67707f7a7677787f7a82887d7f7b787a77 \
#         86827a848a8c8b8d8a888381878a8b8083 \
#         67707f7a7677787f7
#
#     (e) To  prepare a  Brick Engine-level  version  of  the original
#         sound, use Tcl code similar to this:
#
#         set foo_bin   [binary format H*    $foo_hex]
#         set foo_sound [br::sound load-raw  $foo_bin]
#         unset foo_bin foo_hex
#
#     (f) To play the sound, use Tcl code similar to this:
#
#         br::sound play $foo_sound

# Note: Even if you run "sox" under Linux,  the output should work un-
# der both Windows and Linux.

#---------------------------------------------------------------------
# Documentation: Raw-sound operations: base64-data version.

# If you'd like to reduce the size of inline  sound data, you can sub-
# stitute the following procedure for the  simple procedure  described
# in the previous section:
#
#     (a) Start with a WAV file.  We'll assume that the  WAV-file name
#         is "foo.wav".
#
#     (b) Execute a Linux command similar to this:
#
#         sox -V foo.wav -t ub -r 44100 -c 1 foo.ub
#
#         If the volume needs to be adjusted, add a switch  similar to
#         -v 0.5 (lower-case "v") after "-V". Use  lower  numbers  for
#         lower volume and higher numbers for higher volume.
#
#     (c) Produce a "base64" dump of "foo.ub".  To do so  under Linux,
#         use a command similar to this:
#
#         base64 --wrap=68 < foo.ub > foo.base64
#
#     (d) To load the "base64" dump into a Tcl variable,  use Tcl code
#         similar to this:
#
#         set    foo_base64 ""
#         append foo_base64 \
#         gH2Bh3x/lpSEkoJ+k4aHhoqFdnd9jnlvfn \
#         t5fn1ycX6FdGdwf3p2d3h/eoKIfX97eHp3 \
#         hoJ6hIqMi42KiIOBh==
#
#     (e) To  prepare a  Brick Engine-level  version  of  the original
#         sound, use Tcl code similar to this:
#
#         set foo_bin [base64_decode $foo_base64]
#         set foo_sound [br::sound load-raw $foo_bin]
#         unset foo_bin foo_base64
#
#         The routine called here (base64_decode) is  included in this
#         program.
#
#     (f) To play the sound, use Tcl code similar to this:
#
#         br::sound play $foo_sound

# Note: Even if you run "sox" under Linux,  the output should work un-
# der both Windows and Linux.

#---------------------------------------------------------------------
# Documentation: Raw-sound operations: LZ77-base64 version.

# If you'd like to reduce the size of inline sound data further, start
# with the  "base64" procedure described  in the  previous section and
# modify it as follows:
#
# Before producing the "base64" dump discussed in step (c),  LZ77-com-
# press the data.  To do so, use the "lzbetool" program mentioned pre-
# viously.
#
# Additionally, in step (e), replace:
#
#     set foo_bin [base64_decode $foo_base64]
# with:
#     set foo_bin [lz77_decode [base64_decode $foo_base64]]
# or:
#     set foo_bin [lz77_base64_decode $foo_base64]

# The routines called here are included in this program.

#---------------------------------------------------------------------
# Documentation: Raw-sound operations: bxdiv-LZ77-base64 version.

# To reduce the size of inline sound data yet further,  start with the
# with the "LZ77-base64" procedure described  in the  previous section
# and modify it as follows.  Important:  This should  only be done for
# sound effects that can tolerate highly-lossy compression.

# Before LZ77-compressing the data,  bxdiv-compress it.  Use a divisor
# setting of  somewhere from 2 to 10.  Lower divisors  will  result in
# better quality. Higher divisors will result in better compression.

# To bxdiv-compress data,  use the 'C' program  "data2bxdiv.c",  which
# should be available from the same place as this program.

# Additionally, in step (e),  replace the  "set foo_bin ..." statement
# with:
#     set foo_bin [bxdiv_lz77_base64_decode $foo_base64]

# The routine called here is included in this program.

#---------------------------------------------------------------------
# Program parameters: Brick API level.

# For Brick 5.2, set BRICKAPI to 5200.  For Brick 5.3,  use 5300.  For
# Brick 5.4 or above, use 5400.  Important: Older APIs  are  supported
# only for  testing purposes.  If BRICKAPI is  set to  less than 5400,
# some features will be  omitted  and  others will be only partly sup-
# ported.

set BRICKAPI 5400

#---------------------------------------------------------------------
# Documentation: Global variables.

# This documentation section is under construction.

# Important global variables include:
#
# gdata  = Array:  General global data
# layers = Array:  To be documented
# sdata  = Array:  Sprite information related to the current world
# lv     = Scalar: Current world name

#---------------------------------------------------------------------
# Program parameters: Basic colors.

set BLUE        "0000FF"
set DARKGREEN   "00AA00"
set DARKORANGE  "8B4500"
set DARKWOOD    "855E42"
set GREEN       "00FF00"
set RED         "FF0000"
set TOPAZ       "0198E1"
set WHITE       "FFFFFF"
set YELLOW      "CCCC00"

#---------------------------------------------------------------------
# Program parameters: Dimensions and graphics.

# GAME_WIDTH and GAME_HEIGHT  specify the width and height of the game
# display in pixels.  These parameters should be  set to  320 and 240,
# respectively.

set GAME_WIDTH  320
set GAME_HEIGHT 240

# To use  OpenGL, set UseOpenGL to 1.  To disable  this mode,  set this
# parameter to 0. For Brick 5.4 or above, the recommended setting is 0.
# For older Bricks, the recommended setting is 1.

# If OpenGL is used, the game won't work well with  some graphics chip-
# sets. However, for Bricks before 5.4, the alternate mode (OpenGL dis-
# abled) may also exhibit problems.  Ideally, Brick 5.4 or above should
# be used and OpenGL should be disabled.  Note  that this mode requires
# that a particular  "cmake" option be  used when  Brick is built.  For
# more information, see this program's changelog.

if { $BRICKAPI < 5400 } {
    set UseOpenGL 1
} else {
    set UseOpenGL 0
}

# DisplayWidth and  DisplayHeight specify the display width and height
# parameters passed to "br::display open".  The  recommended  settings
# are $GAME_WIDTH and $GAME_HEIGHT,  respectively,  except  for Bricks
# older than 5.4  running without  OpenGL.  In the  latter case, these
# settings should be doubled.

# DisplayScale specifies a  scale factor  (ignored  for  Bricks  older
# than 5.4 running without  OpenGL).  This parameter should be a small
# positive integer.  The  recommended setting is 1 for OpenGL mode and
# 2 for non-OpenGL mode.

# FullScreen specifies a full-screen mode flag (may be "on" or "off").
# The recommended setting is "on".

if { $UseOpenGL } {
    set DisplayWidth    $GAME_WIDTH
    set DisplayHeight   $GAME_HEIGHT
    set DisplayScale     1
    set FullScreen      on
} else {
    if { $BRICKAPI < 5400 } {
        set DisplayWidth    [expr $GAME_WIDTH  * 2]
        set DisplayHeight   [expr $GAME_HEIGHT * 2]
    } else {
        set DisplayWidth    $GAME_WIDTH
        set DisplayHeight   $GAME_HEIGHT
    }

    set DisplayScale     2
    set FullScreen      on
}

#---------------------------------------------------------------------
# Program parameters: Music.

# If you'd like to play background music,  set PlayMusic to 1;  other-
# wise, 0. The factory setting is 1.

# Background music is built into the program;  there's no need  for an
# external music file.

# If you'd like  to use the built-in music,  set MusicFile to internal
# (and set PlayMusic to 1 as well).  If  you'd like to use an external
# music file instead,  set MusicFile to a name (or pathname)  for  the
# file (and, again, set PlayMusic to 1). Note: In the latter case, any
# music-file type supported by the Brick Engine may be used.

# If you'd like to set music volume, set MusicVolume to a positive in-
# teger from  one to 100. Otherwise, set this parameter to a negative
# integer, The factory setting is 70.

set PlayMusic            1
set MusicFile     internal
set MusicVolume         70

#---------------------------------------------------------------------
# Program parameters: Frame and color formats.

# FRAFMTRGB and  FRAFMTTRA specify  Brick Engine  frame-type  strings.
# FRAFMTRGB may be used to create frames that contain only opaque pix-
# els and FRAFMTTRA may be used to create frames that may (or may not)
# contain non-opaque pixels.

# For Brick 5.2 or 5.3, both of  the "FRAFMT..." parameters should  be
# set to "rgb".  For Brick 5.4,  FRAFMTRGB should be set to "rgb"  and
# FRAFMTTRA should be set to "rgba".

# For Brick 5.2 or 5.3, frame color values are  six  hex  digits.  For
# Brick 5.4, frames of type $FRAFMTRGB work the same way but frames of
# type $FRAFMTTRA use an eight-hex digit format:  a six-hex  digit RGB
# value followed by a two-hex digit opacity value.

# Large frames  should be created using  the  $FRAFMTRGB type (and the
# associated color format) if possible.  This produces faster programs
# in Brick 5.4.

# NRDIGITS specifies the  number of hex  digits  in a  FRAFMTRGB color
# value (always 6).

# NCDIGITS specifies the  number of hex  digits  in a  FRAFMTTRA color
# value (6 for Brick 5.2 or 5.3 and 8 for Brick 5.4).

if { $BRICKAPI < 5400 } {
    set FRAFMTRGB   rgb
    set FRAFMTTRA   rgb
    set NCDIGITS    6
    set NRDIGITS    6
} else {
    set FRAFMTRGB   rgb
    set FRAFMTTRA   rgba
    set NCDIGITS    8
    set NRDIGITS    6
}

#---------------------------------------------------------------------
# Program parameters: Transparency.

# TRANSPARRGB specifies a  six-hex digit RGB value that will be mapped
# to transparency  when six-hex digit RGB values  in general are  con-
# verted to Brick Engine frame color values. The color associated with
# TRANSPARRGB should chosen so that it's  unlikely  to  conflict  with
# commonly-used colors. The factory setting is FF00FF.

# TRANSPARFRA  specifies a frame color value that  will  be treated as
# transparent.  For Brick 5.2 or 5.3,  this should be equal to $TRANS-
# PARRGB. For Brick 5.4,  this should be equal to $TRANSPARRGB follow-
# ed by the hex digits 00.

# For Brick 5.2 or 5.3,  the following  three  "CHROMA_..." parameters
# should be set:
#
#   CHROMA_R     Red   component of $TRANSPARRGB in decimal (0 to 255)
#   CHROMA_G     Green component of $TRANSPARRGB in decimal (0 to 255)
#   CHROMA_B     Blue  component of $TRANSPARRGB in decimal (0 to 255)

set TRANSPARRGB  FF00FF
set TRANSPARFRA  ${TRANSPARRGB}00

if { $BRICKAPI < 5400 } {
    set CHROMA_R     255
    set CHROMA_G       0
    set CHROMA_B     255
    set TRANSPARFRA  $TRANSPARRGB
}

#---------------------------------------------------------------------
# Program parameters: Object background colors.

# Future change:  These parameters should  eventually be  moved to the
# class level.

# Name                  Specifies background color for
# -------------------   ------------------------------
#   BG_KARKINOS         Karkinos
#   BG_MEDICAL          Medical kit
#   BG_PLAYER           Player
#   BG_PORTAL_FORWARD   Inter-world portal forward
#   BG_PORTAL_INTRA     Intra-world portal
#   BG_PORTAL_REVERSE   Inter-world portal reverse
#   BG_SCROLL           Scroll

set BG_KARKINOS         $TRANSPARRGB
set BG_MEDICAL          $TRANSPARRGB
set BG_PLAYER           $TRANSPARRGB
set BG_PORTAL_FORWARD   $YELLOW
set BG_PORTAL_INTRA     $TRANSPARRGB
set BG_PORTAL_REVERSE   $YELLOW
set BG_SCROLL           $TRANSPARRGB

#---------------------------------------------------------------------
# Program parameters: Object foreground colors.

# Future change:  These parameters should  eventually be  moved to the
# class level.

# Name                  Specifies foreground color for
# -------------------   ------------------------------
#   FG_KARKINOS         Karkinos
#   FG_MEDICAL          Medical kit
#   FG_PLAYER           Player
#   FG_PORTAL_FORWARD   Inter-world portal forward
#   FG_PORTAL_INTRA     Intra-world portal
#   FG_PORTAL_REVERSE   Inter-world portal reverse
#   FG_SCROLL           Scroll

set FG_KARKINOS         $RED
set FG_MEDICAL          $DARKGREEN
set FG_PLAYER           $BLUE
set FG_PORTAL_FORWARD   $DARKORANGE
set FG_PORTAL_INTRA     $TOPAZ
set FG_PORTAL_REVERSE   $DARKORANGE
set FG_SCROLL           $DARKWOOD

#---------------------------------------------------------------------
# Program parameters: Background tiles and layer.

# BGTileWidth specifies the width of a  background and/or info-display
# tile, in pixels. BGTileHeight is similar, but specifies height.  The
# factory settings for  these two parameters are 8 and 8,  respective-
# ly.

# For the time being, BGTileWidth and BGTileHeight shouldn't be chang-
# ed.  One or more routines  (including  "setup_background") still as-
# sume that the factory settings for the BGTile* parameters  are used.
# If the settings  are changed,  the routines in question will need to
# be modified.

# BGWidth specifies  the width of the background  and/or  info-display
# layer, in tiles. BGHeight is similar, but specifies height. Ideally,
# BGTileWidth times  BGWidth should be  equal to or a  divisor  of the
# "DisplayWidth" settings.  Additionally,  BGTileHeight times BGHeight
# should be  equal to or a  divisor of the  "DisplayHeight"  settings.
# The factory settings for BGTileWidth and BGTileHeight are 40 and 30,
# respectively.

set BGTileWidth      8
set BGTileHeight     8
set BGWidth         40
set BGHeight        30

#---------------------------------------------------------------------
# Program parameters: Random-map mode.

# To enable  random maps,  set RandomMapEnable to 1.  To disable them,
# specify 0 instead. The factory setting is 1.

# Note:  For special-case worlds,  predefined maps may be used regard-
# less of the RandomMapEnable setting.

set RandomMapEnable  1

#---------------------------------------------------------------------
# Program parameters: Random-map dimensions.

# There are four random-map dimension parameters:
#
#   Name                 Factory   Specifies
#                        Setting
#   ------------------   -------   -----------------------------
#   RandomMapWidthMin    30        Minimum map width  (in cells)
#   RandomMapWidthMax    55        Maximum map width  (in cells)
#   RandomMapHeightMin   25        Minimum map height (in cells)
#   RandomMapHeightMax   40        Maximum map height (in cells)

set RandomMapWidthMin    30
set RandomMapWidthMax    55
set RandomMapHeightMin   25
set RandomMapHeightMax   40

#---------------------------------------------------------------------
# Program parameters: Random-map tuning values.

# The following four parameters are  tuning values used during random-
# map generation.

# RandomMapFollow should be an integer from 1 to 500. The factory set-
# ting is 150.

# RandomMapPoints should be an integer or  real number  from 0 to 150.
# The factory setting is 75.

# RandomMapMinSep1 and RandomMapMinSep2 should be  integers from  4 to
# 10. The factory settings are 5 and 4, respectively.

set RandomMapFollow     150
set RandomMapPoints      75
set RandomMapMinSep1      5
set RandomMapMinSep2      4

#---------------------------------------------------------------------
# Program parameters: World names.

# Every world needs a unique name. World names are used as array keys,
# so they need  to be spelled exactly  the same  way  everywhere  that
# they're used. Therefore,  they're  defined here as "gdata(World...)"
# entries. This approach makes it possible for Tcl to detect misspell-
# ings.

# World names  should  be short  (they need to fit on the  game's info
# display). They may use most printable characters and spaces,  though
# not spaces at the beginning or end or  multiple  consecutive spaces.
# Dollar signs and double quotes are prohibited.

set gdata(WorldMain)            "Qlaviql"
set gdata(WorldCaspak)          "Caspak"
set gdata(WorldElysian)         "Elysian Fields"
set gdata(WorldEndOfAllSongs)   "End of All Songs"
set gdata(WorldEternia)         "Eternia"
set gdata(WorldHeaven)          "Heaven"
set gdata(WorldLimbo)           "Limbo"
set gdata(WorldMilk)            "Milk and Honey"

#---------------------------------------------------------------------
# Program parameters: Keyboard definitions.

# Each "Key..._Input"  parameter  should specify a Brick input-channel
# number (0 through 7). These parameters don't need to be unique.

# Each "Key..._Button" parameter  should specify a Brick button number
# that's unique (and unused) for the associated input channel.

# Each "Key..._SDLCode" parameter should specify a standard "SDLK_..."
# keycode number.

# This program directs presses of a  given key to the associated Brick
# input-channel and button combination.

set KeyH_Input              1   ; # h     -key channel
set KeyH_Button            17   ; # h     -key button
set KeyH_SDLCode          104   ; # h     -key SDL code

set KeyI_Input              1   ; # i     -key channel
set KeyI_Button            18   ; # i     -key button
set KeyI_SDLCode          105   ; # i     -key SDL code

set KeyQ_Input              0   ; # q     -key channel
set KeyQ_Button            19   ; # q     -key button
set KeyQ_SDLCode          113   ; # q     -key SDL code

set KeySpace_Input          0   ; # space -key channel
set KeySpace_Button        18   ; # space -key button
set KeySpace_SDLCode       32   ; # space -key SDL code

#---------------------------------------------------------------------
# Program parameters: Misc.

# Normally, DebugLevel should be set to 0. If this parameter is set to
# a positive integer, the program will produce debugging output.  Lar-
# ger settings will generally result in more output.

# FPS specifies the frame rate that the program aims for. This parame-
# ter is expressed in frames per second.  The  factory  setting is 50.
# Note: If you change this, you may need to modify  "FPS divisor" set-
# tings elsewhere.

set DebugLevel    0
set FPS          50

# InfoDisplayFieldWidth  is a  field width  that's  used  to construct
# idsfmt, as shown here. The factory setting is 36. idsfmt is a format
# string that's used for lines in the program's info display.

set InfoDisplayFieldWidth  36
set idsfmt "s"
set idsfmt " %-$InfoDisplayFieldWidth$idsfmt"

# MaxGodTime specifies the  maximum  amount of time  (in seconds) that
# the player spends  in "God" mode  after receiving a  "God" power-up.
# The factory setting is 120.

# NameAndRevision specifies a short string that identifies the program
# name and revision.  This string  should be  less than  21 characters
# long. The factory settings is "BEWorld" plus a space and a six-digit
# revision number.

set MaxGodTime        120
set NameAndRevision   "BEWorld 120422"

# WorldKeyStart  is used to construct  "gdata" keys that include  data
# related to various worlds.  Any reasonably unique text string should
# work.  The factory setting  is "WORLD_PARAM".  For more information,
# see any world-definition section.

set WorldKeyStart     "WORLD_PARAM"

#---------------------------------------------------------------------

# Routine:    dmproc
# Purpose:    Extended version of "dmproc"
# Arguments:  (special case, see below)

#---------------------------------------------------------------------

# "dmproc" is an extended version of  "proc" that adds some  debugging
# features.

# "dmproc" takes  the same  arguments  as "proc",  with  one addition:
# There's a new first argument named "msglev",  which must be an inte-
# ger.

# "dmproc" assumes that a global variable named  DebugLevel is defined
# and contains an integer.

# If  $DebugLevel is  greater  than  or equal to  one at compile time,
# "dmproc" prints a single-line  message  of  the form  "define NAME",
# where NAME is the name of the routine that's being defined.

# "dmproc" also makes some changes to the routine in question:
#
#     (a) Define a local variable named rtn that contains  the name of
#         the routine.
#
#     (b) If $DebugLevel is greater than or equal to $msglev  when the
#         routine is called, print the name of the routine.
#
#     (c) Define a local variable named  IE that contains an internal-
#         error message prefix string. The string includes the name of
#         the routine.

#---------------------------------------------------------------------

proc dmproc { msglev pname arglist body } {
    global DebugLevel
    if  { $DebugLevel >= 1 } { puts "define $pname" }

    set    newcode ""
    append newcode "set rtn $pname\n";
    append newcode "global DebugLevel\n";
    append newcode {if { $DebugLevel >= MSGLEV } { puts $rtn }}
    append newcode "\n"
    append newcode {set IE "$rtn: panic"}
    append newcode "\n"

    regsub -all {MSGLEV}  $newcode $msglev newcode
    proc $pname $arglist "$newcode$body"
}

#---------------------------------------------------------------------

# Routine:    xproc
# Purpose:    Extended version of "proc"
# Arguments:  (special case, see below)

# "xproc" is an  extended version of "proc" that supports pass-by-ref-
# erence.  You can use it the  same way as "proc",  but  any  argument
# names that  are prefixed with "&" are automatically passed by refer-
# ence.

# This routine is apparently by  one or more of the  following:  Keith
# Vetter,  Donal Fellows, Andreas Leitgeb.  It's believed to be redis-
# tributable.

# Original web-page URL (valid as of 2010):
#
#     http://wiki.tcl.tk/4535

#---------------------------------------------------------------------

proc xproc { pname arglist body } {
    set newcode ""
    foreach arg $arglist {
        set arg [lindex $arg 0]
        if { [string match "&*" $arg] } {
            set bare [string range $arg 1 end]
            append newcode \
                "upvar 1 \[set [list $arg]\] [list $bare]\n"
        }}
    proc $pname $arglist "$newcode#original body follows:\n$body"
}

#---------------------------------------------------------------------

# Routine:    lrandom
# Purpose:    Returns a random element from a list
# Arguments:  xlist = A Tcl list

#---------------------------------------------------------------------

dmproc 3 lrandom { xlist } {
    return [lindex $xlist [expr { int (rand() * [llength $xlist]) }]]
}

#---------------------------------------------------------------------

# Routine:    set_class_defaults_barnyard
# Purpose:    Set class defaults based on barnyard prototype
# Arguments:  objclass = Object-class name

#---------------------------------------------------------------------

# This routine sets the  class defaults for the specified class to val-
# ues that may be suitable for something similar to an occow.  The cal-
# ler may change individual defaults subsequently to fine-tune the  re-
# sults.  Additionally,  defaults may be overridden on a per-world bas-
# is.

# Presently,  the  following defaults are  set  (using the values shown
# here):

# Parameter    Use                                        Factory value
# ----------   ---------------------------------------    -------------
# divmax       Maximum speed divisor                          5
# divmin       Minimum speed divisor                          4
# dropshadow   Flag: Add drop shadow                          1
# frequency    Creation frequency                             0.00500
# maxnum       Maximum no. that can exist in one world        1
# minnum       Minimum no. that can exist in one world        1
# preload      Number of instances to preload                 1
# scalemin     Minimum scale factor (may be a real)           1.00
# scalemax     Maximum scale factor (may be a real)           2.00
# shoot_can    Flag: Can shoot one of these                   1
# shoot_effect Effect on object's health per ocbullet        -1
# shoot_score  Score change if destroyed by shooting          0
# smartmax     Maximum percentage that are smart             95
# smartmin     Minimum percentage that are smart             95
# zhint        Render-order hint                              2

#---------------------------------------------------------------------

dmproc 3 set_class_defaults_barnyard { objclass } {
    global gdata

    set gdata(Default_${objclass}_divmax)            5
    set gdata(Default_${objclass}_divmin)            4
    set gdata(Default_${objclass}_dropshadow)        1
    set gdata(Default_${objclass}_frequency)         0.00500
    set gdata(Default_${objclass}_maxnum)            1
    set gdata(Default_${objclass}_minnum)            1
    set gdata(Default_${objclass}_preload)           1
    set gdata(Default_${objclass}_scalemin)          1.00
    set gdata(Default_${objclass}_scalemax)          2.00
    set gdata(Default_${objclass}_shoot_can)         1
    set gdata(Default_${objclass}_shoot_effect)     -1
    set gdata(Default_${objclass}_shoot_score)       0
    set gdata(Default_${objclass}_smartmax)         95
    set gdata(Default_${objclass}_smartmin)         95
    set gdata(Default_${objclass}_zhint)             2
}

#---------------------------------------------------------------------
# Class parameters: Defaults for ocbullet class.

# Defaults may be overridden on a per-world basis.

# Parameter    Purpose                                   Factory value
# ----------   ---------------------------------------   -------------
# divmax       Maximum speed divisor                        1
# divmin       Minimum speed divisor                        1
# maxnum       Maximum no. that can exist in one world     20
# minnum       Minimum no. that can exist in one world      0

set gdata(Default_ocbullet_divmax)    1
set gdata(Default_ocbullet_divmin)    1
set gdata(Default_ocbullet_maxnum)   20
set gdata(Default_ocbullet_minnum)    0

#---------------------------------------------------------------------
# Class parameters: Defaults for occar class.

# This class starts with the "barnyard" prototype  discussed previous-
# ly and makes some adjustments.  Defaults may be overridden on a per-
# world basis.

set_class_defaults_barnyard occar

set gdata(Default_occar_minnum)     0
set gdata(Default_occar_maxnum)     0
set gdata(Default_occar_preload)    0
set gdata(Default_occar_scalemin)   1.00
set gdata(Default_occar_scalemax)   1.00

                              ; # List of possible names
set gdata(Default_occar_name) [list \
    Chitty-Chitty  Herbie  KARR  KITT
]

#---------------------------------------------------------------------
# Class parameters: Defaults for occow class.

# This class starts with the "barnyard" prototype discussed previously
# and makes some adjustments.  Defaults  may be  overridden on  a per-
# world basis.

set_class_defaults_barnyard occow

set gdata(Default_occow_scalemin)   2.00
set gdata(Default_occow_scalemax)   2.00

                              ; # List of possible names
set gdata(Default_occow_name) [list \
    Bessie   Buttercup  Clarabelle  Daisy  Kalikau  Latavao \
    Palauni  Tangaloa \
]

#---------------------------------------------------------------------
# Class parameters: Defaults for occross class.

# This class starts with the "barnyard" prototype discussed previously
# and makes some adjustments.  Defaults may  be  overridden on  a per-
# world basis.

set_class_defaults_barnyard occross

set gdata(Default_occross_frequency)     0
set gdata(Default_occross_maxnum)        0
set gdata(Default_occross_minnum)        0
set gdata(Default_occross_preload)       0
set gdata(Default_occross_scalemin)      2
set gdata(Default_occross_scalemax)      2
set gdata(Default_occross_shoot_can)     0

#---------------------------------------------------------------------
# Class parameters: Defaults for ocdog class.

# This class starts with the "barnyard" prototype  discussed previous-
# ly and makes some adjustments.  Defaults may be overridden on a per-
# world basis.

set_class_defaults_barnyard ocdog
set gdata(Default_ocdog_scalemax)   1.00

                              ; # List of possible names
set gdata(Default_ocdog_name) [list \
    Cerebus Lassie Rin-Tin-Tin Rover Spot
]

#---------------------------------------------------------------------
# Class parameters: Defaults for ocflames class.

# "ocflames" is a special case.  This class is  only  instantiated for
# one world, only once there, it's placed at a fixed location,  and it
# behaves more like an environment than  an  object  (so, for example,
# "nobounce" needs to be non-zero).

# Defaults may be overridden on a per-world basis.

# Parameter    Use                                       Factory value
# ----------   ---------------------------------------   -------------
# dropshadow   Flag: Add drop shadow                         0
# forceposn    Flag: Place at a specified position           1
# frequency    Creation frequency                            0
# heffect      Effect on player's health per attack         -1
# maxnum       Maximum no. that can exist in one world       0
# minnum       Minimum no. that can exist in one world       0
# nobounce     Flag: Suppress positioning bounces            1
# preload      Number of instances to preload                0
# scalemin     Minimum scale factor (may be a real)          3.00
# scalemax     Maximum scale factor (may be a real)          3.00
# shoot_can    Flag: Can shoot one of these                  0
# xpos         X-position (in pixels)                        8
# ypos         Y-position (in pixels)                        8
# zhint        Render-order hint                             0

set gdata(Default_ocflames_dropshadow)   0
set gdata(Default_ocflames_forceposn)    1
set gdata(Default_ocflames_frequency)    0
set gdata(Default_ocflames_heffect)     -1
set gdata(Default_ocflames_maxnum)       0
set gdata(Default_ocflames_minnum)       0
set gdata(Default_ocflames_nobounce)     1
set gdata(Default_ocflames_preload)      0
set gdata(Default_ocflames_scalemin)     3.0
set gdata(Default_ocflames_scalemax)     3.0
set gdata(Default_ocflames_shoot_can)    0
set gdata(Default_ocflames_xpos)         8
set gdata(Default_ocflames_ypos)         8
set gdata(Default_ocflames_zhint)        0

#---------------------------------------------------------------------
# Class parameters: Defaults for ocinter class.

# Presently, there are none.

#---------------------------------------------------------------------
# Class parameters: Defaults for ocintra class.

# Presently, there are none.

#---------------------------------------------------------------------
# Class parameters: Defaults for ockarkinos class.

# Defaults may be overridden on a per-world basis.

# Parameter    Use                                       Factory value
# ----------   ---------------------------------------   -------------
# divmax       Maximum speed divisor                         5
# divmin       Minimum speed divisor                         2
# dropshadow   Flag: Add drop shadow                         1
# frequency    Creation frequency                            0.00400
# heffect      Effect on player's health per attack         -1
# maxnum       Maximum no. that can exist in one world      20
# minnum       Minimum no. that can exist in one world       0
# preload      Number of instances to preload                0
# shoot_can    Flag: Can shoot one of these                  1
# shoot_effect Effect on object's health per ocbullet       -1
# shoot_score  Score change if destroyed by shooting         1
# smartmax     Maximum percentage that are smart            95
# smartmin     Minimum percentage that are smart            95
# zhint        Render-order hint                             1
# name         List of possible names                    (various)

set gdata(Default_ockarkinos_divmax)             5
set gdata(Default_ockarkinos_divmin)             2
set gdata(Default_ockarkinos_dropshadow)         1
set gdata(Default_ockarkinos_frequency)          0.00400
set gdata(Default_ockarkinos_heffect)           -1
set gdata(Default_ockarkinos_maxnum)            20
set gdata(Default_ockarkinos_minnum)             0
set gdata(Default_ockarkinos_preload)            0
set gdata(Default_ockarkinos_shoot_can)          1
set gdata(Default_ockarkinos_shoot_effect)      -1
set gdata(Default_ockarkinos_shoot_score)        1
set gdata(Default_ockarkinos_smartmax)          95
set gdata(Default_ockarkinos_smartmin)          95
set gdata(Default_ockarkinos_zhint)              1

# Note: Names ending with  "*" are female.  The "*" isn't displayed at
# runtime.

                              ; # List of possible names
set gdata(Default_ockarkinos_name) [list \
    Adjur     Aghi      Akten     Ankhisk   Anog      Antaan     \
    Aperakei  Argan     Arizhel*  AsKade    Atro      Auloh      \
    Azetbor*  Badich    Ba'el*    Batahr    Batrell   Be'Elanna* \
    B'Etor*   B'iJik    Chang     ChaqI     D'cIq     Dezhe      \
    D'Ghor    Divok     Dracla    Drex      DuKath    Dula       \
    Durall    Duras     Edronh    Eragh     Gelly*    Gistad     \
    Godar     Goradh    Gorkon    Gowron    Graade    Grilka*    \
    Gudag     G'Vera*   Halaylah  hiJak     Hon'Tihl  Huraga     \
    Inagh     Janar     Ja'rod    J'Ddan    Kaden     Kadi       \
    Kadrya*   Kaftter   Kagga     Kahless   Kahlest*  KaiTan     \
    Kalan     Kalim     Kalin     Kandel    Kang      Kanjis     \
    Karden    Kargan    Katilla*  Kaybok    K'Ehleyr* Kelay      \
    Kell      Kellein*  Kellen    Kelly*    Keppa     Keroth     \
    Kessec    Kessum    Kethas    Kev       KezhKe    Khidri     \
    Kian      Kintata   Klaa      Klag      Kle'eg    Klimor     \
    K'mpek    K'mpok    K'mtar    K'nara    Kodan     Koll       \
    Koloth    Komakh    Konmel    Konora*   Koord     Koplo      \
    Kor       Koronin*  Koroth    Korrath   Korris    K'Orta     \
    Koth      KothKe    Koval     Kowla     Kozak     Kras       \
    K'Ratak   K'rau     Kreg      Krenn     K'Rodak   Kromm      \
    Kruge     Kruger    k'taH*    K'tal     K'Tar*    K'Tel      \
    K'Temok   K'Tesh    Kulan     Kulge     Kurak*    Kurn       \
    Kurrozh   K'Vada    Larg      Largh     Ler'at    L'Kor      \
    Lursa*    Mabli     Maglus    Maida     Majjas    Makai      \
    Maltz     Manda*    Mara*     Margon    Martok    Memeth     \
    Merzhan   Mogh      Mohtr     Molor     Morag     Morath     \
    M'Rel     Muuda     Najuk     Nedec     Noj       Nu'Daq     \
    olahg     olmai     Ondagh    Pok       Porus     Qua'lon    \
    Qugh      Ragga     Rajuc     Rannuf    Restagh   Rocta      \
    RoKis     Ruzhe     Seegath   Seeth     Segon     Shurin     \
    Starad    Surgh     SvaD      Tagre     Tellot*   Tel'Peh    \
    Tiehar    Tignor    T'lak     T'lanak   Tog       Toragh     \
    Torak     Toral     Torghn    Torin     T'Rok     Tumek      \
    T'Var*    Unagroth  U'Qam     Vagh      Valkris*  Vathraq    \
    VeKma*    Vixis*    Vok       Voloh     Vrenn     Yatron     \
    Zharn     ZhoKa  \
]

# Related notes:

# The program now supports both  hunters and grazers as enemies.  Gra-
# zers move at random. Hunters chase the player.

# For "ockarkinos",  "smartmin" and "smartmax" specify the minimum and
# maximum percentages  of  the  "ockarkinos"  population  (in  a given
# world) that are hunters.

# Hunters aren't intelligent.  In particular,  they don't know know to
# get around walls.  As a kludge, if a hunter hits a wall,  it changes
# into a grazer temporarily. This increases the chances that the hunt-
# er will be able to find a new route.

# If you're using Brick 5.2, the "hunters" feature requires the 100922
# "bricktcl" patch to "wrap_sprite_position". If the patch is missing,
# the program will  crash.  This isn't an issue  for newer releases of
# Brick.

#---------------------------------------------------------------------
# Class parameters: Defaults for ocmedical class.

# Defaults may be overridden on a per-world basis.

# Parameter    Purpose                                   Factory value
# ----------   ---------------------------------------   -------------
# cautious     Become cautious if player is this close      50
# dropshadow   Flag: Add drop shadow                         1
# frequency    Creation frequency                            0.00200
# health       See remarks below                            15
# maxnum       Maximum no. that can exist in one world       2
# minnum       Minimum no. that can exist in one world       4
# preload      Number of instances to preload                1
# shoot_can    Flag: Can shoot one of these                  1
# shoot_effect Effect on object's health per ocbullet       -1
# shoot_score  Score change if destroyed by shooting         0
# zhint        Render-order hint                             1
# name         List of possible names                    (various)

set gdata(Default_ocmedical_cautious)            50
set gdata(Default_ocmedical_dropshadow)           1
set gdata(Default_ocmedical_frequency)            0.00200
set gdata(Default_ocmedical_health)              15
set gdata(Default_ocmedical_maxnum)               2
set gdata(Default_ocmedical_minnum)               4
set gdata(Default_ocmedical_preload)              1
set gdata(Default_ocmedical_shoot_can)            1
set gdata(Default_ocmedical_shoot_effect)        -1
set gdata(Default_ocmedical_shoot_score)          0
set gdata(Default_ocmedical_zhint)                1

                              ; # List of possible names
set gdata(Default_ocmedical_name) [list \
    Chidori     Chiyo       Chizu       Kado        Kaemon    \
    Kagami      Kamenosuke  Katsutoshi  Kazuo       Keiji     \
    Keitaro     Machi       Makoto      Maro        Masahiro  \
    Nagisa      Naoko       Ogano       Ozuru       Raiden    \
    Renjiro     Sachi       Sakae       Samaru      Taizo     \
    Tani        Taro        Yasahiro    Yoshi       Yukiko    \
    Zinan
]

# Related notes:

# "health" specifies the number of health points that an  ocmedical is
# worth.  This should be a  positive integer from  1 to 100.  The fac-
# tory setting is 15.

#---------------------------------------------------------------------
# Class parameters: Defaults for ocmoney class.

# Defaults may be overridden on a per-world basis.

# Parameter    Use                                       Factory value
# ----------   ---------------------------------------   -------------
# cautious     Become cautious if player is this close      50
# divmax       Maximum speed divisor                         5
# divmin       Minimum speed divisor                         4
# dropshadow   Flag: Add drop shadow                         1
# maxnum       Maximum no. that can exist in one world       3
# minnum       Minimum no. that can exist in one world       1
# shoot_can    Flag: Can shoot one of these                  1
# shoot_effect Effect on object's health per ocbullet       -1
# shoot_score  Score change if destroyed by shooting         0
# smartmax     Maximum percentage that are smart            95
# smartmin     Minimum percentage that are smart            95
# valmax       Maximum value per instance                   25
# valmin       Minimum value per instance                    2
# name         List of possible names                    (various)

set gdata(Default_ocmoney_cautious)              50
set gdata(Default_ocmoney_divmax)                 5
set gdata(Default_ocmoney_divmin)                 4
set gdata(Default_ocmoney_dropshadow)             1
set gdata(Default_ocmoney_maxnum)                 3
set gdata(Default_ocmoney_minnum)                 1
set gdata(Default_ocmoney_shoot_can)              1
set gdata(Default_ocmoney_shoot_effect)          -1
set gdata(Default_ocmoney_shoot_score)            0
set gdata(Default_ocmoney_smartmax)              95
set gdata(Default_ocmoney_smartmin)              95
set gdata(Default_ocmoney_valmax)                25
set gdata(Default_ocmoney_valmin)                 2

                              ; # List of possible names
set gdata(Default_ocmoney_name) [list \
    Bill Happiness Joy Success Truth
]

#---------------------------------------------------------------------
# Class parameters: Defaults for ocpig class.

# This class starts with the "barnyard" prototype  discussed previous-
# ly and makes some adjustments.  Defaults may be overridden on a per-
# world basis.

set_class_defaults_barnyard ocpig
set gdata(Default_ocpig_scalemax)   1.00

                              ; # List of possible names
set gdata(Default_ocpig_name) [list \
    Babe        Bacon     Barnaby  Freddy  Hamm  Harold \
    Peppermint  Porkchop  Wilbur
]

#---------------------------------------------------------------------
# Class parameters: Defaults for ocplayer class.

# Parameter    Purpose                                   Factory value
# ----------   ---------------------------------------   -------------
# dropshadow   Flag: Add drop shadow                        1

set gdata(Default_ocplayer_dropshadow)  1

#---------------------------------------------------------------------
# Class parameters: Defaults for ocscroll class.

# Defaults may be overridden on a per-world basis.

# Parameter    Purpose                                   Factory value
# ----------   ---------------------------------------   -------------
# dropshadow   Flag: Add drop shadow                        1
# maxnum       Maximum no. that can exist in one world      2
# minnum       Minimum no. that can exist in one world      1
# zhint        Render-order hint                            1

set gdata(Default_ocscroll_dropshadow)   1
set gdata(Default_ocscroll_maxnum)       2
set gdata(Default_ocscroll_minnum)       1
set gdata(Default_ocscroll_zhint)        1

#---------------------------------------------------------------------
# Class parameters: Defaults for octiger class.

# Defaults may be overridden on a per-world basis.

# Parameter     Use                                      Factory value
# ----------    ---------------------------------------  -------------
# divmax        Maximum speed divisor                        5
# divmin        Minimum speed divisor                        2
# dropshadow    Flag: Add drop shadow                        1
# health        Initial health points                        7
# heffect       Effect on player's health per attack        -3
# maxnum        Maximum no. that can exist in one world      2
# minnum        Minimum no. that can exist in one world      2
# scalemin      Minimum scale factor (may be a real)         1.00
# scalemax      Maximum scale factor (may be a real)         1.00
# shoot_can     Flag: Can shoot one of these                 1
# shoot_effect  Effect on object's health per ocbullet      -1
# shoot_score   Score change if destroyed by shooting        5
# sound_destroy Sound when destroyed                        briefmeow
# sound_hit     Sound when hit                              briefmeow
# smartmax      Maximum percentage that are smart           95
# smartmin      Minimum percentage that are smart           95
# name          List of possible names                   (various)

set gdata(Default_octiger_divmax)          5
set gdata(Default_octiger_divmin)          2
set gdata(Default_octiger_dropshadow)      1
set gdata(Default_octiger_health)          7
set gdata(Default_octiger_heffect)        -3
set gdata(Default_octiger_maxnum)          2
set gdata(Default_octiger_minnum)          2
set gdata(Default_octiger_scalemin)        1.00
set gdata(Default_octiger_scalemax)        1.00
set gdata(Default_octiger_shoot_can)       1
set gdata(Default_octiger_shoot_effect)   -1
set gdata(Default_octiger_shoot_score)     5
set gdata(Default_octiger_sound_destroy)  briefmeow
set gdata(Default_octiger_sound_hit)      briefmeow
set gdata(Default_octiger_smartmax)       95
set gdata(Default_octiger_smartmin)       95

                              ; # List of possible names
set gdata(Default_octiger_name) [list \
    Catrina Catzandra Catzilla Fluffy Magnificat Mewsette \
    Raggles Ripley    Tabby \
]

#---------------------------------------------------------------------
# Class parameters: Defaults for octree class.

# Defaults may be overridden on a per-world basis.

# Parameter    Use                                       Factory value
# ----------   ---------------------------------------   -------------
# dropshadow   Flag: Add drop shadow                         1
# maxnum       Maximum no. that can exist in one world      10
# minnum       Minimum no. that can exist in one world       0
# smartmax     Maximum percentage that are smart            95
# smartmin     Minimum percentage that are smart            95
# octigerdelta See remarks below                            20
# zhint        Render-order hint                            10

set gdata(Default_octree_dropshadow)       1
set gdata(Default_octree_maxnum)          10
set gdata(Default_octree_minnum)           0
set gdata(Default_octree_smartmax)        95
set gdata(Default_octree_smartmin)        95
set gdata(Default_octree_octigerdelta)    20
set gdata(Default_octree_zhint)           10

# Related notes:

# If a given octree (or forest) has a hidden octiger,  and the X and Y
# distances from a given octree to an ocplayer  are both less than the
# associated  "octiger_delta" setting,  the hidden octiger will be in-
# stantiated.

#---------------------------------------------------------------------
# "Bounce" list for "random_position_sprite".

# If "random_position_sprite" shouldn't drop objects on instances of a
# given class,  or drop instances of that class on anything else,  add
# the name of the class to the following list (list_classes_bounce).

# The list should include  ocplayer,  non-mobile classes,  and classes
# whose instances are activated and/or destroyed when the player pass-
# es over them.

# For now, mobile classes other than ocplayer should be omitted except
# where it's  important to keep instances of these classes from inter-
# acting with instances of other  classes based on random positioning.
# Explanation:  If classes are  listed  here  unnecessarily,  this may
# cause problems for "random_position_sprite".

# Note:  If the  "nobounce" flag is set  elsewhere  for  a given class
# (call it foo for the  sake of discussion),  "random_position_sprite"
# may drop an object of any class (call it bar) on an instance of  foo
# whether or not bar is listed here.

# It's important to set  "nobounce"  for classes  whose  objects  have
# large dimensions.  If this isn't done,  this may also cause problems
# for "random_position_sprite".

set gdata(list_classes_bounce) \
    [list ocinter ocintra ocplayer ocscroll octree]

#---------------------------------------------------------------------
# Other class-category lists.

# As  explained  elsewhere,  some  object classes  are  classified  as
# "periodic".  The associated  class names should be added to the fol-
# lowing list:

set gdata(list_classes_periodic) \
    [list occow occross ocdog ockarkinos ocpig ocmedical]

# As  explained  elsewhere,  some  object classes  are  classified  as
# "upfront". The associated class names should be added to the follow-
# ing list:

set gdata(list_classes_upfront) \
    [list occar ocflames ocintra ocscroll ocmoney octree]

# Note: A given class shouldn't be both "periodic" and "upfront". How-
# ever, this won't cause significant problems presently.

#---------------------------------------------------------------------
# List of classes with sprite prototypes.

# The list  defined here  holds  the  names  of  the classes for which
# sprite prototypes exist.

# The list should be initialized to empty here;  names are  added at a
# later point.

set gdata(list_classes_proto) [list]

#---------------------------------------------------------------------
# List of sounds.

# The list  defined here  holds  the  names  of  the sounds  for which
# "_bxdiv_lz77_base64" data exists. "setup_sound_effects" converts the
# sounds in question to internal (playable) format.

# The list should be initialized to empty here;  names are  added at a
# later point.

# Note:  In some contexts,  this program  prepends  "sound_"  to sound
# names. However, the "sound_" prefix is omitted in this context.

set gdata(list_sounds) [list]

#---------------------------------------------------------------------
# Compressed music file.

# music_lz77_base64 contains a LZ77-compressed and base64-encoded ver-
# sion  of the  program's  internal music file;  i.e.,  the music file
# that's  played when  PlayMusic is set to 1 and  MusicFile is  set to
# internal.

# Presently, the following music file is used: "heatbeat.mod". The MOD
# file in question is licensed under Creative Commons and is therefore
# redistributable. The artist is Aleksi Eeben.

set    music_lz77_base64 ""
append music_lz77_base64 \
aW50cm9tdXotMS5oYgABBgFjb21wb3NlZCBieSABCQEAA94AHAEDHQEBaGVhdGIBAwQg \
b2YgcmViZWxzLi4uAAEB4gBAAQQeAQdDARABPwAgAQQeYmUgZnJlZSB0byByaXAgNCB5 \
b3VyAADyAQY8AQWMLCBidXQgZG9uJ3QgNGdldAABAo8BBjx0aGUgY3JlZGl0AQRxAQmW \
AQEAFgEaeAOxAC8BAgABAbEBFx5hARw8AQcBAgKVAB4NfwABAQEBAQIBAgMDAQYGAR0t \
AVYBTS5LLgEBrE8FAQL6fAEBAQL6EAELGgwBAgEJp6wwAQQQAQ+fDAQBCiAgAQQQBQEB \
fQENQAYBCCQBAaxMKAEDDAcBD0AIAQpAQAEEEAkBAawBDUAKAQ+ACwEB/AENIAwBCmAB \
BIAAAAECGgEMIAIACwFnrEwsAQUgOgEYIAEEYAIAGwGnAQWgAQNAgAEQQAEPgAEZYEwB \
BWEBGkABBoABGsABB4ABGWABB4ABEWABCCAsKAEe4E8FAQVAAgANAgACACwBIAEGgAIA \
DgIAAQzgTAEfgAEG4AIADgIAARKAAgAOAgACABMBgAIAjQIADAsCAA4CAAwKAQ5ADAkB \
CkACAAUDAAgBDsACAAwDQAIABQNgBAIADwMAAgAJA6ABBxACAB4EbAEc4H1sCAEBfVAC \
AAUCAAIACAIMAQ8gAQIAvlACAA4BjH1cAgAKBAB9YAAAoFACAAUCAAIACAEMAL4BBCAB \
B8B9ag8CAAsBDCgAAArwAKBcAQPgAQhAAQMgAQNgAQGsAQRAQAEDEgEDIAENgAEDYNYB \
AyD8AQQgAgAHAawBDWBsBAD+AQPAGgELgNYBDKBqDwEBDQEDIDoBBCBMLAEFYP4BD8AC \
ABACbA0BDCBsBAEBHQEDQIABCKACAA8CAAEH4AEGYAEEgArwAQEdARJgAQZAAgAGBAwB \
EEABBaABBcABBB8CABABAAEDIAEEgAEFYAIABgEgAQ6gYAABAUABCKACAAcDjAENgAIA \
DAGALAIABQGAAQFAAQ9AAgAeAgACAAsF7AIAFwIAvgIADwIAAgATASACAA0CAAIABQHA \
AQug1gIAHwIAAQRgAgAMAgACAAUB4AIACwIAAgAHBAACAA4CgAIAFAFAAgAHAgABEWBc \
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 \
DjsBCh8CABwOIg==

#---------------------------------------------------------------------
# Compressed "ocscroll" data.

# wisdom_lz77_base64  contains a  LZ77-compressed  and  base64-encoded
# version of a "fortunes" file; i.e., a text file that contains quotes
# (or "fortunes"). The quotes are used by ocscrolls.

# For an explanation of the "fortunes"-file format,  and more informa-
# tion about ocscrolls, see the documentation section named "Scrolls".

set    wisdom_lz77_base64 ""
append wisdom_lz77_base64 \
VGhlIGJlc3Qgd2F5IHRvIHByZWRpY3QgdAEDGGZ1dHVyZQppcwEEGWludmVudCBpdC4K \
Ci0tIEFsYW4gS2F5CiUlCgEERCBiaWdnAQRIIGRpZmZlcmVuYwEEWXR3ZWVuCnRpbWUg \
YW5kIHNwYQEDFwEEUWhhdCB5b3UgY2FuJ3QKcmV1c2UgAQQnAQVeTWVycmljayBGdXJz \
dAEEYkl0IGhhcwEDUGVuAQNgc2NvdgEDYmQBBkZDKysKcHJvdmlkZXMgIGEgcmVtYXJr \
YWJsAQPBYWNpbGl0eQpmb3IgIGNvAQOUYWxpbmcBBd50cml2YWwBA7BlLQp0YWlsAQM9 \
b2YBBEEBA01ncmFtIAED5nN1Y2ggYXMKd2gBA3ABA/wBA4N1Z3MgYXIBBqggRGEBA3cg \
S2VwcGVsAQWobiBjaGVzcywBAywBBOdhbHdheQEEuHR0ZXIgdG8Kc2FjcmlmaWNlAQT9 \
ciBvcHBvbmVudCdzIG1lbgEGVFMuRy4gVGFydGFrAQPnbgEEV0FuIGgBAyhzdCBtYW4B \
AywBBL9ubwED4nN0IHdvcmsKAQO5R29kAgAIAZpleGFuZAEDcFBvcGUBBD9CAQQuAgAH \
AdNpcgEDNGJ5IHdob20BBkhldwoBA9AgdHJpZWQKTm9yIHlldCABBRtsYQEDLHRvAQMI \
eQEFEG9sZAphc2lkZQEaaHNpbGVudAEI+HdoZW4CAAUB5mRvdWJ0CgEF83NlbnNlAQPS \
ZCBzcGVhaywBA1pvdWdoIHN1cmUsIHdpdGgKc2VlbWluZwIABQJKAQNubmMBGHFJZiAC \
AAoCRSBiZWF0ICdlbSwgAgAFAmwBBLN5CndvAQQbbAED0wEEKWpvaW4BBiMBAw4nZAIA \
BQL6CmcBAx1vdQEDBGYBBeZjb3VudHkCAAYBTFBhcHB5IE1hdmVyaWNrAgAFAYsgZm9v \
bAEFYWhpcyBtb25leSBhcgED+m9vbgpwYXJ0eQEDuy4BBitnbGFzcwEDnnQBBARjaGVz \
IG5vIG1pY2UBByACAAYBzgIABQN/ZnJpZQEDVAEDUwEEV2RvZ21hAQ0laG9yaXpvbgIA \
BQJ8IGIBA6NkZQEDv3kKAQQudmlzaW9uAQcvcHJvbWlzZQEDN2QCAAUDamEgZGVidCB1 \
bnBhaWQBByRyb2wCAAUDB3N0AQO/IGdhAQP3cgEEzG1lbnR1bQEHJXNraWxsZnVsIHNh \
aWxvciB3YQEDv2V2ZXIBBVsKb24BA1tjYWxtIHNlAQirU21pdGgCAAUBHFdlc3MBAyJi \
ZWF0cyBmb3VyIGFjZXMBBicCAAYCim5hcnJvdyBwYXNzYWdlLAEEFHIBBbFubwpicm8B \
BA8sIG5vAgAHARkBBTpCZQEDcXJlAQSUb2YgdwIACARDd2lzaAEDZHI7CgEEDm1pZ2h0 \
IGdlAgAGBKsBAzZDdXJpb3NpdHkgAQTRAgAFBDYBBEh0LCBidXQBA910LQppc2ZhY3Rp \
AQSxcm91AQRAAQN+IGJhY2sBBUJEAgAFAkR0ZW1wAQa7Z29kcwEFsXkgbG92ZQEIaUVh \
cmwCAAUFRGJlZAEKDXJpc2UKV29yayBsaWtlAQNZbGwKYW5kIGFkdmVydAEEHQEEO3Zl \
biBhIGhhd2sCAAUBtG4gZWFnbGUgYW1vbmcKY3JvdwIABgE8AQUoAQSDYm9sZGVzdCB6 \
ZWJyYSBmZWFyAgAFBBYKaHVuZ3IBA5cCAAgCEAEJMXNtYQED/QEDMmMBA30BA1pidXJu \
cwpicmkBA+4BA+xpAQYmZGFyAQbzRnJlZWRvbSdzIGp1AQM1YW4CAAUBkSB3b3JkIGZv \
cgoBBBBpbmcgbGVmAgAGBCNvcwIABgLVSGUgd2hvIGxhdWdocywCAAUEQwEGuwEHGXIC \
AAUFpwIABQWAaWcBA1IBA48BA0wKZGlzbW91bgIABgFJSGluZHMCAAUBxwIABwEMeGFj \
dCBzY2llbgIABwM7SG9wZQEEiAIABgEMAQPXAgAGAc1wcmVwYXJlAgAFBe8BBBoBA69z \
AQdTb3cCAAUCLGxvb2sgZGVwZQEDYiBvbiACAAUF2QIABQI4Z28BBSlJZiBhdAIABwUn \
AgAGBLpuJwEDfHVjY2VlZCwKcmVkZWZpbmUBBhJzAQbbAR80dHJhbnMBA5NtAgAGBfRk \
YXRhIHNlAQaYAQM7aWYnAQTmZAEEwgEDCncBBJFjAQMQeQEFFW51dHMsCmV2ZXJ5AQM6 \
eQED03VsZAED8yBDaHJpc3RtYQEJg2lnbm8BA2oCAAYHYGJsaXNzLAED3wIABQSdbid0 \
CgIABgNgbW8BAwVoAgAFBNZwZW9wbGU/AgAGB18CAAUEhwIABwalAQODYXICAAUFEnRo \
YW4gdG8KcnUBA9oBAxEBBmsBBC1lYXNpAQYtZgIABQGpZm8BAzJuZSdzCnByaW5jaQED \
WnMgAQhAIGxpdmUgdXABBEsBA4cCAAYEYU1vcwEEN290AQQxdHMCAAgCgnMBA/VzIG9m \
AgAGCDR3AQW0YWQBAwppdGgCAAUG7CBiAQM0AQb1TgIABwKFAQPwaW1wb3NzaQIABQf1 \
AgAHAf1tYW4Kd2hvIGRvZXNuJ3QBA/YBA4UBA41kbwIACAOxUAIABgIvAgAFAWhwcmV2 \
ZW50LAEDiHN0ZWFkAQSDAQQfaXIBBR8BAwsBAx4BBTZTAQOqaGFzAQRgeQEDUG9scwIA \
BgJ9YQED52UBA4wBBOMBAyECAAUDZndoaWNoIGZpAQPgAQT5IGFsbAEFRFQCAAUGaGxk \
AQPXAQNdb2YgaG9wZSBibG93cwpldGVybmEBCihncmVhdGVzAgAFBqBmYXVsdAED7gIA \
BQmSYmUKY29uc2Npb3VzAQQdbm9uAgAGAx4CAAUJkGhhcgIABQQicGFyAgAJBttqb3Vy \
bmV5AQSlc2FpZAEGRQEFGnBhc3NpbmcBCClnAQNyAQZLAgAICbp0aWQBA89haQIABgHr \
bm8CAAQA/wEGIm8gaQEDsgEDMQIABQa9dQEDGDsCAAUE+GVjdXJzZSwKZGl2aQEHmVdl \
AgAHA/AgZGkBAyACAAYFTndpbmQCAAYBQncCAAUC+SBhZAIABQR0AgAGAg5pbAIABgHs \
V2hhdAEDl3JsaWMCAAcA/3NhbGEBAzlpbnNhbml0eQIABwqnAQPuAQcwZXICAAUJZSBz \
dAEEwAIAFQP0cwIABwIJV29yAQMbbQEEdmJlAQOHaWdoZQEDWwEEqQIABQgOZQIABgaA \
WQIACQhra2lsbAIABQqvAgAFAphvAQO8aW5qdXItCmluZyACAAUBwQEDkgEINCd2ZSBn \
bwIABQUnZmUCAAcGgGhvcnNlcwEDvmYBBYl3YW4CAAcBDWFnAQOicHVsbAEHdFQBBch3 \
YXMgYQEDdgEDyWN1AgAGAWxuIEtldwED528ga2VwAgAFAn5hcmcCAAUG2QEEHGEgcGV3 \
LgEHPmhlIHRhAgAFBtdpdCBlYWNoAQPjZWsKQSBuZXcgbAIABgP3b2YgR3IBBBZCAQTN \
dAIABwfqAQS3ZnVyAgAFBfwCAAUDzU11ARGWAQPAAQP1bQEDHXcBA41zYWlkLAogAQMB \
IkRhbW4hCkkBA5xwcAIABgahbyBtZSBub3cCAAYLuUkgYW0KSgIABQZfIGJlAgAGC5cB \
Axdtb3ZlcwpJbgIABQyLZXN0aW4BBPBncm8BBBgsCk4BA5NhAQPQeGkgb3IgYnUCAAkD \
fnRyYW0uIgIABQSiIAEDSGUgcXVvdGF0aW9ucwIABgnNUmFscGggV2FsZG8gRW1lcnNv \
biAoMTgwMy0xODgyKQIAEQNwaG9tYWcCAAUEM3RydXRoAgAGAncKdXMCAAYH8QEoUgEI \
O2JlYXV0aWZ1bAIABgrlbwEDtAIABQsWOwoCAAUIh28CAAUJ2WxpZQEvrW9sZGVuIAEE \
qGkCAAgJnwIABQPQcmVzZW50CgEDGQEGUFQBBM5zIEZ1bGxlcgEGPgIABQt3AgAKDO9i \
ZQIABQFJdGhyZQEEiW5lcwpsb25nLCABA51tZWRheSAgaXQBA7xsbAIABgVLAgAHBINt \
YWludAEDBGUCAAcMfyIBBJdUYW8gb2YgUAEGW21pbmcCAAUBmSABCAFFQVJUSAEGD3Nt \
b2cgIHwgIGJyaWNrcwogQUlSICABA0kgbXVkAQYJRklSRQEDLXNlbHR6AQPgAQQtdGVx \
dWlsYQEKUldBVEVSAgAGCGhyZSdzAQW0AgAGBh4BA6cBA9VpbmsgYWJvdXQ6AgAFCAxj \
AQMfAgAFBB4CAAYBM3MBA/NhIGhlYWQBBPkKAgAFCaoiUHN5Y2hpYyBXaW5zIExvdHRl \
cnkiID8BBeZKYXkgTGVubwIABgJvYW0CAAcKwGZvcmUCAAUC2AIABw2La2lyYQIABgsb \
IHdlbGwtZnIBBO0CAAcFBCBpbWFnaW5lAgAFDKoKb2NlYW4sICBubwIABQkVIAEDkCBz \
dW1tAQTxAQOBZWN0CgIABQ7BaXZlIG9mIGljZS4gAQXKYW4BAysBA6Rkb3dzCnVzAQMw \
dW5kZXICAAYE90xpbnV4PyAgSAIABQIgIHJlLQpzdHJpY3QCAAUMPgIABQxsb3duIGxl \
YXJuAgAIDLgCAAUF9AIABQ+kZSBtb3N0IHZhbHUCAAUPUAIABgFRYQptAQN0AQR4c3AC \
AAULmwIABgJgZW9waHJhc3R1cwEERVUCAAUDJyB1cC4uLiBXZWFyAQQOb3V0Ck1hawEF \
GmRvAQQaT3IgZG8CAAgDEQIABQWLcml0AQVlAgAJApgCAAUMEwEGem1vcmUKAgAFBIhk \
ZWJ1Z2cBBilibGFuayBwAgAFAusCAAUDcmlmbGVzIG0BBGlwZXJmZQIABQvbAgAHCiJl \
ci0KAQcSIGl0c2VsZgEGYSB0AQU3AQbNSm9zZXBoIENvbnJhZAEEVCJHb2QiLAIABQTd \
AgAGBphlYSBnb2F0LCAiaXMKAgAHDu5vbiBiAQOpIHNpZGVzLiICAAYOQWV0ZSBTaW5m \
aWVsAQVKV2gCAAgLkW9mdHcCAAUOOXBpAQP0cyBjYWxsAgAFAtBCAgAGAkcCAAUDx2UC \
AAUMR2dhdGVzAgAFA/BzdHJ1Y3R1cmVkAQNBdWwCAAYD9XgCAAUF8wIABQK6AQRAQW5k \
IGNvAQNzZGVudAEDPndhAQNfAgAFAqlzIGRlYQEDomZvciBmaWxlAgAFC15hYnNvbHUB \
A6dzdXItCmNlYXNlPwIABwGYAgAFC14BBJwBA19mcmVzaCBwYXQtCnRlcm4BAztjY3J1 \
ZQpMaWtlICBhdG9tAgAFCIUCAAYQZgEDW2gsAgAFBCJkdXN0AgAFDPBiYWNrLCBiZWdp \
bm4CAAUMOmlmZQEDf2V3AgAFCoJBbGwgY2EBA2phAQP6Z3JheQIADgySCi0tIEJlbmph \
bQEDF0ZyYW5rAQPuAgAFDhN5IGZhaQIABhHUAgAFEr1wAQNBAgAFD94BBUoBAxEtCgED \
EwEHIAEEKwEbTUNyZWRpdG9ycwIABgThAgAHCxFtZW1vcmkCAAUMtWFuCmRlYgEEIgEb \
RkRvAgAHDGoBA0MBBOU/IFRoZW4gZG8gbm90CnNxdQIABhDEdGltAQOpAgAGCq1hdAIA \
BhHVCnN0dWZmAgAGARtpcwIABgr5b2YBG2wCAAUJ6gIACQ3bZmFjAgAGDTMCAAUJVG93 \
CnRoAgAFDs8CAAcKh3QBAy1pbmZpbml0ZQEDXHkKYmUgc2UCAAgSd0FsZG91cyBIdXhs \
ZQIABRPWSSBiAgAGDwwCAAYSCwIABQcTY29tcHV0ZXI7Cml0IGNhbWUgZnVsbHkBA+0B \
A6tkLgpJdAIABQgVZ3VhAQOldGVlAgAFDi0gOTAgZGF5cwIABgbqAQPCMzABBSZvdXRt \
bwEFNwEDblJlYWwCAAkGMGVyAgAJEztjb25mdXNlCkgBA+Rvd2VlbgIABQqOAgAJDP0g \
YmVjYQEEIE9DVCAzMQEE/mVxdQEDS3RvIERFQyAyNQIABgxtZW1vcnkBA+5ydmVzIHdp \
c2UBBMttAgAFAYoCAAcBzFR6J3UtaHNpLCA2MzggQS5EAgAJC0sBBS9tYW4gdHJ1c3Rz \
IG9uAQPyAgAFA3ECAAkHrW9hbGQgRGFoAgAFFAVBbmQgaQIABQ4TAgAHEk8CAAYLgWlu \
cXVpcnkBBFMBA4poAgAFDchhc2sCAAUCLWhvdyBJIGRpZWQCAAUKZW1heSB0ZWwBA8Zo \
ZW0gAQMaAgAFAWtkb3duCmVhcnRod2FyZHMKQXQgbGVzAgAGApgCAAYFrWluaW11bSBn \
bGlkAgAFEFdQAgAJBP4CAAUF/mFjaGlldmVkIAIABQrad2hlbgIABw4WAgAPBWMCAAUL \
SGQCAAYLlQpyAgAFEh4CAAYTywEVLgp0byB0YWtlIGF3YQIABxM3QW50b2luAQOyZSBT \
YWludC1FeHVwZQED/AIABhXLAgAHBlxidXNpbgEEwQIABwx1AgAGFm8gdG8KYmUgZGFu \
Z2Vyb3UCAAcBYkhhd2t3aW4CAAUFQwIABRMTAQeMd2FzLAIACAjLc29tAQM4aWQCAAYL \
tCBoaW0gbWFkAQQfAgAIDvhlIGNhc3QBBakBDhdoYQIABwbHSm9obiBCdW55YQIABQNg \
AgAFDHYBBG5oYXMgZG9uZSwBBQ4CAAUHdHNwaQEG/WRvAQc8ZXJyeSBQAgAFDWRsbAIA \
BhShAQXtbm8gAQPqAgAFDLRlbGwgZGVhcgIABgaOaXQKAgAFA68BBx5naXZlIGkBAyJt \
ZWFzdQIACBZkSmFtZXMgSwEDOnkgKDE3MjECAAUJ/QIACA8sIHJlbWVtYmVycwpvbmMC \
AAUGNgIABwuaYgIABQvqAgAFF3Z1bnNoaW5lAgAFA4BjaGlwAQSVd2FybSB0bwIABQjC \
QwIABwPXAgAGBX91AQOmZXNzLiACAAUCqgED7AEDWmx5AQaeAgAFBVluc3cCAAkDN1Bh \
YmxvIFBpY2Fzc28gKDE4ODEtMTk3MwEFpUkCAAcJeQIABwvvc2hhAQPdAgAJCXIKQSBu \
dQEEuwIABQUsbAIABRBQAgAGAstyAQMdRgIABQUacmUCAAUCcAIACgLoc2l4LCBvcgIA \
BRRUAgAFA2oBBRZvbmUgaXQncyBzbGlnaHQBA65tb3ICAAcVZmgCAAgMIQIABhVJcgIA \
BQEXAgAHA4BleGNlZWQCAAUVRWdyYXNwAQVbdwIABgWQAgAFChB2ZW4gZm9yAgAGCfVS \
bwEDrXQgQnJvd25pbmcCAAcO0gIABRDdAgAFFQ5wbGFjaWQBA7BsYQIABQ/WCgIACxGT \
bgIABgcaIG1pZAIABg/LYQpiAQMvawIABQhLAgAFBB4CAAUFmXksAgAFAbJpdAoCAAUV \
b290IG1lAgAGDhxhdCAgd2UBB7kKdm95YWdlIGZhcgIABwMgLlAuIExvdmVjcmFmAgAF \
CUlIZQEGNWkCAAkRW2JhdHRsAQNCbGFpbgpXaQIACQGLcmlzAgAFA/MCAAYRymFnAQQf \
QnV0AgAFDjcBBEIBBRgCAAYSo3J1bgEDCXdheQEGQAEF+wEKOgIABxQlZAIABhoWAgAF \
AzwCAAgXmiBjdXJlZCwCAAkPZGVuLQpkAQQTAQa/RnJhbmNvAQOrUmFiZQEDoAIABQiv \
QSBsYW5ndQIABQ2EAQRMAgAIEclhZmYCAAcQPAp3YXkCAAUCkwIACwvgAgAICjgCAAUY \
QgEDSQIABQTrb3J0aCBrbm93AgAFCuQCAAkawFBlcmwBBmwCAAcEQ0kgYW0CAAUBdm5h \
dHVyYWxseQIABxl5LAIABQvmIHNvAgAGDFlpbWVzIGJ5IGNoYQIABRSTAgAFGbhoYWtl \
c3BlAgAFCIECAAUNBldpbnRlcidzIFRhbGUCAAUNAUV2ZXJ5AgAFBTsCAAYCimwuIEdv \
ZAIABRQAIGFzdHJvLQpuYXV0LCAgT3ogaXMgbwIACA3QcmFpbmJvdwIABQIeCk1pZGkB \
AzFpAgAFGWECAAcKKm1vbnMCAAUDwmxpdgEHkVBlbG9xdWluAQOOTgIABQGhQnJlZWQB \
BYgBA+9zAgAFFZACAAUHCXVyc2UCAAYD+wIACBu8dAoCAAcMpGxheSBwbGFucwIACBPi \
AgAIAeYBBmNDb25mdWMBBI1BbgED5GN0cywgQmsuIDE1OjM5AQVpd2lua2xlLCB0AQgJ \
bGkCAAYChnRhcgpJAgAHFSt3bwIABQkTAgAJF9JhcgIABgQAYnkgc3ABA1Zyb3Njb3Bp \
YyBrZW4BAzVrAgAJEEMCAAgJ6Gh5ZHJvZwIABxstcyBJAgAFBQF3YWxrAgAFDCJtbwIA \
BxvzZmlyAQPpb2YKSGVsbCwgZGUCAAUELmVkAgAGFF4BBCJlbmpveW1lbnRzCm9mICBH \
ZW5pdQED1AIABwlCAgAFDkxBbmdlbHMCAAUWSgIABg4pAQMWcgEEMwIABhp2AgAIEpAs \
IEkgY29sLQpsAQPBAgAFC69tAgAFDbkBA2ZpciBQcm92ZXJicy4uAgAGAUlXaWxsaWFt \
IEJsYWtlAQNwAgAFAkBNYXJyaWFnAQQ3AQOyAgAFBIwBBGMBBL0CAAUBxldobyB3cm90 \
AgAFDZlzAQNuZGUgc28BA5oBBPVnbz8KSSBmZWVsIGFzIGlmAQOPAgAFATgCAAUZWGFs \
AgAGG3YKV2UndmUCAAgZ12V0IG9yIHNoYXIBA7BhAgAFF+0KT2YgcGwCAAYGjwIABgjS \
AQNpAgAHA2IncyBmbG93AgAIB5N0aGUBAwVpAgAFAg4CAAcMf2QKVGgBAzVhIE1vZWJp \
dXMgc3RyAgAGBn5vbmUtcwEEIjsCAAkMs3lvdSdsbAIABRm6cXVpAQPVYQIABhhGAQUh \
SWYCAAYb6XUBA6NuAgAFBU9oYWxmAgAFAiVpdCBzdGF5AgAFBOcBBBxwaWVjZQIABgje \
ZGl2AQRkAgAGFi1hAgAFCF4CAAUXVAEFCwEDv2xhdwEEBXkKaGlkAQQ/bmlnaHQ7Ckdv \
ZAIABhLIICJMAQOOTmV3dAIABRrMLCICAAYZugEDpndhcyACAAUCPQIABQr0ZAEDPwIA \
BgMucwEDP3RoZSBEZXZpbCBob3cCAAUMmyJIbyEKAQRLRQIABRZeAQNqYmUhIgpyZXN0 \
bwIABh7IAgAFAxF0dXMgcXUCAAYYiEEgIHJvY2sBA85sZSAgAgAFDZYCAAcV9SBhAQUa \
CgEFGgIABgP7AgAGAn4gcwEDbAEDFAIABQiib24tCnRlbXACAAULuSBpdCwgIGJlAgAG \
DQl3aXRoaW4gaGltAQWraQIABRLmb2YCAAUbzwEDEWRyYQIABw0lAgAcCcdBcgIABQZb \
ZQEDTGVyIAEDZ2dpAQNec20gb3IgcmV2by0KbHV0AgAFGoYCAAYIJnVsIEdhdWd1AgAH \
DWpvbG9ycyAgZmFkZSwCAAUbWmwBA6ZjcnVtYmxlLAoBAxACAAUDqmZhbGwCAAYHvgIA \
BguFAgAFApNzCmVuZAIACQkeRWR3YXJkIFRob3JuZGlrAgAGHohvb2sCAAYE0AIABgdB \
bgIABgdVeWUCAAUGNXkKc3RheSBhAgAKBSlTdGVwaGVuIFZpbmNlbnQgQmVuZQIABQdE \
AgAGCmoCAAYK8CBvbGQgdW50aWwBA+BncmV0cwoCAAUK9gIABQ+nbGFjAgAFAUNkcmVh \
bQIABwkaAgAGCkthcnJ5AgAFCyYCAAgHEmhhcHBlbgIABQHMAgAGFgkCAAUYJwIABgtd \
CmNoZWVzAgAFCPJnb25lAgAGCHZCZXJ0b2wCAAUFvmNodCAoMTg5OC0xOTU2AgAHCWMC \
AAUOrAIABw0uAgAHElICAAchGnBhcmEtCmRpc2UCAAYTtwIABQI8AgAFFkUBA6tsaWJy \
YXICAAcLsUpvcmdlIEx1AQN5QgEECwIABgcUAgAHDIICAAcU/wIABwgAAQYxWXVnb3Ns \
YXZpYW4gcAIABgTMAgAFFu5ZVVIBBAVCCklDAQUKNE1FAgAJEPZpbgIABwvWAgAFCWYB \
BA4CAAUgFlJ1AQUbY2lyY2xlcywgc2NyZWFtAgAGCrkCAAkSFmhvIEMBA2tFeHBsYQED \
LUl0AQkTAQWmWW91IFdoeQpGb29scyBHaXZlAQUTUmVhc29ucwpXaXNlIE0BA4NOAgAF \
BOlUAgAGAsNUAgAFIP4CAAUJjWxhdyABA/xzcAEDe2Qgc28gd2lkZSwKTgIABQu5bgED \
M2Zyb20CAAUiAHN3ZWVwAgAFDaFoAQMjLgpJAQMUbWVzaAIABwdBAQM7AgAFHB8BBb50 \
cm9uZwIABQxpeQIABg0iAQO6AgAGG8pjaGlsAgAFAYZ3AQQjLgpPAgAFBwNyb3VzIHdl \
YgEEGW15c3QBAyohCkJpZwEDU3NoIGFsbwEDWWVzY2FwZQEGkHRoZWUhAgALDCRKZWZm \
cgEDbFJvY2gCAAUCcQIADBPKZGV2b3VyAgAGF+phAgAFAdlpbmcCAAcCq092aWQgKDQz \
IEJDIC0gMTggQUQCAAkWYgIABR2nAgAFDaR3cmF0AQOHcgIABg8SAgAGC60CAAYa7QIA \
BRjNAgAGCsYCAAYSoQIACQP5AgAPBtgCACUG10EgcwIABQykbiBoYXJib3ICAAUBmmFm \
AQM/AgAGFqBhAgAFDTYCAAYOw2F0AQUtAgAGAX1mbwIABwiXAgAFA3tBLiBTaGVkAgAF \
DjMBBHdseWYCAAUJwAEDrnQCAAUVryACAAULLAIACAcyCnQBAwhlcm4CAAcEFENoYXVj \
AgAGFyoCAAcDY2RvbmUgbm8BBJVtLiBCAQOLSQIACQ19Cm5vdyACAAYKPgIABwvraXMg \
AgAFD6tseQIABQS2bGQsAgAHJEUCAAYcggEERQIABQcIZnQCAAMA/2xhdWRhYmxlOwEE \
hQEEHyBnb29kAgAHF3oCAAYKbSBhYwIABxqLCgIACQ8bAQPxbGwCAAcDwgIADgp+TWFj \
QmV0aAIACQFPYXJrAgAHHUIBA5lrAgAFHAICAAYhKXkKcgEDEQIABhqrVAIACg+EAgAH \
AWBzZXQCAAUOBgIACSGZZmF0ZSACAAcFkQIACAySAgAGFWkCAAUKH3VyLQpzZWx2AgAI \
ERgCAAUBiENvbm4BAx0oMjAyOQIABQJWIlJlYWxpdHkgZXZhAgAIIA1leWUsIgIACRVg \
CmJhcm0CAAUXDmhvbGQCAAYV5iBjbGVhbgIAByNTAgAGHkkgAgAGB4MBA/Bkb2QCAAUW \
DQIABQsrb2RzAgAFJAIKY29uAQNfAgAFCaRhIHN3ZXJ2ZSBkcml2ZXICAAcVnlN0ZQED \
E0F5bGV0AQRGQXRvbQIABQEzR3JhbmRldXICAAYR63dvcmtzIAED7mxvdyBzcGUCAAgM \
tQEPPlRveGljb2xvZ3kCAAcLYwIACAU5AgAFAgtzaWUCAAYlTWRpcwIABQUxIC0KaXRz \
IGRlZmVuAgAJC39vdwIACCYFAR1cIkkgdHJhdmVsIGJ5ICBtaXJyb3JzLAEHDQIABSEN \
eQpzbW8CAAUKSgEEFWRvb3ICAAUGIAIABQKdd2F0ZXIBBiR0YWkBBhkCAAcUayBzaGFk \
b3cBA0xvbiByb2FkAgAFCwdtb29uAgAHAWoCAAUmOwIABQSObmQCAAYetWFuZApzaW1w \
bGUgIGV4cGVjAgAGG3QuICBJAgAFHPlpdmVuIHVwCm15IGNhAgAIAXlEZWFuIEsBA1d0 \
egIABwQVRmFjAgAGDSMBAxtsAgAGAqxyAgAGAicCAAUGLgEHDAIABQbICmQBCSN5bwIA \
BhyQQWxsAgAFAzMCAAYgIgIABSVBAgAGCiZkZWZpYW5jZQEFx2FuYWdlbQIABR/IAgAF \
B1lvYiBXAQM1d2FyAgAHElhsbwIABQYOAgAGIRoCAAUBSwIABRLYAgAGBDQKAgAFFgl5 \
AgAFAuphAgAFAo5yIAIABh+AAgAGIpcBBdhvdWcgTGFyc28CAAkVnwIACQIEAgAGC2UC \
AAsS2EV4Y2VwAgAGE4ggdG9sAgAHAlZQaGlsaXAgTW9lAgAIG6o=

#---------------------------------------------------------------------
# Compressed "bonus" sound.

lappend gdata(list_sounds) bonus

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    bonus_bxdiv_lz77_base64 ""
append bonus_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEf4SCgH6Bf3x+f3l9gH+BhoSAf4B7e39+fICBfoCEg4CDgXt7fnp9 \
gQEDCoOAfoN+fQEDKX6AgYCGhH9/gXp8f38BAyl/f4WCAQMpent9fHyCg4CCAQMbgoB9 \
fn56fIGBAQNSfwEDUnyAgHsBBFKGgoKCAQM3AQMpAQN4gYN+gIOAe359enyDgYOFhH4B \
A058gX58f4B9gYaDgYJ/eXx+fH6Egn+Bg38BBSl8en0BBCmDfQEDIn2CfXt9AQOSh4SA \
g355e398f4OCfoKCAQN+fnt8fHkBAw6DhoEBBSmBfXoBA1qEAQMpgXx5e4B9AQSdg4OC \
goV+e3t7eQED5YKEAQMVAQQse3h/gICFiIOAf3x5AQNcf4J/fYGEgoSDfXkBAyoBAymB \
AQMpAQNuf34BAyl/gYWIgn9+AQNqgH9+gX1+g4aChIIBA2ABA+uFgoEBA2OCg39+fnl5 \
foGChocBAyB9ewEDY32AAQQpgwEDKXh7fAEDXICAgQEDmoMBA6V4eX8BA7EBBLJ+fYGB \
fAEDMH+GhgEDcnp5fXx+g4QBA2+AgYWDf3x7eHmAg4OGhH8BA6B+gYABA299gIeHAQND \
eXkBAzuDAQNpgYEBAx9+e3p3egEDuoWCfX2BgAEDyXp6fH2Ch4eDgX55en6Af4F/fH6C \
g4SGg3x6eXh8AQMpAQU6goGBfXh4AQNwiIcBA8F6ewED2wED7H2ChIaHgnt6AQNiAQO6 \
AQMZfwEDLoF8d3d8f4QBAyl/fXsBA7J/fnx6foOFh4eCengBA2KDhAEDdn6BhYQBA3p2 \
eH2AhoiFgH59fH8BAz4BA3J/AQMohoB6eHp7gIOCfn9+f4OHhYJ+eHV4foKGh4R/fgED \
2oOAAQMoegEDOIiFf3l5fH0BAxF+fX6AhYiFAQN6dXl/g4WGgn5+f4GDg396eHd6gYeJ \
iIR+enoCAAQA/356AQNoh4oBA2F3dnqAg4SEgAEEKIWDfnh3eHuCiImGgn16fH6AgX97 \
AQPihIiKhX96d3cBA4oBA4sBA9uFhoN9d3Z3fIIBA3oCAAUCjAEDs3l4eoCFioqGfnp3 \
eHyBAQPtfX2BhYeGgnt2dHh9g4eGAQOcfgEDyn97dwEEioqJhX4BA7x9gAEDsn1+hAEE \
cXp2dXh9goaGgoGAgYKDgH14dXYBA2GKiYR+ewEDi359fHt9gIaJAQSzdXV5foKEhAED \
ZQEDuX97dnV2fQEDs4iDf3x9fH18fHp7AQNHAQNhf3p2dnkBBHQBA0+FhYR/eXV1d32D \
iIiHg4F9AQN2fHt4e36Dh4sBAykBBJR9f4GBgoKFhoaDf3h1AQOKhIeHh4WBgH9+e3sB \
A9t/hIiLiQEDbHd4eXx9AQSghgED0n4BBCl8hIaIAQYpenp4eHqAhImKiYN/e3h2ent8 \
f4GChYeIhYN9dnQBBVIBAykBA959enl3d3qBhYqLiYJ/end2e3sBBHyGiImFg3x3c3V4 \
foOIh4eEgoGBfXp4d3Z6gYaJjImDfnoBAzR6fH4BAymJioaDfHYBBCmEh4aHhYOBggEE \
HXV7gYiJjYmDfXsBA4Z7ewED+IeNjAED23RvcXh/hIaMj4mIh4Z+cW5sZ2x3hoyTnJuS \
iYKDe3BnZ2txgZaYoKCSdl1ZYml1gZOZj4R7c25pdYCJlpyWhHNuZmp2g5COiIN8enqG \
koyGf3ZqZG53fYmPlpWPjYh+cWhta298iY6MjI+Fg4ODf3hydHJ3fIySjIqIf3l0fX16 \
foCBgYIBA9t7d3x4eoaMi4SDgXZ4fX99d3p9fYWHkJCEgHxzb3J+fX2EiIiIh4uCenNx \
c3J3h4uKhQEDQoGEe3RtcnR4hI6WlIaBegEDGYF8eX9/f4OKkQED6nVzb3OAgoODiomC \
h4p/eXN1dHiCiouIfn56d3mBh4B9hYCAg4eHfXh2cnV3gYuJiIeKhXyCgHNvb3R3f46T \
koyDgnl1dnp7dHeBf4SMk46DgHtzdnUBA5t+goWFg42GenZ3eHd+jIiGgX18eHl/goJ7 \
f4WAg4mKgHd5dXJ5f4eHhYeHiIOBhXlubnJ2eoiVj42Ig354eHp3dnF7gYGJkpGHfoF5 \
c3h6e3p5gIKIiYuNgXZ3d3d4hIqCgYB/fXyBg39+e4KDgIWJgnl2fHZ2gISEgoOIhYeF \
g4BzbHBzeX+OlIqKioJ9eHt2cXN1fYSFj5GLg3+CeHR7eXV1eoGEi46OiX14eHZ3e4WE \
fICDfn6Bhn98f36Bg4GGgnx3eX56fYeDgICFhoOHhn95cHBzd32GkI6HjYl/enp4b292 \
eYGHjJCMh4KBf3d4e3NwdX+ChpGSioZ8end1d32AfnyEg4CChoN8fYN/gIGBf3p3eQED \
FYWIgH6BhYOBiIN6dnN0dXqCiI2LiY0BAzR4cm1xe3yDio6Mh4aEgH95eXdwcHh/g4mU \
kYmFf3p1dXh4e3x/hoWChgEDm4GEfn+Bfnl2eXx/g4SIhoB+AQODgYZ+eHd3dXh+hoeM \
jIuLgnp4dG9teH5/iI6MiIaHgX9+end0b3N5f4WOlY6Jh393c3V1dXp/g4aGhoeFgH+D \
gQED+Hd0d3t8gomKiYaBgH59fIEBA0R7eHd7hIaIjY2Jhn55dHBucnuAg42PiYaHg35+ \
f3l1cnF0eYGJkZSNiod8c3JzcXMBAzWIAQNAhIGBgn98f3tzcnh6foaPjIqHgXx6ent+ \
fnp7fHp5gIaFAQOWAQNDdnBub3R9hImRj4iFhYABAx94cwEDRnqEjJKUkIyGe3Jyb25y \
fYKFjI6KhoOBf4B/fX13cHJ3e4KNk46KhwED73l4enx8fX9+f4SFg4eLiIWDfHFtbXF3 \
g4uPkYyEgX98e398dnV2c3eAiI2Rko2Jgnlyb2xsdYCFi5KPhoKAfX6BgH15c3ByeYCJ \
kpONiYR6dXZ1dXh9f4KEhIMBA8KFiYiFgnhua25zfYqSko+IgH17e3x+fHd3eHZ6g4iK \
j5CMiIN5b2pobHeDjJKVjYMBA3B+goF6d3NwdHyEjZOSjIiCeHRzcHF3f4OHjIiEgH5+ \
goeIhYB1bGxweISPk5CMhQEDUXoBAwMBA8Z7f4SGh4uOAQMndmxoZ297iJGUlIuAfQED \
GIB9dnRzc3qCiY+Rj4qGgXcBA8NweYOJjpCIgn16fYKHhoB7cW1xdoCKkZGLh4F6e3p5 \
eXl7e36Af4GDgoaJjYuHf3JpaGt0gY4BA8OGfn18fX59eXR0dniAhouOj42HhH50b2xt \
c34BA1GPhH57en6DhoF7d3FweH6GjJCOh4N+enp4d3h7fX+CAgAFAsaEiY2Kg3tvamtw \
fIeQkY6LggEDT3x7end0d3l9hAEDwY2LhoJ7cAEF4o6Pj4wBA6N7f4GCfXh3c3d+g4iM \
jYmCgX15eXZ3en6Cg4WDfn9/gISJjIR+d25ucXkBA+OOioeAfn98e3l5d3Z7fYCFiIuM \
i4qDf3VtbW51gImQjo6JgHx7fH59fXp4eHl+hIaKiokBA0V6dnd3enyChoSGgn5+fX+G \
iIeAfHZxcnh/hYiMiYYBA7h/e3oBA1J6f3+Ch4iLiImHgHpzbW9yeoSMj4uLhnx8e3t7 \
egEDIXwBA/yHiYeFgH1+eHZ4eXuAhYiFhIB9fXyBhIaDfXx4c3l9gIOHiYaCg4GAfXt6 \
eHl6fYGAg4eHh4aIhXx4cnBydX+Hio6LiYN8fXwBA097eXyAgoUBA42DgX99fHd4eQED \
9IiIg4QBBMKBAgAFCAZ4eHx+gIOFh4GDAgAFAq17dwED84GAhIWEhYaHgXt5c3F0eoOG \
i42Kh399fnl4eHp7eYCEAQMchoR/gn99end5eXqBhYmGhIN+AQOKgoCDg358enx+AQN1 \
hISAhYWAfnx7eHh+f4CBgYOCgYaHh4F8eXJxdnyDhYuNiISAfn0BBEB7AQMPg4WFAQN/ \
g4F9AQMveHyDhoiGhYN6eXt+AQPcg359fH19e4CBgoKDh4R+fnt5eHuBgAEDpAEDMIiH \
hYF8eHF0eH2ChouLhYWCgHsBA1J4fYCFg4OEgoABA9gBA493d3eAhoeIhoR+eXt9fn+B \
hIB9f359e3yBgIEBA8iAfXx4eHuAgn+BgX9+gIeJhoV/enRyd3p9hIiLiIaGgnx4d3l2 \
e4CDhIGDg4CBhIaEAQMwdHV7g4aGioaBfHt+fX2AgIIBA+J9e3t+gICFiYeCfXx6dnt/ \
goF/gX98gIOJiIWEfXdzdXl5foWJioiIh396eHZ4d36DgoIBA9KAAQPqgHx5dHJ4foSF \
iIqEf30BA+F9gH9/f4GAent9f4GDiYmEgHt6dnd/gQED0IB8fYMBBMqBeXV1d3h5goeJ \
ioqKhHp5dnZ3e4IBBMOCgYSKh4N/eXZxdXyAhIeKiYOBgH57en2AfQEDHXx6AQT+iIqF \
fnx3d3d9goGAgoF+fIKGhYWEgn12d3Z3eH6GiYmMi4Z8eHh1AQP0ggEDhoGChQEDYoB8 \
dnJyeX0BA98BA16Df3t6egED+AEDWgEDWYGEiYqGf3x5dXZ6f4OBg4OBfoCFhYKEgn95 \
d3l3d3uBiImLjYiAenh3dHh+gIABA9GBAQPoh4F9eXNxdHt+gIiLioeFg315eXp8e34B \
A458gIOCiIuHgQED83R5fYGCg4WDgICChYCBg4B7eXl5dnqBhYmLjIqCe3h3dnUCAAUM \
GIOCg4iJh4J+e3VydHh9foWLi4mHhX94eXl5e32AgH1+gISFhoqJAQNxd3N2fX+BAQMO \
ggEDAYB+f4B8eXp6eXiAhYeKi4qEAQMgdnZ5fwEDooSEg4WJh4OAfXhzc3Z5fYKJjImI \
h4N7d3l5d3t/gH5/ggEDQ4mJhH16eHVzeX6AgoeIhoKDgn9+fX59ent8fHp9hYaHioqG \
fnt5AQNRfQEEUYWDg4eHAQNzenV0d3l7gYaLi4iJhX14d3l3d32Af3+DhYSGiIiEfnp3 \
dHMBAxGChoqIhIODf3x8fHt6e319fH+DhoaHiYZ/ewEDcnh8f4ABA4EBA6OGgn5/fXd1 \
d3p6foWJAQMBh4F7eHd3dnoBA8OChoWEh4iEf3x5dnQBAxGBhYqKh4SEgXt5e3p5en5/ \
foABAz4BAwGBfHp5dXZ8gICChYaEgwEDIX59fHp3eHsCAAUNPoeIiIMBA+MBBcMBA5OG \
hYWIhX98e3cBA1F9gISIioiFhYJ9eHh5d3l+gYABA+OEhYWFgX15eXd3eoCBgoUBBMKE \
gH0BBcN8fn6AhIaFAQOSfnt5dnV5fX+BgwEDEAEDMoB8e3l2dnt9AQOyAQPBhoN+eXZ4 \
d3h9goKChIYBA0CEgX0BA/QCAAUJtIQBAx6Cg397e3t7enx/gH9/ggIABQSGgHsBA0F4 \
AQTDAQRRhIMBA1F7eXd6fn5/hIeIh4eFgHt3dgEDIIEBAxuGhYKCgwEGUXp+gIODhoeF \
g4KAe3h6e3t9gYKAgIECAAUMX4J9enp4d3t/gQEE04MBAyF9ewIABQGGf32AhYeGh4iC \
fHh2dnd7gAEDK4UBA5KCAQNRewEDRAEE04WHh4SBf3x4eAED8YKEgYCBAQOWg4SCfwED \
QHl6f4CBg4aEgoMBAw98fXwBAwR+fn2CAQPBh4V+enh3dgED44QBA1KDgYGAfgEDkHp6 \
fgEDMYSHAQMSgH15eHl8foCEhAEDogIABQNAf358AQN0foCBAQMzAQQxAQNNfX1+f359 \
AgAFDdKGhoJ8eXh3eQED1ISGhYSCAQNRfHt8AQMDf38CAAUBx4QBBB8BA7GBg4WEAQRu \
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 \
BFE=

#---------------------------------------------------------------------
# Compressed "briefmeow" sound.

lappend gdata(list_sounds) briefmeow

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    briefmeow_bxdiv_lz77_base64 ""
append briefmeow_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEgAEEAYEBBQYBBwEBDQ2AfwEREgEKJAEOGIEBDw8BETUBFQEBBDYB \
IysBFiMBJ2QBKgEBBO4BLgEBG4OBAQYdAQoiAQcKAgAaASgBBAwCABQBEAEr6AEGKwIA \
BQG2AQdOASfCAQ+sASvyAQyyAQsdAQgLAgAYAj4BExUBLhkBEhgCACgBKAEm5wEmTn8C \
ABEB4AIAFAEYAQ5UARBaAShsAR68ASxGASRgf38CABAD/YGBf34BDBMCAAUCYwEDEwER \
eAEFOgEIDIKCAQUnAgAOA/YBAxMBCyWBAQVMgYB+AQMTAQUWAQUFAQY4AQRyAQomggEP \
XgEGGQEHEoEBAzIBBSUBAwcBDCUBAw8BBEwBDjcBDYQBAyIBBAMCAAYDBQIACAGlAQaW \
AQtwAQUhAQUpAQpeAQRsgwEElgIADQE9AQUTAQQlgYIBBByCgoF/AQUJAQeEAQNJAQOS \
fwIACQN8AQX9AgAFAk2CAQM1AQMDAgAMA0gBCt4BB54BBF2BgX4BBV4BBP0BBAOCgH4C \
AAUBKwEDQgIABgF2fgEES38CAAcBnQEDfAEEu4IBBF4BBsEBBbsBAxaDgQEEMgEHzgIA \
BQFxAQjmfwEGsgEDR36CgwEDWAEDEQIABQFZAgAOAiF/AQj9fgEEL3+ChIB9gAEDZgEF \
SgEGngEDqH+AAgAIASIBA0QBA62EAQO9AQSfAQUhgwEEbn9+fn59AgAHASMCAAgCeYOC \
fX2CgX0CAAUDYQEDDQEDlwIABgEcAQRMggEDYQEDZoB+gYOAAQMiAQPnAQMWAQSgAQNT \
AQT6foKFAgAJBIABBS9+AgAFARABBgyBAQMofn4BA7MBBDUBBO4BBI6BAQPKgHx/hYF9 \
gIMCAAYCDAEDcH2AgX59goSBAgAFAcd/AQX8hIR/fICBfXwCAAUBJQIABQFYf34BAxB+ \
g4QBAwwBBFgBBH4BA8p+f4ODfX4BBNIBA+IBA64BA2SAAQO8AQPugQEDPgEE1QEDDoF8 \
gYQBA6wCAAYBaIGAgQEEzAED9QEEcYMBA1gBAwUBA6SDfnyAAQTSAQRLAQO9AQNbfYF/ \
e4CEgwIABQHCAQOvgAEDcAEDS3+Df30BBH0BBZaCfgEDon19g4UBA+6DAQMyAQSRAQPm \
fn2GhHt9hIABAwsBA4oBAz6BhAEDBAED8QEEl3x/AQTcggEDcIeJfHyFgn6Cg4KBf4IB \
BBiAAQOpAQMwAQMmfn+EgQEEMn97goh9e4WDfIKFgn8BAx16AQNWAQMMgQEE+359foWG \
fYCGgHt/g4J8fYSCfIABAyWChH55f4N+AQVWAQTFAQOQhH9/hYEBA8sBAzMBAyl+hIF8 \
gAEDJYCDAQSwAgAFAbp/AQPshX1/ioN3f4aAAQMdgXt/hoF6gYYBBd4CAAUBE4ICAAQA \
/wED+YB9hIQBA4R/e4CDAQNGhoF7goUBAyWCAQMlAgAFAc2Cf32AgH+BgYOFfn0BA61/ \
AQPefoWFfH+IgHqDg3t/hAIABQGDgX8BAyKBfn6EhHt9g398gYMBBCWHfYCHfnuEgnp+ \
ggEEkoIBA1ODgX4BA0yEfn2Fg3oBA7l+fISHfoCIf3iDh319AQMcgQIABQKsAQR2fwED \
y3yHiH18g4N/fYKHgH6HgXeCiAEDYYKAg4IBAxR/gH+ChH9+hYB5g4iAfYKFgHt/h4F9 \
hoJ3foYBBF1+goMBBZR/foOAAQOyeYCGgAEDlYACAAUBWoWEd3yEfXuDgwEDlQEDdH+C \
AQMlgXyDhXt7hAIABgFSf4QBA9uHenqEfHgBA1mBggEEuQEDKAEDkYSBeX6DAgAFAqV8 \
foiDeYOFenyDfXiAhIF/ggEDaICBgH+BgH2BhX99g4ABBEp9fYeJfX+IfXmHg3l/hYF/ \
g4WDAgAFBHOFgAED131/g4ABA1WFfnuFh32Din15iIh7fQED3wED3oEBA0d+goV/fwED \
14SGfX2DhIB7god+fomBd4OGfX6Ggn0BA10BBEp/AgAGA7cBA+5+fQEE34GEf36HgXd+ \
AQMPgwEDa4KCfwEESoACAAUDt32AAgAGA8N+f4V9eYaFd3yFfHqDgwEEzAEDKX99ggED \
lIR8fgEEx4KDgX2AhoB8hYV5fIV9eIGFgH8BBE6BAQOJAQQlenuEgH6Eg4GDf3+GhHyC \
hXx9hn94f4WCfoKGgX4BA2iDfnqEhnsBAwd7goSBAQM1hoZ+goR9fIaDe36EgX6DhoB+ \
g39+hoF3gIZ7fIV/eYCDAQSnAQNhgoN8fYWDe4ABA0aFAQQlgH2FhHt/hn99hYF6AQOi \
gYB+goOAg4N9f4aBfIEBA2+BhYF+AQPPhIZ+foV+e4aFAQRfgAEDyYMBA016fYSBfYGE \
g32BiIJ8gYF8goZ+gYd/fIWEfIABA8qAf4KCgIKCe3yCAgAFAad+gIUBA/GAfIGDfoCD \
fXwBAzaChQIABQYeAQNkg3t6gn56AQN3gH8BAxiAgXuAAQPHhX58hIIBA/qAfwED8YMB \
A0p8fIJ+eX8BBEqGgn2BgHqBhHx+gnx+hYABA0qBAQRKg4GChAEDWoB4fQEFb4N+gYB7 \
gYV9fIB9fYICAAUBXoGAfn+CAQMlfnyGhXoBA6h/gIaGfoCCfYCHAQPIf36Cf34CAAUB \
0X99gYKDhH55AQPQfIQBA4CEhwEDGX9/iAED6QEDG357gQEDSoN/fQED4IOAe32EgH2B \
hQEDkYeBfIB+foaEfoIBA+IBA/MBAzKDgHx/g4F/gn17gIJ8fYODfX6Gg3t/gXuBhn4B \
A0uBAQM1hX9+hIV8fIaJfn6DfX2BfXqChoF9gwEDBIABBJgBA2oBAyV/hIF+hYZ/eoKJ \
gn2DgH6Egnt/AQMHgoaEfX6EAQNeegIABQETgoJ/goODgXx7hYV6AQOkAQPkgYV+foQB \
AyF9goSBf3x8hIYBA5ACAAUFCwEDnYKHfXqAfn8BA8iHf3yDgoGAe4GHAQP+eX6FgH6F \
hX6AhoF/gHyCjYR5f356gH9/hYB9hQEDOHl+hwEDBnd7g358hYV9foWEfX1+gIoBA7uA \
fH5/fYWDfYKFgX57foiFgYF7eYF+eoOGfn2Fhn16fn+GiAEDsX58AQOxgXuFh39/e3qJ \
iH2CgnuBf3kBBCWEhoIBAxyBAQNng4J5egEDCHyChoCAfXqGhgEDCX1/gHmAhn5+gwED \
8XyChIKDfYCEfHiBhgEEJYJ+fn2BhIB+f38BA8OAhoB+g4WDfAEDWQEDvn2DgHt/hIJ8 \
gIaAfIB9gYh9dn6CgoJ8gYcBA8wBA297hId+fX9+hIZ8fQEDWIGGgn9/fYKKgHV9hIIB \
BC6AfYSEgX98g4l+e3x7gYV+AQMlfn+EhH57fYSLhHh6g4N+fgEDo36FhgEDpoCJhH4B \
AxmDAQMvhQEDUoR9e36Di4h8egIABQodhoJ9gwEDBHp/iYWAf3l7ggEEJYB/hIZ/eHuB \
h4d+ewEDd3t/hYF9hIaBAQNrhYWAgn17gH15AgAFBN+HgHp9goWGfnuAgQEDFYWAfISG \
gIB7eoaGfYCCf4F9eIGFfX6EhwED8YGCggEE7X97AQNve4KHg38BBEp8fYB/AQPDgoUC \
AAUCLHt8hIOBgHuAh4F6gIiFfICIg32AfIKIfHaAg4EBBWt9ggEEuoaHfn59fYSDfICH \
g35/hYR+fH+FiHx0fYSBfX6FiAED3oIBA6eEiX14e3yChHx+hoSAgIOEfHmEiIN+enuC \
g3t8AQRBhYN/fXqDjIF3fX8BA7qAiIR/gIWDfHqCiIaCeniBhH18AgADAP8CAAYCPoGK \
hnt7fn+Bfn+GhH+BAQNceH+LhXx8fICDAgAFBrV9hoV9AQPei4l8en+Af3x/hAEESoR/ \
eX+JhoB7eX+EfAIABQJjhAEDDXuAiYh9AQUlfoYBA9oBA4J6fIaIgH19AQNce4GHgHuC \
h4F9fQED6H96foJ+en2FAQMlg4OBewEE8QEFpnkBBCWDAQPHfH6DhX15foOBfX+FhYB/ \
goSCfH0BA0p8e3+EgnqAiIZ/gIYBA8KBhYZ+d3uDgnx8g4eCfoOGgXp+h4WCgXp7hoN7 \
f4aGgX+DhH58goaFgHh6hIZ+fIWIgn6BhIEBA7CKgnoBA0qBe4CIAgAFAlF9e4CGAQMz \
eYKGfXqEiIB+goWAfAEDpoWAenuDg3p9hwIABQLTfXZ9iIeCe3iAhX14g4iBAQMlggED \
MoqHfHh9hIF5AgAHApuAe36Hh4F8d32EfgEDSgEDJYaDfHuCiIZ+dnuFgnl8hoV+AQNY \
AQMJiIqBe3p/hH14gomBeoABAyV8goeHgHd7hYF3fIeGfX2DhoJ7e4aJgXl5f4MBAyWK \
AQTQhX17AQPMf3d7hoF3foiFf32AhIF6f4aEgHp4gIZ+eYEBA8yAgwEDzIKHg355e4aE \
d32KhX19goaCeHyIh394eIKFfAEDlIN/AQTxeoKHhH8BBCUBA4uHfwED3oF6fAEEdHmA \
hn8BA0qDfX+Eg316gQEDJXp7hYd7eQEDi36BhIF7fISJhHt3gomAAQRvf3+DhXx3gIiF \
fnh6hYd6eYeIfwEE8XgBAy6Ce3d/ioJ3gIqDfn+ChYB4foeGfgEDgoh8eIWJgAEDSoR9 \
fISHhH11e4eCd32GhX4CAAMA/4B6f4WFgnl2gId8AQMpg31+hId+ewEDb353eISEdnuH \
hoB9gIeEen2JiYJ6dn6IfnR/AQTfhIZ/eoKIhoB4eIWGenqGiIJ9AQNGAQNdiIR9eH2F \
g3t+AQPff4GDgX5/g4SBfHqAhoB7AQT7foKEfnuBh4WAeXyGh3t6hYiBAQTyenmDh4N7 \
eAEDtnd+iod/fQEDunl9h4mBd3aDin52gYqDfH0BA/J4g4qHfXV5iId5d4WKgXt/hYJ6 \
fIWIhHpzfYqCdXwBA3B8goYBBs13c4KJfHaBiIN8fIWGfXuDh4Z+c3eHg3Z5hgEE4IWE \
fH6Dg4N8c3yIgAED0YeBfYGGgXyCh4YBBHCHfHqDiAEDyYOFAQSHhn91eYmGeXyHAQWo \
gnx/hYaCenWAioB5gImGf3uAhH98gIWGgXZ5h4gBA2uIAgAFDRQBA6yGhXt0gIyCeICJ \
h4EBA2x/fH+ChoR4dYaLfXqEiAEDNIKDfn2ChIV+dX6JgXh+hgEDfn6DgX2AhIWBeHeD \
hn58g4aDfnwCAAUNE4SEfnZ9iIN5fYWFAQWCfn+EAQOnd4SGfHuDAQNKfoKEgH+Bg4R9 \
dHmGg3p/hoeEfn6DhICAg4WAd3mDhHsBA/uDAQYlhYeCe3Z8hoF4gIiGgX1/AQNOAQOT \
f3V2hIV5eoQBAyUBA5ABBSV5dYCIf3Z+AQPefAEDb32Ch4R9d3qFhXp6hYaDfXuDhX59 \
AQQldoCJf3d/iIeAAgAFC82Ah4V+dniGiHx6hYmFf3uBhH9/AQPLenZ/iYJ5foeIgnx+ \
g4ABA96EfwEDRocBA0WGAQQPgn5+hIaAe3iBiQEEuYaCfXyCgX2AhYV/d3yHh3x8hAED \
nn4CAAUPTISCeneDiIB8goWFg34CAAYNaYR/d30CAAUKooWEgH0CAAUOKIOBenmChn99 \
g4QCAAYOToCBgoJ9egIABg4xggIABw6CgYJ+e36Dgn8BA4qDgQIABRD6gYF/ewEEr32C \
hQIABQ3SggEEAX15f4aBfYGFhIIBBIGDAQZJhIF+goaEgQEEfISAgoN+eX2Dg35/hIQB \
A1x/g4OCAQNxfHuEhgEE+IOAfX+DhYSBgIF7eoOFAQOSAQOkAQO3hIMBA4B7eYABA0kB \
A4CBfwEDvQEDEgEDNn6DhAEDSQEDNwEDt4OBgIB/e3yDhH8BBG6AfX0BAysBA3N8eoGE \
gQEDpISCfnx/AQM3f4B8egEFSQED7n18AQMkgoB/fXt9ggEEWwEEgH6DAQSrfn0CAAUP \
VoQBBDd9AQW9fnt7goMCAAMA/wEDnnx8AQPzgIGBfAIABQmqgoWFAQNJfwEDT4GAewEE \
7QEDEoSCAQdJf34BBVuBhQEEWwEDSQEDQn56fIKBfQIAAwD/AQRJgQEDT4F/eXqBgwED \
5wEEbXuAhIKAAQMSeQEDEgEFeQEEtoKBg4B4eICDfnyBAQOkfn0BA7yDg4B6eH+DfwED \
wgEDEnt+AQQSgn15fQIABQZ9AgAFAP+Cg4GBg314fAEDF36DhQEFEoWCgoR+d3qCg319 \
AQMSgn58gIOCg4R/eXuAggEDW4cBA54BA0+Dg4MCAAUBNX98gYWGhX98AQRbgoF8eX6E \
gQEDeQIABAD/fYKEgYKDe3Z9AQQMAQTmfX2BhAEDGnx4f4WCAQTmhYF9fIABA2yDfHd8 \
goMBA0kBAxIBBLYBA0p+AgAGCaV/hIaEfnsBA0kBBFt3foUBA0mEAQNbAQM3gwED0Hx3 \
fYQBA6SChoYBA9t/hIQBBDcCAAcHWIeGgAEFzwEDDXh8AgAFDJmFAQMlfYCEhIKCfnoB \
A8mAfgEEpYABA6WFhIJ/AQYSfwEDDIF9fgED7IKAfHp9g4IBBBIBBKUCAAUCbXx6AgAF \
AtmChIaDfXwCAAUB4Xt4AQOAfwEDJAEDEnp+AQkSfn4BCJKFhYJ8AQN/hIB9gAEEknt9 \
g4cBAxl6eoEBA3kCAAUDWQEDf4aFgn95eIABAxgBA5EBBFuChgEDtnt5gIaCAQUSgnx8 \
AQOXAQMSAQZtgYOFAQNCfgED7IJ9d3yDhH9/gYSGhYB7foMBA9p9eHuChYEBBCSEfwED \
bQIABQu8eQIABQuQgIOGgn1+gYODg4J7eQEDyICAgYSFg39+gIKDgwED7AEE2gEDSQEE \
EgEFB315AQNbgX+AgYOEAgAFAzQBAxJ4eoIBAxJ/g4YBBLaAAQOAAQNbAQO2AQSShIF8 \
AQbPeHZ/AQNDAQakfICChIWBeXcBBRKAgQEDQnyBgoKCgHl4fgIABRBsAQPVfX0BBBJ+ \
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

#---------------------------------------------------------------------
# Compressed "gunshot" sound.

lappend gdata(list_sounds) gunshot

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    gunshot_bxdiv_lz77_base64 ""
append gunshot_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkBAYB6go54fqyoiKSEfKaMjoyUimxuepxyXnx2cnx6ZGJ8imhOYH50 \
bG5wfnSEkHp+dnB0boyEdIiUmJaalJCGgo6UloCGlIiOhoiMfoickIyGjqCAhJCQknhq \
en5ucGxsZGR2en6AiIaEmKKKcnaIiHZ0foKMlJSIfoyOhHyEio6UfG5kbFRkgGp8XmKK \
amp+enpsanQBAwVsalpmamJ0cHqCiI56fnp0ZmpygoJufHqIfGyGnpRsanJ6jJaKfHJw \
eHiEfnB4fnZqaHp6cHqAhoCQnpqQhoSEioBycGZifGpgaGR6hIaGfoKQhGpydmp8koKC \
hHZ0inpodHqCdHh0aHZ6YmIBA+uEmohyZGqChpaMgIp4eoKCdm6AeHx4dnhqcmiCAQPo \
jIyMhAED1paWAQOxjoqalISGjpaWpKyakKCemox2jpiWoJSSjn6ChAEDrZSYhniChICE \
jIiAenR+ioyGjo6OhnyMioJ+iJB6fIJ2cnB6dnB+fnp2fIB4fnhwfHKIpJSMgIaSioZ0 \
cHRoanqCeH56bnZmcHB0fmpscnp8fnh0fIB0AQM1eHZ6doCIAQMIeHp8eHR0fnpsWlhq \
bnR8goIBA00BA61+foKGAQMBiHByAQSBdoB0dIR4cHp6cm5ygoqAcnhyanBsbmxkZGRw \
dG5ybmxqamxodHqAiIZ+hISCkpCAgIR+gHh2fgEDRnZydHJyAQMkcHyCeHh2cHJycHaC \
AQMkgHx8goB+enh4cgEDbISMgn6AfAEDNIQBA+qAfoZ4fAED33x6eHZ8foKAhHp4fAED \
N3R0dn6CiIaMAQPahoqCgIiQjIB8enwBA6SEiIh2AQOxAQNCgoqEfH4BAwwBA3Z6egED \
YIZ8AQMBeAEDOIqEhoqEenp2bHJwbniEhgEDGgEDf3pyAQMqAQMecHYBAzxwdHoBA/d6 \
AQMPeHZ4enwBA7cBA3yAAgAFAQN+AQMPgoqMjoqAAQM3goYBA7aAgoJ+fgEDxYCAgH5+ \
AQPLgoB4enwBBDaCAQTTAQN7AQMDAQPseHgBA1QBAwUBAwoBA6B+AQOMfn6AgAEEHgED \
FQEDAXh2egEDqQEDGoCEAQWQAQMqeoABAyeAAQNgAQNJAQPYioyGgAEFYAEDFAEDBgED \
bwEDR358AQQlAQPgAQRDAQVIAQNTdHJyeHRyeAEGGAEEG3h4fAED0HwBBHUBBAN0AQPc \
AQOhen6AAQMcAQNegAEFFwEDkAIABwGMAQOrAQVhAQPggoaIhAEEAQEDHQEDrwED6QEE \
e358AQOUAQMcAQMdhoaGhAEDAwEDOAEDKQEEDIqIhoiIhIIBBN0BA8wBAzUBBFOCgoSI \
AQMlAQMHAQMNgIQBBOB6eHR2dHZ4eHYBA7YBAygBAxYBAyEBBFABA3CGhgEFfoSEAQVx \
AQSXAQNQAQOBAQR+AQQZAQOkAgAGATIBBbYBBKwBBNZ+AQMnAgAFAS4BBT0BBSuCAQQ+ \
AgAFAUGCAQN1AQaUAQQGAQP5AgAFAZMBBHl+AQgzAQVzgn58AQRWAQYWAQNyAQQgAQMD \
AQVnAQP4AgAHAQMCAAUBVgEFEwEFYwEFTwEDyHh4AgAGAXECAAUBaAIABQFdAQTpAQQN \
egEDeAEFZQEDNQEEE3p6AQQYAQMVAQUDAQUXAQRlAQe4AQXUAQVZAQVjAgAGAesBA0AB \
BwGEhoaGAQUJAQYugoSEAQUVhAEHPgEEDYQBBBSAfgED0AEFKwEExQEFTgEDlQEEcAEG \
XAEEhgEEBXh6eAEGzwEEFICCAgAGAREBBoKAAQNMAgAFARwBBf4CAAUCP3p4eAEHsgEE \
EAEFCQIABQL+AQavfn4BA08CAAUBMAIABQGbAQcBAQWAAQVGAgAFAUcBBWiAAgAFAP8B \
BAEBA1J4eAIABQKSAQYtAQMhAgAGAdkCAAUBFHwBBQYBDgEBBHgCAAYBAgEHAQEFSQEG \
PQEEFQEKeQEGHgEF8gEEfgEFgAEGgQEERAEGHQEFCQEITgEGDQEFFgEGigEMdAIABQJs \
AQYpAgAJAVIBDGcBByoBBosBCGECAAcB3gIACAEAAQnZAQeuAgAIAccBB4WEAgAGAeQB \
DVEBCDcCAAUBMQEIcQEJVQEIPQEG/AEIFwEIwAEPLwIABwJDAQiaAQh2AQSFAQ2qAQ4B \
AQ2QAQ34AREPAQxBARARAQmMAgAKAXcCAAsCJAEMrgEMPgIACQJDAgANAXMCAAkCWAEI \
eAIAEQIlAgAPAT0BDGcCAAcBIQEHAQ==

#---------------------------------------------------------------------
# Compressed "hit" sound.

lappend gdata(list_sounds) hit

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    hit_bxdiv_lz77_base64 ""
append hit_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEgIEBBgGCg4KDg4OEhIWLioWEgoSHXJ536rxWbqSOin6dhXKPb3p7 \
cGSCakRrZUVKUk82Tkc0P0JGPDpDQz9ITEpFVFRbXGJudHdrd5O1nYianrnfy7vDx8vX \
5Onu8QEFAe/t5dPGyca/vbu3sKyrpZ+bl5SOi4SAenlzamllXllRTlE+QEI6My4uKyQf \
Gh0eGhoaGBYBBgEXGRobHh4hKS4uMTU2O0FFRktPVFheZGhtcHR4fICFiIyPlZibo6mn \
rLS9ubnE0sjG3vLe3fP06uzw8fDx7e3t6+nl4+Ha0tHOwr29ure0r6ysp6Gem5aRjYuH \
gn55eHJubGllYF5aV1RQTU1KRkJBPjs6ODYvLjEvJyYtKyciAQMBICIiIyQjJiIiKSYl \
LSoqKi0uLi4zNgEDAT0+REVGSEtLT1FUV1pdXWFiZ2trbXBxc3R5enqBgXt+houJiY+S \
jpCTk5OWmJuamZqcnp2doKKgn5+goaKioqGeoaSjoqOjoqKjpAEEAaiopqqqqaqrrqur \
rq+trrCysbCysLCytAEDBbCwrgEDAaysqaioAQMzn56cmpeVlJCPjYqHhoSBfHp5dnRy \
cG1raGZjYV9cWlhWU1FQTEpIR0RCQT06OgEDqTIyMjAuLCsBA7wBAwEmJionKSorAQPF \
Li8yMjU2OTo6PT5DR0lLTVBTVVlcYWVoam5xdHd6foGEh4uNj5OVl5qdn6Klpqirra+x \
srS0tra4ury8vby+AQMBAQMGwb68vLu8vbm4uLi2tLSzsK+urKqqqKako6CenZuYl5WT \
kZGOjIsBA6mFgoF/fn17eXh3dXRycXFvb25tbGtqamgBAwFnZ2dmAQUBZWYBAwtnZ2hp \
aGoBAwFrbG1tbm9vb3BxcXJzc3V1dnZ3eHh5ent7e3x8fn9+f4CAgIGCgoKDg4SEhIUB \
AwGGAQ0BhYYBAxMBAxqDhAEDIYMBAyiCAgAHAuoBBDd/AQsBfgEIAQEIEQEDIQEEJIGB \
AQVeAQM/AQRhAQhihYeHh4gBBASIiIkBAwQBCwEBAxUBBQEBBH0BAwUBBDABBDMBBQYB \
BEEBEAEBA1oBBVwBAwQBAwYBBKEBBaYBCKeBggEEqgEMAQEGnQEMuwEMxgEOvgEKxAEG \
xwEGXQEFawEGcAEGAQEImQEHrQEIAQEIvQETAQEIvgEJCQEIUQEKXAEhAQEI6oIBBZoB \
BgwBBQYBBxcBEgEBG00BCYIBDBQBCWkBGwEBBIeBAQODAgAGAkQBMXgBCmkBEFYBCswC \
AAYBegEOHQEThwEfAQEJUwEMAQIACAImAQoBAQomAQeTAgATAVMBCA6DAQ1AAQMNAQ9Q \
ARNfARQBASA2AQQRAQVdAQwaggEDqgERLwEacQEOGgIABwLYgICAAgAFA/8CAA8DIgIA \
CQL4ARcYAQsZAgANAygCAA0DZgEaPgEaYwIABQN3ASU4ASujARQYAQUGAQsLARE4

#---------------------------------------------------------------------
# Compressed "loser" sound.

lappend gdata(list_sounds) loser

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    loser_bxdiv_lz77_base64 ""
append loser_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEgAEGAYEBBwgBDQF/AQcWAQMHAREgAQkRAQsaAQ4LfwEVGQEJEgEV \
cgELMQEdIAEWiwErAQEDgAEKNwEOQQEtTwENSAFSrAEFLwIABQENARk5AQwZAQ2MAQ8y \
ASVBAgA9AVQBEEMBBkQBG5MBOnMCABQCfgIAIQEqAgAxAdsBIzQBEB4CAAsC9QETKgET \
TAEmkwENjAEIMwELOwEFdwEJfH8BBwsBCBEBHWQBAyUBGbUCAAwDwwIABgFcAQVLfwEF \
AQEGZwEDAwEIloEBAwEBB38BByABDa4BBx4BB0EBCT4BC2EBCCEBBxkBCUMCABEDZwEE \
GgEJOwEJdwEFdQIACQJ6AQ4wAQovAQUxAQlHAQaMAgAWAQKBAQjKAQgeAQUPAQ/sAQfr \
fwEFcAEFHoGBggEK7AEDHX5+fgEEHwEGAQEL6AEHQH4BAyF/AQU2AQQ3AgAUAYUBDp0C \
AAoBFQEJ+wEJZAIAFQMQAQYfAQdlAQhjAgANASIBBKUBBMYBB6QBCRwBBRQBBUIBBUAB \
Aw2CAQSlAgAMAh4BBVUBAwgBBR8BCsUCAAYB3QIACAGOAQQ0AgAKAUkBBZICAAsBrIGC \
g4IBAyB+fn0BCaUBC98BB5IBA6J9AQMBAQQhAgAKAWABBWwCAAkBnwIABwEGAQSEAQmm \
AgAGAbIBBDQBByEBBC2CAQZxAgAJAUkCAAcBGQIABQGMAgAJAQYBBjwBCsQBB8UCAAYB \
SQEHLwIACgKfAQV1gYABA8QBA6QBCVABBswBBQwBBQQBA+V9fXwBBCEBBjABCt0CAAYB \
PQEGIQED5YCBgoODgwEFxgIABQFIAQggAQOWAQMhAQTlAQUggAEDMAIABgGGAgAGAZ0B \
AwICAAcBBgIABwHqAgAKAWcBBdgBBaQBBUIBCsQCAAUDwAIABQGTgAIABQE4AQPEfAEE \
owIABgHtAgAJAR0CAAYCsgEExX8BA+UBBsQCAAUBSAEE2wEEVgIACALGAQnEAQSkhISD \
AgAHASkCAAUCY4ABBGMBBiEBBUABA8QBBrECAAUEDgEF1wEIowIACgGKAgAGAZUCAAcD \
CAEEMwEDNH58e3x9fQEEsoOCAgALAT4CAAcBNwEDP3t7fHwBA1YBA4IBBA8CAAcCmwEF \
TwIABQFUfXwBAyF9f4EBA6GFgwEFYgIACAJ2gQEFoQEGIAEEP4aGhQEEUAEHsQIABwEU \
fgEFIH6AgoWGhoaEgX17egEDDgEDvQEFv4IBA599AQN/AQdfAQNgfnp5eXt8AQROhAIA \
BQHWgH9+fQEDv32AAQQhhIOBfXp4eHt+gIOFhYYBA68BBUABA+B7AQYgAQPvf3x6eXt+ \
gYSGh4cBA04BA559fHx8AgAHAWIBBOEBBIF8foGFhoeGAQMtAgAFAqMCAAUBgn4BBCAB \
B5EBBI+EhQEDbQIACANoAgAFAXGBggEFQoF+e3l6fH8BA4GEgn8BBFkCAAcCNwIABwPx \
AQWCegEGooQCAAYBLgIABwL5AgAFA2+BAQMjfnt4en2AhIaGhQEEggIABgM/AgALBHQB \
A1Z6eXwBA0CHAQMhAgAGA/19AQMggH19AgAFAfQBA6Z+fHl7f4KGiIiFgn8CAAUB239/ \
AQSoAQMggIKDhIUBAxYBBeQBA8OEgQIABQGOAQSmAQQGAQOjhAEDeIR/eXd3fH6EAQNh \
gQEE7QIABgWPgIABA/cCAAUBJoR/e3h3eX6AhQEDo4EBBFeBggIABQHvAQNtfn4BA4KG \
hH55dnd9f4WIAQNCfwIABQI7ggIABQLUfHwBAw4BAyGFgXx4dXl/goiKioeDAgAGAUEB \
AwUBAwJ7AQNCg4OFAQM2fHh2foGHiouIhIB5egEDeQEEI3wBAwMBA2+DhoaHh396d3mA \
gAEDYoSBe3h8foABBIIBA34BAwqBhYaIiYmCendzen6CiIgBA2EBBEGCgoCBf36BfnsB \
A62EAQNig354dHd8f4YBA6KCfHp9gIKEAgAFA39/ent9fQEDsIaFgHp0dXp/homJiIV+ \
e36Bg4WFgYB+fX0BA0wBAw0BAw6CfXdzeICEAQPDiIN9fX+AgIJ/fQEDAXx7e3yBg4SH \
AQOie3R2fYGKjIuHg3t3fH2Ag4J+AgAFAwx9fwEDbYaGAQNXenV7gAEDagEFonx+gYKA \
f4B9AgAFASQBAz+JiIiAeHFyfH8BAwqEgnx2en+AAQTDfX5/e4ABBI2Fg4SDenNyen+C \
AQTCgHl6f38CAAYDEIF7en18goSFhoaEfHVyd32CiouIg4B6eX+ChocBAyl7fHp5AQPi \
g4SFhIN/d3R0fIKHi4mIgoF8fIGBg4KAgAIAAwD/egEDz4QBA4OFgnp0cHuBho+OiYKB \
eHZ+gIKFgH9/en15fH+BhIWHhYWGgnd1en+EiYiFhH98dnuAf4IBBON+fHd8eoCIiYqK \
jIV5dHJ5fYSLiIaAfHd4gAED7QED43x9dwEDxoeHioaGAQNhc3h+hYuJhoR+AQMWgoGF \
goIBA0aAfYB6fIOGhoWFfnZxc3x/i4+JhIF8dXmCg4aMhIKBe3wBA0EBAyCJhISDd3Fy \
dn6IjomGAQNiAQOrhIOAfn15fXp7f3qBh4eIh4h9c25vfIKLk46Kg3xyd4CBg4YBA2F5 \
fHh6foGDhYmHh4d9c3V7gYWNiISDend2foODggEEQn59c3t5fIeKjY2OhXZub3eAhJCL \
hIF5dHeChIaHgXx8e3t6eHyBhIaJh4aFfHJxeH+EjI2FhH95dnyEg4SEgn+Bg4R5dnh3 \
f4SJi4mEeG1weYCKkY2EgHlzd4KGh46GgX54e3dzenx+g4mJhokBA+R0e4KKjIuFgX16 \
fYWCgIF+enyBf314d3h9h4uLiYJ3b2x5gImYlY2GfW9yfH6Ch4V+gXx7fnZ8fXuAhIiG \
i4V5eHd9hIaHh4F7enZ5gYODhYN/f4B+eXd5AQM3kZOPi3tsZnF6f4+QiYV/dnR8hIWF \
g3l6fHuEf4CGfoWGAQSxdXJwdYGIj4+IgX11c32AgIWKhYeIhYF3dHN3foqSjYyEcWlu \
e4KNkoOBe3Z5f4mNjomCeXV3fXp5gXl/igEDuol8cGppdX6IlZCLiIJ6foJ7e357foR/ \
g353enyDiZGKgoFyZ3B8iJSakYR8cHF1fwEDrYWCfnuAgnt9dnWAhYuPkYsBA3l3e32J \
h4GCgHt+h4WDhIB9gHh3d252fomTm5iOgXJiYm55i5KUiYN9dXiAiAEDPnp4e4SKAQRI \
gH2BgoSBenJyfYWHjo+Ef3xwb3p+hY+Ni4uGf3dnZW96hpKXkox/cmhwe4eNh4R8eXx+ \
hpGQi4QBAzJ2fXx6fnyEiIuKAQO4cGNteoORmpWNhnx0cnV0gIGCh4eGgnlucHWBiYqE \
hH50dXaGj5ORhXtwcXN5h4yPjYZ9eXt9fXR0cHaCi5eUlIZ6bmlyd4SMjIiHgX56gH+A \
hX+CenV5e3V+goyYk41+d2ZlaneLkpqTh353dnh/gQIABQa4io2QhXZ4bHUBA1GLin12 \
cHh+iIyMg392bnR8hoySj4yFfnRybW96fJGXl4+EeWlocH6EAQNff3+DhYyRhoJ2b25z \
gYSNf39+e4eIjImFeGthbH2NnZ6XjH9xbG1zeoaHi4qHgnt5bnV6g42MiQEDWHV5ho2N \
j4F0cHJ7fYyQiod8fXd8gH96bW90hpafnZWJc2VbZXOElJKSioB8dn58fYOCgHt7fYB8 \
gYeNlJGNfHNqZ252iI6Tk4N+d3l+f4R9eH1/ho2OjId4bmlsfo2Yko6Ccmxre4KMkYuB \
c3B2f4qQkZKIf3lubW1yfYSRmJSQgXltanF2goKDiYWFh4mKhoZ7cm5xf4WIjIV3eQED \
L5GXiH5oXmZ2ipefnIx+dGlncYOJjZGKg314eHR0gH6Ih4WIgYF+fH6Dh4SAeHMBAwiI \
i4d/fXh6fYWAf3BqdnuSnaGdi3loXV5vhpObmIyAc3Bze4KIhYB2cnp7hQEDZoiKiH9z \
bnZ2d4SNAQMMgXp7fn17fHmBgIqTkJCHe2llZnCJl5uVh3tsZ299hpGRhXhtdniGk5ST \
h4B3cWtye32Dio6OioV/dXd2cXZ3eIqKjpWOi4N+eG1qcn+HjJGHfHNxdn6Nko2Acmhu \
coaXl5+RgnVoZW6Bi44BBCd5eXd6fX58eHyGhYeKg4F6f3p1enyGiYaIhoCAeH17gomA \
e25qdHyJmpydjXtwX11qhI6UnI+De3F0dYGLhYR4dX1/hoyIiISBf3p5eoKBf4CCgoGC \
gn+FhHp7bXJ8gIuPkJCGeXFmZ3SHlJiYjH9xaG4BA+eNh3d4fHqFjpGRiX93bG1xfoSB \
iIaGhYGAfXx+eHh0c4SJjZKSjIJ7dHBweYeKiYyIfHZxdXyKk4uHcm1wc4GJk5eTgnpv \
aG5+iIuPh4N6c3l6foGAgnh6iImMj4mGfXR4cnV9ho6JiIJ9enl5f4OHhYB3anR6hI+Y \
mY6BcmljbH+OkpeSg3xzdXmCiIWEd3N8fIiPjIqDe3d3dXuChoOFfXp+e4ODhYiBf3Zw \
fYKKlJKNhHlxbGp2hY+TlI1/dm5wdYCMi4h7b3h6gIuOj4iAeG9rc4GIiImIf35+goGA \
gXp3b3CCiJCXk4x+dXJsb3iJjYuLg3sCAAUFVI6MiXtsdnSAjI+TjYR3AQPPgIuMjouB \
fXN3e32Df3x0cX+Hi5CNhwEDOHBze4aMjoiBe3d2fYCEhYCAeHF7foSSlJWLfndsam8B \
AyiRjYJ9eHV3fYeEhX5xe3qEjoyMhXx2dXZ7hoqHhYJ6eHd/hIWJgX1ycn2Ci5CPjIJ4 \
c20BBLqOkIiAeXFzeH6FhomBdn99gY2PjYh/d3FvdYGKiIqFfn5+fX6ChX58dm17g4yT \
j4sBA3lvcnuGi4qMhXt7dXl6gImEgnp1fXyEjouMhn54cnJ2f4mKioeAfHl6en+Ef353 \
dYKFi5KOiH12cG51gIuNjImEe3l2e4CDh4F9dHF8foWNkI6HAQM4cXR9hYeNiQIABQp9 \
foSAgX15f36FjIuHf3p3dXZ8hYqJiYN7enh9gIOIg4B2c3x/iI+Pi4N7dHByeIKJioyH \
fnp3eXt+hIKCfHuBgoaKAQM4e3kBA/yDh4WFgH18e36AgoSBfXd0fYCJjo6KgHt1dHUB \
A1SMAQNUeHZ6fIGFgoF7en2Bh4kBA7kBA3B4fYOGh4eCf30CAAUI9X98eAEDyoqNioZ/ \
eXRzeH6GiYkBA7x5eXuAg4aDfXl7AgAFCiaFfnl1dXh/hoeIhQIABQuhgQEDOH4BBFqL \
ioiBfHd2d3yChoiGhH57eXt+gYWDgHp6e36DiYoBA1R4dnd5foOGhoSAe3p6fYCCgoF8 \
e3+BhYmKhoF8eXYBBRuFgH97e3x/g4KCAQNAfYCFiYmIgnx4d3gBBFSIhYABA1QBA4WB \
gX18fYACAAUJFn16AQNmgoWGg4B+ewED+4GBgH4BA2+ChwEFLXcBA86Dh4iGAQPYAQO8 \
AQRwfQIABQwuhoWBfQEDln+ChIWEgX8CAAUMQ4F+AQMHgYSHhgEDU3l4egEEU4WCfn18 \
ewEDHIKAf31+gIKEhAEDzX15AQMSAQY4fHp8fwIABQwOgIKEhoWEf3t5eXwBA12FgoB8 \
AQM3gYKDAQRAfoEBAxyFgAIABgzJg4SEgoACAAUOhgIABQ5+AgAFDdQBA0h8fQEEXYMC \
AAYMzYODgX9+fAIABgyTgn4BBqYBBDd/fX0CAAUL/X8CAAUODgIABQz7AgAFDCQBAwsC \
AAUMkQED+39+fgIABQ2bggEDb3t9gIMBB1R+AQP6AgAFDxEBA3GBgYACAAgPRgEDOH9+ \
AgAFDoQBBhuDAQRkfAEDZAIABQk2fX0BA6UBBCQBBC2DhIKCAQVwgQIABQ3GAgAHEVgC \
AAcO6gIABQEefX+AAQYLAQZegoICAAcPdwIABw2igAEE6QEFegIABRCyAQQ3gYACAAYQ \
UQEDlAIABQyPAgAKEo0CAAcQpQEFzQIABQ71AgAFD1YCAAYPygIABQ2CfwED7gIABgEE \
AgAMESACAAURC399AgAHDf0BBYICAAUBIQEGXwEFzAEFZQIABQEyAgAIEyEBBfsCAAUO \
uQIACBIFAgALEzYBBsoBBXEBCM4CAAgT4wIABgFxAQjvAgAHETUCAAcSJAEIXQIABQ6Q \
AQhCAgAFD/YBBkECAAcRMAIABQ5EAgAFAZcCAAYBVgEInAIABgEOAQheAgAFDmkCAAYR \
UwIABRKRAgAJE6oCAAcR/AIABhBFgoQCAAYQLwIABxCoAgAFD9QCAAkUEAIACxKkAQUy \
AQMIAgAFEDkBAw8CAAUB2QIACBNlAgAFAXICAAgSDQIABgHQAQVwAQZCAgAFEV0CAAUB \
UAEDRAIACRPRAQdoAgAGASV9AgAFAqMBBTgCAAkV1wIACA9yAgAHARkCAAYQ8wIACRNO \
AgAGE8QCAAgRNIECAAUBfQEF8gIACBNeAgAHFEUCAAURLwEGGAIABQGjAQSxAgAJE5gB \
BcIBBQ2CAgAFB4QBBVR8fAIABQNXAQbEAQZgAgAHAYgCAAYBOQEEjH19AQecAQQcAgAI \
AXoCAAkTnwIABhCPfQIABQIgAgALErICAAcSUwIABgKkAgAGEfwCAAUDlAEDIQIABgEG \
AQxEgQIABRRAfgEF4oOCAgAFEcECAAYCiwIAChX9AgAFAWMCAAUBXQEFmQEGiAIABwIm \
AgAHE2GAAQMhfHt7fH+BAQbPAgAGEtoCAAcT7QIABhCKAgAGAQMBA2sCAAUO/QEIsQIA \
BwNZAgAIEp4CAAUTo34CAAUB9wIABRIdAgAGAVkCAAYVDQIABgLCAgAGFbcBBOgCAAYB \
owIACRTrAgAGAr+DAgAGEiR6e3x+AgAFA5sCAAYC9gEFHwIABhMsAgAIEwZ8AgAFEugB \
BzICAAYC2QEHYQIABQLsf318e3p8fgIABhOYAgAHAiyCAgAFE/Z/fgIABxNqAgAFBBEC \
AAUBLgEERIKCAgAFENYCAAUCTQIABgOWAQRYfAIABRMMAgAFEmyCgQED/AIACALnAQR3 \
AgAHARkCAAgTZAEFMgEEUQEGqX8CAAUEzAIABRPFfnsBAwF9AgAGBMoCAAkT0gIABhgV \
gwEEWH99fQEGaAIABwE3AQSUgYEBAzkCAAUBnwIABQGFf358eXl6AgAHEwgCAAUE6AIA \
BwJjAQTWAgAFEnp8e3wCAAYTGQEDQ4YBBEUBBA0CAAYBF4ACAAYUHIB+egEDRH0BBDGG \
hoaCgAIABRN7AQXeg4SGhoOCAgAFAtEBA0d+goKEhgEERIB8eXZ4en2CAgAFDb8CAAYC \
KgIABRWEAQM1gIIBAyGGhIB9enh5fH4BA9qFhYUBBOuCgAEGqQIABQE0AQMTAQOae3d2 \
en+ChYiHAgAFE2J9AgAFAogBAwR8AQOJAQapfXx6ewIABhQQhIKBAgAFAiECAAYTpAIA \
BgP1AgAFFKd+fAEFUwEDp4aDfgEDOwIABQF6AgAFA14CAAYBu4ODAgAHBv+BhIMBAwx/ \
gYGBfwEEzX6AAQQ2hIKCgYMBBIp4AgADAP+BhYiJiIMBBOwCAAUDDgED1wIABQFMAQM3 \
hIF8enh6fgEEZgEERAIABQF8gH8CAAUV0AIABhaQgoSFAQbPfoSJiYiGAQMkfXwCAAUC \
ngED0Xt+gIGEhQIABQcYeXl7f4KEiAEEIQIABgOqAgAHBuqAggIABQbEhYaEgAED8nt+ \
g4aGh4UBA6d7fQIABQKafgEDOX0BBEWGh4aDfXp2dwEERoYCAAUQX4KCgX56ent8f4IC \
AAUC3YKAAQNqgH14c3Z6gIaKjYuHgHl4eXuAgwIABRSyf3p9fn2AAQXPfXt4en+BhYaD \
AgAGBNuDhYUBA4J7AgAFAcABA5iEh4mKh392bHB3e4ePj42Mhn57eXt9fn1/f3x+fHsB \
A2OGhYN+e3p5eXp8g4iMjosBA3J3dnt/fwEDTIIBA4B/fHlycnmAiI+QjISAdnN2e4SF \
hoaFgHt9gYaGhoJ/e3VydHh+hIeLjY+KhH52cnFyeYKHjIyJiIeAenx6eHZzeYCGiIqJ \
hoN8eXd5gIGFhYB5eXt/houNioR9dWpxeoSMjIyLiX96c3F1d36EiQED5oSAAQTxfX5+ \
gISHioaDh4cBAylzdnl+gYCDhAIABhZthHxyZ2l2gpGamJWPhXVqa3IBA7mJioWBgHh4 \
AgAFF/l8fIABBLmEhYWFf3p5fXx9goiIh4V/fgED73h1dnR3g4uRk5CLf3hqZ3B3ho2T \
kI+Ge3l4fX+BgIACAAUB9YiNh4iFhn55eXV4dwEDWgEEkwEDW3YBA5J7fIGEiIeGgYF/ \
dnR2foeIjYqCeXJ2eoCKi4uGgXlsd36HjoqJg4B3cW12gIKJjoyKg357dnZxd4CDh4SE \
hoiJgH+Dg4N9dXd8f4SCgYeCfX19hoeEh350am18hZOYkY2FgHVpcHiEiYqLiIF7dmx1 \
AQMwhYSDe32AfoF5g4SFi4B6eH5/e4KIAgAFFcB/gH13en54AQN1j5OMin52bmx1eI6S \
kI2KgXR0eX+BhYKEgHx3cHSCi4eJioqFfnZzcnV9hYqOkoR9fH15eYKBgHp3eYCIjISC \
g4B4dXcBAwqNiIABAyV3gZKPiYd+dmt4f4SQioaIgn52bXF9g4WPkY+HfndxcXV8gYWL \
iHyCgYaHf4iEg35yc3h+h4iEhoR6e36Fh4aIfXdsZm9+i5yVi4l7eWtvdoGIi4iCgXt7 \
cHiDgIOLiYl7dntzfHt/hoqOiXl2fH19gYqHhX57c3qAhIN5gXpteIKKk4mOgnRtZ293 \
jJOTjoqCdmtyfIOJioh+f3Z1cXeFhIWNj4yCd3ZucXKCiY+Vhn54fX57gYiDfnd4fIGL \
jIR+gXtzcX+Hio2OgHRsanR9AQNEjIZ7b2Z2g4WQjYuBgnxzanV+fYeKkYmGgHt1c254 \
g4eOf3p9gIKBg4yHhH51b3iBg4iBg3l3dYGLjoyKgWxkWXJ9kZ6WkomCcmlue4GJi4qC \
hH54d3N/en6EiYZ+fIJ5dnl8ioqXinh3enp4g46Mh4F3dXqGgoN5c3BodYeSmZiWiHFq \
W2VzipqTlY+GdnBzfYKGhYN9fXNvdnSFho6QkY2Ad3BvcHF4iYyUjIN/f3t2eX+Ce3V2 \
fYGMiIt+eXdsb3aMkZaUjnpuZG17hZWMjYJ/bWp2g5CQj4iEfXtxcGwBBCqVl4wBAzRp \
a21/goeIgIeGjIWChwEDiWtxdISJi4l5eW1wfIuRjo2FcWFZaX2MpJ+YjIJyY2d3hYqM \
ioeAgnh6dHd3doKGjX+BhIB7dnN+gYiIe3t9hX+Eh4uFfXp4fIOAg4BycWN3gZSgl5eG \
eWZaXXWFl5uXkIh9cXJ0gn6Cg398c3R/fn6HfoSIjYV4eXtzcHaCioqQh38BA8t7fIB9 \
cXiDhIuRjIl0b2RgdIuWl5iQf2hjYXOFkJiThn9zYnB7jo+QkIR3dW5veHiCfoqPj4uD \
gAED+214goWDg4WAi4aEh4KBc3BxfYWQj5GBdGxteoSWkJOGfGdXZnmMnKKWjIF5Z2Z3 \
goWNkImCfXt0enZ3e4CEioF6g4WDeHp8goSFfHl/h4OEiIWAe3x1foCDhoR6amZkeYub \
m5qVgmhZWGaBk6CalId8cG9zgoeFioEBAwl2gHyDgYCJhIh5eYF/eHd9h4eGioN/goB/ \
fYCDb3qCg42PjYeAbGVec4eWnZyUgnJfY22CjZSXh4F2aHF9iZCMjoR/d2xueHl2f4WI \
iYqHgH2AcGx3fIJ/gYmJjI6FhYF/cW51e4WMkoqIb2hrboSPl5aQhG5UW2+AkJubj4F4 \
amVygo2NkoyGend6e31yfX2AiYeCiImIgHJ2e4GAfICCg4eEiH9/fnd9gAEDmYJ+b1pm \
eImapaCTgndaUmJ7jZSgloJ6dW91f4qHh4V7d211f4R8gIWAiIaBf32Fe3Z5doWDhYgB \
A4d+gHt4eGp9g4eNjYt+e2dkZnqTnKKekH1sYmVugouWk4Z/bm54go6SkI+DfXBqcnyE \
fYaJhIuJh4eBgndwbnN7eYmTkZKOhH12dnFufoWLjY+EfnNpc3iJk5eYh3txWmZ0hJaW \
mYt+cmtrd4aQlIyIfX15eX2EfXd9dH+BhZKLiYN7dXN8eXaDi4+Ih4h8en54eH6Gi4eD \
eHRlYnWClJmdl352al5jdIuPl5mNhHl0dHoBA++DgHt0eIOFjoGCf3iBen6Eh4mEe3V1 \
fX2AioyLgnx0dHN1goaMko6IgnlvYml2g5GXmo2CemtncH6Iio6GgXdwen2JkY+EfHl0 \
cniDiIN+gHyAhYWNiYeEeW5oc3Z8jpKUjod8dnVvcnuKj5GNhHt6cmx4gYqOj4qAd3B0 \
dXyPj42MhHxzcXZ/hYqMiIR/fHh8gQEDkXV6fYGNkJKPf3lvawEDpouPjImBfHl7fHyC \
iYaAAQPXb3F6f42UlJCKfW9nanaAjZCQioR+fHl+hoSCe3x6dn2CiIyGfnl2eHyCio6M \
hHpzc3l9gYqQi4iBeHZxdoCEjpGKhn56dWxseIWKkpOLg3x1bnR7goaFhYR5eoB/iYgB \
A8h9eXZ3g4SEgHp6fYKEi46Lfnhua3B2hIuTk42FfHd0dXd+iYuJhYKCfHh2dX2FiIiH \
hHp0dXZ8hIiKiod9d3h7gYSIhYCCfn57gYWDe3R0dXiCjpCRjH92b3FzeQEDC4qIAQPQ \
en1+hIiGgnt7eHR2eoGJjI2Mh352cHF4f4aIiYqEf319gIOAf3x8ent/gYeHg316eHoB \
A9CNioJ6dnZ3foSJjYmCe3l2AQPthouMhYJ+fHYBBEaHi4uKhX94dXd8f4CDhIF8f4KD \
AgAFCF18enl8gYOBfnx8AQMwioyIf3dxcHN7hYqPjYeEfnp3dnt/g4aFgoCAfXoCAAUL \
M4MBAzJ7enuAgoSHhIJ8egEDR4KEAgAGDHuCgn0BAy93foWKjY2Gf3p1dHZ9goiKhoSB \
f31+f4KEhAIABQskewEDCwIABgmVeQIABQnbhYYBAyECAAUSknx9fX2BAQMngoABAxt6 \
f4SHh4R/fAEEdAEDI4MCAAUKtQEDLoWEAQULAgAGHgQBA5d/fn17fX0CAAYhvIMCAAUf \
4wIABQzKAgAFEFp9foKEhoWCfnt4eHyAhIaHAgAGEgR9fgEExQIABg2BAgAMEGeAAgAG \
EQQCAAYPPAIABQ8WgYECAAUZKIEBBIqCAQMLe30CAAYNRQIABQ6SAgAFDHIBBGwCAAYQ \
9wEERn19AgAGDn0CAAYNGn4BBxkCAAUODH0CAAYNOwEElIACAAYO2X5+fgIABSI4goMC \
AAURj3wBBCKDAgAFIHICAAUOj34CAAUjMoGCAQQPAgAGDdcCAAUMjgEEaX58AgAFH/IC \
AAggcgIABRAcAQS1AgAFD44CAAkkDAIABg61AgAGEBACAAUQs4QBA2kBBIp/AgAGIBoB \
BfwCAAciFAIABRH3AgAFDsMCAAUPpwEFogIABSBrAgAGDlYBBNwCAAchVwIABiI9AQW8 \
AgAHH5cCAAYhcwIACA6MgICBAQWVAgAFDrYCAAclgwIABRBVAgAHJFkCAAUQMQIACSIR \
AgAJD6MCAAonLAIACRG8AgAIEjcCAAkkeAIAByMYAgAIIdwCAAcPiwIABw3/AgAKI84C \
AAgQhwIACAEWAQekAgAFDpwCAAchVAEFegIABQEuAgALEBcBBVmCAgAHEt0BBb4CAAgQ \
iAIABhJuAgAGD2YCAAgiCwIABgD/AQRpAgAIIbMCAAcCewIABg1oAgAJEj8CAAUBSAIA \
CA44AgAHEtaBgAIABiN4AQcSAQZgAQX1AgAGEmkCAAUgywEFMgIABSUtAgAIEhACAAgR \
tgIACSToAgAFIPECAAUBqH5+AQTZAQfiAgAFE4MCAAUhPAEIiwIABhI9AgAFD0UCAAgk \
cwIAByVRAgAGE3IBBwl/AgAFD7UBBrmEAgAJEtcCAAcSgwIABxQmAQarAgAFD+MCAAYB \
JwIABhCnAQOAAQjPAgAHJH8BCuMCAAUVBgIACRMoAgAIASsCAAonDgEGnAIAByPeAgAF \
AwECAAgBMAIABRRGAgAGIqYCAAYQWQIACA/zAQfPAgAII6gBBloCAAgCigIACRPdAgAI \
AWMBCZUCAAYTMAIACgGeAgAJEkEBCZMCAAcmxQIACxL+AQonf4ICAAkmPgEIuwIAChRM \
AQYKAQeeAQYgAgAHAhgBBkYCAAYlYwEIYgIABxMkAgAGAm0CAAUQnwIABhJFAgAHJtUC \
AAwoJAIABwJ1AgAHJ60CAAcDUgIACCaHAgAFEXwCAAgo4gIABhOfAgAKA2ACAAcS1wIA \
Cik9AgAIEh4CAAcUhgIABwFvfwEGRgEGUgIABgPPAQnYAgAFAg4CAAkmOQIACAQDAgAI \
JcUCAAkDDwIABxRTAgAIJVACAAcDywIACBWYAgAGAVwBBSeCgIACAAUZtH4CAAYUMQIA \
BgFgAgAKKy0BBW0CAAgB7gIABwOiAgAIFU8CAAgTGgIACANdAgAIAWYCAAgTugIABxYr \
AgAGBDUCAAYWa34CAAYCeQIABwOsAgAHAT8CAAcnmgIABRHBAgAIJ8ICAAgEugEOtwIA \
CSmuAgAIFlMCAAkkjQIACAK4AgAJBMcCAAgWRgEKmQEIMQIABxfvfX4CAAcmIQIABygX \
AgAIE8wCAAcErQIACAKlAgAGBloBCDwCAAgWnwIAByffAgAJAsoCAAcEsgIACQSJAgAG \
KGmBAgAHERgCAAUGmQIABQLoAgAHFmECAAUYaAIAChYUAQfbAgAKKgcCAAcrAgIABxZw \
AgAIKYMCAAYnhwIABhWDAgAGE5kCAAgCtAIABSaFAgAIGAkCAAkVW38CAAUC1QIACBes \
AgAJKTwCAAkptwIACBPmAgAGGBsCAAYHIgIACCp2AgAJBjsCAAUByQIABwQ6AgAIAbkC \
AAUW6AIABQIQAgAIBmACAAcF3wIABhSBAgAIATkCAAgEZwIABwTZAQVNAgAHAaYCAA0o \
EgIABhfiAgAIBAYCAAkFQQIABxcGAgAKF8ECAAUZ1gIABgE2AgAFAcACAAYHNgEEnQIA \
BQFsAgAFAfeDggIABRl3AgAFKF+DgH58fXwCAAUFiIECAAgFeQIABQKBAgAFB+t/gAIA \
BhgyAgAHJ70CAAYBJgIACBZ5AgAIKo0CAAYBYwIACwGWAgAJBvQCAAYCDAIABgEIAgAG \
B/mBAQU9AgAIAlyDAgAGJ5sCAAUmlgIABRMnfoCAAgAFJ00CAAUTmAIABRnoAgAGGJwC \
AAUFW4SDggEDrAED0gIABgkvAgAHAwYCAAYF7AIABwHPAgAGBBkCAAUmvYKDgwIABhsE \
AgAFGpYCAAcUQQIABgHGAQQ2AQQIhIWEAQMue3sBBICHAgAFFQsCAAUpEYB+fHt9AgAF \
G2B+fHl4fYGDhYYBAykBBHsCAAUBoX4CAAUXhwIABgTTfn1+fXx/gIKFh4UBBFR7e31+ \
AgAFF6aChIaGg397dnd5foKHiIaEAQRmfoGDAQO6fwIABRvphYaEgn9+egEFL4EBBGEB \
A6t7d3d6fgEFbIOBAQOKAQMaAgAFAhyChYaHhH58eQIABSjAhYB8fX1/hIYCAAUc2nNz \
eX2EiomIiQIABQpvewEEYoKDhYWEhX97fXt+gHx7f4KDhIGDh4aFfgEDPnt8goaFg4B+ \
fAED4oSDgn5zcHZ7hYyOjYmJgHdxc3h9AQSzhoKBgoODgHx6eHh6eoCGioqAfX1+AgAG \
BWt+fHuCg4WGg4KCgH18fH16eHl/g4iKh4mFgndscHR7hYiLjIqFf3d3AgAGC+J9eXyA \
hokBA6V/f3t5en2AgX19goWEh4ODAQPbeXd5fnyDh4WIiISBgIN8dnR1e3+Fio2KhoB2 \
cXd9gIiGh4V+enl6gYiIiYaCfnl2dX+EAgAFASB9fH8BBLl7d3p4foWLjIuKgX14eXp5 \
foGEhAEDH4WAfXp5fH1+goSFAQPAdXiBhYmKiIR9d3R2eoIBA2uGhH17e3+Df35+e3l5 \
fIKHjomCfHN5eXgBA8WIhIN/fX4BA+gBAwh+f359fXkBA0UBA1GEhoV7dnJxfoGHkI6M \
hH95dXZ5gISGiIB7fn6DhYeEgoF9d3V5fYiKhoaAenwCAAUS3oKFfXt1dYCCi4+IhYIB \
A0h3AQN8gYOIiYeEfXl5d3V7hIeMiH59gICBf4GHg4F8dncCAAUnR4OAfXZ3fIABA0CA \
f3Ztdn+KkJSNhIB4dXF1e4WKioeDg315e3p5gYF/g4SDfX+AfIB8fIGDh4gBA9F/fgED \
8IYBA7d8fAED2QIABRaWeH6DiIeJhH5+cXJ9gYiOj4iHgXd0c3iBhYaGg4N9dXmAAgAF \
GFGBhYF6fH1+g3p/iAEDygED0n95e3+Cg3x9AQOZhoGChYN9dHJ4AQPliYmGfnprcwED \
b4uLg4N2cXZ8homJioeCgHZ0doKEAQNGgoN/en2BhIGAenuCe3yDh4eLhn99e4ACAAUe \
V4OEAQP9f3l4e4GEg4SDgnx1d3N5AQMhjYiHgHZydXmBh4uJhoR9eHh9hAIABR9neHd+ \
gYmJgoN5d4B5fIKGhQIABSqxAgAFH32FgYB+fnt4eX+Ch4WHhYWIfHNzd3V/h4yPjYN7 \
enZ4d3+Gh4Z/dnd8gIiMiIWDgXxxdHmCh4eGg35zd3mAh4yIg4R7dGt0gIaLj4mHhX57 \
dnV1foOChYeGhIJ9ent+d4CCgoWAfHuCAQPPg4eEAQPReH6BgISKgoF/eHl9hoaDhIB8 \
eG11gIWTlY6Hgnxza259hIeLjIkBA9t5fX5/fn+CgIB7eYKChoJ3en6EhYB6e38BA6+B \
hYaDgoB9gX98gYGAeXJ4gYiNioiMg39zaG58homPkYyEgHdvcX2DhImIg355c3t+hYiC \
hIODgHZ0fYKBfoB4gYaBhoaIhIR+eHR2eneBiIqPin+AfH94bnR9hIWIhoiGf3d1bXaC \
gY2Lin1zdXV5go0CAAUhTHVxdH0CAAUZcIN/fn6AhoJ9fHRzd3mIkJOPioZ9dXB0dnyH \
i4iIhoACAAUE44ODgoOBgX55enp7e4WIiYuIgnd2d3h4g4yNjYeAfHt8f36BAQMpdXZ9 \
hIuNi4Z9eG1vdX+Pj5GLhoBzbnV7ggIABSLKe3Fxe4OGioiHhoCAeHV4e4B4f4SGjImG \
fX8BAw95AQNBe4GFh4gCAAUZ4Xd0d4CJiAIABQJTcXF/go6LjIV/fW5vd4GMkI2MhIJ6 \
cXJ3hYSHiYeFg357fX+Cfn14foJ+g4WIhYeAeXZ5fnp8gYSEg4OEgYR+eHl8hoSGhYKA \
eG5wcHiHjpSQiX94b2xzeoeKjYyHgXt2doGEgoF/f3xzeIGDjJCFg3l4fHR+g4qJhoh+ \
d3N6e4CHiYaCgHx8dXd7f4aOi4iFgn96cW53d4SLkZGKhHh4dXp6gYaFhwIABSxCh4uJ \
g399eXZ2gIWJjoiAe3R5fICOjYqEgXtybHOAg4uQjIZ9e3h2d3Z+g4iKiIOAfn96eX94 \
fYWDjIN5fX2Bgn6EAQeygIGHioJ9enx6fIOCgoiAendpdX+Hk5KRAgAGAlR8hIiPjoeC \
enh2e359goWCfn94eYOGhIiCfYJ/hIN9AQMTgISAf4MCAAUaQIODf4B+eXR7goOMjImH \
gXxzb2t8h4uWk4x/fnZzdHyFhYsBAzd1cnp9AQNBhoKAfXdzfIOFg4SBenx+g4WJhIOF \
fXV1eHN/iYeOi4WDen12b3V/hoWKioaCfXZ1dneChIqKhYB3eXx7f4iLh4SEfwEFP4gC \
AAUGO3t7gImHf354cnR1gIyOkYyFfHZ0cXR6hpCOjYqBe3l5dnqEhoeGgoB/d3d8fIKB \
h4iFh4J5dH1/f4CGhYGCgoB9AgAFCkN5eXd5g4SJjIuFfnd2bm18hY2OjYWAeXZ0dgIA \
BSbpgnx5cXiAgIWLh4eDgn15eHyBfn+Ag4SHhQEDWIR+eXl7fXt8AQNnioaDgHx3AQPw \
h4qLjIiAe3Z0cniFiouJhX16cXJ3eoiJi4qEg3pxAgAFGDuIhQIABR4LgYKAfXt4fXt+ \
iYYBA+8BAzN4dnWBhoqJh4J9fXt3en+FiIaEgn55dHh9f4iMjIyHgXp0dHwCAAUuToaE \
f316fAIABSwlfnt6gYWJioV/e3l3dniDi4yJiIN8e3h5fIKJiYWBfXl2dXt+gouJh4OB \
f3p0dgIABSR2hogBAy57AgAFINaAgX6AgoGFhIKBfQIABRTqgwIABSsUenh2fIGKiwED \
Znx2dHh/hoyMiAIABRh/d36EhYiHhYOBfXx8f4ABBASBf4CDg4aFgH99fnx6e4GFAgAG \
MVx7fH6DhYeDAQOkdnV6gIiNi4iDf3p1cnd+hokBA9OBfn16foIBA0V+fnwCAAYS/4B8 \
fX59fX+DAgAFJJUCAAUJzYSFAQM+fHt6en6Bh4iGhoF+e3d1eH+EhwIABhJCeHqAAgAG \
Efx8fQED0IWCAQV+foKEAQN9AgAGCoSFAgAGHCV6fYGEhogCAAUJSnl5fH+EhoUCAAUJ \
OQIABRG8gYEBA4gCAAUx0oMCAAYL9H+Cg4OAAQMJAQU/gn97encBBH2JiYQBBT59gAIA \
BQPifwIABjBpgYACAAUgcgIACgxbAgAFDBACAAgOXgIABR8ZfHt8fwIABgImAgAFL28C \
AAUJwAEGaIGCg4F/AgAHCU2DggIABgm2AgAFDHECAAk0lH58AgAGD7MCAAUKhgIABR4y \
AgAFH+t/AgAFIZeDAgAFMZF7e31/gYQCAAcx/gIABRJgAgAFC+YCAAYQNQEEPwEJPgIA \
BwwogQIABwrPAQR9AgAGC54CAAUffgIACA0QgAIABSJhAgAHDp1+fwIABwruAgAFDkIC \
AAULswIACAv8AgAFC3ICAAkLfwIABQ5kAgAGJTACAAcOeQIACjTcAgAKI9ECAAokZwIA \
BxMQAgAGHtoCAAYlygIACCP8AgAHEnKAfgIABiSagQEEZwIACQ5ZAgAKNQ4CAAkMgwEG \
VAIACBJ6AgAHEqECAAkS5gIACjYIAgAIDmcCAAcR5QIABgL1AgAGDPsCAAcRlwIABw1p \
AgAJEeUCAAYLoQIABhLMAgAHD+0CAAgOGwIABzTEAgAIDzwCAAkRPwIACA/wAgAMNngC \
AAcPmwIACBULAgALN18CAAcBKgELnQIACRMnAQdBAgAGNqcCAAs2zQIACzdmAgAKOOcB \
CeMCAAgmOQIACA3XAgAIIcsCAAcThAIABxG2AgAHIo8BBykCAAg43gIACA/QAgALJK8C \
AAc3ZgIACjgtAgAGI5QCAAoB3wEHiAIACzhfAgALFJkBCNwCAAYUzwIACBOsAgAJNz0B \
BecCAAgTLgIABw6vAgAIFI8CAAYCvgIABxRXAQYKAgAHEo8CAAg2rAIADAFjAQqtAgAH \
DXQCAA85LQIABQ+BAgAGJEoCAAw5egIACRR2AgAKOewCAAw5egIACDY6fwIACCe2AgAM \
EKYCAAkRKAIACCZ0AgAFIfACAAcO9gIACA6XgYMBCikBCmQCAAcNowIABxAkAQhwAQlb \
AQzbAgAKOg8CAAcDkQIABzVVAgAHFm8CAAs7KAIACAI/AQUSAgAHAzoCAAgXFYECAAcP \
xgIABxXBAgAJEb4CAAk4egIAByT5AgAHOg8CAAUN+wIABhdnAgAHJpcCAAYlkAIACBWT \
AgAMO50CAAk4lQIACDiBAgAKAj0CAAcWKwIADhP6AgAJOMQCAAc5yAIACxJ2AgAHA/QC \
AAYDjAIACgMNAgAGEXYCAAYEHwIABhQOAgAHIrUBC4ECAAgTegIACQGyAgAGEvACAAg4 \
9AELkwEIjAIACAELAgAIAhICAA0pegIABwFcAgAGOVYBB4oBCq0CAAo9BwIACxLsAgAL \
BGYCAAgVpAIABhBOAgAGBI4BB4kBBLoCAAcBJ35+AgAFJqgCAAcTqQIACxQSAgAMPHsC \
AAo6HIECAAUZgQEHoAIABiqAAQnYAgAJA9MCAAcCVAIABihcAgAGAcoBBugCAAcptwIA \
CBf9AQqxAgAMElkCAAcB4wEKdAIABTjJfwIABSuYAgAHKzMCAAgCdwIABTvXAgAGJDcC \
AAk68AIADQLIAgAIFPUCAAYDzQIABwEzAgAHKO4BBscCAAYCLAIABhpaAgAKA+4CAAcE \
bwIABzvnAgAGOCcCAAgBJgIADBUPAgAFFrYCAAYEFgIACD6iAgAJE+QCAAgnjgIABgRO \
AgAIOs0CAAY6OwIADj2uAgAIPcACAAUnlAEE5QIABjj/AQofAgAHOKkCAAUm+IQBBEB8 \
AgAFN22EAgAFKmsCAAYsOQIABhhRggEDPwIABRsLAgAHOlqEgwIABxTBfQIABSaNAgAG \
OgwBBEACAAUtaAIABxdXAgAGBLECAAkCqgIABRHefAIABS1lAQRsAgAGOycCAAYDXAIA \
BTjlgoF+AgAGJokCAAU6+AIABxnZAQWTAgAGEwACAAcCYwIABwVlAgAJBMgCAAYIFgIA \
BwNJAgAIBKKEAgAGKjECAAkGfQIACRU0AgAGFicCAAYDnQIABRlYAgAGAYECAAYDrQIA \
BRPuAgAIO1yCAgAFF3UCAAgqmAIABwfVAgAGHPQCAAcbvn19fgIACAaOAgAJPRUCAAUp \
gQIABQf0g4IBBvwCAAY7fAEEC4CDhIaEgn98AgAFD1yEAgAGOu8CAAgVZnt7fX6Cg4WF \
g399enp9gIOGAgAFDY17AgAFB6ECAAcBjAIAB0BJfwEEYQIABQK1ggIABwO3AQRcAgAF \
ARACAAUSRIF9end5fgIABTrPggEEzQIABwj9f3x8AQSBhIODf3x6egIABi6NAQPtf4GE \
hYJ+AQO1AgAFFMIBBBSAgAIABgFzAQMhhAIABSjFfgIABilSg4ACAAYKOgIABQpZe3t9 \
f4OEhQEEgwIABQNqAgAFLBh8AgAFHDSBAgAGKXCAgoaIhoMCAAUcyAIABwTjgAEDIQIA \
BzzYAgAGCeCBAQTwgIGDgQIABhQcgwIABQlvgIKEhoJ+end2fIGEiImIf3p5en6BhYSE \
hYF/e3h6fH+EAQOAhoF7eXkBA4yFAgAFFGeAgoWFf3x9fAIABQInAQRcfoGBfn17fQIA \
BR3uAgAFEGp9AQMSg4OCg354eXp9g4aHhoeFfnl2AgAGDAMBA1d8AQVKf3p6e3kCAAUd \
9YYBA8B4eHyBhomMiYJ+eHh6fYUCAAYvqX19fwIABgPsAgAGFzx7eoABA2SDg4EBBLJ5 \
fH17AgAGBJuDg4SCg314dnZ8gIaLioiEeHN4e4ECAAU6+IF8dXd8gAEDDISEgnx4en+C \
AQTWAQT9hYeIhHl3eHd/goSGhYeFf3t5fX4CAAUe9oWEg4KCf3x8ewIABRYRhYUBA4V2 \
e36FiImJhIB6d3R4gYSGiYUCAAUUF4GDAQP+e3t3eX+AhYiIh315eHV5gYaKjoyHgXpy \
dn1/g4aFAgAHBy4CAAYLmYSDgn57f3x5f4GDhoaDggEDZnsBA/N/h4WBgwEDxYSHg4J9 \
dHB1fYONj42GgHNteH0CAAUO84OBenN0e4GDi42HhYJ4cnR/gYaLg4F+fXl+h4iFhXx1 \
eXmBggEDkoaEgXx8gH95fQED7YmHgX+BfHgCAAYYaoKDhH97dWxzfIeNi4yIfndzdXeB \
iomLhX4CAAUCnoaBfX13enl7gIKKiYWCenR6eHmFi4+PjIJ7dnJ0gIaHh4OAAgAGPWB7 \
AgAFFoyHhoN9eH15d3+AhIqHhoWEgnx7dwEDPIeGfX99e3+FjIWAgHVudHyFi5COg35u \
a3mBhY2NiIaBgnl0dHl8gYsBAwyHfXJxAQOYiQIABTE0gIiHgYJ4cHh/g4mIh4N+g35+ \
foOEfXt6fYIBAw+ChXx3eQEDpIaCg4aFfX5yaXJ9io6Uj4t9dG1sdH2Mj46IggEDKn1/ \
hIR+gHt4foCAg4WJhYd/cnx6dn+IioqLh3x4dHR+hYoCAAYRZHyEfnp+eoCGiYeIhH1y \
dXhwg4qIjIyGf3+Bfnd7e3+BhoaBfn19fIOKioOEem5veoKFjpKHf3hocYKHjpKOg38C \
AAUVu4GDh4uIhYR+eHN2gX2BhICChH5/hIeDfX9ub39/houIgn58f3t8gIWFgHt8fwIA \
BQPcggEDwn2Cg4iBgYSBfHtuaXyBiJSSjoV9dGlveYaPkAEDgXt6e4B+hoN7fXp7f396 \
f4GEg4h+dH14dn6KiYuMhn52cneBh4qGhX98AQNTgHt3fHuAhoyLhYF7cXF6eIWPiY6K \
gYJ+gHp5e3yDhYiDg3p3dnmCiY2DgHZycHmCh4+Ph357anaBg4mOj4KBf3p3cXABBECN \
ioN/dXJ2foKHiYSCfn16gYiFgYF3cXx+goyHhYF+gX2AgIaCfHx+hIKHh4KCggEDdoGD \
gIOAfoKDfXxwbHx/h5KXj4iBdWxudX2Li4qHgn56f4B9g4R8enoBAzp9f4OEh4eFeHR1 \
cXyGiwEDbH94cXN9hYeIAQMofX17g4F3AQWsioeFfXVxe3V1iYaHjIuGgIV+eHd4gISF \
iIV9e3t8goeNhoF7cnJ3goWOj4eCe3NneYODjpGNgoOAenFrdH2EjJOPiYB3b258g4KH \
iIJ9fH18hoqDgnx0cHh8hImJiIKGAQNQe357eICIhYiJg3t7fnh6hISCg4GAg4SDf3Rz \
a3mJi5eXkYB1cW1xdoaMiYqJgn6Af31+goB5fX6BgAED0IeLi4F8bmp0c4WSlpKIhXtw \
bHN/hoaLiYN/fHt7enp6fIKIioiGgHx4eHt8fnmAfoGKjIqDhH92cXR6g4aKiYB+fwIA \
BUBHeXZ2e4CFiIuJhH50dnB1hYSLkI+GgYJ5bm50gYqQl4+EfXVscXyChYaGgYF9fH+F \
hYR8e3Vre4CDiYuIhIeIf3Z0dHl5gomHiYZ+enp7fn2CgYSDgYOBhoN+c3VudYeIlZCM \
g3V1cnN3gYyJiYmFgICCfH+AgAIABS7kfICBiI6Mg3pyaXR6hJGSk4iCf3Jxc36Ih42I \
hoJ+eXl5dn9+AQNnhgEDeHp4fnt9d3eBg4qNi4iBgXtydQEDDIaHgIF/gIGEgYB7d3Z4 \
hIOHh4WFgnp5dXGChIqPAQPifHltbniEjZCTAgAFN0d0fIOGg4OChYJ/gYKEhX96dnB8 \
ggEDwYoBA9p/d3R1fHoBBMWFgXx9fIB9fYGCAQPFgISCfXZ0c3GBiI+QioN4dXl1eH6G \
h4aLhIF+f3t9f4GAen58f3x/goWMioZ6eGxue4GQkZKMgn91cXJ7h4SLi4WBAgAFLnmA \
e4KHiIeBgXx7gIJ7fnh4goSJiYyKgoB9dXV0foSDiYOEAgAHCTd2eX8CAAUWg4SBeHZ3 \
cHd/ho2Ni4B8e3RydX2IiY+MhH94dXZ7gIaDgYMCAAYRaYOBe3x2cn+AhoyLioWDfnZ0 \
dHyAg4qJiIV+fHp7f358AgAGL3mAgX55eHl3gQEDdYmFfHp8eHp+foWGhoaDg359fHx+ \
f3x8AgAFB2KFiIaEenhybXuAipGTi4F/enZ0dwED24kCAAUSyXh8foKBAgAFMDp8fQIA \
BSQld3h9gYiKi4YBAyh1dXiAgIOHhoaEg358e3t3d36BhoiHhoSBfHd7e3h/hoeKi4eB \
ent2eHmBiYeJhIB+e3p8foSEAgAFI5eDhIKDgn4BAx12AgAFLpeKg4B9dXR2fIOIi4qJ \
gwIABUQmf34CAAU7YoGAg398e315e4SEhYeGgYCCfwIABSa2goaGAQOUf319f3t7f3+B \
hIWDhYV+eHh1cnqDiY2MiIJ8e3kBA++DhIaHAgAFBxJ8f4F+gAIABTDPAQRVfnx5dXkB \
A+KKiIR+fHgBA9KAgoeJAgAFOCR5fHt7gAEDagIABTEdfHp8fHoCAAU/L4N+fX4CAAUm \
XoKEAgAHEmp/fQEDdwIABhKefnt4AQNsgoaJiwED5AEDu3h7goSHiAIABR3SewIABRMs \
AgAHH3SAAQNSeXwCAAUxN4SBAQQpfAIABTFnhYF9AQPSAgAGJm2Eg4J/fn16e3oBA4WG \
AgAFFLwCAAU4twIABQehAQQaAQNPAgAGDBGEg4EBA9d6eHyBg4iIhoN/fnp5ensBAyeH \
hoSCAgAFCj9+foECAAZHd39+fn17fICBhIWFAQN2fnx6en2BgYMCAAY40Hx9fX1+AgAF \
F88CAAUnCHp6AQSEhoWDAQPdenx+goQBBCaAAgAFHccCAAUmA4ACAAYP4gEDngEDXQEE \
KAEEDHoBA8YCAAUL8AIABjRtf4GDggIABiH5fQIABSa2AgAFMYZ/AgAFDVwCAAUBB4IC \
AAoMRgIACDNLewED4QIABieMfQIABTFWAgAFC29/AgAFNSECAAUBrwIAByTBAQWIAgAH \
Rwd7AgAHBsUCAAYTGAEEAgIABg+4AgAGRuACAAUK0AIABSauAgAFCkoCAAUMQAIABxHE \
AgAGChcCAAUgRwIABTmFAgAFHpwCAAUIcAIAByT4AgAFDDQCAAcOngIABjNiAgAHDHEC \
AAZGbwIAChOZAgAFNPACAAUOjwEGGwIABTN4AQaRfAIAByOSAgALDaUCAAUnTAIABgPs \
AgAHOUUCAAYNbAIACDgLAgAIHxECAAY1FH8BBKkCAAoiOAIAByNhAgAIIvMCAAYUEgIA \
CCgjAQeeAgAHMt0CAAU1gAIACA3mAgAIJRYCAAkTlwIACg/tAgAHDl8CAAUSkQIAB0ZA \
AgAGDiICAAgOegIABzbpAgAJJBUCAAkQQQIADCP+AgAKFR4CAAc4qQIACA7sAgAHFJQC \
AAoQrAIAChHmAgAIDvYCABBORgIACDgdAgAJJjICAAgSSgIACUyoAgALEh8CAAoUYAIA \
ChGDAgAHOLqAAgAFFEUCAAkkOgIACEvBAgAKS4kCAAokxAIACRSAAgALSwABBl4CAAYo \
WAIACScyAgAJAQsCAAxMtwIACUx+AgAMEFYCAAc6lgIADU6yAgAIFBYCAAtNKgEJMgIA \
DE2UAgAKEKwCAAYTuwIAChERAgAKEXMCAAkBMgIACRORAgAQE1gCAAcORQIACjfIAgAL \
I+gCABQmowIACRVPAgAKJfgCAAgiRQIACiicAQk9AgAKEfUCAAkpVgIACk7mAgANTbIB \
CcQCAAYpDAELkwIADAEeAgAKFfkCAAoTnoABBDMCAAgURAIADFAtAQnFAQzQAgAIFiQC \
AAhM4QIACQ+FAgAGFQMCAAcBrwIACwG9AgAITUQCAA0BiQIACjtoAgAHApcCAAsT2gEI \
hwIACgGWAgAJExcCAAkCDgIADwFiAQsNAgAPUUoBC0QCAAgBUAIACQFIAgAMAg0CAAsB \
dAIACQJQAgAPKPUBCtYCAAhM/AIACBSEAgALUFwBCT8CAA0m7wIACAG9AgATUZsCAAwW \
GAIABhbxAgAKBAMCAA5RRAIAC0+9AQwfAgAJASECAAsULAELLgIACwM+AQ2DAgAKFhEC \
AAkV6gIACSdRAgAFBnwCAA4TzgIACihGAgAMT8UCAAgCmQIADQJqAgAIAWICAAsBtQIA \
DU/5AgAPAo4CAAwZGgIAC1GOAgAIBU4BCcQBCWwBBt8CAA8C4gENwwIACgTXAgAHATAC \
AAgUugIADgTqAgAIGVMBDBYCAAcm3AIAElFPAgAMVfQCAApRhQIAE1ETAgA6VcoCABRR \
xAIAH1UEAgANGIgBD5YBLooCACNVYQIAE1Q+AgA4VI8BPzYCABgBLgEapwEPFQEh+QIA \
BhqKAgAaVN4BGkECAAgaygIAK1YYAgAiAQUCAAoFkgIADwNRAgAcWQYBEaQCACQBbQIA \
EQLeAgAGA4I=

#---------------------------------------------------------------------
# Compressed "occar" sound.

lappend gdata(list_sounds) occar

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    occar_bxdiv_lz77_base64 ""
append occar_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEgYCAgQEEAYABBAkBBAsBBBABBAqAf4CAf39/AQMEgAEDCQEEAwED \
GAEFDX4BAwN/AQYyAQMBgX+AggEDDAEGJ38BBUaAfX9+AQYgg4IBBlwBBisBBCMBBFt/ \
gX9+fgEDRgEDEH4BAzN+fQEDZgEERQEDKH+ChYSJh4iGhYN9fHt4e3d5fHZ3dnVub25v \
dH6GjJCVlJCPjIOBfnoBA4F9fn11cW5pbnB4hYqQkZCQjoyJiIaGiIMBA1t6cGxnZmt1 \
fISKjY2IhQEDhQEDZ4OHh4iHhoJ5cG1udn2EioyKh4WCf357d3h7fH2BAQMLfXh0dH+L \
jY2PiYSDAQNcend4fX1+hYJ9d3FsbXWAiJGXkIySkIV/gXx4fX4BA6aIgnx0cXVxc36M \
j4qFhYuMhoF8hIZ7dX2ChIB6cWdyeXuBipCNgICGgn+AfHuCiYR+iJaIdW90dHV6fomL \
hH+ChHx/gXR3fn93f4yHhoV2cX+HfHeMkH98i4N5fn55fHl4e4GIf4F7ZnABAyuJjYqL \
jIR6fYR7e4B7fHqBjIF9eHB1d3h/hYyKf4aRg3uHiIR6bnl5epSEenJrfoB1fIeLfnuH \
i3x8hH+Fg319hI2PeXV2b3qBeX2Gi4d8god9fXx8h398e3iSlYCAeHmFgG57j4aCgomD \
c4eLdoB9fHRzko+Cemx6jIN9hI+Mg3yAhHuDgn+BeXyAgIuEgXZoeoiBgYOCj4yBhYWF \
inl0fnp1fYWQfnx3bHl/gn94f4yIhYZ2gpKAfYGCg3t8iYd1bnJ+e3uCioSFgId7bYSK \
gIR0d4eEiYaIg3Fsc4KDfoaGgn2FgXeFgn9+cXeDgpKFdH97eH2DjImBeH+Lg3h9jHl8 \
gnNzf42TdW95dX6DeX+Yjn+EkY93dH4BA413f36Hi4J2cnKBfG9/kouJgn+LhIKChot+ \
dXCBlIKBe3FxfYF7gYmOiHJ+inuJiHWDhnt3hJyNemxugHx5goeFg4OCAQPyjHxygH4B \
A7CJj4RybYOOf3V4jYt7iYZ4eYqAent4e398houAdXBxh42Cg4qPioF4eIaEfYF+eHt+ \
iIWBfHhwcIKEg4yDfo2OfXSOkn5zbHt8epGHf3Rvd3t8fIqLeHyMiX5+gYaKgHd5iouL \
dXt/aXeBf3yDjoV9hYmAdX2DgoJ+c3eWln18f356dXOFioKGhYWAeYGCgIF9e252koyI \
fmd4jYJ5gZOMf3mBhXmCg4F+eXx6foqGhXVpfISAgHyFk4iBAQPMhHh3gnh2fYSOgH94 \
bHZ+h31zh46Eh4R1hZJ+foODf3d6jYd2eHF7e3uEhYSEhYt3cIaJgIZ0dYeChoqMinJm \
cYWBeYeJhX6DhHd/h4OAcXeBfo2KeYJ/AQOxi4eCfYGHg4F3hIV7gHl1eYCXg3CAdXWE \
eXmPkoeDipOAcXqKAQOUe319jYd9dm9+gGx7jouKgnuNh36DgouCdXF7iIeEgHdteoB6 \
gIWMi3V3jH6Bi3h/iH13epKXfnNteHx5gIEBA5WCfoR6hIZyfIF7gH2EkYp9bXeNf3d2 \
hpF+gYeBdYGIe315eIF1g42CgXJsf4uFgYaPjIB+en+Gfn+Be3l+g4iCfn9wbn+EgIaF \
fouNhXWBk4J2cnl8doiPgntzcnp8fIWNeXyKh4aBeIeMhXp2hwEDCnuCcW6Bf3x9ioyB \
gIaKdnOHg4KAd3OJmIp8gn92eHF+iIOIhISDfXqDgn2Cf25zho6LhHJyhIN7fYyPg3x7 \
iH94hYJ+fHp7eoKKiHxudICAgX59jo2BgYiIfX92f4Bze36FhoOCcW95gYRyeo2KhoV9 \
fYuJfX6GgnpygZF/endze3t9goSHhIiCc3qHiIJ/coOFfYiOjn1sa36DeoOHh4F/h355 \
g4aCdXWAfoSPf3+HdnV/iIeBfn6GhIN/fYR+fYF2eHuLjXV+f3N9fHeHkomBhpOKd3KH \
hXl9e354g42BfHV0gHR0hIuLh3qDkYF7hYmHeXB1gwED+X5ycH5+e3+HkH5xhod7h4N3 \
iYJ5eIWYAQMfdHp5fYCCg4WFf4N+fId2d4V7f3x6kI1/dnOGhHl2fI2GgYOGeneHfnx/ \
eX91d5CIg3hrdouIfIGPkIJ/AQORg4B/f3h9f4OJgH95bXiFgIKHgYaMhn97jIt6d3Z9 \
eX2Lin57dXR9e3+JgHqGh4iBeIGLh4B4fomAhnyCfWx6AQNsg4uDgoKLf2yChYCFeXKA \
kI4BA452dXR4iIKEAQO5gnwCAAUEjXRxfoiPinhtfod9eImRhn56hYV3gIZ+fHp8en+I \
in9ycnyCgHx8jI+Df4aKfn95fYJ2en6Ch4SCeHF2gYRyeoyJhoN/AQMpfX+Hgnl0fZCB \
ent0eXsBA76FhYeAd3uEiIF/doCFfYWOjoBvan+DeISGh4KAhn96gIeDdXZ+fwEDo4CG \
eHR/h4WAfoGHgoN/fYOBfH94eXuIiXiAfXV9fHiGkIaCio6GeHKGhXh8e3x5goyCfXR2 \
fnJ4hYqJhnuFj398hYmFd3F2goaJgX1xcX57fIGHjXx1iIZ+hYF7i4B2eoeWiHlxdXh6 \
f4CBg4eFfoV+foV2eoN7gHx7kpF+dXaGgnh1gY6BgYaEeXqHfnx9eoBzfZCEhXdqe4yE \
fIWPjoJ+fgIABQfUfHh9gIWGgIJ0bQEDo4OFf4iLhH99i4h6d3l9eH6MiHx9dXN9fIGI \
e3yJg4aEd3+Nhn15gYd/hX+Ed2x8gHp8gomEgoGKfG6DhoCDeHSBjo6AhIF1d3R6AQOn \
h4SBg3t9hH6CgHB0gYmNhXlzfoN+fYmLhXx5ioN3goV9fHl7eoCKjHxwdH2Cgn1+jIyA \
gYmJfX55gIN1eYKBhYaDeHF5goV1e4eHiIR+gIaHgIKHfX14eJGEeHx3eX6BgoCDgYmB \
AQP0iIeAd36HfoCNj35yb3+IfoCDfwEDhnt8f4eGdHaAgIWIAQPieniDi4d+e3qIhn5+ \
fX6Eg3t4e3+Jf3aCfX1/AQOEhXx/i4l9dXiKh3p5fH56goOAgHl+e3KEAgAGAbqFf36N \
i393dX+Hgn+BfHYBA0aChYOFeHyDfYGHgIGFfneCjIp8fH9+fXmAgYCBg35/gH6Cg30B \
Ayt+e4GHhoR/foZ+eIKFhn6BgXx8g4F+gH9/fnqAg4KDe3p/g4OAg4qEe30CAAUJWH97 \
fHt8hISCg3l3gQIABQWRgYSDgYSGgXyAfn5+f4KBgX92eAEDCIN9gIJ8AQP8goKCgH4C \
AAUJRYSAAQO2e36BfwEDY4J/f4N/e39+fICGhYKFgXd9gQEDL4KCf31+fgEDeoB/fH2A \
AQNYgnwBBC6CAQdFgIB7AQO/AQQPgX59ewEDD4GDhQEDG4ECAAUJxgEEVX8BA9N8AQS5 \
goEBA3IBAyiDgH9/f4GDggEDJX58fH0BA/MBA58BBOF9gAEDAYKEAQQzAgAFCh6AAQTu \
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 \
A0oCAAgC7QIACQY4AgANAucCAAUIVAIACQGTAgAFCxF9fn5/gIGDg4SDg4MCAAUJUgIA \
BgEDfX18fH5+gIOEAQMBg4ICAAUMV4EBBPB9e3p5enx+gYWGhoWDAgAGARmBhAEDJoOC \
fHh1dnl9g4eKiYWDgQEDKXp7fX5/gYOCf318end+iIuKioiEAQMNfXp5eX1/f4SCe3d1 \
cHB1fIWQlI+Ijo6CfYB7eAEDcoGFhYB7dnR4dXUBAzOGg4SGhQEDKoKGfnd/goB/e3Vz \
d3l4gIqNjICBhIB9fn18f4iHgIWRi3hud3h0eoCIi4WBgoN/foJ7en2Be3+KhYKEfHl9 \
hIJ8hI+DfIuDeYEBA397fnuDiH9/fW93gHyAjI+IhpCKd3qGenp/en19gYiAfHl0e3p2 \
foWHh3+EjAEDlYSIfHF8fXuMg3p1cYB/cnyHiYJ6iYt4fIR+hYGBe36RkXZveXJ5gHh+ \
h4qFe4WFen16fYd6fnx6kI5+gHZ8iX9wfoyDgISJf3aEhHp+en95dI6PgHdseY2CfIKN \
joR9gIJ8foECAAUXl4CIgX55b3iHgX2DgoqKgoR+hIp+dnp+d3yEjH19eXF7fgEEK4eJ \
iId3fZGCAQMvhIGCgYV6bXd/fXqCioMBAzSAbnyKg4R5dYSJjISChnlxcH+Ge4OHhX6G \
gXaChH+AdXSAg42HeXh+fX18h4uHe3qJhXV+hX8BA1x3f4WOgHFyAQNifHmQkoGAio59 \
eHeChXR3fn+EioJ4cnOAgnJ4jouFhoKChQED9YmBe3J5kYR8fXV1foB7gIiGh356gIKD \
hIB7goJ5fpGQg3FnfoN2gQEDL4SFfn5+hYN3d4ABAweHhIh5cX6KhX54hI9+goV7fISC \
f3d5e4KFfoOFdXd7eoeJhoaIj4l3cYeHeIF9enmAiIOAe3l5dXyDgoaEfYeQgXmCiol7 \
bHqBeYuJf3Vye3t6f4aMfneFi3+AgHuNhHZ5go2QenN+cHOEfn2BjId9hYZ+fnt6hX9+ \
fHWMl4F7dn6Gem5+j4OEhId/d4KDfIF7f3ZwjpCEgG9xjIR6gI+Pg3p/hX1+hIJ+en5+ \
fImEgnxudoaAf4OAiY2DgH+GiHx1fn51fYSMf4F7bnl/gIR6fYmIhYd5eZGHfXp+iX13 \
hIp+cXV8fXuAhoOGgoiGb3mLgoJ8c4CHhoiCh35ucHyGeYOKhX2FhHZ+hYCDdXJ/gYqM \
fHmAen18hIyHfHuHh3t7g4F9gXh0f4CPh3J2enmCfniLlYOChZKHdHaEg3Z4fn17j4l6 \
dXN5hnZ0iI6Hh4CBioSBf4aHe3V1iIt9gHtyeYJ9e4WHiYJ5gIOAh4J6gIN8fISTinpq \
c4V4e4SFg4WDgX97gYl6dnyAf3+FhYuCc3OFiH55fIoCAAUUw36Gfnp6e39/fYSHfHZ4 \
doKMgYOGj4qAdniIfX2Aend9gYUBAyF4c3d/g4SJg3+Ni3x4iYyAc3GBfX2NhX10dH16 \
fH+Mh3h9jIZ8AQOUi3l6fYeMhnZ9fW18gH19h4uBgIiFfHl9g4R8fnh8l419fAEDF3N3 \
ioZ/h4SGfnmCf4KAentyeJGLhnppfYx+eYOSi355hIN3gYKBe3t+e4CJhIJ2bX2Ff4CA \
hJCGgQEDmoJ5e4F5d4CBioF/d3F6foR+eIOMhIaGdYOQfn1/g4J4eYyHdXd1e3t9g4MB \
A/iIe3CDiYCFd3WIgoSIh4h2aXOGf3iGiIV9hoJ1gYSCgHB3g36MinmAgXZ8foiIg3uC \
iIF+eoSBf394AQPWkIJ0fHp3g3x5jZCEgoiTgG97i392e318fY2Ie3ZyfYJxeIyLiYN9 \
i4h+gYGLhHdxfImFg394cHuCen6FiIp6eIaCf4d+fYaAeXuKlYN0bXp/d4GAg4SHgn+F \
eYCJdnmBfoB+go2MfXJziYZ6dIOQgH2HgXaAhn19e3qAe36JhXx2dHyIhYCFiY6FfHd/ \
hXx/f3l4gIGGhXx8dnF7hIGFh3+HjYR4fo2Ge3J6gXeDjYN5d3Z5fX6Cin56homDgXx/ \
jIl4eYSHh4J6gXRvgX59fYmJgIKFAQNrgYeBfnx1hJWIfX5/e3lyfooBA1WDg356goKA \
f392cYCQiYR0b4SFe32JkIV7e4iAdoQBAzB7fHmBiIZ+cXKAgX+AfYiOgoGCh4J+doGC \
c3yAgwED+HRzen+FeHmIjIOFgXmJi39/gIV+c3+RgHZ6dHt8fwEDLYSFh3V1iIaCgnR/ \
hn2IioqBb2uAhXeCiIaAgYh8eoKEhHhzfoCBjoJ8hHkBA+6Gg35+iISAfnyDfoF+dnx9 \
h4p5en52fX16h4+Fg4WQinVzhoZ4enx9eYaNgHp0dYF3dISNhol9ggEDQIGJiXlxd4OH \
g4N9AQOufXuAhY2BdYKIe4SFeoWCe3p/lIx6bnV9eHyBgYOHhX+DfXuIe3eDfXx/fY2Q \
gXdygYl8dHyNhH+GhHp5hYB9fnmAfHaKjH56c3SJinyAipKGfnx+g38CAAUWIn+EiYB+ \
eG93hIKAh4OEioiBeYeOf3V1gnp5jIp+e3Z2fXx9iIR6goqFgX5+iYmAeHyHhId8gn5s \
egIABRYig4OCh4FxfIeDgXt2fY6Qgn4BA2lzd4iAgImEgYR7e4GDf395cHmJjot8bXuH \
gHl/kYt/eYWHdn2FgXx6fXp9hYmGd215goB/fIOPiYCAiIV/enuFeXWAf4aFgnxzdXuE \
fXSDjQEDl3yAjIR+gYSBd3ONjXh6eHZ6fX+AhIWGhn52f4iEhH11hYN+iYyMempwh354 \
hIeGAQMcen6ChIJ0doOBgoyAgoN1eICIg4B8hYl+gn1/g4CAe3l7fYqGeX58dX58e4mM \
hoKIkIRxd4uCd318enqGi4J5c3h8dHiFioeHe4iOfn2Ci4d2bnuEg4eDfHF0f3t8f4aM \
e3WHiHuDgn2Kf3l6g5aLeHF4dneBfn+DiIR9hn18hnh5hXt/fXmRkn13c4KHenCDkH+C \
hoQBA92BAQMWgHh5jYqCeW56i4R9goyPhHx9goF9goN7eH5/gomBgHdveYSCgYWAh4qF \
gXyJint3e4F3fIqKfXx3dHt8gIaAeoWIhYR7e4yJf3d+iYCBgYd6a3p/fHqBiIOEgIeB \
cXyIhIN5dX+KjoR+hHlzcwEDj4SHhIGDfXyCgn6Bd3B8iI2JenJ+gX57g4+IfXmJhnR/ \
hoB8fHx4fYaMhHJve3+Af3uHkoaBgoyFe3iBhnR3f4CFh4R6cnR8hHl0hY6Gg4F/hIqD \
foSFfnR2kIl5fHV2en6AfoaGh4R7d4GGhIR7eoZ/fouOiHlpc4d5eoWGhIKEg3x8god9 \
dXqBf4WKgIWBc3mCh4B+fYeGfoR8foB/g3h4fAEDuH2CeXZ8eIKLhYSEjI5+cX2KfH0B \
A5V7iYmAenJ6d3N+h4eIg3uOinp+h4yCcnKBgIKLgXtwdn97fX6Jinl5ioV9hX6Binx7 \
e4eUhnR2fHJ6gH9/hYmDgIV9gIJ4foV7gHl9l418eHaEgnZ1iYp9hoaEAQPxfYB8fX5y \
fZGIgndqfo2Ae4ORjX98gYN8gYKBenp9fYWHgYBzb32FgIGDgomHhX1/i4Z4d35+dX+K \
h3x9dnR9AQMofH+HhoWBeIOMhH94g4N9gYOFdHF6AQO5hIaCgoGKeXOEhoOBdneFiYyC \
g4JzcnaCgnuIh4OBhXx7g4GDfnF0gIiPh3Z2f399ewEDInx/jIB4gIZ+fX15eX+Ijn1x \
c3yAgHx8kI+DgImNfHl8hn9yfX6AhoiDd3F1goFze42LhoJ+hIiFgYCHgHlygZIBA0Z0 \
d36AfYGFh4d8e4CChYR/eoKCfIOPjn9va4KAdoKDAQOVhn19focBA5OAgH+FhYaEdnN/ \
iIJ7eoWLfAEDKn+CgH95enuEhX+BgHZ5eH2JhIOEiImGeHGIh3d/fHp4gY2Df3d4enN9 \
hoaHgn2JjH56hIyFeW98hwEDEXxzAQMjf4CFiHl5h4h9gIGDi390f4iKhnt5fnl6gYMB \
AxqAgIV/fX8BA55/fn16i45/eHyGgHt8hIl7gYZ/e32EgoV+en92e4mHhHlyf4eEgYGH \
h398fYJ+f4eCd3qBfQEDp392dH+Bh4N9f4cBA/OAh4R8f358en2Fgnx+enl9foWDe3+C \
g4B9fIOKhH59gYN7gISCe3l9e32CgQIABRXTenqGAQODenqBhYWAhYV4en9/gAEDIn8C \
AAUZTgEE+HyAgoOCAgAFDFSCh4F/g4MBBAkBAwV7fX5/g4WAfn18gAEDEYWDgYKChH9+ \
hIJ+fH2AfX+CgX96e4CAfoGCgYKAfoKEg4OAgQEDfQIABRaMeXp+fX8BAwqDf34CAAYW \
zn5/gYCEhYACAAUMsgIABhjWAgAFDVJ9AQMQgIACAAUMZ38CAAYZqoABAwEBAxZ/AgAF \
I2yBgH5+fgEEO4GDAgAFFuECAAUMsn5+AQQKfn8BAxoCAAUaJgEDuwIABRboAQMFAQM/ \
f3x8AgAFEkWBAQX6AgAIGFqBAQNBfX0CAAoTC4ECAAUTGIABAxqDAQNLAgAFFgQCAAYX \
IwIABhbbAgAHEkR+AgAHF8ECAAYTuwIACQ5BgAEFrQEEMoICAAYUEQEGZgIABw2TAgAF \
GCoCAAsO+oGCAQMmAgAFGTwCAAsQxgIABRezAgAFGEgCAAYkOwIADRIMAgAHET8CAAYQ \
yQIABhoxAgAJEAQBBRkCAAUBPQIACRgGAgAGGD6BgH1+fn1+AgAJFd4CAAkV5QEF334B \
BgcBCpUCAAUZh4ABA5gCAAgWY38CAAUBVgEGGQIACRaBAgALFrICAAgSIQIACBECAgAH \
GR0BB2YCAAUPSQIABQ+xAgAGJUYCAAgUNAEEVgIABwF2AQYZAgAGAeGBAQQZAgAIGwUC \
AAcXzAIADRLgAgAKFlYBCLQCAAgYRAIACAFGAgAHFSECAAYBowIABQF8AgAJGcsCAAgB \
UgIABQItAQZ7AgAGGR4CAAcT8wIACRl1AQW1AgAHAiUCAAkZdQIACg+qAgAHETwCAAgX \
4AIACBX3AQb5AgAIEfECAAga/wIACRLwAgAGAQp9AgALErgBBmABBiMBBPgCAAkU5gIA \
ByaAAgAMFCACAAUB2wIADAFkAgAFGjgCAAsVYgIABRACAgAFFkoCAAgQKAIABhWvAgAF \
GtwCAAcC2gIADRENAgAOEZUCAAkQVwIACBaPAgAKEsUCAAgWqAIADBLvAgAJEhcCAAYC \
PQIACxQRAgAHAhQCAAURHQIABRo1AgAHAj4CAAsCXgIABxtDAgANFkACAAcZnAIACRXF \
AgAIEX8CAAcDXQIABhDhAgAFGSICAAYZgAIABgETAgAIGl4CAAgDhwIACBYSAgALEW8C \
AAwWMQEJpAEJEwIADheHAgAJAx4CAAcWbQIADAI4AgAIKAQCAAsDlgIAChkiAgAFHVYC \
AAYBygIACgMfAgALGKoCAAwR5AIABx1nAgAKGGYCAAsC4gIABgQRAgAKFUsCAAgdqgIA \
BRrJAgAJAaYCAA4SjQIACRRLAgAGGsMCAAgZ4QIAChxFAgARFNACAAcbIwEIxgIABx1N \
AgALAcQCAAwDxQIACyj4AgAIATACAAka9AIABxYSAgAOFwkBCeUCAAsb8QIABxqBAgAP \
A7wBC5ACAAsZ6AIABR4cAQzgAgAIE14CAAkBWwIACRtBAgAPFNQCAAoB9gIADBeOAgAL \
FY4CAAgWKgIACROxAgAKAhwCAA8XTQIACQQJAgASFMQBDmABHQECAAgaGwIAERUHAgAP \
FlQCAA4U8gIAEhfcAgALFZMCAA4B1QIADAUcAgAMFBMCABIXgAElXwEbxwEwAQEQogIA \
ChYmAgAJGT8CABABcgEesgETHAIAIAGFAgAmAaUBGeUCABMBkwIADQLlASN0AR+CAgAP \
GDQCADgBdgEUKgIACCCw

#---------------------------------------------------------------------
# Compressed "occow" sound.

lappend gdata(list_sounds) occow

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    occow_bxdiv_lz77_base64 ""
append occow_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkIgIGAf3+AAQMBAQYGfn8BAwEBAwx/fwEGCgEFGAEECAEFC4EBAwGC \
AQMyAQYnf4ABAw8BBDUBBQUBBkQBBUUBDAEBDREBCV0BA18BAz0BBDmBgX9+fX19AQMn \
AQRdAQQBAQk1AQZkAQRTAQcYAQZuAQRxAQOHAQMMAQNFAQSafgEFHAEEFn19fHx7AQVN \
AQYlAQMZAQfNAQUQAQUFggEFeAEEGgEDAQEIWQEEbX59f4GDgYKCg4KDAQOUe3t8fX4B \
BEkBBDECAAYBJH9+fn4BAxQBBDaAAQMSAQMrAQY4AQX1AQUnAQVvfn8BAwuDhIOEgn8B \
BJABA90BAx0BAwEBBS1/gIECAAYBAAIABwFbAQMbAQUJfgEDRgEEbwEF2IB+fYCCgoCD \
AQOKhAEDDHt6fH4BBW4BBUUBBIYBAzkBBQYBBBUBBRkBCKICAAgBlX59fX+DAQMbgwED \
0n58fHkBA81/AQSEAQVBAQWzAQTIAgAGAQ4BBVcBBRcBBhsCAAUBKAEDgoODAQSCggEH \
gnx+AgAGARsBBUF9fn59fAEEggIACgGLAgAFAXQCAAUBYgIABQEpfIGEgwEFmoOAfHt5 \
eHp9AQNtgoMBA1ABCMECAAUCUwEEogIABQEZgAEDdQEECAIABQENfgEDbIOAAQMagIOB \
AQN7eXh7AQU+AQR/AgAGAXB+fQIABwJ/AQS5gQEECn4BBF4BBA8BAxyBhISDhYQBA2x/ \
fXx6AQM8foABA3YBBKUBBbh+fX19fAEDQICCAQRNgAIACQEIAgAGAQOChIKChYWEhYF9 \
engBBngBBbQCAAUClH0BA3kCAAUBpAEDiQEDigEFjAIABgMCgYB+fYMBA8mFgwEDo316 \
eXd3eXwBA5IBBNsBBWZ+fQEDdgIABgEuggIABgEuAgAHA0wBA7x9gAEDcIaGAQMEgX15 \
eAEFOYKDAQS+AgAFA3kBAzUBAzoCAAcDgAEFEQIABwFoAQMafYYBA2+Ig4SEgnwBA3N2 \
eX2AAgAFAaACAAgBzQED6wIABgKaAgAFAfYCAAYCxgEEOAIABQEghoiEAQM4e3p4dnYB \
A+WBAQNxAQMgAQVffQEEcAEEOX8BBfcBAzQBBLF+fXyBAQMkhYaEhIWDAQVvenx+AQTh \
goIBBjcCAAgCxAIABQMIgoKEAgAGAqp9fHyCAQPyAQPihISBfAEEbnp9foABA92DgwIA \
BgL3AQTHfX4BA3KBAQQTggIABQJffnx8f4WEg4SGhYWGg4B8eXh4eX0CAAYBowEDNQIA \
BgPPAQOlfX1+fgEG3AIABQFjfHuAAQPRgwEDaYWEfXt5eHcCAAUCNAIABQN4AgAGA3cB \
Bmp/AQQygwIABgPifXwBBJmGhYODAQSceXd4fH8CAAYDpgIABgODfgIABQFCfgEDMwIA \
CALjfXt8AQSnhQEEz4B7eHd2d3t/AgAFAsEBAwEBBf0CAAcDm4ECAAYC6oKAAQNyAQSS \
hoiGhoWCend2AQMxfoCChIUBBBwBBi58fXwBA5aAAgAFAxyCgX17e34BA5yFh4eGhYF8 \
eHd1dXh8AgAGAg4CAAcCgwIABgFkAgAHA0sBBMN/AQMdhYiJiIeFfnl3dnR2en0BA2AC \
AAUBzH5/fgIABQOmfQIABQQoAQUvfX4BBByFhoaHhoJ8AQQueX2Bg4QBAxMBAzEBBS4B \
BAQBA9KEAgAFAZ9/gYSFAQMDhQEDr355dnRzdXp/ggEELQIABQJeAQRZAgAGApkBA5+E \
g4CAgoWFAQMJhISEggEELXV3egEDmgEEuIIBAy4BBFoCAAYBSYMBAyB/gIMCAAUBEQEE \
S316d3Vzdnp+AQNoAQQtAgAGAjIBBLcCAAgCEoGFh4eGhoaEAQMbAQSEcnZ9AQMSAQMQ \
AQPOAgAGA1YBBS9/gYKDAQNVjIkBAy2EgYB9enVzcnN2e4GEAQPqAQMrgH5/AgAFA4AB \
BbKAgYGBhoqKiYmIhYOBfXh1c3Fxd3t/hIcBAw+CgX8CAAUE+gEEVwEEtH+DiY+SjouK \
iIV/e3Zwa2hvd32DiImHhIEBA8aBgYICAAUGDHp5eXp7fIOOlZSLi4mHgnp4c21maHN6 \
foKJiYSBg4uIhIKFgHp5ewEDvnl+gX6CjZeYhoaIiIV5eHRtZWVye3+BAQO2hoePioOA \
g4J7en1/d3R3fYGAhpSbkYOIi4uAcnJtZ2BsfH58foiLiIiQjoN/gIWBewEDZmtweH5+ \
hJeclQEDpIuBc3FsZWFofXx7fYaNi4+UlAEDU4iEf3t0bmtydnmAjqiXi4iSkoJ4c3Jg \
Xmh0eHF6goeHjJKTkZCQiYR/emtoam1tcn6SoJyHkJWTh3d1bGNgbnNxcXeCh4uOkZaY \
mJaQioF2bGhnZmpzf56UjIyYm42CenVkZ2xwa2hwd36FiY2UnKKdlo+IgXVpYV5gbHeL \
l4yBlJ6djYB6cWptb2dkZ293fYKFjJ6jop2VioZ+dGVgYWl2iZmCgY+hno6EfHVucG9q \
ZWdweX1/f4qWoKSglY6Jh3lpYF5kdo6Pg3WPnZkBA3B0cnJxbGRlbniBfH2EkqCin5mR \
ioV8b19canyMlHB+j5uahIF6c3B2dm9nYnV+gH57ipadn6GWjomDe2dgY3GMm3l0g5qY \
hoB7cWxwdXVtZG58hYB4iJSbmKCakgEDlG1hXmiUl4BugJ6ViH5+cG5ucXZqZ2x4iHt4 \
hJWel5qYkYqEe21hX3ybj3Zwkp2Sg4JvcHJ0dG5na3eHg3Z8jqObmJONi4qCc2RdcZyT \
em+Nm5KEg2xnbXV4dWVmc4eOenqIoJuak4mAgYR6a2B1mpF5cpCXjoOEbGNocnt1Z2dz \
hYx7fYuimpmUjIN9fXhvZoOejXN2lpiNgYBnaWxwc3NwcHeHhnp/j6SYlY+Jg312cGtq \
nJiEdX+ajoV/d11kbXR3bG9zfI2AfIaUnZqVjYR7e3NtbXirAQMzkJuBf35sYmxvcHZz \
dHmCjnh/kJyWlI6Ign14cnB7oJR8fYyfiIF8cV1qam9zb3p2gouBeY6am5aJhn52dmxs \
e5GmbX6Pmph3fnVpZ2hob3Z6dH2FhnqPoJyTkop/eHJsaICZm2x+k5uTAQMia2ZqanZ4 \
d3iBiIJ+iqiYk5GMAgAFAzmVnoVwhJyUgnV7cGRiZ3B8eHd6g4l+hJOmlJGMhXNwbWt4 \
n5R2e5Cjinh4eWlhYm54dX15f4eFfJGdn5WOiHtxcGl0k59yeJOflW99eW1kZmxwdXp/ \
fYiEfoSlnZeSjHpxbm5vool0c5Woh3p4emZma3BwcH+BgIh+gpCdoJWOhXx0bW6Elolh \
fpiijnh0bGRjcG9tb36GhoF+gZampJmOf3NwcnWggmtng6eRg3pyYGpvb21sfoeJhXeA \
kaCkopeKe25wgJCNYWaFmJd5dmtpbW9pbXN8jYaDf3+KoaKelot3bXCAonZjcIujintw \
Zl50cHJxaoKKi4R3fZCaoKOUg3dyeKOOblx0n5qKd21SaHJzcHB5gouUgH6IlZuemop5 \
bnKXl35VbpCclX9vWFxpc3JydnuBjoqDg5WdmpiPfm14kZ2DU2iFm5iCcl9XaHJ1dXZ8 \
gomGgYScnJyalX1xd4ysd2Fmfp+QhHZmVWpsb3JwgoeJhnyHlp2fno96c3uUqHNfZYGg \
iX50YlhqcG9ucX6Gi4t6hpWfm5uMe29ypKJ9XGaNmY17dVZga3J0cHV9hY2GgIqapZqW \
inlrf6ObfFpwj5aLempYXmxud3R4f4KOhoKJoKKelIVxZoSenWhjdZGeiXhjWV1zb3l2 \
dH+CiYN+haSfnpmGc2yGoJ1YZXmOoH15ZldgbnN3en6Eh4eDe5OhoZuVgnJ6kaxxZWyC \
nIR6bF5WaWhvd3mHhIiIfYmdoqCahHlzf6qRZWF1kZyAdWtQaGpvc3GBhYmJhHyOnaSj \
jH5xc5Grd2Noe6GKfnJeWGpucXl5hIaGiXiGlJ6hnIl6dXutknNibZGShnZwT15la3d4 \
hYiGhoB/jZyfn5CDeG+foH9gbYCUiHd6WFphaGp3f4qPgoV8hZakoJeJfHWFo5FvX3SO \
j4N1alhdaGN0eIiTjIh7foykop6OfXR6opx9WnKKkYl0dFtcZWNwcoGPlIuBfIGXo6OU \
gXhvmKOOWm19j5Bye2BbYWRobnqKmYuFfHuPoqWYhnZ1l6SUX296jI9xfAEDHmZoa3WG \
mo+Jf32Poaadi3Nvk6WaZWZ2jZN2fGRcYGtpbXN/lpSOgXqImaKilXdqiaKgcGRuh5R5 \
d2xeWWpmbm94kpeRgnmElp+jm4Btg5+mfmdpf5B/cnBgV2Zib3B1jJeUh32EmJ2knoJw \
f5ung2lrf46EbXNkV2ZhbnF2iJOPhoCDlpqhoY5tgZ4BAx5pgJB/bHFkWmddbHF2i5CO \
g3uCmJ2hmoJwk6iicHJyhY1scWlfXmljb3N+lpKKf3uJmJ+gln5pk6iebHNyh5BveGZd \
XmdobnV/lI+IfnuImaWilHpxn6mWam17i4pldGBeYmBrbHaGnJJ+dXmNm6Wah3Z7p6aL \
ammCjodpdV1faGJybXeJm5N8dHqMnKebhXKOrp1/cmSMj4Bva1tial53b32QmY92dH6M \
oKOTfXKdr5NydWeQiXRyY11hZmB2cwEDy4lxc4KQpJuIeHavqYhrbnmThG94WGRlY2py \
fI6blHpyeomYqZOBfI25lH9xY5OJem9vVWZiX3Fxi5iZjXB4gpChpIZ3gKqufnJzbZp5 \
cW5aYGVjZHN2l52Rf259ipenkXqAl7mNdmtxjYtzbGdSbmFlb3SMnpqIcHiIk5ujgHiQ \
rLRtd3F2nXd1aV5dbGFodHOcno96bIGRmpuRcYWjsZlsbXiGkWdwYlluX2ZsdIOuln9w \
bYyTm5d6cJ+ypXJ4boOSd3RiXGFuXmxzf52ljHdvfpOdnI1ti6+skm9pfYqGaHFYXmpk \
Zm53iq+XfnFzhZ6kkXhrrLSXd3Zljol2dGFbY2hccm+EnaWBc3N+jqahhXGDu6WKcmSA \
j3xpdFNmZ2JncXqVppJ2cHiJmaaPe32pt4x6cmKYgXVtYFpnZGJycI6em4JvdoSWpZp5 \
fpq9m4BtbIeOcGtnUG5kZ25xgaGfinJwgZCcpHp0kbCvdnFtd5ttdmhaY2lkbXdzo5qJ \
eG95jZqfl2yNqa6Memh5i39uaFxYb11tcnuUqJF7bnGPmJ2Vd4Ssrpl8YnqJh2Z2W2Fr \
YGdzfIytkHtxc4OXnZSDcKyzmnx3YIuGdHVcWmRpW3Nzh5yigHVzfI+ZnYt9jLmginZj \
hYp6am5TaWVeanWDm6WLcm97jJaZjYGIt62HdXBvmAEDBFhtaGFidXeeoY96bHiLmJaR \
eYyruYF8bW2We3JrZF1zYGRwc5WilX5tbYaRl5t3gaC0n3prcoWTZnBiWnVgYGt4f7Oa \
hHVrg5OXk4l0oLGle3ZngJN0dWVjaXBXbXSBpqKEdG9xkpaXjneTsaaMfF57ioRmb1tl \
bltkcX+TsYx2bnOFmJeNgnq1rpJ2b2yOgWx0V2RoZFx1epWqnnZvc4GXmY2Ag6q3jXtz \
Yph+dW9gYGpiXnF3lqSfhGlvgpSYkoCDmL2XgG1rg5JwbWtSc2NgaHeGpaCJcWp9kJmR \
hX6ZtKl3cG97mGZzZlxwZV1od3+un4l0bHuQlZOPdpWtrYZ8ZniOhGprYF11WmZvfZOw \
k3tub42Wlo6AgauvmXhscYWLZnhfYWxoWW55ia6bfwEDTJuWj4V0o7ObfXldhoh5bGhd \
Zm1abXWInrCIdW52AQN1h4CAuqiMdGtzkH9qd1lpamRcdnuVqZx5c3WCmJaQg4GfuI59 \
cluRhXZra1ttZl1tdZCko4BwbX2QmpGFgI65ooBwa26bcm1uWG5rYmF0eKSolHluc4eZ \
lpF7g527in5oYomUcm5uWHZjYWlzia2hhHVpepCdlop6k7GxeHZmaZ52cmpjYW9eZnJz \
qKyUeXFphZSZln9/nLGad2dpep5ndWlfb2Jfand8t5yGdmpzkZiVkXWWrKqCe190j4hs \
bWNeb1tpcH2Zs458c2qGmJyUhXqnrp16aWWBknF1Y2JoaWBtdoWqmoN1b3WVmZWKeJmu \
noR6VX2KgmtxW2JqXWtwgpu2iXttbIGemI2CeLKukXV0YZCIcnphYmZnX3R3lKygenBu \
eJablIaAkLqYhHRcgZB+a3dVZ2hjZ3KFoKyOdWxxg6CWjH2AprOIeW9Wm4N3b2labGdh \
b3KaqZ97bmoBA+yThIKSup2Cbmd2nHNvb1VwaGRmb4aup4x4Z3KKnJeJeYqnt396Z2aY \
hnRtZ1l1ZGVscJ+um35wZ3ySnZOAfJawq3RvaHKhcHRqYWRqYWVwerSki3NncIyZmIt9 \
jqaukHVib4eWaG9kXG5jZGl3kbmagW9me5idkYJ4nrCneHdhfJd9cWljZHBeaXGErKqH \
dGtrjpuVh3yJramQdWB1ioxmc19jamJha32Wt5N7bWx4nJaOgnaksZl8elSHj39rbWNp \
bV1pcImlsYR0bHGEnpSKgXywr5FzcmGRjHVwZ2dpZ1trdZOso3twbXaSnI6Fgoq5oYVt \
ZHmUgWlyX21qYV5ugqCukXdtb36ZkoiBhZm4kXttW5KQe2hvYW5oX2RvkKeohndsdIif \
j4mAhqqyg3RvXaCGdW1sZWtkX2t2nqqefnBrfJGdh4SCj7ehe2xscqB3bnBla2ZgYGyG \
qqWOemlxhpeSh4CJnLiHeGlqjJNta3FicWJfZXCZr6CEdml6kJqKin+Lord4dmpslo1w \
b3JjcGFgaHKdq5uCdGl/k5qIinqNqbJydmlrnnpxcG5lbV5hbHWsqJaAb22FkZKJjXiL \
qKxodGxwonl1cW1naV5hbXuso5J+anKJlJWPinqSraVpcnF6oG1zb2pnY2BlcYOto5J/ \
a3eJkZSSh3aQrKBqcW94o291cGloY2Bkb4GropF8aniIkJOTj3SHpapndGxxoX51b2pg \
aGFjbHmnpZeCbXSGkZaYi2+AoLRudWtwnot3cGxhbGVma3OlqJqFbnCCjpach3J7lrd6 \
cGtzk5h2bmxbbmpnam+bpqCOc2x+jZmcgnJtfrCea2d0d6eFdGxlam5oY2d/m6OahGVz \
h5qgi3t1eo63j3Bme4qXgGZsam9uaWBuhZ2nl3VrepKhkX96eneZq4tobHeSlINgdnJy \
bl9mbIKapJF3cH6elop+eX95jqCZZmd3iZSKYnZ3cnJaZWx1i6mag3R1npaNg3qEg4GI \
ooReaoSHoXl1fX9vZF1gcn2bnY57doqYl4WAhIuKeW6Ki3pdhY+XknJ/dm1kWGN1e4Sc \
j4R9gJaQhYeMiox3aWl9onRvfoyXk4FzeGNnZmh1dYaSlIiJhYqOh46LiYR6cmxsfKRy \
fImTkJJ4eXtnY2JpcXSDkpCIhHaMlZeVk5CLgXNjY2d3nYd/hpCQlnx3dGFvaWdrdHeJ \
iYJ/h5WamJGQi4WAfXZnX2N2h5qOgIyPkYyBcHVqZ2djb3GAkpqLiISEko+QAQNrh4J6 \
cGNocHV6gZeMiYyVjYh9dHRqZ2RlcHiAiY6JjoyTlo2ChYmKgnh4c25ub3N2en+Knp+S \
go2KiH5jbWtqa21weH6GlpeUioSPkIN9fYCDf317d251en1+gISJi4eEjI2HeIR/gX9s \
AQNBb29xf4KEkI2Ri4SIh399fn+EgX17fXZ4eHh8e3+DhIOCfYGGhYiKhYCCgYWBeXN4 \
d3d3dIGAhIiJhYOBgYd/f4ABA4qDgH14foGCgoB+gYGAgXt8foCAfHx+gYWEgwEDD34C \
AAUTPnl7fX2EhIUBBAGGh4kCAAURRX18e3p6egEDBXl7foGDgoOEhISDfX+BgoECAAUT \
KAIABRbWAQQNAgAFF3cCAAUWe4aCgoOCfn59fHx8f4CAgYMCAAcRsoGDgQIABRINggED \
rgIABRLWAQMhfgIABhSvgoN+fgIACBe7hIWEgX6AgYF/AgAFF88CAAgXdgIABRbsgAED \
ZYACAAYRpQEER4MBA3Z/AgAFFZ8CAAUX2AIABxQoAgAFEiEBA9x+AQUYggIABRZxfX0B \
A02CgAIABRZMAgAHFYZ+gAEDQgIABxhSAgAGFocBA4gCAAYUzIIBBCoBAwEBBUACAAYU \
S4F+fHx9fHt7ewEEqH9/AgAFEuACAAgUHoCCgQIABRhnfwIAChhcAgAFARMBA0cCAAUY \
twIABRYAAgAFEjQBBR8BBPsBA2SDgwIABhg5AgAFFDoCAAUTKQIABhiJAgAFF4oBBDcC \
AAUUsAIABRTCAQUbAgAGGR0CAAUUYgIACBkuAgAFFdd8fAIABQGGAgAHGFACAAUYkAED \
NwIACBgVAQRXAQNWAQaHAQR4AgAFFLcCAAcYjQIABxTqAgAFGMV/AgAFFpQCAAcXWQIA \
BgFJAgAJGh0CAAUBQ4ECAAUZOwIACBaPAQNLAQQIfQIABQGRAgAFAbsCAAUXmAEENgEE \
GQEGwgIABQETAQYFAQVtgIMBA1eBgQIABRd7AQisAgAGGkeBAgAGGfkBBj0CAAcYzAEF \
dAEFwQEIgQIABRezAQVuAgAGAQICAAgW2gIABgIhAQYfAgAGGWkCAAgZlX4CAAcCVwEE \
4QIADhqHAQafAgAFFu8CAAUYWQIABxXBgAEDTIKDAgAGGm4BBnYCAAwazgEHNwIABQF8 \
AgAHGcgCAAYbMQIABQGbAQYfAgAFASR+AQZqAgAIGVsBBCACAAgZ/AIAChtTAgAHAvAB \
CVMCAAobTgIABRigAQguAgAKGjIBFgECAAgZ/gEFNAEYJQIAGBuYAQoRAgAMHAwBDCgB \
BdwBFFuB

#---------------------------------------------------------------------
# Compressed "occross" sound.

lappend gdata(list_sounds) occross

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    occross_bxdiv_lz77_base64 ""
append occross_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkIgoGCfoB8fH5+gIKCgH58en2AgoOAgYJ/gYCCgIGAfX59hIKGgn98 \
eoCAhYCCfXt8fYCAgn9/fn8BAwV9AQQIfoGBgX97fXp/f4KBfoJ/goCDgQEDRwEDFwED \
UH6BAQQugn+Af4SBhoGDfwEDMAEDEIB+fnp9ewEEPn1+en99gwEDQH6AfoKBAQM5gHyB \
gYUBAzF+AQOPAQMpAQMhAQRugX0BBRCAfn18fwEDFoSAAQOXf4CDAQMaAQSjgIF8f3oB \
BIcBA1h8AQMxgYIBA4l+AQNJAQRHAQMeAQNHAQMYgIKEggEDSH2BAQMIAQMpf38BBLcB \
A1MBBIcBA8Z/AQM2AQMWAQMCggEESH18gAEFXH8BAyN/AQNjAQMHAQSAAQVQAQOCAQQQ \
gQEFKYABA9iCe397gYGEAQNBfHx8fn+CfoB7f3yDhIaFAQRHgoKAgn1/e38BA0d9gXp+ \
fICBf4J8gXmCe4V/g38BAwwBA2QBA2yBAQP9fwEEpYWCgXx6eHt+g35+d3t9iZKal4yA \
cm1rbXFwcHF6kp6fnZaCdnV5cGJjZXF+naCfl4OCdIN9iYNwYWJke4Whnp2IcnttioKV \
h3ZnYWR1i6CdlX90bnqFkZWMd2FjZXqBoJiZf3VucoWLmo6IZ2dic3aampqOc3Rkfn+b \
l5h+aWNlb4ObmpZ/dGdyfo6XlIxuaWJyeY6Ri4Z2f3eGf4aCh4p7f2dzaX+Hj5SChG57 \
dYmPlZJ5dWFwa46OlI14f2uDfZONj4JxbmV5do+JjYUBA8SCgI2LjHt1Zm5vhIuSjoKA \
cHx6jo+TgnRmZm9/kJSQg3txen+QkpSAcmZkc3+SkZCBenN5f42TkoFzZGZyf5KSkYEB \
AyJ+jpGTgHBiZXCFkZeQgHlre3yXlJJ7aWFndI6VmY16dGmBgpyTinNjZWWHkJ2ShHRq \
dH+TmgEEIWhxlJSbi3hxZ4GFnpSHb2FlZpGRno+BcmR8f5yWjnRgY2OIkJ2Uh3Rmdn2Y \
mpB5Y2JjfJOamoh3Z29+kZ2SfmVhYnSWmpyKeWtsf46dk4JnYGRtlpWdjXtuaICHnZWE \
a2BiaZOTn5CAcmV+gJ2YjXFgYmIBA4KWiHVmdXyYnJd6ZWBic5KanZN5a2Z8iZ6dh3Bf \
YWSLl56ag3JhdHibnZh7AQNibo2cnZd5b2R5hp6cj3RgYWN9l5+di3NmbXyVnZt/aGBh \
ZpCenpx+bWB2gZ6dlXNgYWJ4np6dlHFkZniTnZuDZWBjZ5ifnZx/Z2FxhQEDQm0BA0KH \
n56cjXJgbHqcnZR1X2Fie52enJZ9Ympyl52WegEDQXWXnp2ahWNpbJSelHsBAyB2kgED \
QYpqaWyQlox0X2FjfJWfnZ2MamxtkYyFamBjZoebAQMgg29qe4iEd2FjZHCUoAEDinlv \
cIB/e2VjZWmHoJ+dm4J0bnmAfW1iY2Z1mKGfnY99bnh7f3ZoY2VtgJ6gnpeHe3h/f390 \
aAEDPoMBA36Uh358f4N/d21naHB8iJCUkYuEg4KEg4B1b2psdHyHiIyKiYeHiIWFfXlw \
cHIBAzqFf4aBiIiLi4WBd3V0d3uAgn59eH2AhomJiIKAfH0BBQJ/fYB+gAEDAYIBA0iD \
gn9+e3x9fX57e3x+gYKGg4aBAgAHA50BBCICAAYEXoQBAyiCgoCAfn6BgIGCAQMBgH58 \
ewEDMHwBAx4BAwR/gIGCAQNMAQUBAQUyAQYBAQQKAgAFBMYBBwEBBDqAgAEDEwIABQQZ \
gQIABQR6AQQiAQU7gQIABgQyAQMXAQZqfQEEHAIABwRJfn59fQEEkAEDGgEDVAEDGn9+ \
g4KEAQRsfwEDZQEGyYMBA90BAwF/gYMBA6t/AQNmAQRdgH+BAQNngn1/egEDGoCAAQOl \
f4J+fwEE7X8BBHR/f3wBA0wBBOgBA8ABA/YBBHMBA4CBAQSlAQP7fX5+gIKEAQTSfQEH \
JoABBBwBA4ABBA8BA1gBBp18fX4BBM+EgIF7AQMLgoCEfwIABQWffXx8AgAFBh+CfoN/ \
g30BA2oCAAUFoAEG6AEE9X8CAAYFHgEFRH0BA9uEAQYaAQN6AQRsggEDG3x8en98g4AB \
A9CBAQTRfYB9AgAGASsBA5sBBLl+AgAFBb8CAAUF+Xx/foABAwKEAgAFAToBBEd/AQUa \
gQEEDHyAAQSfAgAFBhp/AQOHAQPVgn+EgAED/AEDaXyAfYN/hYGCAQMpAQRefQEDK4KC \
gn8BAwt+AgAFAcgBA0eAgX+BfoF/AQSkfgED5YGAgH19AQPMAgAHBvMBBAV/AgAFATeA \
goEBBDN/AQUqf4OCg4IBBs8CAAUCP4GDAQXnfH1+gIKCgwED6QEDUwEDcwEDSYABBFN+ \
AQM1AgAFBpMBBtOAAQRkAQSDAQRUggED+4ECAAYCDYKCgoGBAgAHAloCAAUB9QEDNAEG \
EAEED4GAgIEBAy18f3sBA8iAgoQBBQ0CAAUBDgED6gEDZoIBA5sBA7mAfgEDNYABA2QC \
AAYByn5+AgAFAnwBAyh8f32BfQEDmIKChICAfH4CAAUBGwEDQ4F/g4ABA6x8AQZlAgAG \
BtB+fwEEBYABAyyAgn6BfIF+gAEDHH8BA1MBAxYBBCcCAAYDOwEGlH5+fQEDDwEHZAEF \
Jn8BBRIBA4QBBIp/AQOdAgAEAP+AAQNsgn8BBs4BAx8BBcKHh4eFf3VuaGltdoCLmp+d \
m5WBenBmYGJjaYKSoJ2djXtkaGuDjZWSiHxub2d4cYmBlIeQfX5yeoKLmJWTbWpgZWSN \
lZ6ZioBkdGiIgpWLj4J2cmRyaId+l4qPhn18cH96jYyYg31nZmZzh46ci5B0fm1/e4eK \
jox7eWJxZoN/l4+Qh3x6cH56jIqWgX9la2R7gpSWjIxyf2qEeZCKk4B9am1qeIKJlISQ \
dYhvhXeJhpCEf25sa3OEipmHk3ODaoN5jYuRgntobWh9g4+ThI1xhmuKepGGj3t6ZXBo \
g4KTj4iHdIFwiXyViI93dGNsb4eIl4mMeHt0fYSIloaGcGlnaoCFk5GHiG+Dbo1/loqH \
emloZ3eCj5OMiHd7c4CFjJaHgmxmaGuGhpuLjX11eXWMhZuHhnBiaWaHgZyMjIFyfW6P \
gJuJiXRjamOCgpiQi4ZwgG2LgJaPh3tjZ2V6hJKWi4pyfG+DhI6Wh4FoZGZvh4qci415 \
dXZ3i4eciIZtYmZmh4OekI6CcX0BA4Cbi4l2YmRke4OWlo6Kc3tshICRlIyAbGJkaYSJ \
m5SMg3F8boqAm42MdWZhY3GEkZuSjXt4cXmCipmSi3BoYWRujJSekIxzd219hY6Yjoxu \
bGFpZ4mJnJCRgXp4dIKAlI+afntiYWJvgJefnZt1dWFydpSenZNxY2BhZZKenZyLdmBq \
aouQnZiXhnNmYGFjdYqgn52XfHVjc3OIjJaDeGViY22Kk5+Yl4B/doGDi5GFcgEDJWSD \
mJ+ekot2gXmLhpKJgWgBBBOEnaCemIt1enaJipaKe2QBAxNskKGfnJCAdHmAi5GRiXcB \
A3JjbIaboJ2Sh3t+goiOioZ3bl9hY2l3hpOYl5CKhoOEhoeEf3l0bWxnbW97hI2TkZCI \
iIKEgoSBgH16dnNxcXN1fYKKi4+KiIICAAYEMIJ9e3d1eHh7e35/goSEhoWEgoCAgoGF \
f4F8fXp8fHx+fH4CAAUFZ4ODhIGBAgAFBN5/fgIABQthAgAFAycCAAYEyIICAAYDSgIA \
BgN0f31/fQIABgpjAgAFA3YCAAcKbAEDIYGCAgAIBq4BBxIBAzQCAAUDgAIABQRWAQYP \
AQQzAgAGC1eCgAIABQULAQRDAgAGC4YCAAUDlQEFKAEEagEEYX6Af4IBA1UBA499gICE \
g4ICAAYGIAIABQrWAgAIBxoCAAUF0oMBBLJ9AgAFBI9/AQR5AgAFBB1+fwIABQUiAQQz \
fwIABQbWAgAFBBsCAAgGrQIABQUsfXx+f4KChIKBfHx6e3+ChISEgYB8fQEDlQEE9AEE \
6gIABQRHf39+gn8BA1kBB28BBUsCAAUFA4F/f31/fYKAhAEDZnp8en+AhoWEf357e3t+ \
gIKDggEFcH19f34BA/YBBX0BA+9/gAEEbwIABQe7fn6Cg4WFAgAFB+gCAAYEnQEDIH9/ \
AQelAgAFB+B6fHyAAgAFB0sBA6cBA5IBBTgCAAUBCQEELQEECgIABQGaAgAGB+0CAAYH \
0YIBA096en6AAQPJgoB9fXoBAySDAQPUgQED6QEDTICDgYR/AgAGB/IBBCuAgoCCAgAH \
BhGAhoGFf4B4e3l/f4WFhIWAf3h7eH+AhYOEAQVpfAEDIgIABQaGAgAGByh9goGGAQOV \
fHp7fYCChIaEgXx5eXwBA82Eg4ECAAUFtQEFAQIABgihAQVdAQSMfgEELQEDC4ODf356 \
eXwBA+ACAAUBIH0BBCGAgICBAgAFAUp+gAEFmAEExAEDroKGAQO6fnh4eX6BhoWFgoF8 \
e3p7AgAFCQcCAAUHRgEDOgIABQk8AQPcAQMZfn6FhYaCgHt3eHuAhIiHhX96eAEDk4OF \
h4OAfHx6AgAFB/aDAQPLfQIABg2ZgoKCAgAFBzIBA3ICAAYH9Hp6fH6BgwEDqIJ9AQN7 \
AgAFATSCAgAFAh1+AgAFBi0CAAUCqwEDZwEDlISEhIB/fQEDnn+CAgAGAoMCAAUGw32A \
gQEE2wIABgc/fHh0cXB4go6SlpGLhYKEhYeEgG9hYWRkgImdn56YiIJtdWZyZ3R1hpWd \
nZuYg3JeYGFkZY2Zn52dlIB8ZWthamZ/ipufnZuRcV5gYmNyAQQMmYaMc3xlbWNteIuf \
np2OfWBhYml8kZ+Wl4GGfIaCe3RkbXORnp2YhGRgYmV9k6CemXp6bHx/hn51cXSKmZ6Z \
imNfYWRulaCem4N6ZHZ1hXx+dnyHlpyVh2JgY2Rsl6CdmIp4bHRzg3uDeIaImJSPemNi \
Ymh1m5yekYtzc3J4fXmAeouOnJKMbgEDqmt+npydi4lweHN7eXZ6eIuSnZaQawEDX2qE \
oJyciIVveXaAe3cBA2SRnpqVbgEDGGeBoJ2ciYRud3eCf3p4cYKLnZuXdWFhYmV8AQPK \
jYVuc3WAgnx5cn6JnZuafmJgYWN0nZ+ekodxb3V8hHx7cHyFmp2dh2VfYWNrlqCeloh3 \
bHd4hnt8bnZ/lAIABwxdZICgnwEDSWx0dYKFfHhoeH+bnZuQcF9hYmaIoZ+cin9pdniK \
hH1xZHIBA3Gck3gBAxlogp+fnYx/a3N7iYx8cmFqcJqfnZmKYmFhZHeXn56XfHdpgYKV \
gHZhYWWHoZ6cmnheYWNogQEDM4p7cXaIjZF6aWBiaJEBA9aYcAEEGoWfn5yLeHh8j4+Q \
dmJgYmeLoJ6bmnxfAQNOfJSfmpN/gIOOlot+AQQQeJ2fnZuVbl5gYmV6jJqSkomOkpSU \
f3IBAxBoeZwBAxuagV8BA+hmeYSWk56XnZSSfG9fYGFkcouhnp2bmXljAQO6ZHCHnJ6e \
nZqOiHBnYAEDK3SMoAEEOINkAQMcY3CEn58BAxyNhXNlYQEDD2+EnwEDipuOaV5gYmNp \
fJqgAQNGl4Z+ZGEBAw9oe5cBBA+ZewEEcWNwg6ABAzmbkoNzXmEBAw9ygp4BBDmVc14B \
Ax1kcocBA2Odm42AbQEEHWR1gJ6gAQMPlXlhAQNzZWyDAQUOlH90AQPgY2VxepmiAQSQ \
h21eYAEDLHaMoQEDDpuJfGUBBJ9neIKgAQTKloZlAQSSZ3uTAQNZmpqDeGIBBEppeIed \
oQEDS5aFaAEFPHeNAQM8nZuJdWZgAQMeZ3qBmJ8BBFqMdgEFlWyDmwEEo5d4cQEEHmZw \
fooBA7MBA5aHcF5fYmNkbYOcAQMPmpd5cWEBAx9ob4CGnJ0BBB+LdWABBPBnfpegn5yb \
mn9xYmBiZGtrgYGZmQEDXZaOf2hgAQR8cIyfnwEDL5B1a19hYmhoen6Ll5yenZuSjXZq \
AQQ/ZXaOAQMgm5uNc2leYWNqa3t+jZMCAAUB2o15bF8BA0BlcIoBA3+bm5R2AQNAY2dt \
doCGkwEEYJeOgXFjAQS+Z4KUoQEDUJqCbWVgYWRvcoCBjpMBA2GakIh5cGEBBEFphZSh \
n5yamH9sYwEDDnN0g4GNkZmdnZqPinp1ZAEEIWiBkKGfnZ2Zg21nYGRkdHKCgouOk5qZ \
m5CNgHlsYWFiY2Zxhpqgn52cknhuYGNka3V5g4KMi5WVmZWQh395bWYBBCJuh5iiAQMi \
jnlqYmNlbXZ7goSJi5GSlpKQiIB6c2tiAQMibICSoJ+enZKCbmhhaWt3eoOCh4eMkJGT \
kIuDgHl1bGUBCSOckIFsZ2Fsa3p5g4GFhYqOj5SMjYKBeXpycGRjY2dvhpMBA4uZjXtr \
Z2Ntbn56hn6HgouLkJCLi3+CeYB3emxoY2VmcoyYAQMlloxva2Joa3V8gYOChYQBAyWO \
jIeAfnp/fH9yawEDpmuEkwED95mPdmtkZ290f36EfYOAioqSj42Hf3x4fX6Ign9vZGNk \
ZXaRnaCenY6CampjcXR+f397e36DjZCUjol/eXZ3f4SOjIh3aAIABQFFlgEEmIl6a21r \
eHeAeXx3e4CIk5KUiIJ3c3N5gomRkI6AdWRhY2Rte5eboJ6cioV2dXFyc3B1cXl6hYyV \
lZSKfnVwcHd+iI2Tj41/dWVhYmNpd42XAQOilYt/dXFrbmtycXt+h46VlpQBAx9pbG14 \
go+UlJSKhnVtYWFjZm58kpsBA4CViX1zbWhsanJ0fYKKkJaWkYx/c2hmbHOEjZmZmpCJ \
fXFlYGNjZnGAlJ6fnp2XiH1xbWhpanJzfYCKjpWUk4yCdWxoa3J+iJKVlpGLgnZtYgED \
2W17i5ieAQPai4Z5dW9vbXBvdnmCho6Rk5CJgXdxb3N4gIeMj46MhX51bWVjZ2x4gI6S \
mZWUjomEgHx5dXMBA+J3foOIio2Jh4F+e3x8AgAFCRSDgoF8d3Nwb3J4f4aIjYmLhYYC \
AAUIYHx4eHV5egEEIoKAfn+AgoUBAwiCAgAFFGd6eHd3eHx+goGEgAEDE4SGh4WBf35/ \
fYF/AgAFCY59fAIABwo1AQQtAgAGDZUBBRZ8fXx/foICAAYQyAIABRDsAgAFDzwCAAYO \
tAIABgpeggIABg7RAgAFDv0CAAYN4YIBAygCAAYKngIABwpnfgIACAfjg4QCAAYKLnx7 \
fgEDV38CAAUKZoKCAQVxAgAFFSECAAYN5QIABwoLAgAFCA59fn6Bf4ECAAUJSgEEU4MC \
AAYK7wIABw7cAQQmfnx8fnp9fAIABQ+GAgAFDogCAAYIxQIABRWXAQQkAQS0fAEDAQIA \
BQggAgAFCvmAgYIBA4cCAAgOeAIABRHGgHp8fHp/egEDWoJ/ggIABRGEAgAFCpoCAAUK \
l4EBBCB8e314fnt6gn0BA4GCfgEDPIQBBAWCfgED5YOAhH8BA9J6fXkBBIQBBHgBA0GD \
gAEF0wEDRoSCgXx/fHp+eQED0AEDCoB8gX4BA1uCgAEDl4SDhIIBAw96gXd/f3yCAQP5 \
eoF/f4J9AQQ1gISEAQNegAEE2wIABRAhgH0BBdABBM4BAzUBAz16gXl9gXyCAQM9fYAB \
AwN+gISBhAEDdYCCfX98AgAFCe57fX5+gQIABRBlhIIBA0qDfYF9eYF9gYJ7f30BAzeA \
gX+EhYIBA8UBAzsBBYN/fnl4c32Ji5eQh3V9cYZteGl8gpGDj3qMhIN2eHyRjI1kdG+G \
gnt1hISZf4F1fYB7c4GDm494cXV5i2p3dIeYhn9+eoxxdXuJm4pnem2Pf213go6acIJ3 \
hIRreYyWnGxueXmNZm+Mj5x7cYR8f2xrmJydcmaBfIRkaJCYlXttiIVxZ3GZn5Job4KI \
dmV3mJWNaX+JgWdnjJ+cfWCEeodmco+ehoBplX1qY4CfnYJhe4F/aXABBBNrlHllZomf \
nHpggXt6Z3eanYOAcZNsYW2Unptua4V1dGOHn5aEd4KEYmWEnZ6DYoByfGh0mZ2Ihm2P \
ZmR4lp6TY3tzenFqlJ+Oj2eLbGV3jZ+XZXdyd3pnjZ6OlmaEbWiAjZ2VY31sfXZqjp6L \
lmWCbGaHk52LYoNlgWlwlpaPhmx+amyYk51uc3pufGh+n4WYaXtybYKbm4dlf2t9aXmW \
kZB3dnF0dp2Yk2KAZ4BneI6bh4VueXBxmJqaZX5qgmh4hp6FjmZ9bHiNnpxseG97b3WE \
noWSZn5re42fmm11cnpxdIWdhY9ofWp4j5+aanZ0eHByhwEDM2h9a3eQnphpeHB9bHWJ \
noeJagEDIpSelmV/bIBpeIqdhIdqemx7lZ6QY4JqgmZ9jZqEhQEDX32Ym4Zlg2iCZIWS \
lod5dXNxg5yceWmBbHxmhpuNjHB6b3WKnppucnl1dG2InYeNbQEDZY6flWh6cnxrdYue \
g4lrf2t6k5+UZX1vfWp2jJ6Bimx+bXqWnY1jg2yCZXyQm4KEbXtvfJWeiGSBaoFlfpGZ \
hIBveHKAmZyAZoJrf2WClJWGfHR2cIKdnH5ng218ZoGXkYd4d3RzgZqdfGiBbH9lg5eT \
h3p0dnOCnZl7aX9vfGiDmI+JdXdydYOdmndrfm59aIaZjoh1dXJ5gpyWdW59bn5pipmL \
i3F4cnSMnZlxcXxydG6Em4mJc3lweYWemHBxfHB6aYibi4xyd3R2iJ6Xc255cnlshZqM \
inJ2b3uHnJdxcHttfWqImouLd3R0eIWdmHRue299aYeXjol5cnR5hZuYdm1/an9mh5SV \
h4BueHWFmZ19aX5rf2l/kJiDh2t5coKXmwED7mx9a3mMnIKNbXhzgYuejmp5c3V4boma \
iI1zdHV6i52SbnR5cnprh5aOiHtxdXqIl5p1bX5sfmqBlJSEhmx3d4SXm3xpgWx/a32P \
mYSLbXl1gY+diGd9cHpydImbhYtzdXd/i5yQanh4cnlthZiLh35xeXqGl5lxbX5vf2t7 \
kZaAiW94fIGMnYFmgHB8dnCJnIKJd3J+fYaZkWZ5d3R/bH6ZjIOBbnuBg5Kabm9/b4Fy \
dJGVf4l0c4J/ipuBZIRxe3tvgp6ChH5sf4WElJRjfXxvf3V2mI98h3N1iYGKnHFqh3B5 \
fnGFnX+BgW1/kIGVh2GBgG56fXSajXiBfXOLjISXa2yDe3CAeoOYhHh/eX2RiI18a3p/ \
dHN/gZCLfnl9foqMjoBrenx6dHt7jo6Ce3x8h4+KiG50fn5yeHyFkYl8en6EjIyKc299 \
fnZ1fH6OjYF6fYKKjox9a3h+e3N6eoePh3t8goaPjYRtcn1+dHZ4gI2OgHp/hI+QjHNs \
e4B4cnd4ho+Je3uEjJCPgmpygYBydHZ7iJCEeH6IkZKPdGh4g3txdHN9jJB/eIGOkpSK \
bGp8hXdzc3N+kI57doORlZaCaWyBhndzb3J/ko56dYOTl5iCaGuCiXlzbXB+ko97c4CR \
mpqEaGmAin1za215kJN+cHuOmp2KbWV6jYN2a2pzipWEcXKKm52Oc2Ryi4l6a2hvhZSM \
dG2Em56VeWZshouCbGRsgZOQeWx+mJ6We2hsgouGb2NogJOQe2x8mJ2ZfGdsgoyGbmNn \
gJSQd2uAmp6ZfGVshY6CZ2NohZeOcmmJn56UcWF0j4x2YmNyk5iAZ3KYn52EZGiFloFj \
YmqJmoptZomgnpRrZH2Xi2RiaIiWinFrgaCemHpsf5CHZmFnho19cXiMm5+TioWBfnRs \
Ymx5fXR8jJCFiJqdln5rb316Y2R0iYSEg4aLmZuOhnV2d3VlZXqDf3iMj4iHmpeSfmZy \
fnhhaoSOd3yNkYmQlo2Obmp1fWZlf4t+dpOQh4iZjpB5YHeBbmF+kINuk5WFgpaTjYJe \
doVzYHuYgWmNmoB/jpaMimBzj3Nfdp56a4qbfH+HmY+KY3OYbGF5nW5vjZ17foKZk4Nl \
d5dlYHubZ3uLnHt+f5qPfnJykGZicJhsfIedfnyCl4x+g2qKb2ZtknJ7jJWBgIKRjn+J \
aYJ4Z2qJfHiMjYp/fo6TfYxseoJkaoR/c46KjH5/jZR+jnRuiWVpf4JwkIaRgXyKlXyN \
fmWPamd/g22TgpGEd4iVeZCAYpBtZoGBbZR9lYV1iZN4kYZhj3Vkf4FslXeVinOGl3iQ \
i2WCgmJ8gG6Qe42RdYKYeY2Pa3WNYXeAcoaEgZl0fpl9hpN4ZpNpbYB2e4x2nXl8k4aA \
kYZijXdmgHl1jHObgXuMjX6Kk2V+iWF7e3OId5SJeoSUgISZb3CTY3J/c4B7i49+fpeD \
gJeAY5RwZX94dYGCkYN6lIt7k5Bhg4lgd4FvfX+PhnuKkn2JmnFsmmdsg3lrhoaKfYaS \
hYGahmGQf1+AgWV4joGBg5GHhJKXaXeYY2yOb2SRhHgBA0iHj5SKa4qKX3yHZW2ZcnWR \
ineWkYmKeIp8YYN4YnaQaHyXenyeioOafH2HZ3d7aXOFb3yOd4Cch4ScfnmSb22CcmeD \
eHCHg3WPlXuXk3SKjmZ7h2VxiW5ykHtylo12l5JyipFoeolsbot3cIyDcYmQe4aRfHaK \
gHGDhnN9inl5ioB3hYV5gYR8fYSAfoKBAgAFGUICAAcUTgEFC4ICAAUgDAIABQmOAgAF \
FN4BBx+BAgAGCkABBhUBBQMCAAYKMAIABRhrAQkBAQQ1AQY5AgAFFMgCAAgKdAEISgEL \
KgENAQIACxt9AQlKfwIABQqRARkzARwBAgAFFJABCwkBEEkBElUCAAcVUAEPPwElaQEd \
WAESAQENagEYNQEQFAIAKwEGARFgAgA4AUEBGRYCAA4BrAENK398dH2Vkohza3iGjYN8 \
cHR+jI6AcXeLlZJ/aWFriZiUhHFpeI2QhXl0eYaLiXtvbHiOnI5zanaIk4h6cXd/gnx/ \
hoeCfnx+goKAfHl6gIaEgH6Bfnx8hoR9e3uDhoMCAAUimHl9hI6Cend1d3WEmZyFbGd5 \
kZODc3qDh3Nqc4eQi3lzf42Pf21ziJCBcG+Fl4pva3qLj3lpcomWhnJ0f5KUiH+AjIt3 \
Z2NwewEDhIeZmpWOjpOaiGBfYmhub3d8mpyTjouMlYp+godkX2pjb4OPiZqPjI6Fc3yA \
gIqKZmJ4b29ven2bm4Z8hYaPkoSHlHoBAyZpdIaBmJ+YjHZseI+Qj4+IZGhzYmZ9ioqe \
jomCc2J3m5yVjXRgeHBiaoN/l5yEkZBtY32SmpqCaGiCaWVsfZGejYKUhm5hbpSemYhw \
aopvYWV7i52Pf5qYdGBmjJ6VgWpzlnBgZH+RmH59m5hzYGaVno+CdnqVa2Bni4yJgYie \
lWlgbJKcgYSLgIRoYHCKd3+Mkp6LbmtyfZWHko1ueH5iZHh5ipWFk5mAamhtmpGGkH10 \
jWRid4B4j4eRnIJsdWmHlIKWiWWIdmBufnaRjYGci3d2anOdgo6VcXKOYmx4eH6VfJWW \
fHt1ZouRfpqKZId5Ynp1do6If52FfIBxbpGBi5x+ZI1va3FvgY1/hp2Ahnl0dol8kpqI \
a391Z2xthoKIh52KiXp4b317jZKVfHGHaG1jfH2DgI+di4KBeXd7hAEDp3RzhWdxZYR7 \
gYKNloKDg3t3e4mLjZCJdXhyZ2lrfHyAiY2Uh4eIfnd8iImJioVrem9vcHGBgYGLiJCF \
g4B9dX2DhoKJiod1coF2dmt9fn9/goyKgn2EgXx5h4GEf4mHgnd9f354cn96fHx9iYGE \
AgAFGJqBgYOBhIWEhHp8gnmCcoF8fnx+goCBfwEEHIV9hH+Bg3+EgIJ9foN6gnZ/fXsC \
AAYZTgEDH36DAgAFF+cBAyYBA3mBe4B9fnt/fH5/fX+CfYCDfIV/gIGBfoKBf4R+gQIA \
BgR1f32AfIJ8gH4BA3EBBBOCgX6Df4CBfwEDTn2Cf4B+gAIABQ9LAQQFgn2BfQEEGAIA \
CAR/AgAFA8d/AQM9AQM6fwIABQ6GAQQfAgAFD0iAgIB+hHyCfgEDT3yAAQOGgnyFfAEE \
FIJ+gAEDfX0BAxOEewEDp4F8hHyBgHyDf36DfIN9gH+CAQRGgwEEhgED2QEEzQEDO39/ \
AQOwAgAFJaqAgQEDCwEDDwEFFH6De4R6AQRxAQMCAQSMAQNWgQIABQ9IAQMZgwEEC39+ \
hXqCAQQRAQPJAQRAgQEDQoN8gX4BA3oBBNEBBNABA9x/AQMoAQMaAQVHfwEDSgEDRwEE \
hXsBAwd+AQMbggEEsn4BA30BBEOAfwEDWH8BA1MBBPACAAYGZYEBAz0BA7B/AQR9foAB \
Aw0BA/V9gwEFPgIABQ/WfwEDPQEDBYEBBLABBFl/AgAFBpACAAUBSgIABxBxAgAGAVF/ \
AgAFIeECAAYalYKBAgAFAVl+fwIABSHeAQMmAQUqAgAGHycCAAUbtwIACwTYAgAHG70B \
CEcBFgECAAkiRQEIYwIACAWGggIACCE3AQ4uAgAGG14CAAUbfQIABhk5AgBYBcYBBfUB \
E2ECAAoi9wEdPgIABhJCAQ0kAgAGEkIBBlgBBwF9fH18fH5+fwIABRIvgIICAAUhCAIA \
BSJuAgAHHM8BBBOJhYF8d316d315gIR+g4B+g4GChn+DhICCf3p/fX6AewIABhEThoKA \
fHd8dneBeYKEfYd/f4aBg4h/hYN+hH1+f3p9fnoBA8oBAyWFhIJ4eXtyent2g39/iH6F \
hYGIhQEDToGCfIF7fXx6AgAFEzWGh4WIhHp4dnt6eHVuenqJkpCQg4KFjoSFbW1sdAED \
N3J6hpeZlYeGg4iHc2BhY2qOi56Ej4qSloZ9ZWdsfoOMe4R8jo+IgWlrZ3yEkJCQjZOM \
kH5uX2FjbYmOno2ci5eIfGxfY26DjZOKjYSPgYBqZGRshY+el5KKh4eFfWwBA1JxlJef \
kJqEioBvaWBoc4+dm5KIfoN2emdmaHCNlJ+Vj4Z9g32DdWZhY2OBl5qbjZV9jHBxY2Z0 \
gpual4qDfX1ycGNucIaNmJWPioGAfoGCe3RiYmRvk4+fjZiFhYBrbWFxeZKYmJGIgYB0 \
dWZrcHuMjZiOj4SDfn+CgX1vYWJjdo+Snoqbgo15bWpjdnmWk5aQiIiBdG9ibm6Dg46R \
lJWHhHZ/gISBdWRiY2qHjJmRlZSMh2prYnJ5ioyPkJSPiHVtY250fH2AkZadjIZ1fICE \
hHZwZGRrbYZ+mZCbkomDbnVodnN/h5CVk42FdnhrdG11dIKPmZqPhX59gH5/eXhwamZl \
dIGNmJCai5GAeW5qc3eChoiSjJGEf3RydW9wb4GQmZWMhYOEgn57eXl2a2RjbIGEloib \
kZqJfXZtd3F3d36LjpSJhIJ9fW5nbXWLh5OHkIuKhn5/f317cW1kbWt6f4WQj5mRkYeC \
enVzdHR9fYSEjIuJiX6Bcndwb31+jYaOhoqJgYF4fnp9fnx3bm92dYJ4h4WRjoyLhIh+ \
gHZ5eHx8f4CDhYMCAAUEMgIABxTQgIECAAcD7gIABgqJeX16gXx/fICCgQIABSbCAgAG \
JMoCAAcdfH8CAAYjRgEECgIABwWQAgAGBIUCAAYDXQEDHQEEKwIACArQgQIABgRvAgAI \
BFICAAYE7wIABgRlAgAGBGACAAYLQwEEQgIABQN0AQVSAgAFI3UCAAcDuQIABQSYAgAF \
H1cCAAwLYwIABhUKAgAFBiQCAAcEuwEGd4CAf4IBBnoCAAoGSgIAByrvAQVjgQEEswEI \
SgEFEgEEsYF+gQEDc30BAwUBBGgCAAYgUgEFdn4BBtcBBoQBBfsBBXkCAAcL94ABBqYB \
BRoCAAkEEQEGhX4CAAYFiwIACAEfAQNbAQcLAQWuAgAFBu6CAgAFBokCAAghHQIABgxR \
AgAFBuIBBZY=

#---------------------------------------------------------------------
# Compressed "ocdog" sound.

lappend gdata(list_sounds) ocdog

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    ocdog_bxdiv_lz77_base64 ""
append ocdog_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEf35+f3+AgIB/AQMBfn8BBQcBBhB+fn1+fn4BAwqBAQYdAQcbAQgf \
AQYwAQU0AQMOAQQQfgEFMwEHIAEEQAEDWgEIWQEEZQEGAQEGbwEFVAEFL4CBAQMBAQU8 \
AQRsAQUBAQQhAQqXAQQIAQMvAQYZAQhSAQdQAQcMAQpdAQhkAQh9AQNIAQq6AQqQAQQ7 \
AQbXAQvWAQZOAQZxAQr2AQgVAQQ8AQUvAQcXAQdmAQZlAQWYAQ9JAQXBAQnzAgAJARYB \
BywBBuEBBRQBDDoBBekCAAoBZAEFYgIABwGOAQVFAQgRAQu2AQl1AQpzfgIACwEoAQVm \
AQQCAQpYAgAGAWICAAgBtwEK+QELHwEJsAEGIwEGqwIADAIeAgAKAW0BC4EBBhJ+AgAG \
AkcCAAcCGQEHlwEIPAEH9QIADAGvAQVYAQnYAQeyARRjAQr8AQYKAQbpAQubAgAJAfR+ \
fQENsQIACwHwAgAIAXICAAYBIwIABQEYAQpgAQaLAgAJAhcCAAoCWAELaQIACQLDAQWt \
fQIACQJUAQm3AQMJfgEIkAIACwIOAQcnAQd+AgAIAs8BCyIBCmYCAAgCNwEOdgIACwLk \
fgIACQMeAgAIAQkBCyUCAAYB2QEI7QEIGAIACwJnAQlOAgAIAh0BCXUCABAB0gIACQNa \
AgANAsgCAAcB4QEIDQIADgHcAgAOAVICAAcCZQIADQJVAQwrAgASAsUCAAYBLAEJSQIA \
DgEgAgASAhICAAgCKgIACQGrAQf7AgAKAyUBDgcBD3UCAAsDwgIACwNHAgAPAvECAAsD \
dAEECQEKuwIABwP1AgAKA7ABB7ACAAoBgAIADgNbARBlAQjPAgAGBK8BBsOBAgAHBQ8C \
AAYBmX19AgAIAYMCAAcCqwIABgUuAgAFAZkCAAsBeQIACQHuAQM6AQMagYKCAQMlAgAF \
BYsCAAUCpAEDAQEGuAEDGwIABQRhgoODAQMgfHx8AQRfAQXdAQNWgH4BBW+AgYKDgoEC \
AAgE3wIABQEggQEDT4B+fHt7e3wBAx+DhIMBBCGAAQSfAQNDAgAFBcKAfn17AQMLgIOF \
hYSDgQEFE398enh4e34BBC+Afnt5eXuBhomJh4J/AQR2AQM4AQVNgoSFhIF9end4fYSK \
jIqFgX17ensBA5R8AQMHAQM5hYaFgHl0c3qDio6MiIOAfQEDF3l5ent9fwEDVAEDZn14 \
d3qBh4uKh4MBBOMBA255en6AgoIBA76AfHd1eH+Gi4yJhYABA2l8AQN+en0BBNmFhYF7 \
dXR4foWKjIuHgn4BA4QBA1N7fX0BA7EBA9ICAAUBOoOEhQEDGXp7AQRngoF/fQEEqIAB \
BGaCgH14dnZ5enp8gYiLiYWBfnl5foSIiIaEg3x0bWtudAEDjIqJiIeIiImHh4R/fHhz \
cG9wcnN2eX2DiIyRlJWSjYaBfnt4dHBrZ2ZqcHd+hYyWnp2WjISDhoeCe3Jta2ppaWxx \
dn6Ik5mbmJONiAEDqHJydXp8enZycXV7g4mNkJGSjYR7dG9sbXN8AQO/jo+Ohn10cnd9 \
goWEgHp0cQEDaXl4fYeTmZeOhoKCgXx1bmptdHl6eHd5f4eQlJWQi4V+eXd0cnByeHx8 \
eXqCjJKUj4mFhYN/enVvamltdHh6f4aPl5mXkoyEf39+eXBmYWVvAQMqfYONkpaUkI+P \
jIR7dW5oZGZscXd9hYyRkwED0IsBA3h2cW1qcHuEgHh0dn+Ij5WZmY+DenVybWhjZG14 \
hI6TlpWUk46FfHZzd3l5d3h+gn90bGxxewED+p+hloJzb2xoYmJqeYyXmI+EfXx9AgAG \
CG6Cg4KCg350a294gIeMkZadnJF+cnFsZ2Zpcn6KkpKMgXl2eHp+g4iNAQORd3d4d3Nu \
bHSAiIqLkJiak4N3cW9sam56h5CQiHx0dXoBA02HjIyCeXh5eXhyaWh1ho+PjYqJioqN \
kY2Ab2Vla3WCjpCJfnh5e3t8fYGDgX17e36BhYmIf3d1e4GDg4F/fHhza2lxfouUmp2a \
kYV/fXx4dnZ1dG9sbXB0eoOPmaGko6CXiXRmY2NkZQEDTnSAipCSkI2Mj5KUko6GempZ \
UFNbZ3aGkpmYlJGSkQEDh3V2eHyAhYSDfndubXV9hIiSnJyOeGNbY3WKmaCdkX1tam1w \
c3d8enZ1eoKMlpeSiYJ/gIOGi4+Pg2xXTlFda36XrLGsoZSFenZ5fn99dGhcVlpodQED \
4ZCUl56hogEDinJTQUFOYHWMnZ6UiYF+f4WMkpaVjHtuaWlmZmhrbnSAjpumqaKVhnRi \
VFNebn2MlpiVj4qHhoJ9fYCChIJ9eHVvZl1eZnSIn6+zrJ2MfXJnYWFlaG51e31/hIuP \
kpWVj4eDhY2SjYBxYVRQU1xoe5Kkra+kkoR9fYGDgHdoWlZbaHiJl5ydlYZ5eIOVoqCU \
gWlTSExabIKZpqaci3tyc3uGjpCJe2peWmFvg5efm5CFgYOKkJKQiHxqWQED32p7jpue \
mZCHgYCEAQMWi3xnV1JaaXuOmpuWkY6KhYGAgYSBeW5lZGtydnh7foOHAQPcmJaPhXtz \
bWttcXR3eoCGjI6NioSBf3+BgoWHgwEDGGhkZW18jZ2mppmDbmRqdYONjoiBe3RwcHV+ \
h4+TkIh+enuAg4SBenZ0dHR3fomRk4t+cGdmcIGUnZuPfG1nanJ/j5mZkIJ0amdud4KK \
jIiCfHh4fIGEhIMCAAUEEgEDgoiFfnRtbHB9ipaclot+c21udHt/g4iKiYaCfHZzcnN4 \
foOIiIWAfX6ChYWAeXd5AQMyiYeBeHJvcXmDio0BA6yDfHl4d3V0dXl9gIB9enp9goaI \
ioyMiYN+fX18eXNubAEDUISLjI2Ojo+OioR8dG5ubnByc3d8AQNHioqIhIB+AQPyi4Z+ \
dGtmaG0BA3qEipGWl5aTjYeBenRycnNzdXl8fX5+fHt9gomPlJWPh353b2lmaXB4f4SJ \
AQNlhAED/n19AgAFBUeDgoB9e3l3d3sBA1ABA2qDfXdzdHl/g4aFhoiIh4SBfn57enh2 \
dnd5fX6AgwEED3+ChYgBBHl1bWlpa292foYBA48BA/WEhYeJiIWDg4OAeXJta2ttcwED \
vZCQjYgBAzIBA9mJioiHg314cm1qbG91eoCEAQMSiYiDf3x8foEBA/aJAQMbdnZ4e36B \
AQSMe3x9fgEDm4KFhoeGhQEDnn4BA595e36DhYeDfnh1dnp/hIWDfwIABQZZgoSDgH+A \
ggEDdQEDJwIABQdGfQIABQXsfHsBA96BhIaHAQNBhIKAgH9+e3gBA8J+goSFAQOigoKB \
gH8CAAUGgHl3dXZ3e3+Dh4gBA8OLiouIhX94c25vcHJ0dXV4e4GHjZCRj4yJhgEDd3Ju \
bnF0eHyAhIiMjY6OjYmFfnd0c3R2dXRxcXN4gIiPkZCOjIqHgn16eHl5eXcBA8t/g4iL \
joyJg3wBA2N2dXNzcnN2fISNk5SSjouHAQO/fXh1cnBwb3B0eYKKj5CNiISBAQW8eXYB \
A1Z4foSKjY2LiomKAQNSe3VvbGpqbnN8hY2SkpCMh4SBgX99endzb25wdXoBBNGHi4+R \
ko+IgHlybmxucXZ6foCChYeIAQM8i4mGgXt0cG5vcnV4fICFiY2QAQNBioJ5cm8BA8t2 \
eHl7fH2AhIeLjQEDpoR+eXd1dXV2d3l7fX+DhomLigED9Hx7enx8fXx6eHh5fICDh4mJ \
iIWDgH17enoBAzl9fQIABQIHiIeEAgAFCBR6enh3AQQ8AQN7hoeGhoaHhYSBfnx4dnV0 \
dXgBA1IBAyqHiIcBBfd7enh1dgEEaH6Ag4YBA6aJhgEDKnoBAyoBAxR8fX+AgYQBA7yI \
h4UBAxV3AQUVAgAFB+sBBNGIAQMqf3x5dwEDFHoCAAUIcYODhAEDAYMCAAYHoXoCAAUI \
TH+CAQM/AQOVf3x4dgEDZnsCAAYKdYGDhAIABQJKAQSrAQPOeHgBA0CChIYBA5GCfwIA \
BQIqf39/AQPoewEDFgEDaQEDaIKAAQP2dnV1dnh7AQOmhoaFg4KCgYKAgH5+fXt5eAED \
0oCDhIWFhAIABQlBAQP8AgAFCLABA2eCgoKDAQMUAgAFCbN9fAIABQlaf4EBBBaCgoB/ \
fHp5AQTMAgAFCZwCAAoM2QIACQyOfwIABQl5fwEDRoGBAgAHCkwCAAkK0AIABwqcAQ0O \
AgAGC/d9AgAIDIYBAxJ9AgAKCu8CAAsMtAIABwx1AgAJDkgBBmACAAUJ8wIACg4AAgAH \
D2oCAAYNewIABg0lAgARDoIBEF4BC5ICAAoOogIACw9qAQYLAgAJC+oCAA8O4wIADQyM \
AgAID2oBCIMCAAkM2wIADQwSAgALDhQCAAcPiAIACgv/AgAOD7wCAA4MRwEE0QIACA1X \
AQ+GAgALD3kCAAgQrn0CAAUQggIACw9qAgAMDkQCAAgNmwIADAEAAgANDygCAAcBZAIA \
CwxCAgAMD2oBC/ABBpgBChcCAA4QOwIAEA0PARMbAgAJEaYCAAoMPgIACAwfAgANDR4C \
AAkPdwIABgv9AgAGDn4CAAgChgIACw90AgAKD0gCAA8PagEKJAIACg6fAgAKDtoCAAcC \
PAIABg9qAgAOEUcBD/kBBnACAAgNmAIACwEKAgAIAS4CAAgSNwIADRBNAgAGD0oCAAkP \
MgIABQMiAgAIElcCAAoCcgEHpwIADhC6AgAID8wCAA0B4AIACwJPAgAOAcACAAsOVwIA \
CxAyAgAKEjUCAAYDtQIACxDFAgALESECAAgBJgIADxFhAgARAb0CAAYBRgIACA4+AgAS \
DgkCAA0DtwIADQ7nAgALAu4CAAwSywIACQQ/AgALAioCAAgB4gEN/gEQWgIACg84AgAM \
EZCAgAIADQ/qAQ+fAgAHAkECAA0RkwIADg/mAQotAgAODvACAAoEJwEGvwIABwThAgAZ \
AucCAAsCmwELdQIABwQTAgANAegCAAkUaQIACg/ZAgAIAZcCAAsCpQEP0AIACQ7UAgAI \
DvQCAAgC+gIACQ+CAgAJD9ICAAcFjwEHLgIACQHyAQUzAgAJEXuBAgAFCFABBzl+fn18 \
fQIABQWXAQQygQIABQVLAgAGD2p7ewEFGQIACQ9qAgAGFVyAgIKDggIABQSgAgALD2qC \
AgAFD0wCAAUPaoKDAgAFBuMCAAYSaHx7AgAJD2p8fHsCAAgPan9+gAEDIH16eHh6foGD \
AQNsfnt5eXyBhYiJh4OAAgAFD+F8fHt7enx/AgAHD2p4eH2EiYsCAAkPan18AQNqfoGE \
AgAFD2pzc3qCio2MiIMCAAUHVAIADA9qfAIADA9qfHx6eXh6fQIACA9qeHYCAAgPagEE \
5gEDOHp9AQP8AQOegXt2dHd+hIqMi4iCAQYbenx9fX0BBsQBBOoCAAUPanx6AQMbAgAF \
D2oCAAUQEoCGAgAFD2oBA1Z3AQOAfIKIiomFgX56AgAKD2pua250e4KIi4mIAgAFCCyG \
gwIACQ9qdQIAEQ9qbAIAEg9qegIACA9qd36IkgIAEg9qdAIADQ9qbgIABQ9qjQIABQ9q \
c3Z9goQCAAUPanJ2eXl5fYeTmgIABQ9qgAIACQ9qdnl/iAIACA9qdnVxAgAFD2p4eoKL \
kpSQioaFg396dG4CAAYPan6Gj5iZl5GLhH9/fwIABg9qeXx8fYSMAgAJD2p0b2hkZWty \
AgAHD2qUAQQqenUCAAUPaoOBeHR3AgAFD2qYj4N5AgAID2qFjpOVAgAHD2p0d3l4d3h+ \
gwIACQ9qoKGWgnNubGdiYmp6i5eXAgAGD2p+fn1+AgAGCzp+dGxveICGi5CWnZ2RfnNw \
bGdlanN+ipMCAAYPant+goiNjIN7dwEDAXRubHR/iIsCABAPaod8dHV6f4CCh4yLAgAG \
D2pzamh1hwIABg9qi46RjgIABg9qgwIACA9qAQNSgoF9e3t9gIWJiQIACQ9qe3hya2lx \
foqUmp2bkYV+fXt5dnUCAAgPaoSPmaCko5+XiHMCAAYPamZrdQIACQ9qk5KOhntqWVFS \
AgAFD2qYl5MCABAPam9tdX6DiJOcnI54ZFtjdYmZn52QfW1pbXBzeHx6dnZ6go2WmJGJ \
gX+Ag4aKkJCCbFZOUVxrfpersayhlYZ5dXl9f310aFtWWmh2AgAPD2pATmB1jJwCAAYP \
agIABQG6jHtuamlmZmlrbnR/AgAGD2qFdWJTU19ufYyVmJaQi4iGgXx9f4KEg314dXAC \
AAUPaomfr7OrnYx+cmhhYWVpAgALD2qOh4OGjZKNgXFiU1BTW2h7kqMCAAcPaoCDgHZp \
W1ZcaHiKlp0CAAUPaoQCAAgPak1aa4KZpqabjHtxcnuGj5CIe2peWmBvg5egnAIACg9q \
a1gBA99qe4+bnpmQhoACAAcPamhXUllpfAIABg9qiYWBgIKEgXhtAgAHD2p/AgAGD2qX \
AgAKD2p7AgAFD2qJAgAHD2qGAgAGD2pmAgAFD2qlmINuZWl1hI2OiIJ7dHBvdX2HjwED \
dn96e4CDhYF6dXR0dXYCAAkPam+AlJ6bjgIABg9qjgIABQ9qaWdueIKJAgAHD2qAhISD \
gX59e3t+goeIhX11bWxxfIqXmwIACA9qgIOIiYiGgXx3AgAFD2qEAgAGD2qBhoWAend5 \
AQMyiYaAeHJvcgIABw9qhHx5eHh2AgAMD2qJigIABQ8FfAIABQ9qAQNQfISKjI2NAgAF \
D2p7dG5tbwIACA9qiwIABg9qh4yMhn1za2ZobXV6f4SJkZaXlZICAAUPanFzcwEDV3x+ \
fn18e32BiZCUlZCGfnZvaAIACA9qi4oCAAcPan6Bg4SEgn99e3h3d3t/hoyPjomDfXd0 \
dHl/hIaFhocCAAUNSn17end2dnd5fH+Bg4OCfn5+goSIiwIABQ9qaGlrcHd+hgEDjwIA \
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 \
AAYU1QIADwLiAgAJBCMBEEQBD54=

#---------------------------------------------------------------------
# Compressed "ocflames" sound.

lappend gdata(list_sounds) ocflames

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    ocflames_bxdiv_lz77_base64 ""
append ocflames_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkBAoODgYGBg4SFhoaFhAEDB4eGhIGAgYKDg4B+f4OHh4SAf4KDhIOC \
goGBgIB/fn+ChIJ/fHx9fX17fH2Af3t5en6BgH58f4GCfnh1eX+EhYF/f38BBCsBA0KB \
gYKBgH8BAwoBBBABAweAfn19AQNNgX5+gIOGhYEBA0SAgYF/fn5/f359fn8BA14BAwEB \
Ayl/AQNgfn8BAzp+f30BBAqAfwEDNwEDGIB+gIGDgwEDUwEDNgEDnwEGCoKEhAEEnYMB \
AwYBAw0BBHABAwEBBFMBB1oBAwUBAwcBAwIBAwF9AQMKAQXFAQMIAQMGfX6AAQQxAQRy \
gIABBaQBA00BBFcBA12EhIaIioqHgwEFyIYCAAUBGgEDGISHiIYBBG0BBXGFAQMUAgAG \
ATmFhIIBAzyCAQMFAQMtAQNTAQQDAQMaAQO+fQEFbn18e3l4eXx+fnx5eXoBA/YBA4gB \
BPQBBJCAgQEDggEDIQEDkYIBA099enl8AQTwAgAFAWF8e3t9fwEDDHsBAw1/AQOmAQMW \
AQMdAQNjAQOlgX8BBDGFhoQCAAcBDgEDhQEDj4MBAwUBBdF+fX+DhoWBfn6BAQOsAQSX \
ggEDDAED7wEEDoGDAQY3gAIABQGqAQMSfwEEG4B/fHt+hIqNioaBf4CDhYJ8dniBio2H \
fXh6gouOiHxycHmEjIqDAQPBeHuAhH91cXuQnpuKeHR+h4V6cneHlZSFdG52gYiEe3V3 \
foOCfHd5gIWDfnp5e3p2cnF1fYSIiIN/fwEDVnt5f4mNiHtwam10fYeNioF0bnN/hX9z \
bnmIkYx+cG1zfYmQkIyGg4GAfXt8gomMiYR+enuEj5KKe3J2hI2NhoCBhomJh4SCAQOs \
fH5+gIGAe3h4f4iMioR/fX1/goWFf3dzd4CFhIB/goSDgYKGioiDAQPuAQUve3p6e3x/ \
gYGBgX96eXl8fX1+f4GCgoB+fgEDNoJ+fYCHioiCfXp8AQMVgQEGGH9+fHx/g4aDf3p4 \
fYGEg4B/gIB9egED/AEDT317fYKFhoSBf38CAAYCYIGFhoYBA0R/goOCAgAFAgF+fX4B \
A0d9fHwCAAYC83x+gYSGhoUBA9UBBB6FAQQ4ggEDRXp7gIWHhYB8AQM4goF/fwEDYYKE \
hYWDf30BA9gBBISBfn19gAEDNQEDQQEDrgIABgI2AQQJfHx8fX4CAAUBsn15eHsBBdMB \
A0B9fX18AQPjfQIABQIXAQNefH2AgIB+e3l7gISEgH17AQMzgAEDVwIABgMiAQNohIKB \
hIeHhYMBBAGChQEDCoWEAQPSg4WIiooBBBaFh4iIhoWEg4MBBAOFAQMzg4eJhwEEOoAB \
BJ8BA298eXt/hoqIgHl3foiOjIN8fYKEf3ZyeIWNiXxzdYCIhHpzdoCGhoF8eXoBBLJ7 \
ewEEtn5+f4GFiIJxXlVbbH6Ih4J8dnV4AQP8f34BA6t+eXZ2fIOGhH97fAIABgEPf399 \
enh6foKEg4ABA9gBAxWEg4F/gYOFAQQGgoMBA4sBBPgBA5aIgwIACAL+hYKCAQTThAED \
yYeGhoaIiIkBAw6GiImKiIcBAw2GhYOEhoaGAQPZiQED4YQBAyODgIGFhoaDAQM2hIB+ \
fYEBAwZ8enx+fgIABgN1fHkBA30BA5Z0cnUCAAUCLX18end3eXwBAx0BAyN9enl7fX4C \
AAUEU3+BAgAHBN1/AgAFAZ1/f39+f4CBAQNQfgEDAQEDuXp7AQPdfXt5e34CAAUExX8B \
BCiAAQMGAQP1fX8BAxp9fH4BAy8CAAYEeYICAAYFZ4IBBQSEAgAFBOCBAQOeAQTaAQMz \
gwEDBYGEh4aCfXx/g4SCgIGDhIEBAwuEiIWAfH6CAQMMfX+CgX16en4BA0ABBGh8enkC \
AAUC8AIABQP2goABBAeEhIQCAAUFHwEDFoCAgIGDg4SFAQNxg4aHhwEDc4WFgn5/hIyQ \
jIN8e319dXN9kqOgiW9kcIicnI2Bgo+XjXhpboSanIlzbHiJjYN1bXOAh4V9eHyFjIyF \
eXJydHd5enx8eXd3fIOFgwED6gEDC3l9gAEEaX4CAAUDLoJ3bW13hYqDd3Bye4KCfXh5 \
fH15dXd+hIF6dnqAgn98foABA/WCg4B7d3h+h4mEfHl9h42KgHh3fYWIhgEDz4OIhwED \
l4CHi4qGgQEDwISHh4iIh4WAAgAFA3qGh4iGgwEDaoSGh4WBfn+Dh4iFgoCAgoGAfX1/ \
goaGgwEEMISCgH+BggIABQPYgIOEgXx3AQN2hogBAymCgQEDFHt6AQPyfX0BA0KFgX16 \
e3x9AQNYhIB7eXuChIN9enp+gYJ9e3t9fwEEzH1/f358fX1+AQMUg4OAf36AAQTiAQUG \
AQNzg4J/fn8BAweBf35+gYMBBnSDhIMCAAUGWAIABQYjgIGDhYSEAgAFA3SBAgAFBsMB \
BPWCAgAGBs0BBBR/fn5/fgIABgX8fQIABQJOfgEFQgEE4oJ+AQOViIcCAAUE0AIABQIm \
AQY7AgAGAnoCAAYG6AIABgQDenx+AQOuAQOvAQbXAQQWAQZUAgAFB2EBBL2AgAIABwcV \
AgAFAgl/AQMXgQEFnAIABQR2gwIABgQghoSEAQRgAQTWAQS6fwEDdgEDyAEELwIABQSf \
AQWZAgAHBzABB4sBA5cBBSMBBp8BB1gCAAcHDwEECAEG+QIABQckAQQzAgAFBqYCAAUB \
OAEFxAEGAQIABgeFAQcOAgAFA2ICAAUH9wEDGQIABQhKAQQBAgAFAyCBf3x6eXl7enh3 \
eAED74CEhoaCe3d8hY6PioEBBPV/goWIiYV/fH6DhoaDg4WIioiGh4qNi4aAfH2Bh4iG \
ggEDW4EBAzQBBagCAAUDlnx5eHyChouLAgAFBgOCh4qGgHhzdHyEiouGg357eHd5foGA \
fXh2eHwBAyp6en2AAQOBfn17eXp7AgAFBiV9AQMFeXh2dHV4foGCfnp5fIGEgn14eX+E \
gwEDBnt5cGpwhJebjXZpbn6OlIx+dniDi4wBA4OAAgAFBQ6KjY6Lgnl3f42SiHNla3+M \
i354gJCWi3hudYWNh3p1foyPh3x5gIeKh4SGiYmDfn6Ch4mFgICEh4mHhAIABQO/hYUB \
A0qEiYqJg4GBgoSGiImHg4KEiImIg4B+AgAGAVkBAyaBfnt9gIKAfXwCAAUErIKAfHl7 \
gYWDfnp7fQEDEYMCAAUJzH9+e3p6ewIABgTcAQPYfH19AgAFCHKBf316eQED8AED9nuA \
hIQBAwcBA0SAAgAGAqV9fX4BBB57fX0BAx19AgAHCVx+AgAFAo5/gH9/AQNofQEEdwED \
B31/gwEDpn5/gIGCgoKDAQSpggIABQi+gwIABQMoAgAFAlSChoYCAAUIdoeHhoSDg4eK \
i4mFAQYPAQMOhomMjIqFf31/hYmIgHp8g4uLhX56foOGAQPCfoaLiYIBA5uDgn17fICC \
g398e3+Eh4V+eHl/h4iEfHl7fwEDZAIABQMgAQNLgXl2d3x/fnx7fQIABQM0enh4en5/ \
ewEDBYGAAQPuAQPNAQTFe3p8AQOSAgAFChqAfnx8foOEgn58fX4CAAYDKH8CAAYCrwEE \
DICBAgAFCn0CAAgCrICAgYB+AgAFAr+AAQM5gH99fn8BBQqCgQIABQgLAQTvgYQBBQaD \
hAEEAQIABQtnAgAFAoGFhYaEAQQLg4KCgwIABQa4hQIABwYCAgAGBfoCAAUKdQEExYCD \
hYiJiIN4a2ZtgpWYiHVsdoeSjYF1cXWAj5eOdl9aaHuFg3t5fISNk5CHfXd2dXV8hoyG \
eXJ2goiBdm1udYGNkYt+dXR3e3t+hYyMgnRsbnqHjol+dHV+homGAQNgfHd9i5aQf3N4 \
h5KMfXByfYeKiAEDl4eHhYWDf3x7foCChYeIh4R+eXl9gYJ/fH2ChoV+d3V5gIWFgXp2 \
d32GiIV+e3yBgoB/gYeKh395eH2EiYeAfHyAhYSAe3p7fwIABQQmg4OCgH+AAQP7gX9/ \
f3t5en+FAQNdg4aGhH97enp9AgAFCp2Afnx8fwIABgRLf3p4e3+BfwEDEIGBfnx9gQIA \
BQUdfXx9f4CAfn8CAAUHuH9+gQEDeH98AgAFAZ2AgQIABQvEgYOHhoWCgYQCAAUMYoKC \
hAEDJ357foIBAw+Ag4eHgnt4eoCDhIOBf35/f4EBAxZ9AQQ9gH0CAAUGE3t7f4UBAyJ3 \
eYCDggEDzYCCggIABQXRAgAGCdZ/AgAFCyABAyx8enl9goeIhwEEj3p2dXmCiYiDfHl7 \
f4SHh4SBgYSJi4Z6cG53hImBdnWBj5SKfXuFkpiUi4B5eYGLinpnZXuaqZx9Z2qEnJ6H \
aV1phZmYint2dnh3eoGEeWRWX3qVmolyaHKCiH5xa3SFkI6AcW11g42Lg3x7foOHi4uH \
fnZ1f4uOhHVvdoSMioOBhYiEeXF0gY6OhHt7hIqFfXuCjI+IgoSMjod6c3aAhYWFhoiE \
fnyAiYyFe3uCiYZ+eX2Ii4N2cnyJj4h8c3J3AQPIioiAAQTQg4B9e36BAgAFDDOEgHp2 \
d3t/f319fYCDg4ICAAUJg4GDgX4BBQiCgH58fYCBfXl6f4SFgn57ewEDDQIABQqmfX1+ \
gIKEgQEDqAIABQOEAgAGA9qAAgAFC0h9AgAFBpsBA0N/fH6AAgAFBlwCAAUNPAIABg0+ \
gYABA8WFf3l5foWKjIqGAgAFCNSGh4mJhoJ/gISLjImCfYGIioUBA8SGioiGiIqJgXVq \
Z2x2gpGep6ifjXdmYGh7j5mUh3dwc3uAfXh1eH4BBHYCAAUIf3x7eXd1dXd6fYABAxKE \
h4R8dXV8AQObAgAHDVwCAAUEpgIABQTBgIABBCwBA/2DhIJ/AgAGDiR/fnx6fH1+fH6B \
hIJ7dnR6fwED9n8CAAUH038BAzUBAwqDgoECAAYHeoGEg4ABA0yFiImIhoSDggIABQ84 \
AgAFA+SGiYmHgwIABQhtfH+BhYSAfHt/g4SBAgAFDK99fH6EhoN7d3l+g4IBBGQCAAUD \
M4uJhH9+goaEf3p6AQMehIACAAUIPYUBAwl9AgAFAmyEAgAFDe+CgwIABQqzAgAHDLWB \
AQRRfAIABQwpAgAFDe18fH5+AQcGfHt7fH1/AQN8enl6AgAFB/p9AQPse3p5e3+CggED \
7n4CAAkPk34CAAUE8n0CAAUBD4CChYWCAgAFB48CAAUE5X6AAgAFB6+BgIIBA5CBgYKG \
iImFAgAGEBOBAgAGD4ICAAYIOIKCgX9+AgAFDl0CAAUFDQIABg+PAgAFC5yCg4ECAAUM \
z4SEAgAFDt5+gYWHiIaDfXt8gAEDUYIBA1KAAgAFCymAgAEEcYCFiImHgXp0cHF3gIuW \
nZ2VhnZtbXR7AgAGBVwBBtABBOp9fAEDRoJ8AQPIgX56AQPbAgAFA/J/AgAGA5KGfnVy \
dXoBA8yBhIN9dG9xfYiMhXp2fIWGf3l9h4yEdW11g4uIf3d4fYEBBPd/g4eHg316e3+D \
hIB5dHV/iY2If3p+hoeDfn+GjYl+d3qCiIeDgYOEhoaIhwIABQGPhYaGg4F+fwIABQnG \
ggEDGAEDsISChIeKioiFhYWFhISFh4iHhYOEhYaFAgAFC6WFhAIABQRVAgAFC7KDAgAF \
D5iAAgAGBu8CAAUCdIGCgH16ensCAAUBsH1+AQQRgX98enyAhIN/fX6DhYB2b3B6hYR4 \
aGNtfYqNjIuLhXtzd4SPj4N4dXqBhIGBgwEDZX17AgAFDRF/end3d3h6foOHhH53d3x+ \
fXp4fIOIh4J/f4KCfXZ1e4aPj4Z7dXqChgIABQSkAQRlgomPj4qDfXyDiouCdGtyhpqh \
loF1d4OOjYBzcHqHioV9e4GLjYh+eXl9gwEDxXp1dn2DhoSBfn1/AgAFA/1+goWDfnt7 \
f4OFg4J9d3R3foWFfnd1e4KGh4YCAAYQkAED64B+fwEDJoF+f4GBgYSHiIeDgAEDH4N+ \
fYCGiYeDf3x8gYWIhoACAAUD2AEDbIiGfnV3gYuLhHp2eX8CAAcReYF+AgAFB44BBOKD \
ggIABgIDAgAGD0d+AgAHAnSAAgAFAsWCgoMCAAUEgwEEGwIABQWtgYKBf3wCAAUDEwIA \
BhIaf34CAAUBg39+AQMUgIACAAUNAAIABQKvAgAFAuSAAgAFBMsCAAYLcQIABQqoAgAF \
DxoCAAYCwQEECIICAAULkgIABQrGgQEFEgIABgrVAgAGCuYCAAUHlQIABwLzAgAFBOoC \
AAYI5oABAwUCAAUPo3x9gIB+AQPBAgAGC8d+AgAFEeh/gYB/fQIABRAXfnx8AQMNfXp6 \
foODf3t6foECAAUIpAIABQ/HAQaFggIABRJUhIKAf4CBAQNtAgAHA1aBf35/ggIABQc9 \
AQXgAQUUAgAGEFICAAUEjIGDgQEDhwIABhKbAgAFCV0BBDkBByIBBQwCAAYTG4ABBV4C \
AAYLZgIABgy1AgAFC1oCAAYTngEHSQIACBLXAgAJA8MBBIWAfgIABQmrfwEDyoICAAUE \
x39/fn18fgIABRNFf4B/fHl7foCBgAIABgsPAgAFDfV+gQEDLn8CAAYBWgIABQPKgQED \
mICCiY+NgXBkZnWFioJ2dH2Kj4uDfn58eHh+iZCOhX56enyAhYaEfn2Cg4B4dXyFiIV+ \
e31/AgAFAbuAe3h8hImFfXV2AQUXeHZ4f4WFgHwBA4gCAAUJYgIABQiUhH98fIACAAUD \
owIAChOhAgAGAUcCAAUMpAIABhTSAQMhg316fIGEgQIABgGPgYKFh4cCAAYM7H4BA08C \
AAUM4n1/goQBAxOEh4qHggEDX3x3dHiCioyFfQEEngIABQWDAgAFC70CAAUNJn95eHyB \
hIICAAUSR4F9ewIABgiNAgAFAm6Bf34BA08CAAYTXQIABQ6DgX16en2ChYN/AQVnAgAF \
EhYBAx0CAAYHLX+DhYWDgYACAAUFGAIABhGkAgAFBqN+fn+AgAIABQFigQIABRPIAQQQ \
AgAFFUOFhoUBA8gBBPCFiAEDkwIABQ/igYOGAgAFFbmDAgAFCP6Fh4WCf317fH2BhAIA \
BQQwgIF+eHd7gQEDZ4B8fX+Bf3x7AQN0gHsBA74CAAUN4H59fH2AhIaGAQPEAQPFAQMm \
goKCgwIABhQkAgAFBdR/AQPxAQZyAgAFAu9/AgAFEdACAAYCtQIABQJZAgAFDlACAAYC \
TgIABQNmgoSCgYKEhIJ/AQSshIKAAQMNgwIABw3cAQbmg4mKhX14eH0CAAYCF4EBAxEC \
AAUWEX+CAQPmAQPDgHt3eH0CAAUBhoOEg38BA6cBA64CAAUDeAIABQ9vg4QBA6h8AQQH \
AgAFDokCAAYDNAEEXAIABQNFAgAFAxuCAgAFChACAAUSJwEHdQIABQFcAQQGAQWqAQYb \
AgAHBoYCAAYL1QIABQiqAgAGBDkBBhB9AgAFFaECAAUC2AEEHAIABw9kAgAGEcUCAAUU \
KQIABgPVAgAFCkwCAAUT6AIABgwRgQEDtwEDOISFhAEDHoACAAUSs38CAAUEa4IBA8sB \
BL2EgYCAgoKDgwED3gIABgReAQQHAgAFA2YBBEsCAAUDwQEDYQIABRQOAgAHEF0CAAgB \
VgIABQ9Cg4J/fHuAhoiDenV5gYaEgH6AhIYBA1kCAAUGWwIABwyeAgAFEmMCAAYFFH59 \
AgAGD+cCAAUShYKAAgAFC84CAAUBzwIABQ/tgAIABQJUAQf1AgAFBG0CAAYB0wIABQRF \
AQV2AgAGA8WCgwEGAgIABwQ0gAIABQ3Qg4OBfn1+gIECAAUEHQEDYXt+gAIABRb0AgAG \
AS4CAAcTEAIABQEUfX5/AgAFFyACAAUFLQIACA1MAgAGDUEBB9wCAAUNPQEFDQEDUAIA \
Bg4qg4QCAAUBJYSEAgAFE94BBQYCAAYUlISEAgAFCRQCAAcQewIABhQNAgAFDu4BBFl+ \
AQP8AgAGCNYBBdwCAAcYAQEGCQEEjgIABgXyAgAFA1wBBqQCAAUTyX19fX18fAIACBd2 \
fHwCAAUXtAEFBgIABQaOAgAGF68CAAgCNgIABgG1AgAGES8CAAUTtwIABxGTAQMNAgAF \
Bh4BBA8CAAYK6gEEy4QBBgcCAAcT14aFgwEFQgIABgFIAgAJEcUCAAcX0QIABRFUAgAH \
ASKBAgAFGUYCAAUJ3wEDzn9/f30CAAcNAAIACBi9AQWWAgAGAvEBCQYCAAYC/wIABgXs \
AQVKAgAFDVkCAAUBWgIACAOeAgAIAeECAAYCAQIACBRwAgAFEZSCAQXggAIABgKHAgAF \
B28CAAUCHAIABgsbfAIABRKRAgAFBuQCAAYZpgIABQEeAgAFGbZ+fQIABhlTAgAGAhwB \
Aw4CAAcDaAIABwpRAgAFBmECAAYKWwIABgYUAgAFA5EBBFiCAQZmAgAHGjMBBRwCAAcC \
ugEHsAIABwEmAgAGB40CAAoTMwEG4QIABQrLgYOFhoWFhAEGsQIABhDyAgAGB7x9AgAF \
Fw5/foKFh4F4dHmEjo6Hfnl4en+EjI+PjIqIhX11dHuGioZ/eXZ4fIKGh4SAfXt7fHsC \
AAUMInp7fgIABQQwfHp5fIGGiIeBe3h3eX0CAAYHVQIABQIzAQXiAgAHEBUCAAUCRQIA \
Bgr9AgAFGsh+AQbdAgAFC/ABBcwCAAUCdIECAAUCsAIABxBJAQWkAgAGAYoCAAYBiwIA \
BQGaAgAFG2MCAAcDBQEHCQEOAQIABQamAQVe

#---------------------------------------------------------------------
# Compressed "ocintra" sound.

lappend gdata(list_sounds) ocintra

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    ocintra_bxdiv_lz77_base64 ""
append ocintra_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEfn+ChIF+fHh3fH5/hIWFg316eHV5e3+CgoGAeXZ0cXZ5fICCgH57 \
eHp7fX+EiImJiIaDhYiLkJGSkpCPjImKi42RkpGQjIiGhYWIio2OjYyJhYSDg4eHioyN \
jYuIh4MBA1OHiIaCgHoBA010c3JxcGlnYl9dXVxbW1paWFZUU1NTVVdYWVlaXFxcXmFi \
ZWdqa2tsbW1tcHF1d3p8fX5+f4CFh4uNkJKUlpaYmJyeoaWnqaqrAQUBrK2trKuopaKf \
np2cnJqZmJSTjouKiAEDAYeGAQONAQSGhISFhoSBgICBgoOEgwED0H5+fn2Af4ABBAl8 \
e3x8f4CDAQMoAQUBh4mLjIyLiYiFAQQzAQM7gIB8enp5AQMBeHdzcXBwcXJzdXZ1dXRy \
cXJydXd5enh4dnNzcnN0AQMBc3JwbWxqamtsbGxqaGdjYmJjZGdnZ2ZjAQMKZAEEzm0B \
BB5qbW9xc3R1dHV1AQPWfX+Dg4aGiYmMj5KVAQPSn6ChoqKmqaytr7GwsLCvAQMGsrOy \
sbCsq6mopqWlpaSinwEE4QED4JWUk5KQkIwBA+SHhYUBBM58e3p4dnUBBIJwbm1sbGsB \
BgFqamloaAEDeG5uAQN7AQMVbAEDCm8BBCBsAQOkAQMTAQQkAQMLbm9wAQM3bm5wc3N2 \
eHt7enl4dnd4ent9fn58AQNYenp8fn5+fn18fHp7fX+Cg4WEg4KBg4QBA7SQkJCOjY2O \
j5SWmAEElJOSk5OWmJkBBZ+SlJSXmJiZmJaVlJSVAQMVmJeWkIuGg4mXor/Fv7KNcGxt \
epSblpB+ZWBcaIGNoKyfkn1fXGV0naqno3xeUUdScYCXnYZ1XDcyNT5hcnRzXUM7NTpV \
Y3iDf3ZmT0pKUG1+jpqPfm1ZVmJpfYaEgXhnYmBfbHR+hIKAfnp6fX6EiAEDnZIBA4+S \
kI+OkJOWn6GioZmRiYCCjJCcoqCbjoB7dnmIkJykn5iPgX+Dh5mjqKqikYl/eoGLmaOi \
n5Z/dmhlcHuBk5SMhnNrZmVwfICLjISCd3Bzdn+Lj5aUh4F6dXh+gY6RkZCDfXRtbnJ2 \
gIOFhn90b2Znam13foSGgX14cG5ydHyAho2QlpOBe29qfZCVmI1mVkRBWm19k5F/dwEE \
sHKJl6emkYZzaXmNnbS2q6SPhIB/jaCmramOfm9haXiBlJeTkIWAeXV7hI2cn56bj4WF \
homUmJaUiYF+e36DhYWDd3BpZWdqbG5ubGtra21wcXV0cAEDC3B4fYiKhoN6cm1qbnp+ \
hod/eG9lZWdsc3d4eHBraWZqdHqAhYKAfHh6f4CQlpqcmI+Jg4SHiZSZmZiTjImBf3+A \
hIeHh4aCgoGCgoSFhoeJiIiIioqMjY6QkJCOioiEggEDFwEDIISAe3dycnN2e35/fnp4 \
c3J1d3yDh4qKhYSDg4OCgYiPlZGHd3F0gZKUj4JvaWtzf4OAd3N5h4F5c3d/hQEDfICM \
iYmLj4d/eX+Ij4mEfnhzcXd+f3NwcnRzdHp6dGxsdICEf3NsbXJ+jJGNhX5+AQOUi4yD \
fH6Kk5KCc3F8g4B6eX14dXoBAyV0cnN8ho2Nh3t0eIGPj4SAgIaBfnx/f3h4AQNiAQNC \
bHB8gIiBd3BxAQOrfYF9fYGLj4uBhIqTlJWbm5eJhoyam5aQi4iDipOViYB6gIOEg4aJ \
ioN9gIqOiISHk5aVj4iDfn6Gk5WPhH59eHt+hYF7cnR5fXdva2xvdnt8dW1qbngBA21+ \
fnZ3eoCFgH+AhoSCgoOFgwEDCn14c3d7f39/gHtybnR+hgEDAYiEAQMXiYqKi4+Oi4aF \
hIOFh4mFgHp6eXl4d3p7eXR2en97eHh6eXYBBFJ/goWFhIGDhYiJio+OiYB9fwEDl4uL \
iIJ/gAEDNokBBAqCgQEDaYyPjYmGh4eGh4mKiYWCgoSDgYCAf3x6e3p5eHt9fnt3dHV3 \
enx/gYB8eHp+gIWJi4qIhYSAgIOIjo2JhYGBgoCAgoWCgH58gIGIlpqUj394dnZ3fYSM \
AQOegHx7gIaMjIyLhH13cXR8fX99AQNTdHJubW9weHx8fXx4dWtobG94goWJiX95c3F2 \
eoCKjIuHfHdzcnZ7gIiJg35xbGtsdoABA7YBA+MBA4SAkJOUk4qFg4KCgoOHh4eIhIKB \
fnx9fn+Bg4aEgX94eX6BhIqLAQNChoB8gIOMlZWSj4iDAQPLg4iNjYyHgHp5en6ChImJ \
iIaAAQPPho2OAQP3iIaEhIMBA3+LjIqIhIB7AQThgYMBA7d2dHJxd3t+goB9e3Z1d3uA \
hYiKiIGAdnN4fICFhoaDfHlycHN3fIMBAyt4dnVyc3V4f4KCgXx5e3x/g4WIiYiFf3p6 \
e3sBAwyHhIF9dXNzdoCHiYuHgoB8fHx+hIqOkY+JhoKAAQMeiosBBRZ7AQO5hoWFhH18 \
eHUBA4IBA2yGgH58AQOlhI2Pjo0BA8R/gAED2o2Ni4WAfn+AgoOEhYWEgXx8fX+Fh4eG \
hIOCAQMWf4SHAQN4AQRMAQNjf4GCf3p3c3Fyc3R3eHt8eXZycHJ1eHx9fX17eXh4AQMJ \
f4IBA2B5eAED2n6CAQNefXh3dnd8AQTbh4aBgH9/f4KGiouNAgAFB4GGigEDAQEDWYKA \
f4OGh4iGgoGAfn19f4OHiwEDH4J/f4GDiIiMjoyKhYCAgYOGiYmIh4aEgAEDDIWHhgED \
pIEBBAuGiImHhQEEVn8BAyKHhoN+ewEDeXl7AQOOfXh2c3ByAQN7e3t7egEDmXp9foAB \
A2l9fAEDxn+Cg4MBA6UBAxV8AQM4gwEDd3p5fYCDAQSjhYSAfoCDiIuLiYiEhIKCg4SG \
iYgBA3Z+AQS5g4SFhISAfX5/gIcBAyGKiAEDjX+AhoeKiYYBA059fQEFTAEDYXl6fHwB \
BDB+fHt6egEDdYODg4J/fgEFH4aGhAEDK3t6e31/gYKCAQMWAQMqgICDhISEgQEDS4OF \
hYgBA22CfwED0QEDjQEELAEFroGDhQEGunx+AQVYfgED0wED4wEDDH19enoBA24BBNV6 \
enkBA89+gYKAAgAFAWYBBG0CAAUI/oaFAQMBiYqNjAED0oiHiosBBAGKiYiHhwIABgF9 \
iAED8oQBA2yHhYOBfgEDSAIABgdHenh1dHR2dnd5eHh3dnZ4eHgBBGYBBGR8fX0BBF0B \
A7gBAwqAgYOCAQOZf39/AQMKAQNEhYMBA+yFhgIABgjUAQN2hoeHh4aEhAIAAwD/goIB \
AxqCgIB+AQNggIEBAwwBA6QBBMGBAQMYgoGAgAEDRYEBAwEBAwcBBeKBAQMRAQSIAQXk \
AQMUAQYJAQQhfHx6eXp7fH0CAAcCbwIABQgBfX0BA458AQUhAQiNg4SFhAEEWIKDh4mJ \
iYcBA92DhISHiIkBBPCGAQSYAQSjhQED+oQBA6aFhAEDoYGBg4QBBcKBAgAHCYECAAUJ \
goABA00BBL2BgX8BBFsBAxoBBZoBAxYBBq4BBKwBA8IBBNoBBRaDAQQ1AQMhAQSwAQXN \
AQTAgAEEQX8CAAcCQoMBA0IBAyABBR8CAAYB0wEE24B+fXx8e318AQXwfn58AgAFCkoB \
BEh8fXwBBkUBB1UCAAcBJwEFmAEFowEDAQEECQEDeQEDBAEECAENAQEFEQEEwQIABQGC \
AQgJAQ0KAQXgAQUBAQRMAQTgAQbeAQ0BAQYcARsSAQkPAQQJgg==

#---------------------------------------------------------------------
# Compressed "ocpig" sound.

lappend gdata(list_sounds) ocpig

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    ocpig_bxdiv_lz77_base64 ""
append ocpig_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkKgAEJAX59f4Z/e3+JhXh/g4OBfHqDin53got/dHuHhXt5gYKAenqE \
iX11gox+c3+Jf3iAiIiDf4GKiHt7iYl9e4aIgn6Ch4yEfYWKgnmBiYF2eHx7dHGBnI1q \
do16YHGCf313dH1sXZ+ZeHCZqXV0nY6Cbn58hoB6aY6OXmGFiXF0kIJ2hHlvhIJxcpCC \
a3+dfG+GjIKFi4WJl4V5j5yFhJSXi4iPhYGBfn2Hg3p5iH5udouAdXF3eXh6dnx8dHB6 \
jY5scomHZWV6gYWCe36AYl5to6pld6azjledrnJUf5GOel1wkZBRYJ2PYXSTimhtenyA \
eWyHmXpkhZt2Y4ubg3eDipCRgH2XmX+Fm417h5OJe3d+jIVzd4iFeH2Gg3t2cHR1cXiA \
em9sbGORqWJ1jrOLVqOpclx+cW2AdWiGnVtbl5hkcpKKb4GAdoKEZHaXgGOIondmjZF/ \
iZeGkJmAdo6RdnmXjXuDioaDgH5/iYR7g4x8cXqFfwEDAX56bmhukZN3foh/bmhzbnN5 \
d31/Y1mEsGxwjrGeYZqvdnaEhoF7eX6JlW5Yi4NdbI6Eam9+e4CIa36dg2uFk3NsiZV/ \
h5GIioZ1f5SNb3SVkX2DkZKWk4mGkIp5eXVlZnh6c3d+gYWEfXd3cHOKg3N8g3FkcHl7 \
hoqMkoNqZmeDrnyBi6qnbYSffnl5i5Z7eomIemlliotiXX6edU9xmJd6aXeOhHF3dm5q \
iJp/eI2en41/hYaCfoOOf3OBk4x6f5SThoOEhIZ/fHpyb3yJioB5eHFsb3N/iIuIg4V8 \
Y1GUnGB7kLGOV5SekX1uiZiAan56a09pknJpfIiLdHCDjIR9gZSEa4OQf25vhZGMh4WR \
loaHjYSAfoGGhIeJhYOBiZWUgnuGj4FrcHhtaXF4dXaHk4VwcYB+dWpnYHOWjnx6enp7 \
h4yJiISDi3lhXGSPqXeMsLOpd5Cbb2+DdXl3YGh4gWpkg4WCnJh7gId8Z2pza4SSa2CK \
m5KCe4OLhIaGhHl2iZGGgYyIgo2HgYGAAQQDAQUFgYABAwkBBgEBBgsBBg4BCBQBBSEB \
CBwBBzQBBhYBBggBBRcBCS0BCzsBBSEBDFIBDVYBRgF/fwEDe39/fn9+fX17d3V0eI+M \
b22NnHZrhJaJfwEDH4N9bXyJf257lY13doqQAQP3g4aDdXWBgXF1iYh1dYWKgHqAio6J \
fHyHhnh4iIt/eoOHh4R6fYyOgH+LiYABA1J2cXOAf3Jwf4Z7dHl8fZahcnWbsXxbgpaU \
Z16DjoVhbIqOfFhymItgY4eTdWVxh4R1dYmPgG99lo1ze5ydgXePn5l9d4uRgHSCkIt4 \
f5OVe2+DlIZzeImJeXeCi39zdIV/Z2ZzemhhhqyFbYiQal5yboaQcnuLa0+CtJZqfLOs \
W4CspWBwiXyGfWNwlYFOXZeSX2OPhWlzf32AhnF+m4pedp2AX3iVjYqUiX6LiYKLnpKD \
j5uGcoGGf3d+dn1+c3qIgnqHh3lyeHF2end6f4J2fXptXWOloVJjobFkXZGXl2dja7Gc \
VGeroU9Wjp9/YHaGhXZkfaCLYW2ik15pk4ttdJCYj35/kJ5/boibgnGFlIt9gImZkH6B \
k4x3eI6KdG92enBlcqCrbF6LilhYgH9+eWx4dE94rYNweLSRW5ymf2mEdoGChmB/mWhV \
e4xwcYiRcIF/b3mIc22Ij2xym45se46Gg4mJgpWQe4KdjYKNmY+IjYqAgn99g4h8d4OG \
cm+Ghnpvdnh6eHh4f3ZwdIaTeGuAjnBicIKBhnx8g25bZoqzhF+Ws6tZf7ONV2yOlIRg \
ZYmYZU+KoGxmipR0ZXd8gH9td5iLZnOZimN5m414foiNk4d5jZyJfZWXf3+RjoB3eoeL \
eXKCiX4BA25/d3NxdnJyfn50a21ncrF9ZIGsp1qFsoBpa3pqenxtdJp7UH6heWSHlHV3 \
h3d7h3Fnjo9ocqGMZXuXhIKTjoebi3WCloFyjJd+f4iKg4F/f4SJfX+LhXN2goJ+gH9+ \
fHNpaYGagHeGhXVmcHJud3l5gXBZZ62LY4amrHV5sYt4e4aDfnt5gpOKU3KRa1+CjnNp \
en56iHdwlpNvd5SCaXyWiH+Ri4iLe3eNlnpsiZqBfoySlJaNho2Pf3h4bGByfHV1fICC \
hn94dnRvgYt2d4N7Z2l4eIKKipGMc2Vob6iSeImbsoRtoI14dYiUg3eGioFwX3qWb1hv \
l41VXo2chmxsiYx3c3hzaHmZi3eEmKCWgYKHg4B+jIl0eY6Sf3qNl4uDhIOHg3x7dm52 \
hYuFenh1b21we4WKi4WDg21Vb65xa4Wop119n5OIdHWajG53f3RaWomBaXiEin5xeoqH \
gHyNjXN3joZ1cHuNiomDiJOLg4qGgX+AAQNViIWDgYONkYd8gImHdXF6d290eXp3f4uK \
eXR7gXt0cGxvh4+AfXx8fIGHhoaEgYaCcmttep2DfZaooYZ/kYB0fn56fnJxeX98b3uE \
gYiQgn6Dgnd0end8iX9vfYuKg35/hYKDgoN/fICHhIGDhYGChgIAOwSKASw0

#---------------------------------------------------------------------
# Compressed "octiger" sound.

lappend gdata(list_sounds) octiger

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    octiger_bxdiv_lz77_base64 ""
append octiger_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkIf3+AgYCBgoGDgoOCgYGAAQMBf35/fX5+fn8BAwuBgoKDhISFhYaG \
h4eGh4aFhYQBBAGDgwEELQEGAYEBAwEBBTh/fn19fHx8e3oBAwF5eXp5AQMJAQUDe3wB \
BAIBAwF9AQMBfgEDI3p5eHZ1dXR1dXd4en1+gAEFYYYBBQGHh4iJioqJioiGhIeFiYmM \
jY6PkJCPkI+PjYyKiIeGhIKAf318AQRgeHgBA0N0c3JycHBxAQQDAQMFcnNzdAEDVHZ2 \
dnd4d3h4eQEDe3wBA8YBBN4BA2KGh4iIiouLAQRSjwEEA46OjIyLigEEAYmIiAEEW4SE \
AQPLAQTFfnx7e3kBBQF4dwEHAXYBBAV5ent5egEFyX17egEDhXsBBAsBBF+AgYF/AQOY \
AQM4AQM6AQQffgEDdgEGc4qLjIyNAQNoiQED1osBAwGMAQMBjYsBAxABBHOFhIECAAUB \
M3sBA853AQPOAQO+cwEFxHQBA8R2eAEDgAEFAXl6eXkBA4N2AQQdcXNydnd6egEDd4CC \
hIaIiQEE0I6PkI+QkZGSk5UBBwGUlJOSkAEF34eFg4ABA615eHZ0c3JxcG9vbgEGAW9x \
c3R1dwEFXgEDVnFubWxra2xtb3F0d3p9AQO6hYeHiIiJh4eGh4eJio2OkZSXmZudngED \
AZ2cmpiXlQEFXoqIhoOBfnx5d3Rxb21ra2ppaWlqagEDRQEDAWxqamlnZ2NiYWBhYmRn \
amxxdXl9gYWIio2PAQWllpeXmJiYmpqanJubm5qZmZeWlJSSkY+NjIqHAQNTf316AQPu \
dXNxcQEDWG5uAQMDb29wcHJycnR1dXZ4eHt7AgAFAlx4end1AQPUAQMBAQMZdHd3ent8 \
foCChYaHiouMjYyMjY2PkJGTlJWXmJmampsBAwKamZiVlJKQjYuIh4SBfn17eXd2dHFw \
bgEE92tqbWsBA2ZubgEDxWppa2loZ2dnaGgBA8tucXN3en2ChIeJjAEDT5KTAQQBlAEG \
AZYCAAcBaZOSkZCOjAEDVYWEgYB+fXx7eQIABQHJc3IBA75xcQEEm3V2AgAFAj8BA7x0 \
AgAFAq9xAQQbcAEDBHN0dXkBA7WBg4OEhYaGh4mKAQNlkQEDspmam5ycnZwBAwGbmZeV \
k5GPjIqIhoWDAQNeenh3dHJwb29ubQEDAW4BAwhvb3BwAQNLAQMFbm5sbGpoAQMBaWxt \
cHJ1eHsCAAYBDQIABQIgAQYCjpCQk5SXAQNempqZmZiXAQO7kQIABQFziYaEgoB9AQO4 \
AQO3AQObAgAFA0sBAwNyAQMBAQOucnMBA8sBAwIBBAhwcAEDcgEDGnR3eXsBA7eEhgIA \
BQLdjo+PkZGSk5SVlpYBBAOUk5OSkZCPjo2Mi4mIh4WDAgAFA7B5eXh4d3Z2dnR0cwEE \
VAEFTwIABQEaAQMXeHh5eXoCAAUEKHoBA+B3AgAFAdQBBhwCAAUB0oSGhwIABQLkj4+Q \
kZECAAUECpCQAQNwkpOSAQMBAQNpjQIACAF8fnt7enkBBGZ1dXQBBGgBBUcBBXBxb29s \
bGtpZmdmZ2doa21vcnV4e32AgoWGiImJiouNjgEDWpKTlZWXl5eYmZmZmJmYmJeWlJOR \
kI2MioeEg4F/fXt5AgAFAdNwAQUBAgAFARlzAgAGBGd2d3d5eAEE3HcBAyFxcG9tAQNo \
bG5wAgAGASKAgoMBBGMBA2GNjgEEv4+RAgAGAYGZAgAFAYGWlZSTkgEDv4yJh4SCgH58 \
engBA/pxcAIABwOicHFycQEDZnNzAgAFAd1wAgAFAfIBA1xrAgAGAd16AQO+AgAHARiN \
AQW9lJWVAQMDlZSUk5OSkpGQAgAHAX2GhYSCgYCAfn59AgAFBZMCAAYEznZ1AQUBAQS7 \
dwEEuwIABQTmAQQBd3cBBNECAAUBPXR0dAEDIXh5fAEFxIeIiYqLjI2OkJGRAQNrAQUB \
AgAFAXoBBGaKioiHhYODgX9+AgAJAvpzcgIABgEiAgAJAcd4eHp6e3sBAwMCAAUBoXgB \
AyYBA3l6fH5/AQNchYaHh4eIAQUBAgAFBSGMjAED0wEDBYuKAQbAAgAGBo9/AQMBAQbG \
AQNCAgAFAW8BA7wBBLp6AQRaAQRceQED4Hx7fn6AAgAFBskBAwZ/gH4BAwsBAwyBgYGC \
g4MBAwMBBAGCgoEBBEp8fXx9fX5/gYKEhIaGh4aIAQOEAQMHAQNvhIMBAzx+AQUBfX1+ \
fQEEBgEEdgELeHZ3dXZ1dgEE2Hl6fX6Ag4QBAz+Ki42PkJEBBAGQkI6NjYuJiIYCAAUC \
+H59e3p4d3UCAAUCg3BwAgAGBA8BBTl7fHwCAAYGloGCAQMBAQSdhAEDAYWFAQOCAQXz \
AgAFB38BBfECAAcDGQIABgZVf4ABBLKHioyOj5KSkZOSkgIABQcYAgAGAxeMi4mHhYOB \
f3t4dXJvbWtpaGdmZ2UBAwFmZmdoaWxub3FzdXd4enx+gICDgwIABQfMAQYBAQNzAgAJ \
B9CFAQMCAQSGAQQSAQUVg4QBBB+Gh4iHiIiHh4eHhoSDgYACAAUBjgEDvX9+AQOhAQMC \
gICChIWHiIuLjYqJiYaIhYaEhAIABgXCdnRycAEDiWdkYmFgYGBjZmhqbXBydHV3enx9 \
gAIABgQ9jI2PkpOUlpSUk5COAQPAhoWEAgAFCEyCgIKBAQQIf399fHsCAAYB5Hx9fgED \
MwEFrQEDmgIACAiDAQa4goABA294dgEDWnZ4eQEDKQEE4YaLiZKRlZWVlpGPjY2MioyK \
ioaFgX16dnJtAQOQY2FhYmJkZWZoAQMBamlqamxtb3N3fYCEiAIABQLmAQMCjIqJiIiJ \
AgAGAdWQAQNCi4iGgwEDjHx9f3+BAgAFAiACAAYCjnt8fAEEloSFhIODAQOufnx7e3gB \
A618e34BAyoCAAUIFn+CAQMBAQO3iImMj4+QlJWUk5ORAQPqjYqIiYeFgX98eXZycW5s \
a2lpZmZkZGMBAwFkZGZnaWtvcnV4fAEDa4SEAQM8iYmJiIN/e3x6fYOIj5GTlZWXmaCe \
np6YkoqEAQN0gIKFhYeKiYmHhoF7d3Z2dHR1dnVycHF0dQEDinVybmprbnF4e38BBKeJ \
i4qIhH54d3V5eHoBA8KBAQMRjpmXnZ6enJeVlZCKAQPxjIqSkY6JhIF6dXFuaGBgZWhs \
cHRzb21paAEFmmhudniBhoV/fXt5eHuChoqJj46Ni42MjZOVlpiVkIuHf3x6dHR0dnR6 \
e4KFj46RjIt/f3R3enuHjJKXlJWTlY6MioWDfX18enh4eHN0AgAFBId4cG5wcW5uc3Fw \
ampoYWRpcG56f4KDg4B/g4eOl56nqqupq62popiFcmReYG14goeCeHhxbW9uZ2RpZnF5 \
go6KjI2Dfnh5b2trAQQOm5sBA4aJfndyb2hqdn2IlJqblY+HgHh4d3B0dX+AAQPql5aS \
iYaJiIiEg4SHipGZnZ+cm5KKg3RrY11fXGJpcHV3fAEDPW5nX15eY2dxiJCRkI6Jd3Nx \
bmppbnJzg4mYnKShmpWJgoWGiY2MjomDgIKAe3Z0cWxwd4KFio6PjomGhX97dXJ2eX2C \
hoiCf35+fXl6fHh0d3t5fYCEgoWLjYyHhHxyb29xc3h7ewEDG3l6fX95eX99jYuTmJec \
mgEDA52bmpaMhIABAzqEhX55enl4enx6cmZfXVdWW2FhZGJna25ucGxjYmZ3jpSYm5CP \
iIyWk4+Oin+Ekp6jop+VhHd2eXd1enl0c3yJjI+UkX94c3NvbXJza25teoCGh4mEgn6G \
obCvq6KQdm93eW9kXlhTXHB/iZCSjo6Sko2OgHJramhzgI+TlZOTi4J7dWdfYWhpcnyE \
hYWFg3l0cW9ubnZ7hI+ao6errqmglI0BA0+KkJWSkIyGAQP1bmdeXF9nbXN8eXZra21q \
ZmFTSEVNdKC7wb2zlnxtamVcVlRQXn2dt8TEu6OSjHxsXVhZTlpsh5iiqaaem5OLeWxZ \
WV5jboeeraypr6yloZqRf3Z0eIOIhouIgnt/gHFlaWNdW2hxdXl3fXp6cnFuZFpfbXJ3 \
f4V/fn2CgH6Bfn1+gYaQmaaosamSfWVXUFZmbnN+gZOowM65nHdZUlZea3yHk6Csub60 \
mnpjUVRgdYSLlJqbqaegknllT0RES1dgZXOLnKKjnoZnVVBNT1tna3KBjI+Zop+XkIh6 \
b2lnanF8goySkpOJg4mCfHJya3ONorq3rpiHg3t5enx+gomcoaCYj4JvZ2djY2dyf4yb \
pKCahWdRSUlGUmVweJSjo5yRg2JLT0xVXnCOk6OmqqKMhH5xZVtganJ6jqCdmJ2diXNw \
bGx4lbS9wMfCuKiYiHNiV1NZX218ipGNjY6DdWljU0dKV2BxfoaHiYl+fHBucnV3eX2C \
hoeFhIWCgYeEfXqCiYyUlZGFfnlzeHt0eXZxbnODgoCGgn6CiJSRk5COjJmturq1saec \
jYZ1Xkg7PEleeYyZmpWKgH52aVdTTFBbbX+DhH6Ee3RtZlxaZIWQkZ2yq5WXnIdzd4F8 \
hZWUjpursK6poY16cXBzd4OEdXBydm9xbGNaW19gand1dW5ka3l1bHB2lrKyp6iYd2x5 \
cWtdZWdgZG5/lK2+sLeujYuak3d6jY+MmqulnpmKf3RrX1BSVmJ4nKaak454ZmVbSTo6 \
PVJlcoOKjYGOl4p8haGZjZ+sl4eFf2RLS0pQV2BpeYqPt9vZx7WflIl9bW12bXaQoq+o \
ppuIe2tsZmFlam95h4aHin9wb2dMTFFRVmZ3hpqlpKKSh39zaVxYWGBneJyspp+inYaF \
h4l8eYKZl5ewtKKIiIh9cXR7dWl3iZigmoVsXElFTk5HXW93hZqejIV/e3JnX19jY216 \
hZSMmZB6eHl2cXeLqszWyMKminl3a2BnbGyNq7W8u7OfjX5oVkQ9Nj5QaX+Up6mdmpFu \
TklDOUVYanuSoJ+ln5KDd2tdWVhcc3yBlqKdnr7EvaeKf2xTTl1dWl53f351lKmblpaV \
j32DlZyWmKGnpaWflIFuXVdcXV1rh42AjZ2MenVrYV1bVlZcYWdxd317goWIh5KflIeH \
f3h6foF7cm1ycXR/gH97enV4cX6BdnySnJanvci/o52LbVtoeYeVnaCxsq+rn4NwZF9T \
RklQTFVye3mIjn5ybGFYVlhZW2N4fXuFkImJeXJzbm56l6atvsvBrZqMgH5/aFtvfIef \
uMKynJ2ah3p0Z1JFUldkeYqQhnp5bWNkZFRPVWVxgI+dloZ8dW5fc5yrk4mMemVvfXVs \
a3F0eZejmqOvqpucp7OfkZyimpymqJWFenJyd3lyZl9gYl1gYFROSEtXYGVxeICJj4+O \
fHBmYmBjdJmmo7K7p52jmnxiYFdSX3iXoaa4t7ConI10WEY9P0xecHuKkJ2ZhYSAb1xb \
X2VreYufpLC4u7ewpJB9dYKPl5WTnJ6bmJGBb11RS05RVVxyfoCOnZSBeWhTRkZES0lZ \
aHiMk4+px8a6sa6NXEBOY11pho6HhqG3s6aVgGxcXl1iW1Zga32Qp6iMhn96gYWXnpSP \
laKhnKGmo52WnpuQiXxrYGNcXGRmZWRoc3aAj42IiIBzb2dZWlxTUVhaXHB4dIKZvLy4 \
r6WTg4B/cV5YYmV3i6OgnZ+km4l+hGtVVltXZnB0fnqKlIeFfHpwb3+PkJeWoZuftrCo \
xMKfi46Hg390dXhweIeFe3Zqa2lhZ3BqYE9OUkRQcHhsYGV2iZqdoZV2bHV0bmNhX2Rq \
eZeurbPY2M/FvJ9iPk5oUUphdIOMucW+ta6hi3poVkxAO0tmdIeSk4uFf29qblhRVl9l \
bHaJnqKpsLm0rJyNiXhvi56al6SmnJqgmZB+dG5pW1BVUUNKUVRdb25sd4B1eoOGhYyc \
m39dVGZyfo6AdWdhhKmvrrClk5CRlJWDeHFvc4GSmZWIgoV3gI5/dWlnZ2h2goJ+gI2J \
fnxxbW5saX6LlZulo5iOioR8aFljdHyIlZqJhI2MhnZrXkc9RE5XYGhweYKVr7y5xc6y \
pJd7cHV4gI6an6y2uK+noJF8bmFAIhogKj5lj5Sap6CcnZeJclg2LjE6RVt1i5aqs7zC \
t5h+cGVdYGdlY3OFj6S2ubWrpZqOh39ya2VdZHZ6gYBvZ2x3foF+eWxeXGZqcXd8hY6Y \
uMzSv6GLhJCeoJqRj358k6ipnZWNfnNxfXdRODw+PWiQiH16bWNeYGBXQTZCV15rgpeQ \
hJCXnam5uaaZlIF+mKR+bnVjZ4GJjZmdlKCvrKSXjIJqYGJoYFlcYXF5hZyflIuFf3d1 \
bWRrbWhre4WDhIeZoJikoaeNdGZoW1dkc3Z/hpCXoZyWkYNyZ15WTEtTW2Bnb4KWrbe8 \
vbarmIyIfnV9h42Snqarp5+bkHVkUkRCQ09fcI6Pb3qhooWDiUsqMkZYZ2xvfYaRr8jG \
uaGLb2Bkbm1ZT1FjeaPLzMW9s6iTh25eSTI1PlBrgpytsK6zt7KpmHBNOj5FTVVcYmh2 \
kY+pyr2ppJmSj4yLjoN7iJejpqCbk39xcGhncWBPWl1UXHJ7dnFzb25ycGZeYF5jdoKJ \
iYOGiIiSopyKg4B7gpCqtqWJfHyDjJ6kkn1zdXuGl6Wjj3t2f5SelYVxVEFGWV5YUVRa \
YHSWp6qimI6FkpJ8gH2CaXWRkpeMgYd4eXeChn1xa291b3gBA2ZxcnJlYlxjYWh+gniJ \
m6GmusTCr661uK6in5Z+eXp4dXBsbGdfV1ZYVltiZW97f4qRj4V5c2pgXV5fXV9tfpGk \
r7CunZSSjoJ9d3qMh3iHnJiLkpyWinNnTjAqPU1MUFdqb3ODkY6QrsTN0NjYv6qhlYJp \
XFhaXmV1lrK7xMa+tKqek4RiTEc7KicwQVRWWm14fJikkH17b2NmbnFsYl9iaG5tcH6F \
f4edsrewqaKZjoWNpKeUgISWlZarrJl4amhkYF9dXlRIUW2Bh42alYSChoR8gJyump+Z \
kn1va2NoaWhseH+Gm62qpJiMeW1lUTkyO0VNVWJ5naq2uJmDf3VxbnZydIWZttXZ0cm/ \
sKWNgIB1aEwxJC04Rl55gnpyc358e5Spn6y7r6KiloFybXN7aldWbXuHjIuMe2RleHNo \
bHFiXlpqf4eDh5SOiKKvpZaJg3pzdoGGg3Vnd46RmLG7qpyenZSGeXFmUEBCUWFpeY+V \
jYuRl49+c3BiVVVhXVlfAQOhg32WoK6VlqKVgouQjn94bmpmZWJjanB4e4SYjpeSj4+Q \
o8XGubrKu6+7w7mtoZB9aVhZYVpMQTswLEZbWGBnW1dfZmx1dGplcHVseIV/bWNmdX5+ \
hJyvq6OrrKKhraqor7Wgi5GfiYOTknZnZ19PTlJVXV5eaXx7cXiFe3BueHh7g5eqtrOn \
mo5/bmJfXWBnbXqcucbL0Mm+rKichG9dSDczOUdccn6EhoOBfYSIgHpzZ11XW1tib2tr \
dICGj5qcm5GNh4aHf3lmZWxwdXp+hJCXi5rBy8PK2cOinKChmZCKgHVhVmR4e3Z7fm9V \
S2BoUElQST00P1ZeY2due3hyh5iVnJ+Xj5GVjpGWiXh1fXt7kKCgqsTSxr27sJ6OhHdj \
T0NBPj5DWW1vdX+Dg4CAg4h+c3N1a2dyipGYqba0oox9eW5icIeNf4CXoZuesLamk4V6 \
bWNeYWRiWl1vg3t5g4d9bWtraGNeXV5STE1gYV9lcHdxc36Ko6260MO2nZ6elI2JipCU \
oae8z83HxLqunZOLeWJUS0M8O0FLU1dYXmNiX2JlZGVpamppa3JwbnJ5gYSIjZKZn6ix \
tLCvrJmJi4h9en8BA5iEio6MgYOCdmJkZGFgaGxpbHZ2gImNiJKLiYqOkYaGhXx7dnl4 \
eYJ8f4F/fHuCe21sbm1wmaitlp2RgXFtcnZvamdxfIumxtPOxryroJN9amRYQjM1ODpI \
YXKCh4yWmZSOioyKe2xrcnZ4g5mbin5yYVNMU1xdXGJlbn2Kn66ysKuhmo+Gh35vb3Bq \
anuPmJqcop6doKOjnpGHhIFvdXd+dGp0cm1tanVubGdkdHJ3eIGBf3V7en12d2psYl5j \
a3aDgoqWm52YoJq2yLGys6KTjJ2in6Wom4uFf3l6f390bWpgWFxjX1VKPTQyLzA9SU1T \
ZXV7gJWdk5GShn+Ah5WXkZaamZiUpLy+sKino5GFlaOZj4uEf3l1fYJ7b2ViXFJSXV5c \
ZGJpd3l/iJWPgIOUlJGgqJuOgYF5dnJxc29kXV5mAQOEjZOQkqGhray4uKykoY96cXZv \
bnR5eX6DiImOjIF3cGFSR0RFPzo8QkVNaYaOm6utnpeYmJOUmpWLfm9qbHF6hpOWlJOZ \
nqewq6ObjXVfVE1HREdNUFpndIKTnJ6eo5+Si5GLg3h2fX98gY+UkIqKjImKkpefoZmQ \
iYSAgH+EgXpya2xqaG5vcm9mZmNmZGVobGRhXWFla3BucXR7g4mNmb3M1MqzrJOOqqac \
kpCGcXeTpK2vqpyLfnNxeXdoVkw/Li9DU1lgZGJiX15mcnRvbHBzcHWBhoN+gYeJjJGZ \
op6dpbnLyrqtoIpybXh+c2pta2dvgZioqJ6UhXNnaGtiWVNVUVthbYWIi4iQlpOYoaKd \
kox+enh3eHVxY15dX19mcHV4foyenL/S2M/Cu7Okknt6alVHTVlka3yGjIuFf4OCd3Bl \
VkZBPjxBVGpyd4CNkY+Rl6OilYyHgn18g46OiIqKi5CXo6anpZaDfHZtaGReV05MUVln \
dH2KjoyNkZeXi5CJdWx0eYGKkJmalJOboKejoZyOeHBsc3Z0d3d0cG1xeHt6bWZbVktN \
VV5kanR+go+crquxsbK8vLe+vraejoV6Zllgc356eoaKg36Ej42BcWheT0E/SVFPUVxs \
dXyLnZ+WiH5yY1ZUXWBcXWNpcHiEk6GlnZmbmJyjqauusqafnJeXjY2FfHJnbXJ3foaN \
iYF9e3pza2RgV1FNT15kZml4iIB+j6WmorC2rKKorKasqaCgl4N8fX90cnuAd3mKjYqJ \
gnZiWVpeY3B5dWpbTUhLUVpiZF9ZWmZxgJKZkYmAeHV1gpOVk5qZlJu1wr65sJp9bWxs \
cHh5enZ1doGQm56aj4RxZWFbWVhST05TWWNueoSIipOgrrvJ1dW/pZWAc2hkbXJvdXqO \
pLK4vrauopOHfGleVktAODdCUmJxfIOEenFydXVwa2hiWFVZY3FxcXdwbHuOlp2ot7u4 \
ubiwsKaQhIBzY19lbWttfIePl56kpqGYjYZ3ZF5bVE1ITExTV2FseoWIjpSSkpWisLy9 \
urShkH90dnJxgYqJjpmio6Wpp6CUiHdqYFZPT1BOS05XY2x6h4mIg3x2bWZgWVVXWFxg \
aHqEg4aPmZ2YnKumlI+Pi4uUm5qZmY6DhoeCgoWJgQIABRn4jJOSioWCfHJsZ2FaUlBV \
VFpjbm92fIKDfYiMh46YrK2rpq+rmYqMh3h1j46JlJ6YlJOWkY2PhnRwaltVWFxbWF1i \
XWJrcn6JiYiFfXJpZ2lmZ2hmZmptc4SQkJSbnJWQlZiWl5+ak5WVjImMj4Z8fH54dnyA \
g4F9fwIABRQtg3tuZl9aUU9TVVpianF3f46anqa7zcrAva6XhHhwb3V+fXh/gHyElJ+f \
nJeMfHFsZWJhW1RSVFlcaXuGiYuMiIF7eHNtaGZlZGRqdXp7ipOSkpOUlpOTlpWUkY2Q \
lZGPkYmMe3l9eXd4fIB7AgAFGdB+eXdyYVZTU1deZGt0eYCWpqirt8C6s62jlIN1cGxl \
aHN5e4CHio2Rk5SRi4F0a2ReW11gX19ja3B3hZCYm5WJgXhtZWUBA4ZkZWdwgImLmZ6Z \
k5mYnJWWlY2Ni36GjIR8enhxZ2pvdn14gICGh5OirKynl4l2amRpcXZydHuAgIiUnZuU \
kIl6cG5vcXBwbGZmaWpyfoCFkpCKkJWXlJGPhnlybmpqbW5xdHh7fYWOkJKVk42FfHZy \
b2pnZV1ZXGVucnyMk4yJkpqXlpqcj4Z/ewIABRicdW5sbnd7goqZl5+jo6akpKCQioB3 \
cGxsb3N4gIiJiIqLioN/d25nXVZZWVhfc4CHk6Ghm5CHgXqCioSGi35tbHJ1eYWRj4eF \
gHx/hIiIiIV4am93d3mGkIt8dnR0cW1tcG9nY211eX6OAgAFGvGFgH6Ae3d3enyAgYaB \
gY2anKKqrKSZlJSSk5KPjYd6cXB0dQEDLHx1AgAGGGl2foB2b21lWlZaX2Nobnd+gH2C \
i4mEAgAFF9mIkZ6joJyclIWDiIV/fXx3c3N5gYqPjo6KgXd4e3h0dnNtZmhqbnN5eX6D \
fn+CiYaHjoyFgIGBeXZ1cHN1eHx+h5ucnq+zopqam5yWkIqAdWheYm1yc3uEhXp1eXdu \
amdnYVhUXGRoZ296fHd9iIyPkZOZmZSQj5OSh4OGhX98gIWFg4WKjo2LiouHfnd2dXJv \
cXZ3c3F0d3V0eHx9fX6Ah5GUlZ+hn5SJgnx3bmxyd3dzeYB/fYGHhH56dXZze3iAhYeK \
lJuZko6AeXJxdoGGi4mIhICAg4J+enBmYVxXWmRxeH+Jjo2OkJCPjYuGfnt8fHt8f4KB \
fHp7fHt7AQMJAgAFGGeAgoWEfn2AfXx+foCCf4CAf4SJio2SlZGLjIyIg4mGg353AgAF \
GbV5e3t3e3x5eXt6eXJvbG1vbm91eoGBiZWZmpyfmZSMiIV/fYOJi4eIiYaBgIWLiIB+ \
fHRsam1xcnFzdnd5gYqKhIJ/dW5qamtsbGxvcXB3gYKHkpORk5eWlZmbkY6LhHx5enZz \
dHR0dnyEhY2RjIiEfnt1cXFubG1rbXF0eH6OlpWeo6CYlpSTjoZ/eHNvbHN+g4SHiwED \
VoSDgH14dXBram1yeH6BAQPUe3h6e3h2AQSkcnV2e4GBfISQk5CUl5mVj46LiYR8enhz \
bWxyeHh7goiGgoSHioeFAQM0eHFxc3NxdHqChouSmqCfnJ2ZkoZ8dG1mYmNqdHZ5gYiJ \
io6TkoyFgHlzbGpscHJydHt/goqJjooCAAcDAAED5nBzeHx+g4eGggEDAYCAg4iIiI2P \
i4qIhYGBgoKEiIqKioyKhwEDHn58eHRwb29vAgAFHGl6gYiGh4iGhAIABRYUfoCBgIGF \
hoSFiIiGhgIABh0afH58e3x9e3l6enl3dXR1dHJxdXV1eHt9gYiVmZuemZGLg4SJhX+A \
fnl0dn2CgwEDy4eDgIKDgX56eXZwb3N2d3h5e3t6fYGEAgAFGRuDgoODgn18e3cBBER6 \
egEDwQEEawEDmYiHhQIABhxmeHZ2dXd3eHuCiIuMjo2JAQOWAQV8en2AhIaJi4gBA15+ \
fQEDEgEEAXp9f4CAAQPpAgAFGw5/f38BA70CAAUgrQIABRqQenl8fn1/AQT5gYKDAgAF \
GlKCgQEDgISEhIACAAUbM31+f34CAAUbgYECAAUd/wIABR3jewEDEYSHiAEDeoyLioeE \
g4B6fIB/fH2Bf3x+AgAFIUF9fXwBBFd8e3wBA8N9gIKFhIOCgH16AQThensCAAUFWoKB \
gAED6oeKiomGhYB/gAEDjnwBAzN7foGDhYaGhAEDHn8BBBF4d3l5ewEEgoGCAQTVi4qJ \
hYJ+fH17AQNUfwEDFQEDFgEDWoEBAzwBBFsBBFwBBSyBAQPJAQRCfgEDKQEEAQIABQOd \
AQQshoaFhYaFg4KBgQED+3t8AQVHf4ACAAUaqYICAAUcmgEDAYGBgAIABgEIAQZDAgAG \
G7wBBFeAAQW0AQMUf34CAAYBEgIABRoXAgAIHGEBAyoBBB0BBQQCAAYbWQIABxtaAgAF \
Gj+BgoKDAgAGI1wBBhsCAAUiZwIABRuBAgAFGoEBBGcBBRUBBzsCAAUcUgEHDg==

#---------------------------------------------------------------------
# Compressed "pop" sound.

lappend gdata(list_sounds) pop

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    pop_bxdiv_lz77_base64 ""
append pop_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkBAoABAwF/gIGBAQQGgICBAQMCAQYBAQUIAQgNAQoMAQwSAQkZAQkV \
AQMJARAzgQEHWAEEBwEIHwEFMgEDcwEEdgEdAQEQdAEIOQEJdgEGEQEIHgEFAQERjgEJ \
MwELcAEFKYCChIWEg4mWoKSgoaamp6enpqKfpaamopeSkI2Ed2tjYFxaAQQBWQEDBFte \
Z2ttc3mDi5OZoAEDK6YBAwGnpZmNhoJ+dmxjX19eWwEFKgEDK2JvfouTl5qgpQEDTqOh \
oaGdlY6IhH53bmVdAQVIWlthZ250fIGHjJOXnp+lnIKGhoiIiYmKiYeHhYOCgICJlaGj \
AQiNowEDjaeil5EBBI1qY18BCo1aXmZqbnIBBo0BA2inAQOQAQeNdwEDjV4BA41ZAQds \
b36Kk5ebAQMlpqajogEGjYN9d25kXAEDIFlaWVtiZ211ewEEjZicoKIBA26mo5yUioJ8 \
dG1lYF0BBdNbX2Nna3F4gYmSmZ6goqSkoZ2Yk42IgXt2cWxnZGBdWlpdX2NqcXd+hYyR \
l5qdnZ6dm5iUkY2Ignt1bmlkYV9eX2BkaW4BBWORlJmanJ2dnZqWkYuFf3hxa2YBAx9e \
YGJma3B1eoGGjJGWmpyfoJ6cAQQghH94c25raGZmZmhqbXF2eoCFio6TlpmampmXk5CM \
hoF7d3JvbGlnaGlqbXB0eX+DiI6RlQEDHpqYlpKOioWAe3YBAx9ramlrbW9ydnx/AQM9 \
kZSWl5eXlJKPi4eDf3p2c3BubWxsbnFzdnp/g4eMj5KUlpaWlJOPjImFgX16dnRxcG9v \
cHJ0d3p+gYSJjI6QkpGSkZCOi4iFgn56eHVzcnFwcnN2eHx+gYWIio2PkJGRkI8BBR5/ \
e3l3dXJxcnJ0dXd6fX+ChgEDH46PkJCOjoyKiIWDgHx6eXd2dAEDHXh6fQEDW4aIiYyM \
jY2NjIuKiIaDgX99enl4d3Z3AQMefH6AgoSGh4mKi4qKiomIh4SCgAEIHnh4eXt9f4GC \
hIUBAyABAwGIh4aFg4KAfn18egEDAXl6e3x+f4CCgwEDHoiIAQUfhYQBAx9/fXx7ewED \
IHt7fX0BBSABAz8BBAGFAQM8gYB/fn19fAEDIXx8AQQegYIBAx+EhYWFhISDgYEBCBwB \
BB58AQQegQEDPIWGAQM/AQMhAQM9f38BAyB9AQUfAQM9foCAgYKDAQM/AQMBgwEDPgEE \
XAEDQQEFAX5+f3+AgQEEXoIBAwECAAUEcgEFHAEEOAEDWQEDHAEFeQEFOwEDHwEDIAED \
HwEDdQEEeAEFWoABAyABB1sBBCIBCUABAyB8fX8BAwEBBV4BBF8BAwMCAAYECQEDFX4B \
AwF/AQRfAQQfAQQWAQMcAQRfAQUNfwIABQQOAQUGAQMFAQQIAQgEAgAKBH4CAAcERAEG \
AQEFSAEHTwIACgRMgIEBBVwBBlcCAA8EwwEGQAEIcQEKRgEFSQIADAS6AgALBKABBM0B \
BmMBB9QBBgECAAcE3gEE1QED1wEEhn8BBjwBA9IBCSEBBCABBPR9AQUiAQZdAQgdgYEB \
BVkBBBoBAwQBCl2Dg4OCg4EBAyMBBT0CAAoBMwEFXIKCAQMdggIADwXsAQXzAgARBacC \
AAoF0wEI7AIAFAXjAgAGBcACAAoGaQIABwEjAgAIAXkCAAkF0gIABwESfwIABwFBAgAV \
Bn0CAAoGCQEQFwIACQGgAgAIAVQBAwQ=

#---------------------------------------------------------------------
# Compressed "poweroff" sound.

lappend gdata(list_sounds) poweroff

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    poweroff_bxdiv_lz77_base64 ""
append poweroff_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkEgAEHAX9/AQoEgH8BBAcBCAkBBwsBDQEBBCkBEBABCCmBAQdQAQQO \
AQdEAQYIAQVfAQYuAQcCAQ9YAQwPAQgMAQZOARABgYGBAQYaAQhDAQeBAQkBAQpvAQaY \
AQ0cAQeOAQfrAQtyAQltAQcJAQNmAQUFgYIBA3EBBnIBBAkBBAgBCNwCAAcBLH4BBE8B \
BQUBBW5+AQcLAQmOAgAGAUoBDMIBDEsBAwsBBGIBCHgBBQsBBUcBB8UBBFF9AQVUfgEH \
AQEEYgEDFHx9AQMXAQYQAQYbAgAIAcIBA0OCggEFVAEFZgEDDYMBBBABBxgBBhsBBAwB \
BXUBB98CAAcBJgEDZwEGvn4BBF0BAwQBDsgBCAYBBikBBSQBBAYBBAgBCScBBmQBBFWD \
gwEGeQEGjAEHYQEIMAEGyAED2gIABgEZAQRaAQWLAgAHAUUCAAcCfgIABgGxAQZ/AQPB \
AQV5AgAIASUCAAUBLgEG3AEHBgIACQHDAQeMAQR1AgAFARgCAAYBSwEFdX1+fXwBBAF7 \
e3x7AQWKAQq8AQVPAQStAgAHAS0CAAcBowEGT35/AQUXAgAJAoEBA3MBBAECAAYBawEE \
9wIABQIqAQjhAQRUAgAGAZ0CAAcBpH4BAzgBAxQBBM4CAAYBwQEEm3wCAAgB1gIABgMa \
AgAIAb0CAAYCHoKDhISDg4IBBuIBA1uAAQM8AgAGAah+fXx9AgAHAtkBA8wBAz0BBXd/ \
AQRjAQTlAgAFAb19fAEE3Xx8AQQDAQMZAQR5gYABBacCAAgCd4IBA14BA18BBcsBAwOA \
AQPQAQdxg4SDAQN0AgAFAb2BAQOlAQPOfHsBBKsBBLB9foOIkYqGfH+IdmlwAgAFAiR6 \
eXh7d3h9fnl6AQNXhIV8eX2AfgEDbHV9fXqEjn5zd359gI6GhIKSjZGGgIN6gnuCcHeF \
g4SAf4eAjop8g3KMk4mAfHZzgXl9eoB2fIFwf3eIf4CRiYNzeXiCio6TiYx7fnh8hnWD \
fIqDhYOMhHqFbHR4i4N0dnFnb4l7fXVsbGWAd5B7fYJ9j4iUdIJjWGiEgIqXfmdyfmuF \
hIiTkHp4c42kiY92dpR7oIuXg4qOeZ6Xg2yfiG9xjHiLiIGEcXFren+LgoZ3h4RvbIuN \
bHh9c312c3p/fGtlaXqQfnR4cG18kIABAyGDfH2CfnuOiAEDxX2Iho6LeXp7i4eTjIGL \
h4iLi4eGjYaKiIJ9goeBh3t7fG51in95eYB1c4KEf2x7eH2AfYp5fHZ1cW59bnZ+eHNv \
foh/gX13fYaHk4KIi3WDhoOIhYV8eIaDf4aKf4CFg4SEiIaCi3uIAQMHhYR8gXt8eY+G \
i393e3V4en2Bf31scX1tgX5+hnx8hHZ5hXh5gHh5e4J9fX+Ae3d8fnp2fXx8fHl3g4N9 \
e4R+fH2AiIN7gYaCf4KFg4N/fnuDhYJ/eICFiIiJiYGJe4J6goyIhH6Lho54eH6Ke3Z6 \
coB/hod3fYmHe3SAfnV6fYCEd31+i4CCgHN2cHN2cm90cX16g4J6cHR+fHl8gH13hYiA \
hIiIfoF+goSMh3x9hYmCf4WOlYp9foCPj4uJjIyPlZeemZabko2QiH2EfnJ7enx+e3V3 \
eoCDd3t/e3h8fnxzdXmBgYiLdnFxd3+HhYJwcnl7eQED1YmBeXR4en96gXp2cWhvc21h \
Y2RueXR3cXd9eXyBg3yCgoqIg4KBgoaKi4SFhIeUjYmAf4iHkIqLjIaTjZSSjIKHj42I \
g4aFjoaBfHR7e29sdoB0cnaBenJ6enh4dXRzeIeCfnuEgoGIh4OCgn+BgIONhnyBen+H \
joV9hoWAhoeIiYCHhH9+e4d9eIp8cnN6gG5xdXd9d36BhYmJhXt9fYeNhYJ9iY6Oh4KG \
g4OFgHqAeX19goR3eH2Ei4N+gYKEfH6Ch4h9fHt3fnhycWhkaGhrd3B1fn1taXp1d3Nw \
bm1scHJ0gXV7eHyDhIB5hIGBe3Z5goqQjouQkIuQmJmemZWVmJqcn5GUk5GKiYmDgoWE \
gIaFfXZ3doJ9doB8fX+AgoiDgIR9e3l0cHp2cH93goeFhIOLjI2Mi4iDgoaHioaEe3iB \
e398fXx1bmt6dHFuZm50cWNmcWtpaGBhbXR6fIB6dH17hYJ+hIaJi5GVl5eXmZOVlZSU \
jo2Ok5CMipCKiop/gnx4enl6dHN4d3FvcXBrbGtwdXRxcXJzenZ1eHZ9eHmBgIGCf3mE \
fnx6eH+CiIiOkoyCe3t8goSFgYGCfYF4c3p6d3h0c3F0c3R5dn5/e3pzb3d8fHt9foCE \
ioSBiYeJi4yGg4YBA6yJhoiIhpCalJOam5ualZOOkpCOlY2OAQOLkI2JhYeChIqHh4aF \
hH6DgHt7fYN7e3+BgIB8d3R6dnp6cXR1cXN5eH12b2lpZmlqAQNrdn8BA55wb2loY2Je \
bG1wcmlucHZ3dm93gIaLhIePkI2Mg4mHi4iHkI+Ih4OBgnN4eHx3eYKKjJKNgoSEiYeG \
ioyDhH+EfHp6b3R1bHN2bnl2eoN+eXx2dXZ5eQEDw4CDiIqNj46QkIuLh42JgX99fYGA \
d4N6foiBgoJ/fIR9dnuAgYOKjY6Qi46Ni4+MiIyIgYWChYyNlJGSlZeemJGQjIeCgoaM \
iIiKioqRj4qLg4OCh4iFgYN9eXt7eHBzb3B3dHV2amRnZGVoZ2hsb3JycXJwcGxpcHNs \
a2ttdHNwbWhkY2NobHFzeoSEhIeHAQM+kYsBAwYBA7R3dXl9foWJhIKBgYN8f4SIhoCE \
hIWHioqIgnyBfnt5d3l4d4N/dXt6fnp3eHZ2dXp/e3d5eXWAf4SGi5WSAQQBlI2VlI2J \
hoeJi4yKhH58gISMjImIhnt/gH59iYZ/hIKNiYKAgYeEhomKioaKh4SFho6SAQO/gISP \
jpKNfn59gIeBgn9/goKHhYaJiHx6goGEiYV9hYmMkIV5gomDgX92dXZzdG1ueW9vdG5w \
bGdqbGhtbmtta29zeHJwdHl6dnqBhIB+hH53dHBxfX50dHiAiIeAg4N8dXJ5fX18gomQ \
jpGPiouJhoCCgX6Cgn+Af355hJGOiIUBA3R8fAED8358foCDen9/d3p7gImBfXd+g4KG \
gH5yAQNceHsBA+p4fHt2eXhycnJzdQEDLnp0enh1bmZmYWdrbGxwcHF1cnJ6eHiDgomN \
j4uSi4ySjYqPkYiQlZaPjJCXjIqGhYF9f4SKioSGkouHhY2Qi4yQkYyJi4mLkZKXl5aU \
jYuGh4eChoZ+eoF/AQOOhIiFho6MiYOKhX6CioWFiImMh4iBf3lydXVsaWtwc3mBfgIA \
BQhAhoeMjomKjY2PjIqLhoCDhoaEhIKCgIWCfIKIhH55cHRxcHF2d3FraG5ta2hpZl9j \
Y2JiaWloaWhtbW1vcGhmaGlsAQMgen2Eh4WEh4uKgnwBBOJ3eHl/gnl2d3h9fHp+fHp8 \
gIOJi4V9eoSChIB5AQNMbm5rdHFrcnt7AQM2AQM3foEBA5d9hYWGgISAgYJ4dnZ3d3yF \
jYyRk5KXlZWUlJmgmpyfm5iXlpKUk5KRk5YBAwaTj4eHg4WKh4aMj4mNk5eSjY6NiYuJ \
iIiBgoB7dnl2dnV0dQEDt2tqb3J0dn2BgoSHiYiDf4WEg4WIjIiGiYuEfXRvbWxqampt \
c3Z6fISAe31/goaFiIqJioqKi4uKiQEELnt4dHRwb21nZWViYWJfa2pnaWxram1wcnF3 \
AQNddwED1nt6e3t7gISBewIABgjMfn9/gYOHioqJi46NkI2KhoeHhoB9e3h1cnNydXJy \
dXZ1cnl9eHd7fH59f398goeDhAEDcIuOkpSSkpOSkJKTk5WRjpSTlJqZlZOPAQMSAQMB \
jIuIh4mDgH99e3l5AQNydnJ4eXx+fICDe3yAfHp7fHp+eXYBA4h7eHZ4c3N4eXmAgH2B \
gIKGgoSCgAIABQd9AQQec3Z+gIeAd3sBA0R8AQM8fXx8f318foCFg32AgHpzcXZ2bm5v \
b2xqbW9wAQMBcnN0eXt7gX+BAQNHf3l4d3UBA1UBA3p4fXl8hIeFg4OGh4mKioyNjIoB \
A5eOk5GPjo+PiY2Rj4yLhYV8enx4en5/gIOHjY2JiIaKiYmNi4mKjI+TlJeZmgEDApmW \
k42MAQMpf4B8fnt9g356f36GhoKChIaDhIiIgoKGg31+e3NtbWpiXlxfYmJiZ2xrZ2dm \
ZWZmaG5uAQOcaWRnZm1yd314eH1/f355fYGEhYeMi4mIh4qKh4eHiouIiYyRk4+Kj4+O \
ioWDhYSDgX+DfwEDknx6fICCgX97fYWHg4WGh4QBA9qCfn97f39+fHl/f3x5e3yBgoON \
jIeIiYSKk4+Li4iAfISGhX94e3h2dnR1cXN1d3d4en19dnV1b2tyeHRydHRua21sZ2Vm \
bG1qb3R2cXZ7f4SLj5CQkpORko6Ni4yFg4eGjAEDCIyLkZWZm52goqGfnpyYl5OMjIiD \
goJ+gIJ7eXd2enp8fXp3c3NzdHNzcnBvcW9wcnRvcHR2dHZ6AQNve399enx6eoKEgISE \
hoSBgX+AfHx/AQMIfHp+g4KFiImKg4WIiIqGg4YBAx2EhIB+e3l/gHsBA1p/fH5+end4 \
c3RybG1oZWZlZGhtb29xd3d9goUBAwGDgn9/gYOBfXl1cwEDgHl6fAEDMoWGg4KGiI2O \
i4qJiY2QjYySj46SioqMiIaDf36AfX1/goSCg30BAyKKioaGiIiMjY2PkZOTj5KUmJ+d \
mpeRl5uWlI+Lh4eHg4J9eXx3c3Z5fXl2eHh6f4F/fnp7e3h2cW1rbGhqam1ydnd2fn59 \
foGCh4uGf3+Ff39+eHlzb2toamZhYF9iZ2ZlampucG51enp9gXp4dXBxdXRvb21scGxr \
bGxuc3Jzd3Z3d3p6f4MCAAUNW4CCg3p5foODgHp5d3kBA917fH2DhoiMk5iZmpugoJ+h \
np2fnZ2fn6GhnpucoKSko6SkoaGhoJ6dnZuYlpGNjYyHhIJ9eHR0cXNya2poZWZqampo \
Z2dkZ2trAQOEdHNucnd3AQNydnp8fn9/gYKDgoUBA66Cg4OCf3x6c3Bwb3FycG1ucG1p \
a2xucXIBAyZ8gIWDgoSDhYqKhoeOjYmHhISIhYABAy6ChoSCAQNAhYmIioeJjo6Pj4yF \
g4WCfnt5d3N0dXJzc29wAQPmeXt+goB/AgAFDvWAfH1/fnx3dXNxcnFydHd4AQMIdHd5 \
e3h0AQOMd3oBA4sBA2SJioyMio6SkpSWlpual5ibAQPUnp6em5mZlJeYlJKTkY+NiYmL \
jIuFgIGBe36Df3+DAgAFDXN5dnd3dXV1AQOtdnZ5AQMBdXZ6dHNyb25sa2xsaWloZGRn \
ZWZpaAEDBGpscHFyc29ubWpqbnBrbG1sbW1rbXF4e31+gYOEiIiHiYiJjY+Oj5CMjIuI \
jI6NkZWUlZiZm6GgnZqWl5iWlQEDAZKPjY+QkI+PkZOWkI+Sk5KOjIiEh4UBA45xbGxq \
Z2VjYmJkZmZlZWhpbHF3fYGCg4SGh4WEhYKGh4J/fXZzcnJwb3EBAwFubnN0eHx9fn+B \
gHp7fXl5enl3dHR0c3N1eHt/g4iLj5KVk5GUmpiamJGPk5GTk46Mj4yLjoyJiIqIhoaH \
hoaIh4WDg4CDhH98end3e3lzc25tdHVwbG5vcHBwbWptcHJ0cXF3eHh9f318AQOAiouL \
AQO0AQMCioaHiYECAAUPgX17e4OEhYqJh4oBA+6OiYaIigEDWoGCgYCEgoB/e3h9fXp5 \
eHZ2dHJ0c29tcHFua2lrbmtsbGhna2xrbHJwcHZ6fYKEiIwBA1iMjQEDBoeGg4KBf356 \
dnh4dnV3dHN0cnIBA810dnd4AQPafX18e3x6enx9fX9+foODgoOEh4iKjIyPkpabm52e \
nZ2foaKgnqCgoaCjo6GgoZ6enJqamJWTlZGNjo6IhoqKhQEDwYiFAQMDg4SCf3x8eXNy \
cW9pZ2lpYVtbWVtbWlhYWFxeXV9jY2JkaGpqaW1vbAEEqAEEC2lqamxvb3IBA4d1dHh8 \
fYB9gIKDhomHiImJioqLj46KjY6NjI+PjYyQkI0BA2uLAQNhgH59eXV3d3Z5eHp6e4KD \
AgAFBymMi4qNkJGSlJGPkZIBAweTkpKTk5GQkZCOkI+NAQM+jY2PjIuMjYuJiYiHhoKB \
gH14dXVycG1oZmdoZGFgXlxbXF1fX19eYGJjZQEDE2xra29wcnR1eHp9fnx9f4CDhoaG \
h4yMiYyOjQEDUI6QAQMBkZSVAQNklpiUk5WXlZKVlZKRAQMBjo6OAQNqjgEDZ4iKioiH \
h4aFhoMCAAUQOYJ9e3t7eXl5eHd3dXV2dnRycXNzcG1scHFramlmaWtpZwEDAWhoZ2du \
cm5ubm9ycXF2eXd3eX6BfoCDgoSGAQOzg4SIAQO6iYmGg4KDgYGAend7fX56enp4ewED \
nn99f3+Ag4eJgoCFjI2Ii4uIAQOojoqMj4qGioqGhISEg4SDgX+Bgn16fX19fHl6d3V4 \
eHl9enp7fH6AgoSFiIiHjJCRkJWalpaZmpiZmZmYlpaUkY+NjouJhoB+fHwBA4lybWxs \
a2wBAwFoZ2hlZ2dqbGtra21ycwEESHp6fH2AgQEEgn59foB/AgAFCIJ6fHwBBA5/gICA \
goOAgQEDgIWHhYaKjIyMjpCRkZSUlZeXmJeYAQNol5WTk5IBA2uKhYKCf398dXNyb28B \
A2Zqa2xtb3Fwbmxwc3JycnNzcnUBA2h+gIGBhAEDR4aFhYKAgoF+fXl4dnV0cW9xb2sC \
AAUBO2ZhYWVoAQMBaWtub3EBAzZ2eXl8fX6Dg4ODgoOFAQMBhIWGh4aEg4aDg4J/AQMS \
iIqNjo+Rk5WYmZuampydnKCioJ+fnpycm5mUkpQCAAMA/5CRjIiNkY+Li4uKiYqNi4eE \
hIUBA8iCfgEDVH5/f3p4fHx7e3l4enp3dnZzbm5wbW9zcgEDsHV4d3NzdXd8fHoBAx56 \
AgAFB1l0cnZ4dnR1d3d2dXd4eHp2dHh7enh5fQEDIncBAxZzdHZ0cwEDr3Bxc3NvbHF1 \
AQMudAEDQXh3eAEDvnt7fnt4e3wCAAUUtYCCgoWFhoiHh4qMjZCTko+Ql5iYl5aXmJcB \
BAEBA7OWlZaTkI2Nj5KSjYyNjY2MjI+QiomIhoiKiYR/f4B+AQOsdnZ2cGxub21qaGpo \
aGhnZmhpampnZmlpbG8BAwFwc3R0eQED24CDhIYBA/GLioqNjY6RkIyOkIyGhwIABQJG \
goICAAMA/4CCg4B+f4OCg4eIiIiJi4uLjo+QjpCUlJOWlpOUk4+OjIuKh4aCgIB8AQPz \
cnFxbWppamtrAQVvZWJjZWVkYV9gZWZkY2NmZ2loam1ucnRydHuAgICChYeKi4uMjo+O \
jQEDBwIABQnPhoUBA3N/f354d3h3dnVzc3N1dnV0dngCAAUB1X+ChIWHiQEDo5CQkpSU \
kpOTkY8BBDqJiYeFhIKBgX99fXx7enp7fHx9AQPPhQEDq4qMjY6PkZKTlZWVl5qZmJeV \
lZSSkY+OAQOvi4qJh4eEgX9/gH59fXt7end3enl5engBBG1ybmtpaGloZ2hpAQMBbG1v \
cHR1d3uAgoQBA/iKioyMiYgBA6WGg4KCf3x7eAEDL3N0c3FwcG5ubW1sampsbm1ucHFy \
cXN1dXZ3eXp5AQPGAQMBd3d5AQMEAQUJeHkBA6F7AQSnfYCAgYOFhoeKjY6Oj5KWmJmZ \
m56goKChowEDAaKfn56cAQSxlpSRjo2Ni4iGhYOCgH18fXt6eQEHSXl5AQNLe36AgYGA \
f358AQPCAQMUAQOOdHJxAgAFBzxoZ2ZmZGNiYwEDAWRmZ2doaGgBA51tbwEDmXZ4eXx+ \
fYCDhoeJjI6QkZKUlZWWlpeYmJeXmJkBAwaYl5aXlZOSkY+MjIuJiIaGhQEDo4eHiAEG \
AYeHiYiJiQIABQyXioqHh4aGhIKAfnx5d3VzcGxsaWVjYmBeXFxbW1taW1xdXmBiZGZq \
bG5xdHZ6fH6Ag4WIiouNj5EBAwGSkpCQj4+PjgED2oyLioqJiIWFh4WDg4SDAgAGF4aB \
goSEAQR1hocBA3CIAQNlhoUCAAUVdYGBf3t6enl4enwCAAUIQXFydXNydHV1AgAFCZZ5 \
enp4eHt9fX16eXl5eHt7e3x9fXt8AgAFFrZ/gIF+f4KChIYBBFOIjI2LAgAGAcGFhISC \
AgAIGJF+f358fHx4d3t5dQEDrHt8fAIABxZGgoICAAYMgoSFAQORhgEDQYmIh4mKAQSy \
AgAFAQ0BAxSEgQIABRZzAQNufHp2dHR2dQIABQH5AgAFB0x+gYGDAgAFAT2IiIiJiImK \
iYqMioeIhoOCgH59end4eAEDJ3t5ent6AQS2AQOCAgAFFsV+fYEBAx5/f3wBBNF6eHd3 \
AgAFBD92eHcBBAN2AgAFAm13d3R1d3h4eAED53h8f4GCgQED24iKiouLAgAFA5iKi4yL \
iYmLj5COjY+OAgAGBpWMi4qMjI2MjY6NjpGSkpKTkZGPkJCNigEDioABA2h4d3VzcnBu \
bmtnZGNjYV9eXlxdXF5gYGFjZ2hpaWptb29xdAEDd3d7fYCEiAIABQOqj5CRk5OQjpCP \
jwEEXY2Mi4iHh4aEgQIABRg2eAEDo3V3dnd5ensCAAUNgYuNj4+Rk5SVlpaVlQEDA5OR \
kpOSjouJh4SBAgAFAsl2dXR0dHJxcHBwcnJzdHV0AQPid3h5ent6ensBAx96egED5gIA \
BQ8+dHV2dwEEVHx9foCBg4WJioqMAQPajpCQkZEBAwSQjwEFiIqIiIeGhIODAgAFAxB9 \
fAEEQnkBAwN4dnV2dXRzc3JyAQVmAgAFAjICAAUI+Hh4AQNrfH1+f36Bg4ICAAUBq4WF \
h4mJiomHh4kBA2CNjY6OjoyMio2Lh4aHhoOAAgAFGLt6AQM3AgAFCgYBA5QBAwR3AQPr \
ent9e3t7fAEFSX1+fgIABRhJf35/AgAFGGx+gIKAf4CBggIABRm8goCDhISEhYKEhQIA \
BQiIgoCCggEDBH+CfoaFnpKMf32DT2Bwgnttb290eIWQjomDiJWTlIKJhXuGfoiGjIh4 \
eneHi5OSiY6PjZSZlImEi5GSgYN9fHxsc36Pinx4eIN9cHB8iHxnZnmKemRndnVpX2WI \
iXRwcHZ2amNteHV2dXJ4f31yc3RtdnpyfIF3cHBxgot3cwEDpXd2iJB/am9/jo18eIGE \
enyGjI55cX2Kk42Fio6CcG50hZKMk5uajoZ+fI6UjY2MkJWakIeOe3uKjIaWlZGQg4OE \
g4N9hpSWmJeDeIt5d497dIZpcpWSlHVicHBXXm9zeXVfZnd5dWlmY2xkZ292hn5xbmpx \
bGd3naSdfVh2gHRsbXWKpKOkmJB6XGJshI6CeHmDjZKKgX+Df36GhI+ain6Ge3FwhZyg \
mpKSgX9ykpKGh4qTfIWGmIl0ho6PjIaOnolqYHugm3hucIWXh4aSfnJxco+ReHFvY25w \
e357cHKPhn1zZXN3bnqUlYqIgYmMfWt6fYeMhJiJc25xf4+Vhmt0f4OfeE5VZZasnJyk \
iWhQW3N+gXt/dm5seYWJgIWGeG1ofIqFcW98goB2gJGLeXKCjod6c3JrgImJhm9wgYR4 \
fXFyclxwo7yid2VpaWtug5IBA8R9g4WChIaDenF5gISDgHt5d3iEi4uFggIABRAAgIGC \
g4uOhn97eX56d5i1qIRtaWx2eoiXk4R8gIeHiIiKhXt2fouLjIyDfXh6hY6OiYeHgn8C \
AAUIBYaIhYF7b3Wes5V0Z2ZveYCOlIh4dnt+f4KEgHh0eYKJhX16dG50gIiGf314d3h7 \
fH99dXJ0dYGXln1saGlyfoKHin90dHyAfoCAeXV2f4aHg3t3dHZ9hYsBA4x8fHx+gn96 \
eXyPmoZ3dHNvd4SMkId8AgAFEeIBA3R4AQNUhIB8eHd9homHgX19e3x+fXt/kJaHeXRz \
cXuFiY6HfXoBA4h/hYWAfYCGhX57fH1/goeIhAED7wEEAYSZl4B0dHNyfYmMjYR5eHuA \
gIGEgHt6gYmGfnl4eHmAioyFfXh2dHN4iZuRe29wcnJ+i4yGfXd3eX+CgoJ+eXuBhoR9 \
eXt7fIGJi4J6eHp4eIeZlH9zcgEDxI2Rin95eHqAhoeGgH59foOGgnx8gICChoiEe3Z2 \
fo+XjYF0bGt1iJGQioF5cXJ8hIiDgYF+e38BA8t4fYKEhIN/dwEDdZKHfHhxbXKDjo6H \
f3t0cnuDiYV9gYB6fX8BA+V+hISDg395eX+PlYR5dW9xe4yWjoV/eXR3gouMhYCCf3t+ \
g4SBfoCFhIB/fIGTkYSCdW5ydIeUjomGe3J0eYOJgoOJf3l9enx8eoGGggEDd3uKkoV+ \
dW1xcn6SkISDe3JzeIGJhX+CgXx+fnt+fHmAhAEDCICWkHt6c2tsc4eVjIOBfHBue4SG \
gn+GhHd5fnl7fXyGhXp8f4yTgHl5b21wf5KQh4SDdm51fISKgYOMfnd8d32CfIOFenuD \
kpiGd3NwbG4BA5eKgYB/cHQBA/GBgIaCeXyBAQPZe397gpqZhHxya3BwfZSQg4N+eHd7 \
g4qEe4CBfH2CAQOreXx/fISZm4Z7dXBxcIKXj4WBgH52eomNhX5+hIF7gYiFf319fXqB \
mp4BA+FvbnB/lJGFg4F5dHmEiYd+fYJ9eH+Dfnx4eX95f5iXgXhzbm5sfJWOgH1+enBy \
gYWBe3p/fXV5gn15enl7eHqOloJ5dm9vbHSLkIJ9f3x0cnqEiH55gYB3en98fXp3fXuE \
mpWCfnRsbW5/lZGDgoJ7d3mAh4mAfoSAe4GCf4GAfIF/hZmWg397dnJvf5ORhwED6Hh1 \
hYyJhH6BhH2AhoN/fHl6gZKaj4t9bnFtcIqSiIiFend5eYSLhH1/end+fn6CgHl4dH6T \
k4eGfHBqaHWJioSFg3pydXuBhYN+gHp0en97gIJ8end7kJWHhIB0bGp0hYuGhYiCdHWA \
gYKGgYGBdnmDfnuFg3x9f46Yi4KBeG9rdYeMiIeIhnl0f4KChYKCg3h5g4B9goJ9d4CV \
lYuMfnNyZnCHioSLj4B5AQPgiIN9ioN0fH12fQEDkYCClZWIhn5ybGpwhImCiYyBeXx5 \
e4eCeoWBc3uAdn6GfH2AgpKWiIKAdWprc3+Gh4WIh3h3fnt/hoCBg3h3f3t6goF8fIeV \
k4yJfXdvZm+Ag4KLjIF/gHd7g4CAiHx3gHl0fYB9gH+ImpSKh31zbWlvfYODiouBfoF6 \
eYSCgIZ9eIF8dHyBfYCBipmWjoZ9d21pcH2ChYmJg36AfHuDhIGFfnZ8e3V6gYB+gYmV \
lZCIf3pwa254fYCHiYODgnx8gYGBhX14fXlzd319f3+CkpiPi4d7cmxpb3p+gYiGg4WB \
en6DgYGAe3x7c3V6fX9+f4uZlY+Lgndwamhye3+FiYYCAAUYMIWAgYJ8e3hzdXt+foCE \
jZqXkYqCdm9ra3N8gIWKh4iFgH6DAQRMfnx2cnd7AQOshZCbk5KNfnZwaGl2en6HhoWJ \
hAEDOIOCg399eHJyAQNpfoGGkJeUkYd+d21oanJ3fYOEhgEE0oSDgYJ+fHhzAQNpfX6A \
hY6YlY+JgnhxbGpxd32AhIeJhoKChYaFg4B9eHRydXl8f4OFjZmXkYyEeXRtam51en6C \
hYiHhISFhYeEf3x4dHFzd3yAgoKJlpeSjYd9dm9qa3J4AQM0iImFhAED14SAfHp1cXJ2 \
e36BgYaTmZSPiYF5cWtqcHd9foKHiYWDhoaHAQVHcm5zeX2AgoaPlpaQioR8c2xsb3V6 \
fH2EiIWEhYiIiIaAend1cHB2AQP2g4ePlZSOiIN6cmtscHZ7fX+FioYBA9iIiIV+eXVy \
b3J6gYKDhYeNlZWPiIN7cWtrb3R6f4GGioiGhgEDR4R+AQOxcXN6gIODg4SLlZWQiYR7 \
cWhobXR7f4KHiwEDs4eJh4J9dgEGJISDgYGJk5eTi4Z+c2lmanMBA+eGioqFg4UBA9x/ \
eHNycXJ5gYaGgn+AipaXkYqEe25lZW13gISGiIqIg4KEiIiEfXd0cXB0e4KFhoN/f4mU \
mJGIgnhsZWdwe4KHhoSFhIGAhIuNh311cW9wdX6Fh4aDfHh8ipibk4h+dGljaHSAiYuH \
goB/fX+GjpCJfnRxb3F3f4aHhX96dn2NnJ2Uh31xaGNpdYGJiIN/fn5/gomSk4p9cm1u \
cHd/hYeEf3l4fo2coJaIe3BoZGp1gYiHgn59fYGFi5GSi3xwa2xxeICGAQMmend7h5ef \
m4t7cWpmaXSBiYmCe3h6foaMkZONgHFpa3J5AQNMhYB8eXl9iZmgloR0bGprcXuFi4d/ \
dnN5g4yRkI+JfG5pbniAg4OEgn56eHqAjJqelIFybW1wdH2GiYN4cXJ6ho+Tko6Ge29p \
bnqDhYKBf316en2Bho6YmY98b21ydnl+goR/d3R1foqUlo+Hf3lycHJ7goN/e3p7foCA \
gYaQmpuNd2tsdHgBA1yDgHh1eIGNlpaOg3t4dAEDW4KEgHt6fICDhYOBhZCalYJwa3F6 \
fHt+AQM/d3V4hJGXlIl/egEDKXV9hIN+eXl8f4F+fH6Lmp+RfG1sc3l7fICBAQRvd4aV \
nJaIe3Zzc3R7goSBenV0eH+EhH58g5KdmYh2bwEEKXt+f3x2cHJ9jJmZj4R8enkBA419 \
f314dnZ8hYmGf3yBj5udkX5wbnUCAAUNQAEDKnB6iZablYl+eXh3AQQqfHZydXyGi4qD \
fHyElKCejXltbXN4e3t8fHlzAQPti5icl4t/d3NzdQEDanp3dnqAhoqJg36AiJSdmop3 \
a2tyeAEDgXt4c3F0f46Zm5SHe3Nxc3gBA2p6eHh6f4aLjIZ9eH6Mm56Tf29qb3cBA399 \
e3ZxcHeFlJyYjH51cnR4fH9/fXl3d3yDiIqGgXx6gYyZAQMsbWZsdgIABRfGdXJyeAED \
LJmMe29tcXmBhYMBAyx4e4KIjIuEfHh0eISUn5qIdGlrdYGHh4J5c21scHuKl5qThXp1 \
dHmAhYR+d3Jyd3+Hi4mEf3t6fYaVoJ+Od2djbnuGiIJ6cQEDUXuJlp2YinpubnaBh4V/ \
eXd2eX2Fi46Kg3t4dnl+iZSblocBA1x4hIqHfXNsam13go2WmZKHenR2fYWHgnpzcHR7 \
AQO1AQS2eXh9hpSdmYhzZmh0gYmHf3dwbW50foqWm5aJeW9vdoGGhX93c3V6AQS3h4B7 \
eHh6fYSOl5eNe2xpdIKMi4F0a2ltdX2HkJeXjoF0cHV/iIqDeQED+ICGh4iGg397eHd5 \
f4qVmZKDc2pueoWJhHtxbGxweIOPlwEEjXN1e4OGg3x2dHV5f4SJiYaCfXp5eHh9hZCZ \
l4p4bW54hIsBA71ram1zAQSPl4x/d3Z7goWCfXVzc3Z7gYeLioUCAAUCy3x8gAEEYoJ0 \
b3V/hQEDYW1tcXR4go2Ym5SKgn5+gIF9d3JxcnV6fwIABRZPgYGCgn96d3qFk5mWh3du \
b3mBhH95dHBtbXB7ipmdl4uAfH2Dg4B7dnRzcgEDbYiKiIQBBTJ5dHR9ipmemIl5cG8B \
A0t+enRrZWVuf5GdoJmQhn56eHh7fHt2cXBzfIWMjoyKiAEDynl2dXR0fImXn5mLfHR0 \
eHl4d3VzbmhpcYOWoKGakYd+d3N0dnh3dHJ0e4SLjo6Ni4eDfHl1cnFwdH6OnaKcjX94 \
dnV0dXd3dG1oaneIlZubmJOLfnJtcHV3eHR0eYCGiYuMjYuFfnt5d3Rzc3N2fImao6KW \
hnlxb25wc3h6eHJwdYKPmJublox+cGlpbnV5e319gIOHi46PAQM1eXZ0cnJ0d3l9hZOf \
o5yNfnNta2pvdnt8eHd5g46VmZmWjX9wZ2Zrcnd7f4OGh4iJjI2KhAEF0HZ2eXp+gIWM \
lZ2eloV0aWNlanV/hYeCfn2BipGXl5GId2tiY2t2gYiKiYWDgYSIiomEfnZxbnF2foKD \
gYGBhYqTmpqPfnBkYWVue4WLi4R/e3+FjJGUjoJzaGRocn6JkJGLg3x+f4OEAgAFAzxz \
eH6ChoYBA0l/f4CFjpSSh3lvampudYGKjYd/eXp9g4qTlY6Bc2pobHWCi5KOhXx4eXyC \
hwIABQY9c3h9AQO4hH95d3d6gY+fpZ2JdmhgYWdzg4yLgQIABQWDk52dkn1sYmFlcICQ \
l5OIAQPce4CIioZ+d3V2eXyBhYaEf3wCAAUnxIeUm5aKfHJoYWJvfYmKh4SCf31+i5aU \
jH5xZ2Jkb4CTl5WOgnlxcnuCiomEf3h0cXZ/hYiLhoSAe3h3AQNIlaSglYBxZl5ianqN \
jYmGfnl2fIqUnJQBA+5dXmp+k5qek4Z6cG51gIqIg351dXV5hIqNioSBfHp8en19enp8 \
iZqdmZB/cmJdZG2BioqMh4F4dXyIk5ONgnVqYGZzhpaamY8BA15rdoGNjYuEe3Z1fISJ \
i4WAAQMJdXp/gX+BgpOinpiIdWlZWGBuh4uOkoiDeXqCjZSQiHpuX15qeY+ZnZuLfGlo \
c3yJioyJfXdzd31/h4iHgnt4en+AhIiLiIJ9d3Z2dICRlY2DenVsbXR+i42HgoF7c3d/ \
iY+Kh355cWx1gYuPjouEenJweIGGhoaDfnh2e4GEAQNFhH56e3p7foGCf3p1dHyLoKme \
kndlVlBhdI2al5KGeG5ueIuXmJWGc2VcZnSImZ2ej3lqYmx5hZGVj4N1bW9yfIaNkQED \
V3d4eX+FiIiCe3l5ent/hYR/eHiKmJOKg4JvXmZsfYaJjpGPfHiBgYV8gIN0c211g4eM \
k5eSg3JucHR3e4eJgn16f35+g4mNhn0CAAUTF4OJiIWChH98fXt/fXp6eHl6ip2ZkoBy \
al1kcIeZkpGJgHVqdX6JiYmGgHpvc3h+g4eYnZeGcGZfYW6Blp2XjX93b3B6g4iKhYN+ \
d3h6gIWFiIaEgXp8fH2CgIN+dnVvcHWBnKqhjHhtX1dmfJGVkIyCeG9xgo2PioZ+cWhr \
d4WQkpeVh3Roa3N6hI6UjH54d3h4fISJh4OAgoJ+fYGIiIF9fn18enwCAAUSFIQCAAUT \
t3oBAyR2cW97n7aok4N1W0pXb4mTkZKOgW5tgZCTjod7bF9gcIaWnJ+Wgm9lbHV/iIyL \
gXlydn2DiouLg3t5eHt+g4aIhQIABRTee4GFhYF9fX0BA9WGgHhycGxrdZ28sJN6cl9N \
WXOQmJKOi4Jua32Nj4eDgXVnZ3eJkZWYlIZwaG15goWKjoMCAAUCGoKHiYV9en5/f32B \
hYOAgIGAfHt/AQO6foB/f3+Cg358f4CAfn+BgX18fX16dn6WpJiGeXFiWWN5kJWPjYl+ \
b2+BjYyFgn1zam19jZSTlIt7aWZyfIOFioqAd3N6goSGiYiAeHZ5fHt9AgAFLAmFhoJ/ \
fnx4dnh/hIKDgoF+fQEDWn9/gH13dXV4d4uxtZ17a2RTVmuLn5yUioN1aXOHkoyDf3du \
anaLmJqVkIFxZWl5hIiIioZ8c3Z9hYaGh4V+eHoBA6oCAAUsAwEEXYF+fHp4fYKFggIA \
BRPTfoOEgoB+fXl3e4CDgX5+e3d4iqKjk4FzZFlcbYeVlY+GgHRweomRjoV9dWxocYST \
mpaQhXdubneAg4UBA9N4eYCGiIeFgnx4eHyBgn99fX1/goaIhgIABQcofoSJiIN9fXt4 \
enyBhIWCgH97eXp8fn17fICQnpmNfnRoY2h0ho2MiIeBeXh/iYyIgH15cm90gYyQkY+I \
fnVzd3x/f4GDgn9/g4KCgQEECXx8fYCBg4WBfXx8fH1+foABBM+DAgAFECh8fAEDuXl6 \
gIWFhAED3nl4AgAFEX1/AQM6jZqcjX1wa2pqdYCKiIJ+fn99gYWMjIZ+e3p2dnqEi4uF \
AgAFLTABA119eXsBA1WBhIaGg4SDgX17foCBfwEEBH8BA7qBgH59ent8fgIABSzKfgED \
J39/gIKDgYCAgIKAAgAFLd9/gAIABQGhAQUBAQPwfX8CAAYs04EBA28BA7MBBR1+AgAG \
LqkCAAUtMAEDOH9+fQEDzAEDJwIABSzwfn1/gAEDUgEDAoB/AQMNAgAFLq6AAQX2AQXc \
AQN6goODgwEEkgEEKwIABS1VAQRLAQQtAQRNgIEBA4gBA2SDfHwBA2uCAQS1fgEDB32B \
ggEDZAEDtoABAyV9gn+AgQEDOAIABQE2AgAFLtQBBA4CAAUu7H4BA1R+fQIACDBoAQQc \
fn4CAAUuNwEFLgIABS7GAQQGAgAGF7cBAxQBA14CAAUGHQEDa4ICAAYwA38BBDOCgQED \
EgEDUn1+AQMsgAEDCYGCAQOVfYF9AQNNAgAFL48BAx+Agn0BAz9/gn6AhAIABS5Og34B \
A4gBAzUBA54BA90BA1yDAQWzgIACAAUuZAEDUn+BAgAFJU2AAgAFL1t+g3qBhHl/gnyA \
AQMRg4J+foN9e4IBAxp9f4V+AQMeAQS+AQNxeYGBgoUBA4J8gn99AQPEAQQsAQNSfn8B \
A3aCf3wBBKGCfAEDTn6CfgEEDYGBf4N9AQXmgX2AAQOYAQNqAQNTf4CDe4KBe4MBBHsB \
A6B/AQQYgYJ8fgEDnAEERAEF6AIABS+ZAQPggIKAAQNKgn+EAQQUfQIABzC5AQOgAgAG \
MLoCAAUBVHyCgn2Cg3wBAyiDhAEE5n8BBK6BAQNlf3oBA/mDgXyBAQNVf4B+gH0BBM8B \
Ay4BA7B9ggEDZQEDDAEDPQEDsoEBAykCAAgydgEEzAEERICAAQQmgnx9AQTZgoB9gQEE \
u34BBFcBBAwBA5ICAAUn/oF+gYICAAYoB4ECAAUCiYKDAQPQeoOFAQSXgIMBBEh7gYOA \
AQP+eoIBBCV8AQOge4GCewEDHn+Ge3yAAQMxgXp+hHx+goEBA6B7gYR7gIN+gX99AQO3 \
fwEDn4CCAQXnAQPUAgAFEjcBBHaBgn4BA2KAAgAHAxGBf38BA48CAAUwZ35+f4KBf4N+ \
AQNVAgAFL+cBAzQCAAUyzXqDAQMIfAEEC4GDe35/f4CFfXsBBEGEeoKBfn2BhXuCAQPf \
AgAFAYSChH+BfX2BgYEBA999gYB7hIR9fIR+AQNbfH+Ef3+BfnuEgH2Cg31+foF7h4J5 \
gAEDNIZ5f36FgH6De30BBbB5ewEESYJ6gQIABgHJAQSwgoB9fgED+gEDNwEGsAEDWwEE \
ToCAgH6Cfn2DAgAFGHuAgn6AAQNxAQOGAgAFAiYBBvMBBdx9AQMrgn57gX8BA1J9fIB+ \
AQQHAgAFBDcCAAUDWn2Efn0BBfV+AQNjAQNxgX5+gAED9QEDc4B/AgAFA4yEfH+BfIKB \
gAEDlHyAhQIABQJBgoJ9gYJ/fIGDAQNMfIN/f36BgnuCf4OCfAED1oGCfn4BA/J/AQQn \
f3sBA1F+fX9/AQMKAQOnfoJ5foN+fwEDNAEDKIR+fwEDdwIABSJ4fX8CAAUEt3sCAAUE \
u4ICAAUGAoCCfQIABQGhAgAFA8eDAQM1f4ABAxSBgQEDFoCBg4N/fHyAhIWCfXx+gAIA \
BQZ9AQOPgIB9AQNpgYB/AQMUAQNYfAEDVYABBNV7gYJ+gX0BA4wCAAYZlX0BAykBA219 \
AQMdgn5/gAIABTMOAQTbAQMbAQPof4ECAAUEG4ABA3F+fn6BgwEDJwEDBn8BA5cBAz2D \
gX0BBKCEAQQwAgAHM7yBfIEBA6aAfQEEtgED1gEDJwIABRn/fwEDeQIABTJ6AgAGM3CB \
ggIABQKMgwEDKICBhIMCAAUEv4IBAzgCAAUzPwEFuAEEmwIABTMOfwEFxIB+fgEDBwED \
Y30BBCKBAQQPAQVwAgAGBP0BAxACAAUDYAIABRpsAQQ2AQN2fQIABzQTAQUDggEGeAIA \
BQV+AgAHMzsCAAc1YgEDmQIABTL1AgAGM/0CAAUIEQIABzVRAQhyAQT3AQQHAQUOgQIA \
CDWiAQcmAQTbAgAGM1YCAAYzoQIADTUIAgAINcQCAAk2FQIACzW5AQQXAQQ0AQayAgAF \
HXgCAAo2GwIABjTZAgAGBdwCAAY2wwIABzZ+fgEG1QEIaAEJcQIABQglAQaXAgAFBiEB \
C28BBX0CAAcE1gIABjZ4AgAHNZYCAAk28QIADzeqAgAINNACAAk01wIACTerAgAJHiMC \
AAU1LgIACDSUAgAHAQACAAcGowEHWH4CAAo2AwEKCAIACjgoAgAGAQACAAk1JwIACDVH \
AgAKNtoCABk39QIACThpAgAIAYgCAAgBigIACQENAgANNwQCAAYBmQEIHAIADDeCAQyj \
AgAJOAwBB00BCvQCAAk36AIABwFXAQm2AgANARoCAAg1+wIABzePAgALAgEBCgkBCLUC \
AAg1ngEKIAEXAQEJHwEFKQEFrgEJtQIACAJrAgAGAYGAAgAJAnsBBiYCAAc1wQIADTiM \
AgAKAT0BC/YBCQEBBj8CAAkCegIACgFgAgAINxQBB94CAAwBQAIACTi0AgALOYICAAgB \
LAIACgGzAQ1iAgAFNnQCAAw4jAENTgIACAFKAgAJAdQCAAwB5wELDwIACgNJAgASAukC \
AAoDXwEM5gIACQK/AgANAzYBCyMBB/cCAAwCDQEFoQIABjdrAgAIAl4BClYCAAY58gIA \
CQFTAgAICYUCAAcDIwIABzfVAgAJODIBB/sCAAsBFQIACDo4AQvgAQhrAgAJOlcCAAgB \
wQIACQMigIEBCUACAAcC1QIACgOHAgAFOKMCAAoC9gIABjhYAgAKAXwCAAcDAwIABgoB \
AgAKA28BBm8CAAY4yQEIdgIABjplAQmsAgAHCTMCAAgBGwEGdwIADDsoAgAJA0oCAAc4 \
wAIACDolAQYIAgAGOa6CAgAGOFkCABA7ZwEGxgIACgUrAQYyAgALAaoCAAcE6gIABTlw \
AgAGIhQCAAc6SX59fwEIXwIACAHxAQVogoICAAgLjHt6enl5e3wBAzyDAgAFOKgCAAY4 \
xYIBAwkBBN5+fXsCAAUibAIABiCJh5KbqKyimIV6dWtrbmlnYVlbWmFveIGEg4eEhYyR \
mJmUkImAfXp9f3x8eXRxbnF3e4KDgn8BA0GChoiHhX97AQMagoKAAQRye3+DiZWcq62m \
n5GIg3R0dWhkVlJWVl5ud4CAgIaGipCXmpiQiYV/fYCCg356dXFycnmBgIJ9AQOMgIaH \
h4F9enR2en17eXZ3d4GPqrCono6Ad3R8hXdrVFJSW22AjIyHg4aMlpykmop4bXByeoOD \
fXRze4WPkpKKfHZ2fYF+eXNubXV/hIeDhIiOorGsmoBxcG5wd3dqXlhjcoONlJOLhoeQ \
k46CeGxnaXWBhYOCgoeMk5aOgQIABS7oeXdycneBh4iGhIWHjaGll4FrbAEDY3hyZ1xu \
fo6VkZCHgIKJjYJybGhsdoKOjYaFiZGQjYZ5bmlxeX57dnd4fYOLjIWGhp+mlYRqaG9v \
fHx1bWF2goyWkY+GeoOGh4Jvb2pxf4mRj4iIh4qGgnlybXF5fX56eHZ5gYqMjoujmIl6 \
ZwEDzXhxc2tphoaQkouPhH6DhYF0ZG9veoCJkomGhIqKgHx1eHd0fHp8cnh8hISGlK2f \
jXZmgHB3fXRwYGSEipaRiI59gImFg3NnbnN+hY6Ph398hIaCf3l5dHZ8gAEDB3mEgqGs \
mYhgZ3pzg3Vzd154hpWgiYeFd4WIiYFraGp8houNhYB5f4qIh3h3dXV+f4F6e3aCg6el \
koBdenuBhnB1ZWGAg5SUg4x/g4uFj3psZm+BiIeEfn56iI2LhXN5dn5/fnx4dHl/nqKR \
gml6eniKd3hsXH+Hk5F9h4GCkoqNe2xsc3+BgX17enyJj4qDdXt9hIB6fHR1doumlI1z \
cod4jIF1c19xiIWQgHqGgY6UjIZ1bXWCg315cn17g42Hhnh5g4aDfHl0dHGOn5aGaX2J \
fpJ9dnladoiFjXR8hYKPkJaGdm16hYF5dnR4eYONhIB3f4eJh318dHZ0iKGNgml3kYWP \
g3VxWnCLhYpxdIABAzGVjHp2f4iDdXVze3qBhoOAdoKJi4V8fXh6dIaaj4Vrd46Hj4N8 \
dVpxg4OHb3N8fYyOjo1+eYWJhnpzd3l4goWBfHOBh4mIgIB+en1+g4+JhHZ2ioSOh3x7 \
aXKBf4FzcXp4AQMfioJ/hIaEgX15fnd/f3uCeYCEgoJ/gIKDf399fH2Eh4V/foWGhoWC \
hn92e3p8fnd7e3iCgISGfgIABQ2/fYB6fH5/goOAgoGBhYODfnt/fH1+AgAFHQiFg4SC \
hIOBgoF/fHx+gIICAAYEXwEDYHt7eXx6fX1+goCCgwEEIYOBgH58AgAFBIt/gYKCg4CB \
fQEEPwIABQ5fhIWHhAIABQ8tf317ent9foB+gHx9fn+AfX17AgAFOTuAgYODhoOEgX8C \
AAUPpAEEGoKDAgAFD6SBgH8CAAULV4KAAgAFPcqCgH59AQM/fwIABS0jAgAGD5d+AgAF \
D+MCAAYEeYABA2qCgH9+AQMdAgAFPmaCAQS1AgAFEhsCAAUHpYIBA7x+fAIABQrme30C \
AAgQdICChH+CAgAFJzSCf39+foJ+ggIABQZLgYJ/gX6CgoGDAgAFCukCAAcLLX+CgH1+ \
fHsBA72DfYKCAgAGPZl+gn9/fwEDo3mCfoMBA71+gXyAf4F9AQMXAgAFPfoBAzqGeoR5 \
fH13AQMQAgAFEF6DAgAFBZqAAgAFC+wBBNODfoR+eoR/f4GDdYl3fYZzh3x/gH2CeYZ3 \
hXh/hXuKe4h6hX2AgXyCeQEDWXmGf3Z/g3iIhHeDgX9/goR+eZJulHl+jHcBA2R3AQMn \
gHx+inyFfQEDzH19h3SKe4KAhHx7iXOLdHyFdIZ7h3uAh310jnd8jXSJeoV3jHOFewED \
VYd5i3CPdId4f3uJcId+fol6h3GRdYp7g31/gnt8iHaHeoN5iHp5iHeGf4F3iXaIfIJ9 \
hHqPbpGAcpd0hX2Ea5duiIJ7gnuJdY13AgAEAP+Af4F+f4N/gAED3n6De4V7fYJ7fol9 \
d492hHyBf4J+hHiDgXqCgIF9gIJ9bpV2gIV5fIh5fIpslIF0hYV0jIB6hIZ+dIiAgICC \
eYR/g3qBeI57e39+gH2FdokBA6V/gYV9egEDxoCEeYJ/fYKFcot4gotviYd1hoZ2hX91 \
in5zl2yEjXl/h391jHiDAQN9jHN+jH13km14lXWBg3aFiHd8hX99iXKMeYV3hIF+fXqI \
aJN3doKFfYaAdod7h3N+hnqAhnWAgniLenqGen6KeX+EeXuKfXyDg3Z/iH6Ibop4iIRn \
hYCFgQEDbIJ5jG93mHlziXeAjHh4koB+gnOFgIKBeH6Ld32Ec4iFgH+BfgED/IZ+gQED \
qgEDwX2EgH1+fYKJinB4f4WJgnt1gIWIfnx6foeBgXx3e4SGh4N/enmDiIh8e35/hHx6 \
gIKEfn6BhoF4eX+Lhnx6gn19hYKDhH16gHuAiX55fH1+gYCIiXlweIOKh318en2ChYOD \
e3p/goaAeXiHAQOcdn2JiYBzd4GIjXl2eoWJf3d5g4eGeXSCioV9dH+Mh3xzdYeKgHl8 \
gYaCen6ChoN+egIABRIrgIKDfnx+ggIABQ71goACAAUTNn0BBAUCAAdApwIABgidf34C \
AAYNJQEGB38CAAUSuQIABwnOAgAIQ7MCAAUDMgIABwlsAQQgAQQegQIABw1dAgALDJwB \
CCICAAlEGwEFUwIABkMyAgAFEDl+AgAFCg0CAAUVlgEFFQIABQROAgAGEhYCAAUOgwEG \
kYEBBDcBBxd+gAIABQ+/gAEDtoGBe3h2fZKNgG9wipSOcWmAkY9/bXOOkXRrfIyNf3N+ \
iYWCeX16g4uIem99jJJ8b3qMiH9zcZORd2xxhpqLZ2V7kpJ7bXJ/j5aAZG6SqoBNZJao \
h2NsjJR6YnCLlYRzcIKJeoGMhXJ0iIhyaHWcoW1ahaiWbVyCnpR7bHB+goSAc4CPiXRr \
dIaKfIGNhH14fYmEgImHeXiBh4J3doOGf3t2fYR+ent9hoR5c3uEhoR/gomHe3l5hId+ \
fX18f4N/hYR6goaAhYB/hHp6g4OFg3JueYSJgXB8kI+HeH+VlX91fomHdWtzfXtybHJ+ \
fHl6f4SDgYaMiYeLjYyFeX6Dfnhzdn6Ae3V3fISDeHJ3jJiHeHR/lpGLkYp1fZWckWhY \
f5aHaFJpi4duYGyHk4BxfYqRi4GHi4YBAwN+d3eEhXVtcH2FfXB2gYmFeX2JiH5+gYWF \
gn6CgZKsj210i6qYYVRwgoduUmR3fnxwcoeMiY+OjwEDBZWIdXN5hIBrZnJ8gX52ewED \
uIWDhoYCAAUkrX97fn6DoZ9zZXqhrn1UXXSMh2JbbXyJg3mDi4mMjpCTh3l/hoB6bW18 \
gHx4dXuHhoCEg4SFf4GHhH15eIGHgXoBAz9+gpilh2hmgaWjck5XdZOLa2VygI+Ph42K \
goSGi4x8bW94gYF2c3qAhYeEhIJ+gISEgHl0eYGEhH98gISFh4WDgHp0eH+Tn4ZoYniV \
noBiYHGEi4B5e3p9ho+Wj3x1f4yOgnRyd3h4fICCfwED9I+Jfnh9hYN7d3d/gn+AhoiK \
iQEDzX57eXl5d3Rxc3mHmqORdnCAlJV+aGNseH+AgoR/foWOl5OBcnF2fX58fHt3eoSP \
k4l6dn6FhX54dnV2eoGHh4F+g46Oh357fHp4eH2Afnd1fgEDZwIABTS6e5irj2FRbI6c \
i3Frcnl+hpGSgG1ugpWXgnBuc36HjI6PgnZweIaMgHJsbnuGiIiHfnp9hIyNhXp5en+C \
goJ/fX1/gYOBe3l6e3yAgYKBfHd0coSqro1nX3GGjYF2dnZxcoGUmYt5c3mGhn16AQMe \
eYGOlIt/fH6AgYB9enZ0eoOIhn9+gYSDf4CDgn16ewIABQQOgoKBfoCDhH96eHoBBF+B \
fnhzeZSqn3plbHgCAAUSu3VqdYmYlYZ4d3t6eX2Egnhxc4COk4+If3NwdYGIhXt1eX6B \
houLhXlwdH+HiYaBfHp7gIeJhHx3d3yCh4iEe3Z5gYeEf3t4dHJ1i6urh2pocHd9fYGH \
fmxtfpKakoZ/fHNudYKIgXd1fYWJi4+ShnJob3wBA5eAgXx5f4iOiHx2d3p8gIWJhn54 \
ewEDtYCAfXx7gIWGgn17AgAHRdx9enh7jqWegm9tbG52fYiPg3R0foeQkIyIfGtlbn2H \
iYWCgX19gouSjn9xa251foeNi4F5eHuCh4aDf3h1eH4BA1qCgX57fH+DgwIABRLdAQNY \
goF+f4GDgHx7fXt2eIuko4VxbmttdXqJlolzcXyDiYqKjodzZWl3gYSGio2GeneBioqF \
fnh0cW14iI2NioR+e3h3gISBfXt7AQNPhYqJg30CAAUuVwEDhnp6fYKDg4SCf317eXp6 \
eXl8f4eboY5/eG1nbXB5jIyAfoB9gIWHj5KGdG5tbHB7iJKWj4R/fXl5gYOEgXZxd3l8 \
hYyNioJ4d3d4fIKGhYJ9fAEDpoSHh4N+enh6AQXBg4OCgAIAB0Yuf39/fXp5fICMmZmN \
g3hsZ2htfYuKhYSDfnx/hImMh397dW5tdHyFjo6NjId+ewEDjH58fH16eH2ChoqLiYWA \
e3Z3AgAFHbQCAAVHY4OAgYGAfgIABTDuAQMTAgAFPf2Af36AAgAFDfN/f3x6ent6e4CG \
io2OioaAd3FwcXR5foKFhoWEhAEDA4QCAAUm3XV1dnqBhomMjAEDWwEDMAEDMgIABUjd \
gYSFhQIABTHifHp5d3l7f4IBAxACAAUJ2AIAB0eUAgAFDv0CAAgPJQIACkoUf399fgIA \
BQ+XAgAGBgMCAAgUeQIABTEnAQOkAgAIDo4CAAcKOH1+AgAFGiMCAAUOqQIABUezAgAF \
FQeDhAIABhvqfX19AgAFDz4CAAY6nYECAAcP1QIABhHRAgAIBscCAAkSgQIABg8XAgAF \
SZ4BBQyCAgAFD3wCAAgRVQEFmgIABxI7AgAFEAkCAAoTGQIAB0jbAgAGSdgBBQ4CAAYP \
lgIABxBrAgAIEC1/AgAIScwCAAdJjX5+fAIABRvngoOCAgAGARYBBT0CAAUbbAELewIA \
CEksAgAJEekCAAcU4AEGDgIABxVJAgAHB68CAAYQtwIABhCuAgAKSjQCAAgUJwIADBOn \
AgANEycCAAkQfwIABhGwAgAKSrMBBloBB4ACAAYRHgIACElEAgAIE74CAApMJwIAB0tU \
AgAMFBYCAAoUEAIADkxSAgAIGi4CAAsWFAEJ3QIAChJ5AgAKEigBByIBCBICAAlNVgIA \
CkxoAgAOFkACAAhMFAIADEywAgAME34CAAcRNAIACBa1AgANEvkCAA9NYwIACBYIAQl7 \
AgAME2gBDGoCAAkWTAEPqgIABxdRAgAKTZ8CABABDQIAEE3zAgAIFjgCAAoWwQIABw2q \
AgAJCXEBDKMBDCoCAApNrgIAERX9AgAJF6oBEdABCRECAA4BoAIADU6PAQ3xAgAICiYB \
C/cCAAkUAgIADxZ/AgAKFOwBEeICAA1O3gIAFk79AgAJEvkCAA0WxQEIaAIAChVKAQz9 \
AQ+/AgAIFGACAApPEgIAChyrAgALAosBBh0=

#---------------------------------------------------------------------
# Compressed "win" sound.

lappend gdata(list_sounds) win

# This variable contains a sound effect compressed (and encoded) using
# the "bxdiv-LZ77-base64" procedure discussed in the program document-
# ation.

set    win_bxdiv_lz77_base64 ""
append win_bxdiv_lz77_base64 \
YnhkaXYxMDEwMDkGgAEtAYEBLi8BNQEBOWQBBDkBCT0BJ0YBBicBCy0BCAt/f3+KlpN4 \
bnt/dGlfYoKUlYKDlo2BgJCRg25odIifl4F6e29meomNi4R+g4eIc2Jfb4mOnZRxZ3F1 \
eoSKgn2Cg4qMiouHkYyHc2Z3jaCfmYdvW1lqipqVi4GGfGRiYXCDi4eChYyIe3d3jJSd \
nIt4YG18jYeKioSIjot+coOJd2tzaG2BgIeTjoiGd2Vxf4mJhYN9hIqQhWtecH5+AQMP \
g4mPgmliZWl8lK6fkpZ6a3F9gIGLgXl3hY+FfYqKipuekXdqUlV/l5yHdmBkfoqOjX6D \
fXFveGhwhpmhn4tzWUxQdJOhnXphY4CFjZWUjn9xeYSLdnGAipuOcmZeWXGYopySfXJz \
dnh7eImPn56VfVxPZnqYrqaPalBaepqfno5uXWd2ip+kk3ltdoF6c3p/kJ2XfGlbaoKQ \
n6GYj3VkXWV8j4OBg3Zrd3RqZnSKoJ6OeF5WYIOeo5Z9cIGPgXeIdXWVpZV+bWZrhYqE \
g4V1aXKIk5mUk4ZubX6gr6OMeW9aXW9xe46PmJV/ZWJuc4qbmoJwdoeHgIKEe3R4gHyD \
h4+MhX59fHN2c3+kroVoWkJWdoF/nrKajn2Tl3huZGN6kIhueZSfj5OMd21wV2WGq7OR \
cmptY3KKenuRmpmIhH9iWmePnYyJfYSHhHNseYOMj5GSl4N4d4OMh3tqcm5UZoSUnJmR \
f3BnZWhrcIyVmaGWfFxvj5J+j5iZjICDfX2CdVxeiIeDjY19cXh+lpZ5eoeIbnGGi36U \
qaBvUGl0bGh9jH94eQEDqZJ8cICXkHaIdWyFo5qRj3lORG+NjZeotJ2PjIqGfmdebouV \
j3hdcJCGjG4/MWSlkollcpzRxZNgUkNNS3ywsa18V0RteZC6ybmHV2WAgHh9iImglGhr \
cWloi6ieh2FNWn6Vl398fo2WmpJ3UFp4jqqci3hyfo6RgYaCWEdshpu5pY15Y3J9hHuK \
lJyhkHF4ZmBrcYukp5qCg21ZZXNlbIN5bXuOi4WNdXeAd3x6X1Z8op6WgXSAkZZ5gnZp \
kbyzlm5kZnWEd5Cpd1VeeHR3goyViGlzmK2de3p/aV9ofH6TlJmVgGlUZXyPl5JzZHuX \
oYuCgn9qX22AlJacjWlkf4VjYnGUt7qVgHNjVFpwcoefj5uYkI12c2xTYHVrY4ysq7Wg \
clBXdW1zmqiyrJyKcWVaWmSLsbarnpl8TCcsXJClrKOPb0pifnyKkIVhZ5CgoIJ4c4CH \
e3tqZYGjvbSBYHZ9bmNVZ3V8eHuOh3hxhMLRpIRwcl5hdYmhsKZ/YmmAdnWcnW1gaXmI \
kpCOhG9renVlfZywmouBd3lpXWJmboKbpqGbiHxzb3RxfHZvd4SEgY+bb0pkdGuElqe9 \
lnt9jox/ioWNbWp1gpKulo+HTRE+opR6boOz5dyRP0M6OVqz5KmQhGpPVlNzpb/Bn25x \
j3BjZ2BihKGRmKakg25qV0tHWYKvqqOMcF9ZZXiYtq6UfV1eXmWPtNHPomBKSDdOi6Ok \
q5R3cmdpWWWVsryxkm1Td3tacYJ8e4qPi56QemNJV26UnYqJi5+ekHFbaXCEoJt+gXZd \
dJ+Dm6h+Vmpna6G5tpViW2Nhdo2frItubm1jWGNtdYyBfZOSeGF9kZiCYXGGioaZhnt/ \
bmuOsIdsaWVxkaGXjJacm4BfX22FnpVmcJSah4aCeHxscJKjn31ndHlSSmSHkpCYoYdw \
aWleWnWsrIWKdl9cdJSkrbKMcl9eeZemnHxkboSHeJSwnoVcTFZ1f5ejnZBoaXh3iZ2P \
dG5xdHBqdYmcn4+MgYCXnZiHUkBsj4eJgYOLf2tucm9weoewyLB7amZeX3SLiJmzo3h0 \
f1xUeJOEhHtzh6WdjXtiYAEDzoyno7Gojm5nWXGAanKToot3V2CAiIKUqqF4V1VNWmOU \
wb2JdYZqYmd/s7yuloN0Wl5xnZuMip2Qg353mpRrcIZtTkZnlbvEom1eQBw1ksGsmJyI \
bltjdoqQrbefj455YFBZc4qiq4x6bHSSb1JPZHCBpZWJnKmSY1dvjYmBkbi4gFBGVU5o \
s8+tiWRCQ1Zwh6CvqYlxZVBGf7zRv6h9SllrYXq1ro58fHV0dYOFcImTjYZ8eWtzfnh2 \
foyKf3uUl5V6VGCNdn+riWl2Z2SVn4x/ZGZ5d3mZnYeBkJN+d3iDhXJvboGUoYZsb4OT \
h3R/gG5mkZOChYaWlJlkUV9gY4ufoI6UnJuLeGVYdpWhiImMho+jn3lZTGKDnpeCdXl9 \
ZUtehIBxdI+Ec4SQg3+WmY2Bfl9ZdI6RlHqGimt1dWRxc5Gai3V/dXqEn5Wrqn5vf3d0 \
bW6GqrWljYBtTVlufpGWkpOXgGBVVGyYtr2cbT9NfpSCfIeHh3xzgYd/hZJ7b21mbZeg \
ln90d19UhJ+Sl595YGR6jKemkISGemtcR2yaoXp2f2+Dm6uSfGZ9noWAgXpeX1FZf5al \
r7+yZD89RHecvcKmbVtxaWaGq7KblHxXWWNugpmjopqacFpqeYGHj52niXBkZWB3joZ6 \
eGZpbmhofaC2nGtdbm9xkLrNrY9rVVZijr/IooZXMzJPmrmyl4lqS1BWhLbe5algQk9b \
UoHD6pxGO1U6S4O3xauDX1hTTWCHoqCSkJaWe2yAjYKMjn13fIh5gJOVkpuAbXhyb4Sd \
q49kVWNpcnqVsaeOZDIwW4urrZ6SemdZaIKZl4ylnmRIUH2hpp+DdWdihqWomoBmVGd8 \
jpign5JzXlhihJOcn5NtXmyDmJGLjIRnR2R8dH2Pl5uIfJOEeHl4bISZnpOCdnN3i52V \
goJuY2ZxdXiGiH5/h4eMgG9wb2JhbYyrwrKnf1s5QWCGqMmTfIhgYYd3fHaMmH1kc3KI \
lamZhXleXYKcqpV4eoqZl5WDdF5cV1J9wsWWl3Q+NDhiqsG7rIVWUnacn5CGZk9Ma6HO \
zaaATjxUeZuzspx+YlhbbJS9p31lYltolq2linVpU0tdcn+XsqqAYmtvX3CXkYyfrrOH \
goJjUW6FfHmJo6WgjVlhcmRolaefkHVtcWtZYJCkoaOVbFZEUoijs5+clHRLT2NmfJGh \
pYt8hodsb4t/bn+PoqGOf394joJfd41tUWegvamaek1AUnuhr6aQhWhkTlOQrJt+dYF1 \
SnalrsCtg1M+VnSJraWDZ153gZGbeX6RfHByhYd8fH5qcpaioZmHaEZAfKe2qZOEYT1N \
cZXHtpaHdExUb5qhh2ddboCElqqznG86IERznKOop3d3m6qVgV1LcJSHcIOks4t7TDhT \
hb/RwZd1VzdMdYO2v6KTYWKGcoGBdXqGhXtxgaWhgWlscWhphJaVnI2MgHV+dIOOnqeF \
YVRXZp/DvJqJeltdUVmJq6yDZ1theYJ6hY15aWhuZnaTlZednIZuYllmdYmqrqeWgm5b \
YHSOnJ2glnpaY3F+op+IdXV2cYCTo5uKgV9TZoWfnYVnYnOPc5mffmdOWIWPpL2jdVxY \
ZHiNpqd0UVxoiam4q4VsW1Vzlp+rqHdRZWt7q7apiGdKTG9+iZyijF1DWnOdp5OOgWN/ \
jX2GhGhla468rqSVZ0BXfZGRlp6Sg29Xaoucjod6dHF8jpaxmmdBRXWgrqOWcENSZXCW \
v720fkckQ3aQr7OSZ1Noe5m1qoJcU3WIo7O4lWVKT3GJlpR+hYNod4aOg42HeFpoiJik \
q4NEUGl2gqW5oGppe3mJlZZ/Uk9iYYuwu7KKX1JTdImhsaVvTFByk52rnIV2aWePl5Fu \
W3mSkZ+flYFkTENihK7Et4FYTFpth42Tj3ptZHF2ip+0l1NNaX2EnaF2bpi2pYduYTtT \
fHSXx8ylfzIjQIPK072FY1xXZoN9mrCUfWVzrKebgldNaX59iqSylWtNXH6MbWVyf4J8 \
jZqWfFFIVH3DxpqBck1ShrfMwY1OMCRIkrvMt51yUElge5qznHRhXWGArKiVeWZphJiQ \
iId1ZlBadJutnYtkPkyEudexfV1IRm6TrK6li2xJSIKssqN3OCxZn9q+lHE8Lz2Nxbur \
gFE6PnO5xKuTc1FLZJLGxY9oQT1io9fJmWgzNWqMs8mub0M9U6DLz7WHSx8oV6PZ9L9U \
GhZPlK24yqNeZ3Rwg4RxcVpHiNfqu3dHMjNcm9Dcs3tNPDpcmr+7l29ORGKT0OC6YSAl \
THedt7qYcVVFaa+3o4pcO1+SsLyieF1OZImmuquQWyM5dbPAsJlnRE1mgai8oH5lSVB4 \
qbCpkXNUXHN8ipODX1Z5nKeyo4ZlU2KFoq2lhVJGUWqauLyab05DWHun0cOVXD48U4Sz \
vp53WFJrpbWYbU1cc3qUsrKMYGdjd4+kq6V8WE96f3+Ij5qSb0tdkZmfko9qaHiJj452 \
YGR7nqeDZHRUVouWiZqanZlyZmyAnJqIaWJugJOQhop8a1lwlKiXd2pubYebkoOOjH5u \
XGyElIaBZGOAhH6RmHtDO155p8K6oIFmVmGFr7eUZV9caJWroYWIjnJhbICJoJmOiYBy \
eolvaG2DlpWXl4dnXnN1d4WJeniEdF1yqrSqeGdsYGd2hoqMj41+dG91goqRe2J6dI6p \
poNeUlp6lZqTiHxncXN3jJudnJCJhoV7dX18g4SLlZeif0ZBZ5CZkpR9a2Fcf5KgmH1i \
aHV5fJu8oH5qUUZUh6mai5aZhYCAd2pYWoCRgo20vZRoZGx6g4OMl4t+eHN1fIl9a2yB \
h36DioeFjIB1e4Z9e4CCkJePi3hrcWhxgJWcioV9Y2KCnaiYgWlmeoRyd5qtgVZda3yU \
kJKYfWxrbn+Ee36ChImGj4xzY2dncIObo6aJbHmBdm5/lpJ8aHWWkoaJkoN1cnyGjox+ \
a2iBgZGohmZcd5GOjJuKdnh8d1tZfqCmhXmNf15zfYiYmoiCkopzc2Jgb3iPq66EY3dx \
bGKPmaeOf3xoZGd7oKmWbUlbcoSptKR6X2ybpY10endkcpGZhYGGgHJ8b2l7lZd6Z2N0 \
jJGPhYV0aXWCl42Kgm9vkZeAjJeAbXuHdHSLh4aDf35xb3R0e4eGgJCNg3R0d3h3j4qM \
jm5YZXGAp8SvdmRycGV5mK2Te3Brc4SSj5OVdF9weGRrmbqkjHpydGx2b3p5gKOnjHdy \
c3V0gXh3naGFX2t0cn2XoYhWU3V/ep2ymnVsfoyTlJiFbVdigZykmYp8gnFhYXeNkY+Z \
gV9agaGJe4N7X2mDlq+ulXdjYW2DeXualGZefZyZjnd+g2lWW3e1x5p4c3KBlY11cnF+ \
nZWMj4qCbl9HZKG8s5VoQD1giKK+qX10c2RggJuReYKTdGyYpYdiWF95laSvonxSXHB/ \
kKaspG49L1CGtsa8mltFSVGBraqFdHh+hpqsl31fUFp6pbi4mFtLWGBxm8G0eko+Zo+m \
r6iFY2WCgXN6gnRhbYyYo5N4Y2d0iI2msqVwQk9wiaKprYNWUF5/gXqBnZp7bHOJmJV5 \
a25sg5uYkW5fWmt6oZ+XfWVbYoujoaWbdUxFZpS1t5V+ZFR2oqKXhHBRSGacxsikaUpH \
V2yTvMGhbFNodH+FeniEf2pmg6KSe2BLZpq2uJN7dF5ehpyciYF2YWqTn5JsVF1ucoGy \
r4JfUEdUic3RvZ9nMjxyirHOuGtAT4CdpaGUiGFSYHugoJ91Xl96qKSAZ2FqZHas0rV7 \
WDhBYpTO2aVgRUdliq6lkXZwXVJtjJ2goXhYUVyPrqOIXFODnK6yonxmRjdXnM/SqmMw \
N3Kry65xW05hjrazmHtfP0x6pqiWjWhVXHubt7KOcElDha6bjIp5Y2V3qbuBRDdNcZiq \
samPYz1FcrnAoJRoTElpnMDChFZYa3GKnZh+bU4zWZXD1cGKQjtjgpmmt5BWUXWFlI2C \
gHZlaomdoaWDaGtygZuidTc5apy4x691U1NWZX+kp4Rqcn6PsLCdeU9ATnOjxLiJUzxK \
YIu0yaFtUUZcnb+vjXliY1xceaSmkXt6eW9yg4B+fXJkc6HDnF1Va4OJnamfg1pOYXaN \
qridalhriJucmIpbWYuLe4eFdnqRj3xnd4dkUWaPwtu6h1syJEB4uMKhfVxgepOXla2e \
UE1pY36ptqwBA1NueHmId4aJhpedknVobWx7g5OKcltBVHyYqrKfdGVsaWeDkYqIh4uD \
j4GFemxze4aOlI93YGx2iZmWlpGBeWJxna2Ze254dX6bn4NwXmloipCAgGyAgXWAi5GO \
bFBOaoWct8Kca19eb5GkkndrWHKcp5uWfFxOZH+bop+Ab21jb4uam4dzcE5Kmr+3pXxh \
Z2tsf56nlXVfYHKGpauEZWlzfoylnYpwaWtsc4qTgnd1bW2Jlo13Xlltobycd219fW1p \
jrS0cEZhlZJfYYKJhHtxepeqi1dTd5Z9hKOVhHNjdI9/bHqQkZiBVVZylaOglpCSjXpr \
WXCOloOKj3x1eHiBfoSJgXuDfn6Ti3NxanB1eZOdi31ua2qMpIhvdnl1Z4OlqIpcXXRu \
g6GghWpWXn2HmqGJfH95dYV7cZGtjneIhn9sXmR+ipuzsIluXEE9XJi+s5iQh2hbcYeO \
h3iBiIyWk4Z1Z3uGgX2QnpZ5XFpoX26enYdvbHqTn3trWGCKh3yHkafCrHVRSkVbb5y0 \
oIVze399d3KSp35+jlpJcXqbtcPCiWhJUUl7tLG1o4plZX18j5J7X2Rxa4ammXdcXWBy \
nbaTdGxraXWjpY1hXWV1i6mzpIheWVtti6Ouj2xiY3eHnLaocFVfjJaao5NpVVlng6Ob \
cmRiXn6lp4p0dVpRb5Sfn5qGameQopCRgk89Zoytu7WLcmFOW4KgqJeJbXqPg3qDiX9z \
a4aelYhvaVdMf7y2tJNhTFpqka23jV9PZHKUs6V8a3V4fIedn3FjaG18kZeUknhfVVlx \
iaCziltdiKqWbWNziZSbnZiNYkNdjpqisqaDblFBX57KpoV5W2eBg4+oj1RMZ5GlsKGB \
YkxIeaq6q4dsVlp0i4d4gYtubJOvrI5zYUpYeJ2lsKN6Xk1xqKGZiHJkX32Mi4dtZHiC \
mJGHjopjPE+CpMLKmVg6P2SjwrirgmZhYniUhmpldo6tsLOabTg0XYilydSWVjkwVIy+ \
x59jUlx0kKSkjGxJSXWnx7WPYDMwaKvCyKNgMkV+paeagGFcaH+cral/ZEM2cr3RvqNu \
QDNPiLSyl3ZccpKXinhhWmB1jKjAsn5KMktxlM7nvXpJRFh3nr2ugExMcJzKvJBWMUV4 \
nbG+sno9N1lti7G8i1pWW3ycuJ5uVElZfq7LrHhaUmWHnqqVdllTb5CitbGac0BFZrCs \
kIhza2iGoqmNcVVBUXmmuKKQfFxLcJufk3deS1+Wyb2VdVg8UoivtpR2XF16laesiGRe \
Y2eXubCXjXtGRXqnsKiQVDRAVaHzyo1dODJtm8bLnVlASWZ1o8GobVFecZWnn5luTFNZ \
lbSrm4JbXHSRlpKKgHJcaJ3GqXJFQlyMscWwfkk+aKGqmo+Icm5ldYCDqZ56ZFV8npqT \
kGRGUmeVrLOjdFdfZpCrqYNUTmN6hpaZh3p7cmd+nbudcV9MU2ul59WGSSRAjbyfhpWF \
aWl1iIx8ZHqNhouLhH1rYXCEkKW0qnZPV22EmZWJkohuamB4i6GSd3B9g4aTmY5+cnN4 \
i4mQkH5obHyDnq91X3BoaIaRkJB/b2Z4hZSShXR1Z2aEg5ithmFof4iPkIeCgH98gIaN \
mqN8WWF4jYyiroJgXW5+h5qiiIybf1FAT3SPoot8pKuDSENheHuRvcCLgXZoZWiBmJmN \
kYZybW9yaXaZoZB1g4pzapKifmJnend7lop+fX9xbHmLkYmIe2hpcYOTnqCKfoFjXXaI \
jIuKiIh/ioqPdVplf5yTkZGCd2pzhH9xenxqgpOHgI6JallcZXudurqXcFNUaIiWmpSA \
dX2DlpGFhWE+cKaelI98Z3OJhH2Ch3Fjbn1piZqhqHVBRGiJpKWfn2dAYZKZk5uMbWl0 \
e4meqIxqVGCEj6inhHRZU3Wdt7SMdWZUSmGkx7SEV1JUd46Ll5VxWGSdq45wdGduh6Kd \
goiOdFxUeZ6QgZB3XHqNkpCKiGhRZ46tq6GHZEJHY5GkuK+BW2puZG2lvoNcYm5sg8vj \
mz0LLHbIxKCegWJdZH6io4l6emVieZ2nhm50eYiQkKCRbFZkkpdvZ4B9ZWRuhpG2sIl2 \
bFxmepOnmXhjW3mTmo+QfmZSQnW8t5+Ob1ZieZimlYd3ZVBinMnEkWdQVV99p7yogVhF \
d5CKnq6ATktmgqDEuHVGQFFmmdXDimpiS1aWx6SLgn1eS3avpXJBUZG2nW9bg3piWn2w \
rKyNcEY3a6G6xLyFTDhBZJO1spZtX2NyjKzLlE8+T3Sitq+gfU4nT46qvauAX0dcqraS \
lIRmT2CJoKqugnFSQm+jsbKUWkFEZqnZx4JVSVx7j7Wwek1VaXuZqqOeg0ckSIfB1L2Y \
YkRHaYWuu4piYWqLrLCHTkZMVZrMwopyWEhghqq5l3VPPE6QuLuxkVoyR3ye0s6dfkZJ \
VZOlrI2MaE5jmLIBA5JcP0V1tci2eUc4RoO2v7aaWTVMcYeZxbZ9Rz5ynZqngFBNW3eM \
t82obTglSpPGza6FYUxTdaO9pHZiYU14uMeugFw6NnOtr7OibFVVUm6osKWNbklSdqCn \
lppxNFiZp6yFfItnTGKKtL2oeEdPhKWyp4JVM09wnLrBsn1JP1qRqqGHY0lNe7fMlGRa \
Sj9blrStqIhbU1eIpK2pmG9QQF2esauJc2def52elYtyUVCKtLWsmnVdXlpvjbCxmFxL \
bX6gqpd9Wk1fjrm6mG1aUkxrjJexwqFSLVh8kae2hllNcImZr6+EUVl8h3+YrodlRlaF \
oJR/amVqi6Wop52CSjlPda++oIB3g3ZhV4m11owxPIJ6tcuFfGVDaYuVmZx7aXdnR2Wp \
vK53RFByl8azemZZXnuTjpSbpHRrY2yNmpWNakdUX4TBw5xgQ0tyoK6jjmZUUXWkuJuA \
dXJmWWuIl6SAbnZ5gZygl3pcUmeenoSGbFJ6dnupup5nY3RviqWafGhfZXSUucOaYEhP \
YoKWp8Owb2JFaYmwioBUUlxzm826i2xPWFR3kqeiflZSXny4wp2AZEBJfaOpppOAWVFh \
mrSQgIFgRmCbvsGVdF9CVYmvspp8amNddKK9tJ9oQ1FVdKWzpY9jS2OdrpKGfF5UhpiK \
kXZoeH57gX2XontsdWx5nouWekxif5eflpKLe2RPaKPDsYxlS0Z4n6utkoFvWEt8sLiR \
VzBCd6awrZNfUFFjqc61ckZngH1ii6q4onJXZ3WPuqdtTllrfrXaomtbWVlrqrmeh2hP \
UHymso1xV0dFc7G0t550TTRPdrfLso9hQ0tokJaUsaqCYFCAn6GPeFtVbqGwrpd1XkZT \
f42YmIlqanZ2e4ycim5ac6CspY6AcFVSfaeVlqBvQGWqp36LprWHPEuakq6sSStRga6/ \
rXJKRkhyi5qjqJNtSE50mrmifmhXTmqiwLCIdoBnZnCOupxmXmt1koyKnoZUS2qGnbKa \
fl1WcJWOmq2EWE5al6eQeG1xb3WSn4iIeoJWZ5ivt4pMXmxfm7CdlYloXG2coZqXh1VG \
X4KitbedZzQuaaK0mYeBcGFyi4uPkodpW1p7kqGgfWZhboquyJVvc1VCUIq6zpxpVlR7 \
qLSTb2xSX4OLjp2Db2yEiY2Rm4JuY3KJnqevlm1BPFCHpqypnnZeWWR8lpmRcm6FkH2D \
knJri46Tj5F3T15sZH+nrpuCX1pxjKahhmpLXHx8mK+sk1NFbIWcl5WHcmFmhqKspJV3 \
UElgi6urq5iCW0ldj6WUgWNlc359lL/EmVMtXq6ne258k5mHcXOKmI12W1dseIWin3Bm \
hY2Ie3t0a3FvfY+UmZRqRWCRmZanjnJdV3mVoZOFgnhwboKmn4hgWYSKkKadh3t0Z1pz \
hZCunYFzeX9xVV95hY+blJWLdmJycXGDk5ecnoxwaGdygI+fbV+iqHV0jolpXXODpKqZ \
jXdnUEpoiqaylnthTmKEoZiFgHd4fX+Rn4BlVmOGnp+Eho2BYWKLl49/aoaIbWyLmKCM \
b2x4hnuAkoF5cndzjZ+TgnZodIB7hqKMcXSBfZehlWReV0pqkrHP0Yw9Klh7f5WbkXZm \
UWF+pZ+SbVtSX3mSmZ2MiHxyfoaDhoePhYKFiZyObXCAhYKWnIJuU0Vvj6ignKN3U2dv \
ZnKQkIZxaHiNr7aWXz1Pe5mplH1sZ3yNoaacgGNBRoSztaaPgF5FUn2RlpyHaWltbZCu \
l4BnYmZtjbClfGxbXXedwKp2VUVgiaylnqhxUF1ti6GjlHtkUWeTmq2wjV43UoiZp5uI \
c11cdpm0o3VWU1OAq6ujm3lWT2uXpquaXVhoe5Srrot2cG15k5OTjm5YWX+xsph2a2pb \
U2KHo6J9cXlvb4+cj3NUTXOVsbyrjF4+S2OW1L2PdmJITXmsw6h1V0xdgJunuaByS059 \
rsW0i1JBVXqnubiibUVObJOsnGlJUFNts8S9omw3PFd1n7achXhvcY2XmIdgYGNxjrO4 \
rH9JMT5xsda7nm5APWSNnpuTkG5WXX+drqGDYFplirahfpSOYD5YiaSUk4lpaXaUn5WD \
XEFWdI+5v5h7YVJhjrmpiHBERGOPuL+paVNXZYSqpZR3U1h5lrC3mXxWOEhsk6Sso4t+ \
aGhrfouafmZdZm+ZsqJ6cVZHaZ2vlHJsWGylub+kYjtAfq+4q5CHcU1KbrCwoJN3Tz5Q \
earAn25kaW6Gk4eOkGlQS3bFy5dhWEpeeJirk4l5bVZvmLW2qX5NKEeQyNSlb2xVPF6n \
vrGMZEFadn6On66XaDQ5aJCsuqh7YVxdf6ukgntseZKhmomBaV94jZKMgXdvcnqKo5yF \
fXZnV3SWnYp0amFliqmzsYRWP0VglbeslndpZGKAo6ORg2pUZ32OpbOGaGZyeo+chod/ \
W1V0q7CVf3RqbGVzjZWahHSChXR9g5KXf2lidJ6UdYKZgXFmdpqjhWNeb3mHmqeXdV9f \
bX+MnKSRdGFqf5imlXdYWXybs6SUgmVZa3mOoJNvZWxlapOdl451YGF8hYaTlIFjVXup \
qJiNeGBsiomQkoR3cHdwhKKkgn19cWWFloNuYXmKhpCdiXl2foB7e4aUfFF3srqHaGdw \
ZHKEho+lqIxqXVdmhJqloZB4XF1uiKiylnt1Z11qiq6limNqcn6Ih4VzbHGKmJSci29i \
c3Fwj6CffGNphIqYmn53dWJwg5uFj6mBUGiPj4qfmXpUUGB2m7bBomdDRmB+o72xnnRO \
QFaZwJ2CgnJcWWuarKCHemFZd5GSkomBc2Reh6qVfH5ye350eoKFf411aomXnaGQckZH \
bJW0sJqMeWFaXXmXo6KFjgEDV3CKlZuKb25oZYKlrpFtbnuBgYOPhYiRhHGBhHZsbo2V \
hHx9dnZ9g4KEgoKEiHpzdY2ReW1vbn2KmaWVh3dqbnB0cIaAgpOYlYl6f3R7fHl1cYGD \
e4ePj4BzfXh4jY2DgIN+bmh6oqiJeoN1ZXOCkoiMl355hHh7fH2NeGt9kZSPg3JjhpZ7 \
d355cXuMkJSIeG90c4eZpohodpN2WmF+lp2Te3p7cWV3mJmSgIN9Z3CBgYiPiYJsa4WR \
jHNRZo6WjouWpollZYJ2dYaSjoVpa4iIgJeUcmh4f4uUmn1aW22Ho5+elGdXbYycln12 \
fn5ocJOwpn9nZ254iJmdknZrcHl3fnuFmI6IimtaaIOSk4d3gIuDd3uMgXhwb3h7eoWC \
gpqokHxzcmthYYWgraePdVlcfqCckpyFbG1pf4eKdW6KjYaHooZyaV9yfYqYl3pse4J/ \
gIyCZGaRmIyIdG5te4qGg4iMeXp1h5aUiIBoYGZyjKellXlyZlNtkLqshXBoYX2Gio2W \
gnJ7e394e5WKcmh3fn+PjImQgFVVcJSwmoyAcG18gnp1k6ebd1pYiLCed3x3aXyNl4p3 \
e4JqbYGPk4Zvfn1kZYyknnpmeIVxd4Z2cH+RnIFgfqSfYUZ4oKGWgm9wc2R7joWXpYdo \
a3+Gh42OhW1ranmKpKGUinlfYnSIkYd+d29dY5a3mn96clhtgZSclo51V15ylKScjX+I \
hGJjhI2GeHqBfYuSe2VyhYqSnIdydWt+e357epOnlnpuY2+IfG18jKCKeoB/gXNobnWH \
kYt8h5GPZlmPsIhiRWOSopuomINzZ2NweYSSkIeOfXiEeXBkeJ2wnlVJkZdiYHJtkbae \
e15Ga4iZqKiCZHyVfHSAjo+Fd3JxeJWdj4d3aHuSjHhvcnyNmpF8aGN/iYWKfHRydWpn \
hJaSkoZ2ZmN8fpGxsI5hZl9ofo2ZjpmonXdCSnicnqufgnuCaWp0eoWLeIGaj4BkbnR8 \
jpSNf3Ftb3qFjqSff2xwcniHj4GJhXduYXCGjo+XjnZ4dXJ6hIF2c4CVnZd5aXNxcXiP \
k4Z5iIaPiQED73l1dYiOfXeKjIGEg351cGp6j4x4bnmTh3VtfY+XlJqGaGJwgpWFfoyT \
hXt9eHJ6gJOaem5vXmaRrZyLZ2d3aFyErqyEbnZ2aG6HhoOWmpeDY2uHm39jdZaPfXBr \
eYeAh5B7gI2BaWiHlJKMfYZ5dXN+fnyBlZZ+bXB8dHx4eIOKhnV3in98gQEDf4mCj4pu \
dn54h5SJhXWAoZZrZnx4bnt+gZGXlHxcXm9+kKmWfmpndHpxd4OLk56kjVpKYnWAi5Gj \
lH1ueoaBa2F3ma2hb2iBh29pjaaSggEDX3x8jY+JjX5fUmiEo5eTlX9qcH+GXmikwqRe \
RXaOdYGWe22EhHhqY4Wcjn2CenN1iH95e4WDipGViXN3cGl3jZGTj4V5b3yOkYZ3ZXB9 \
h4iNloJqb29gX32jsJmOd1Zgd4WUoIF/bXdwgJWjonlmc4WGfHKFhYWZjWdxjoV0dn2L \
jnF5lo9pZ3eGjpiSfmpgYneMlJGgnH9ramZxkZWRj35tamR0houZm5BvanhycouIgoSB \
fYyaelxof4WEhYSEd2x7kpaRin1taWZ5jJufkYB6gH1ucpCbkoh4cm9+jX4BAwF8i5yW \
eGlraoCUh319dmR5mZiXgnRxf3JleoJ7kqWRaGd6eoKFhJaSfHVtZHmPloeBi4qTkHdr \
bXCJm5aHfmlgeJefmYl8c3Nuc4GDlpiFbmd5jIiHhntjaXd+i5SRgGt0h45+c3p2eoV/ \
i5KNhHt0d3t/jI6RhnZsbH+ElqqJZ19jbIaamY+OhG9vcHd7d4eajntyf31vcYuXioaG \
hnVpaHqIlo1+bm58kZGZnHtZXoKRno11b3J2h4eJhY6fh2Rbbn6Lk5yMa2dsfouCg5GG \
cIOQg25zeX+Wl355e2x5kpiId3NwcG16kpODgYiBaGByfICPl4V8jZqHem9obnuRoZKK \
fmtmf5aVlHRbbn2CkqObcVtYa4CTnKGMd2daZpCVmpZzaHB8h5aQhoF5bXJ9eIeUmHt7 \
g4VwdImHfWx1hIuKkoh7c3iEhoF7cnqJmY1uYmZ4lqinlX5vXF9pfZqlln9ncIGDipiR \
d2JreoeViXuCh4CHk4ZlXWx9lJqLhXNZYX+KkpeVinRlan2QkZOXlndjZHWQnIyFdnp4 \
f4aEgHR2cgEDvId4cXBzj56RgHlmWn2kq4mCdmNkcIqilnl1fmtujpWQjnlyeXFzhISD \
hYZ+dXaInYtydHmIg4J1coWGgo6LgIN5dIGThXh9fYKGjYV6d358eoOMgI6FenN9gnp2 \
fJebhWxhaHqPjpWPemtrcX+DgIODhJGKcWdxc4yikoR7cWFphaOrmG5bXmyDoZyRfHN0 \
fIR8e4KMh4eIfXh0fH2GkZuViG9ZbIePj4mPfGV5dniNiXp3g4mBf3R9i4h+dXpycXB+ \
mKutf11kcHKGjYmTiHx3dnRxh6OTg3hkb4OMkZSMc3FkaHuUpaKYhmRUZXmJmp6Hamd/ \
iYeJiYN9eHd7iYh+enx/g4eEb3WLiYqPh3JiZnmWnpOIdGpmcoagmYaBd3R6f4qKhX97 \
fHh/e3eDkJABA/GGi4GBfXVseoGKj4x6aHSFjZGNhGZfdJKehXJucX2Ilp6ei21ia299 \
mpqKfHZ2dn+JiYKDcXaJjIB2g4p/gISAfHh5f4qQgnt7d3iAiIB6f4+QAQMXgXVwgpKP \
g3pzdHF5iIeMgn+Df3dpdYKFiYuEeXF1cISdk4eIhW9phZSEfXx8dnyJpJB6eHppbomd \
l455c21xcoKTkIR7g4Bsfo6EhIiAfHZ5b1uFqqCWi3BfXHaKnJySh2lecIeUk4p7eG9x \
hIOUnZBxY2RykZOOj4V9ZmKHmI6DhHt1dXaCh4N+c4abmnltcXB8ioiTkIlvaHOBmZd+ \
cWJqgpKenXpdbX1/fZCXiXpveHqEioB4g419fJOij35uZm9uhp+Nf3Vre3t7hY+JhIp3 \
bm+BkIeBe3Nobo+joYBfW3SEjI+LhG5sgYuKiXl8hgEDDIeAcnaGj3+AhoV5f35/jpaL \
f3NyeH59e3+Jhn57gYB8hot7c4F+fX5/d3qKhXeCmJd+dG5udX2Fi5GKhHZ1enyEk5KB \
eXl3fH18foOIi42Abm5yfouIjoWGeG5mbY2qpoNjYm+Bj4yLhIKKhHt2d3uGjYuDfoB7 \
d3+LjYFweYSEfH+BfoJ/eoOFg4KDiXx7gXt2eYmYjX54b212iJSOiYZ4cnh/go+SjHNo \
cIWLiIqCa2p6kpeNgnhrb3d4gYiMi4eIhHh5eHl+hImHfnN5AQMGjot6eYqJeGhui4t/ \
gJuIcHyEdXWAiYF6b36PlYhzcXuEfHwBA56Jgnl+iH2DgIFdcZGSjIqAeGt4hIiIiYNz \
Y259i4+MgIJ7dXp2eIyQh3x1douFfomMinxod4mGg46Mf3VsdoKDi4qJjYJvbHmDjIZ5 \
hIiDeHJ5ho6Nf3txbXV7iZWUeXB1d3uHiYuMeGRrfY+JhIyFcXaGj5eTgmxpcX+MjoWB \
eH16dXp+foKPinhsfIWFgoyHfG94eXyDhn+Ei4uCfXFxc4GJjZGCdnSCkZSRhXJsdoF6 \
e4qTi4ZvaXqKj5KJgXVwdXR+kJCDfH56cXqQkYeIgXZwcnOBnp5+bHKChYKBh4N4d3l9 \
goaEh4N/e4SLioN6cG59enZ8kJuPfXZxdoOEe3t+kpd6ZWdzla2XeG9zen+ChYB8j5GE \
gHxub3+Sk4J4f4iCfH53dX+PioN5AQNLhIQBA/B3eHtodZqdiXNwdXuCjYt3b3yFiYuL \
hHl8AQM3g4d9cAEDtYaGin1yc3iDjZWMf3ZqaHiJjIuPkowBA2JzeIeTjXxwb3yMk4h8 \
dXmLkoRxbICHhIiKfnF9hn6AhYB6dW58lJuPgnZvcnuEjpCLiXxlcpGMi3RzcXmHg35z \
c4eJgIKBeHJ6fX9/hIyEcnWJiIQBAyR4eH6Cgn6KioeFhoABAyWAjY2PjnhoZ3SBj5oB \
A8V3dGtygY6SigEDKXFkZYmel4V4eG1vgo6MiImAdG98i4uNiHZndIKNhoB/gH6GhICC \
fXp8foSHf29zgoaLiYZ+dnRzdoeLhoOEgX2AhoR4d3qBhouIgYSIgXZ1gYN6eYiJhH56 \
e4CNjoqBd3h2dX6DgIKGgoKAdIGMgnd2eX+EhI+XhWRqgYR/i4qBiId8dWpqgZiglH1n \
ZXKGjImGhHt2en8BA/qCeX2GiYaHgXdweH9/gJCYiXR5e3d9hYJ+fYaZj3ZybXSHkZCH \
gHhvdoWEeoGRiX15bmx7lpR6AQMie4N6bH+HkIl5e4t5a32Fg5OIend3b3mLlpWHenBn \
bYmfint8fICKhXx9foaFfXkBA+R6g42FgIV+fIF2cICUk4eDe3p8gYF9hYeCfYGIfwED \
s4OBfXZ8hoh/enh4f4iKiIB7e36CgH1+g4WCgIGBgIKChIV9eoWLg3l9h4iHfn6AdnmM \
iXtucHyOlIV1cHOBioGGhn52fH6Bh4eCfHV7iYeGjIh8d3Z4f4CAiYkBA+OAenN3hoyE \
goeAb258h5CThHVveH5+eXqAhYsBA6V8eXN7iZCHfHp7hId9cXiGiIWChYWBfX1+e4CM \
jYB5cm53gYmPjH55f3x9gX14f4WIiISAfHyHhHN3g5CNfXd9fYGDe3h+hYmGg3t+hYB2 \
d32Cg3+Ff3p5eYaKjIiFd21xfIiJAQPMfoeLh3yDi39zcoF7eoeRmo5ucIGFfX9/d3qI \
g4J/dn6Eg4uLgHd2AQPtgoB4eoaHhIF+fXcBA29/homDewEDdoWBAQNod3x/fIGLjIB9 \
hH94fnx+goSBfIOEf3+Bf3p1foSBgwEDO4OCcX+PgX2JgHF9f4GEg4WTg2x1eneDiYaE \
f32AeXaFjIiGeGx4jI+Be4B/g4R+enp/gIWGkIqAeXl9f4SCd4GEiIOAfgEDUYEBA7OC \
fXt+fH+NAQOXcHSEkAEDM398eHuAfoWLiIB8dHN4hpCFgYV/AQMkgn+Bh3p6fn2BjZOI \
cmx4h4KEjYl/fnt0dHWBjo2HhoF5c3Z6gIWChY2He3l2fI6QhnkBAwF+goOBfH+FhIWA \
fH+EgYF8enuDhYCEhXt5gYmJf3V3eoGIjoh8dXV7hYmKhIB/eXiAhoR9gYR/dnF8iIWB \
g3x9fX+Ih4KBhYN9e3t4fYKEh4SAd3d+AQO+goGBhoJ9fH2HjIR7dHWIloN0foYBA418 \
fYWJhn97gIJ7fYF5d4eCfHp/gnyAh4WChoB4dHWAhH2DiYeNh39/fXV4h4eJhXhye4SD \
f4mQhXZteH5+hoZ9hYaCe3x+hoB5fYWFhoN0c4CLg39+hYR7dn6IAQPCfYB/io+CeHqB \
g4CAen+EiXx1f5KJgIR2b3R9hIOJjop6c3p8fICJi4h+AQOagICCg4SEhIN9enZ+g4WI \
hH98fH18dXqGhYGBenp8hYV/fXt8gISKiX19e36BiIR7fXx+iJCFgIN/enqBhICDAQPi \
gAEDd4OGg4OBe3l4goSBhIJ8gX94d4ONg319hIF5eoCIhYIBA1N8fIOJg4GFf3t/f4F9 \
fIZ+fIWDfICLiXt1AQMJgIQBA2eAfXx6goWEg4eDe3d7gIGBgYKJiH96eH+MjIBzdn5+ \
gYOEgQED84SDgHl3fYGKhoB7gIR+ggED5oWJg3t5f32CioyFfHR0eoWNioV/fnl3foWK \
hIGAfnx7fIGBAQOngX98AQMCiogBA/J+g4B/AQOtf4B9f4KGg355eYKEhoaAf4J8en59 \
gIiHAQMEg3l6fn+FhISGgIOBfH2Bfnl9gHp5gYWEgn5+foSIh4N8dXZ6AQMPiIkBA1t4 \
eYCDAQMae3p8e32CiYmCAQMsfYKDAQPNgYeGg4ODdnV9hoeCeHmFh4B+eoKCgIOHhH95 \
eoCHgIKEfXt7e3+GhoIBA0V1cn+Tlod9dGxteIeLj4+Gdm98g4OEiYaBeXp/hIiGgXp5 \
f4QBA2R4fIWEgwEDOoGAfQEDEoF+goB+goaEgn19gX17gYmFgH2Dg318fn9+gIGEgHx+ \
goWHg4GFAQPXen2ChQED9AED7n99eHuBgYOEgYIBA/h6AQMrgoeJg4GCgXt4en6EhoiK \
g3t8fQEDS4WIgwEDBwEDdIWBf4KCAQM4AQNge36AhYeBfX5+AQPahX8BAySCgIB/gYOA \
AQNtAQMBfHwBAzR+fQEDEX5+gYF9fH+DhIIBA16CfH2AfX2Eh4N/gX93eoOHAQMugICB \
goB/gnx4goiEAQO/gn8BA1oBA9yGg39+eHmAg4uHfH5+gH99AQPGgYaJhIF9enh/f3+E \
hoGAhAEDVn1+hYQBAwWDhoUBAxiAh4aGhX8BA+4BAwR6foKBAQNLAQMpgoKAfX4BA2N9 \
fAEDpISEAQP2f34BBDOAgAEDTX1+fYCGAQNth315e3p8gIeHAQMge3h/h4Z/fH+BfnwB \
A5iBfoCCgoOBfn+AAQOCfIKEAQONgYIBA6Z/gH+DiYZ7d3d4gIaFhYeDe3cBAyx/hISD \
fnt9f4MBAzF9fX8BA3V9gYKEgX+AAQN4eXoBA3iEh4aDfgEFTIKCgYSDfXt9g4N8en+D \
AQPxfnt7e4ABA69+ggEDInx9gYWDAQM+AQPfgH16fYKEhYIBBFF+en2DhoN/AQNTfnwB \
A0WCg4KChIB7e36BhIeHgXp5fHwBAxOEg4GDAQOeAQOogAEDuAEDiHt7AQMWhoV/fXp7 \
foOGAQOlAQXBgX8BA9mDAQPff4EBA+aCg4ABA9F/AQRafAEDT4GBggIABQISAQPwgX8B \
AwoCAAUB5319g4mHfHZ/hQEDX3+BgH2AgYCAf4GFAQSCgIEBBFZ+ewEDQISCgX17AQQZ \
goGAggEDgwEDYX9+fYKHhYGAfnl/hISEgH4BAzoBA6ABA1yCgH57fIABAzODfgEDhwED \
kgEDk4QBA159fH+EhIODfn0BAwt/gX9/g4OAgYaDfXt6fX+EhQEDVXwBBFB/fQEEWn8B \
BMUBA4wBA25/fn99AQMJAQP0AQNKAQTTg4B+f4N/enwBBu8BA0uDggEDuQEDiAEDbYIB \
A0eBAQMTAQO6AQMLAQN4gIGCf3x+AQO0g4OBfn4BA019AQNDAQONAQNmgoEBAwEBBCQB \
BG+AAQPcAQRlAQMgAQN1AQMXAQX7AQMqgHx8AQMggYMBA1CBfX0CAAUBXoQBA4l9AQNu \
AQN+gYKDAQMXfH0BAy59gIQBA7N+AQPaAQMqAQS3AQQjgYGDAQPafHp7gYWEAQSBAQNd \
goB/AQNGAQS0AQS2gQIABjb7AgAFATUBA+cBBZN/AQTogwIABTcdgX8BA7SAgQEDNgED \
sgEF3gEDL36BAQMdAQULfgEDp4ABAx8BBfuBAQTDAQPKggEDLQEDQYSCfXwBBbkBA9AB \
BGwBBE4CAAg3fgEEEAEHEQEEXgEDPQIABQEsAgAGAUKCAgAFASkBA6oBBE0BBzYBAw+B \
AQMQfgEDBgEEcQEDGQEFvQEFvgEGdwEGXAEEKAEGCQEDuwEEPwEFzwEFZwIABzfrAgAF \
AVgBBBCCAQVGAQQVAQXEAgAIOAgBBDACAAo4KAIAEDhWAQVPAQsaAQidAgAVOFQBCCoB \
ChoBC2YBBroBCQEBDAwCAA042AIAFTja

#---------------------------------------------------------------------
# Misc. data.

# Future change: Document this data.

set    fr1data ""
append fr1data \
AAAAAA AAAAAA AAAAAA AAAAAA CCCCCC CCCCCC CCCCCC CCCCCC \
AAAAAA AAAAAA AAAAAA CCCCCC CCCCCC CCCCCC CCCCCC AAAAAA \
AAAAAA AAAAAA CCCCCC CCCCCC CCCCCC CCCCCC AAAAAA AAAAAA \
AAAAAA CCCCCC CCCCCC CCCCCC CCCCCC AAAAAA AAAAAA AAAAAA \
CCCCCC CCCCCC CCCCCC CCCCCC AAAAAA AAAAAA AAAAAA AAAAAA \
CCCCCC CCCCCC CCCCCC AAAAAA AAAAAA AAAAAA AAAAAA CCCCCC \
CCCCCC CCCCCC AAAAAA AAAAAA AAAAAA AAAAAA CCCCCC CCCCCC \
CCCCCC AAAAAA AAAAAA AAAAAA AAAAAA CCCCCC CCCCCC CCCCCC

set    fr2data ""
append fr2data \
DDDDDD DDDDDD DDDDDD DDDDDD CCCCCC CCCCCC CCCCCC CCCCCC \
DDDDDD DDDDDD DDDDDD CCCCCC CCCCCC CCCCCC CCCCCC DDDDDD \
DDDDDD DDDDDD CCCCCC CCCCCC CCCCCC CCCCCC DDDDDD DDDDDD \
DDDDDD CCCCCC CCCCCC CCCCCC CCCCCC DDDDDD DDDDDD DDDDDD \
CCCCCC CCCCCC CCCCCC CCCCCC DDDDDD DDDDDD DDDDDD DDDDDD \
CCCCCC CCCCCC CCCCCC DDDDDD DDDDDD DDDDDD DDDDDD CCCCCC \
CCCCCC CCCCCC DDDDDD DDDDDD DDDDDD DDDDDD CCCCCC CCCCCC \
CCCCCC DDDDDD DDDDDD DDDDDD DDDDDD CCCCCC CCCCCC CCCCCC

set    fr3data ""
append fr3data \
CCCCCC CCCCCC CCCCCC AAAAAA CCCCCC CCCCCC CCCCCC AAAAAA \
CCCCCC 888888 888888 444444 CCCCCC 888888 888888 444444 \
CCCCCC 888888 888888 444444 CCCCCC 888888 888888 444444 \
AAAAAA 444444 444444 444444 AAAAAA 444444 444444 444444 \
CCCCCC CCCCCC CCCCCC AAAAAA CCCCCC CCCCCC CCCCCC AAAAAA \
CCCCCC 888888 888888 444444 CCCCCC 888888 888888 444444 \
CCCCCC 888888 888888 444444 CCCCCC 888888 888888 444444 \
AAAAAA 444444 444444 444444 AAAAAA 444444 444444 444444

#---------------------------------------------------------------------

# Routine:    setup_graphics
# Purpose:    Sets up graphics mode
# Arguments:  None

# For related information,  see the comments  in the  "program parame-
# ters" section named "Graphics".

#---------------------------------------------------------------------

dmproc 1 setup_graphics {} {
    global BRICKAPI UseOpenGL
    global DisplayWidth DisplayHeight DisplayScale FullScreen

    if { $UseOpenGL > 0 } {
        br::graphics open accel \
            $DisplayWidth $DisplayHeight $FullScreen $DisplayScale
    } else {
        if { $BRICKAPI < 5400 } {
            br::graphics open sdl \
                $DisplayWidth $DisplayHeight $FullScreen
        } else {
            set gra_opts [list sdl]
            if { $FullScreen } { lappend gra_opts fs }
            br::graphics open \
                $DisplayWidth $DisplayHeight $DisplayScale 0 $gra_opts
        }
    }
}

#---------------------------------------------------------------------

# Routine:    lz77_decode
# Purpose:    Decompresses LZ77-compressed data
# Arguments:  data = LZ77-compressed data

# This routine decompresses the input data and returns the result.

# Note: If you'd like to create compressed data that's compatible with
# this routine,  you'll need to use  a  separate LZ77 compression tool
# named "lzbetool". "lzbetool" is a short pure-Tcl script that  should
# be available from the same place as this program.

# This routine isn't original,  but it's  believed to be redistributa-
# ble. It's based on code by Miguel Sofer that was obtained from:
#
#     http://wiki.tcl.tk/12390

#---------------------------------------------------------------------

dmproc 1 lz77_decode { data } {
    set LZ_Escape1 "\x01"
    set LZ_Escape2 "\x02"

    set output ""

    for {set i 0} {$i < [string length $data]} {incr i} {
         set char [string index $data $i]
         if { $char eq $LZ_Escape1 } {
             set char [string index $data [incr i]]
             if { ($char eq $LZ_Escape1) || ($char eq $LZ_Escape2)} {
                 append output $char
             } else {
                 scan $char %c length
                 scan [string index $data [incr i]] %c offset
                 set index [expr {[string length $output] - $offset}]
                 for {set j 0} {$j < $length} {incr j} {
                     append output [string index $output $index]
                     incr index
                 }
             }
         } elseif { $char eq $LZ_Escape2 } {
             binary scan \
                [string range $data [incr i] [incr i]] S length
             binary scan \
                [string range $data [incr i] [incr i]] S offset
             set index [expr {[string length $output] - $offset}]
             for {set j 0} {$j < $length} {incr j} {
                 append output [string index $output $index]
                 incr index
             }
         } else {
             append output $char
         }
     }

     return $output
}

#---------------------------------------------------------------------

# Routine:    makebase64
# Purpose:    Sets up a global variable used by "base64_decode"
# Arguments:  None

# This routine  initializes a global variable (named "base64")  that's
# used by  "base64_decode".  Note:  "base64_decode" calls this routine
# automatically if necessary.

# This routine isn't original,  but  it's believed to be redistributa-
# ble. It's based on Tcl "base64" support code by Stephen Uhler, Brent
# Welch, and Chris Garrigues.

#---------------------------------------------------------------------

dmproc 1 makebase64 {} {
    global base64

    set i 0
    foreach char { \
        A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
        a b c d e f g h i j k l m n o p q r s t u v w x y z \
        0 1 2 3 4 5 6 7 8 9 + / \
    } {
        set base64_tmp($char) $i ; incr i
    }

    scan z %c len

    for { set i 0 } { $i <= $len } { incr i } {
        set char [format %c $i]
        set val {}
        if { [info exists base64_tmp($char)] } {
            set val $base64_tmp($char)
        } else { set val {} }
        lappend base64 $val
    }

    scan = %c i
    set base64 [lreplace $base64 $i $i -1]
    unset base64_tmp i char len val
}

#---------------------------------------------------------------------

# Routine:    base64_decode
# Purpose:    Converts "base64"-encoded data to binary data
# Arguments:  string = "base64"-encoded string

# This  routine  returns  the data  that  the  input string represents
# (which  may be  either binary or text data).  Note:  Embedded  white
# space in the input is ignored.

# This routine isn't original,  but it's  believed to be redistributa-
# ble. It's based on Tcl "base64" support code by Stephen Uhler, Brent
# Welch, and Chris Garrigues.

#---------------------------------------------------------------------

dmproc 1 base64_decode { string } {
    global base64

    if { [string length $string] == 0 } { return "" }
    if { ![info exists    base64] || \
         ![string length $base64] } { makebase64 }

    set output ""
    binary scan $string c* X

    foreach x $X {
        set bits [lindex $base64 $x]
        if { $bits >= 0 } {
            if { [llength [lappend nums $bits]] == 4 } {
                foreach { v w z y } $nums break
                set a [expr { ($v << 2) | ($w >> 4) }]
                set b [expr { (($w & 0xF) << 4) | ($z >> 2) }]
                set c [expr { (($z & 0x3) << 6) | $y }]
                append output [binary format ccc $a $b $c]
                set nums {}
            }
        } elseif { $bits == -1 } {

# End of data. Output whatever characters remain.  The encoding algor-
# ithm dictates that we can  only have 1 or 2  padding characters.  If
# x  is  {}, we have 12 bits of input (enough  for one 8-bit  output).
# Otherwise, we have 18 bits of input (enough  for two 8-bit outputs).

            foreach {v w z} $nums break
            set a [expr { ($v << 2) | (($w & 0x30) >> 4) }]

            if { $z == {} } {
                append output [binary format c $a ]
            } else {
                set b [expr \
                    { (($w & 0xF) << 4) | (($z & 0x3C) >> 2) }]
                append output [binary format cc $a $b]
            }
            break
        } else {

# Line break or another character that  isn't part of the encoded data
# stream.  Based on RFC 2045, we should ignore this and we can option-
# ally treat it as a warning or error condition.  Presently,  this im-
# plementation  ignores characters  of this type  but doesn't  produce
# warnings or errors in this case.

            continue
        }
    }

    return $output
}

#---------------------------------------------------------------------

# Routine:    lz77_base64_decode
# Purpose:    Decodes LZ77-compressed base64-encoded data
#
# Arguments:  data = Data that was  produced by  LZ77 compression fol-
#             lowed by base64-encoding

# This routine converts the input data from "base64" format to binary,
# decompresses it, and returns the result.

#---------------------------------------------------------------------

dmproc 1 lz77_base64_decode { data } {
    return [lz77_decode [base64_decode $data]]
}

#---------------------------------------------------------------------

# Routine:    bxdiv_lz77_base64_decode
# Purpose:    Decodes bxdiv-LZ77-base64 data (see below)
# Arguments:  data =  bxdiv-LZ77-base64 data (see below)

# This routine takes data produced by "bxdiv-LZ77-base64" compression-
# encoding as input and returns  decoded-decompressed data  as output.
# For  more  information,  see the  following  documentation  section:
# bxdiv data format.

#---------------------------------------------------------------------

dmproc 1 bxdiv_lz77_base64_decode { data } {
    set data [lz77_base64_decode $data]
    set n [binary scan $data a5a6a1a* magic revision divisor data]
    if { $n != 4 }           { puts "$IE-01: $n"     ; exit 1 }
    if { $magic ne "bxdiv" } { puts "$IE-02: $magic" ; exit 1 }
    scan $divisor %c divisor
    if { $divisor < 2 } { return $data }

    set str ""
    for { set ii 1 } { $ii <= $divisor } { incr ii } {
        append str "\\1"
    }

    regsub -all {(.)} $data "$str" data
    return $data
}

#---------------------------------------------------------------------

# Routine:    setup_sound_effects_sndname
# Purpose:    Sets up one sound effect
# Arguments:  sndname = Sound name (omitting "sound_" prefix)

#---------------------------------------------------------------------

dmproc 1 setup_sound_effects_sndname { sndname } {
    global gdata
    global          ${sndname}_bxdiv_lz77_base64
    eval  set hex  $${sndname}_bxdiv_lz77_base64
    set temp_bin [bxdiv_lz77_base64_decode $hex]

    set gdata(sound_${sndname}) [br::sound load-raw $temp_bin]
    unset           ${sndname}_bxdiv_lz77_base64
}

#---------------------------------------------------------------------

# Routine:    setup_sound_effects
# Purpose:    Sets up sound effects
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 setup_sound_effects {} {
    global gdata

    foreach sound $gdata(list_sounds) {
        setup_sound_effects_sndname $sound
    }

# Set the default "exit" sound  (may be changed as  the game progress-
# es).

    set gdata(sound_exit) $gdata(sound_poweroff)

# An  inter-world portal presently sounds  the same as an  intra-world
# portal.

    set gdata(sound_ocinter) $gdata(sound_ocintra)
}

#---------------------------------------------------------------------

# Routine:    setup_audio
# Purpose:    Sets up audio (including music and sound effects)
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 setup_audio {} {
    global music_lz77_base64
    global MusicFile MusicVolume PlayMusic
                                # Initialize audio
    br::audio open speaker
                                # If music is requested, start playing
                                # the specified  file at the specified
                                # volume
    if { $PlayMusic eq "1" } {
                                # Play built-in music?
        if {$MusicFile eq "internal"} {
                                # Yes
            set   MusicDataBinary \
                [lz77_base64_decode $music_lz77_base64]
            unset music_lz77_base64
            br::song play-buffer $MusicDataBinary
        } else {
                                # No  - Play an external file
            br::song play-file $MusicFile
        }
                                # Adjust volume
        if { [info exists MusicVolume] && \
             [expr $MusicVolume >= 0] } {
            br::song adj-vol $MusicVolume
        }
    }

    setup_sound_effects       ; # Set up sound effects
}

#---------------------------------------------------------------------

# Routine:    play_sound
# Purpose:    Plays a sound
# Arguments:  name  = Sound name (omitting "sound_" prefix)
#             delay = Number passed to "after" (or zero to omit delay)

#---------------------------------------------------------------------

dmproc 1 play_sound { name delay } {
    global gdata
    if { ![regexp {^sound_} $name] } { set name sound_$name }

    if { [info exists   gdata($name)] } {
        br::sound play $gdata($name)
        if { $delay > 0 } { after $delay }
    }
}

#---------------------------------------------------------------------

# Routine:    quit_program
# Purpose:    Quits the program
# Arguments:  None

# This routine quits the program.  By default,  an appropriate  "exit"
# sound is played first. To disable the "exit" sound, use:
#
#     global gdata
#     unset  gdata(sound_exit)

#---------------------------------------------------------------------

dmproc 1 quit_program {} {
    play_sound exit 2600
    exit 0
}

#---------------------------------------------------------------------
# World definitions: Main world.

                                     ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldMain)

set gdata($World.is_invariant)     0 ; # Flag: Random maps are O.K.
set gdata($World.width)           46 ; # Default map width  (in cells)
set gdata($World.height)          32 ; # Default map height (in cells)

set gdata($World.ocintra_minnum)   1 ; # Min. no. of ocintra portals
set gdata($World.ocintra_maxnum)   3 ; # Max. no. of ocintra portals
set gdata($World.ocscroll_minnum)  1 ; # Min. no. of ocscrolls
set gdata($World.ocscroll_maxnum)  2 ; # Max. no. of ocscrolls
set gdata($World.octree_minnum)    1 ; # Min. no. of octrees
set gdata($World.octree_maxnum)    3 ; # Max. no. of octrees

                                     ; # Worlds that this one connects
                                     ; # forward to
set gdata($World.to_worlds) [list \
   $gdata(WorldElysian) $gdata(WorldMilk) \
]

set    gdata($World.map_data) ""     ; # Default map data
append gdata($World.map_data) \
1111111111111111111111111111111111111111111111 \
1----------------------------111-------------1 \
1--111111111-----1-----------111-------------1 \
1--1------------1------------111-------------1 \
1--1-1111111-------------1---111-------------1 \
1--1-1-1------1----1---------111-------------1 \
1--1---1------1----1---------111-------------1 \
1--11111------1-------1------111-------------1 \
1----1----------------1111111111-------------1 \
1----1----111----------------111-------------1 \
1----1---11------------------111-------------1 \
1----1---11-----11-----------11--------------1 \
1----1-----------------------111-----11------1 \
1--------11----------------1111111111111-----1 \
1--------11111111111------1111---------------1 \
1--------------------------1111111111111-----1 \
1---11-----------------------111-------------1 \
1--------1------11---1-------11-------------11 \
1----1--------1-------1------1-----------1--11 \
1--1------------------1------------------1--11 \
1---1----111----------1----------1-------1--11 \
1--------1-----------1---1111------------1--11 \
1-------11------1--------1-------1--1----1--11 \
1---------------------1111---------------1--11 \
1-------------1-------1--1111------1-----1--11 \
1--1111----------1-------1-------1----1--1--11 \
1--1111----1----11-------1------------1--1--11 \
1--1111---------------1111111-------111--1--11 \
1--1111--------111----1--1-------1111----1--11 \
1---------------------1--1-------1-----111--11 \
1----------------1-------1111---------------11 \
1111111111111111111111111111111111111111111111

#---------------------------------------------------------------------
# World definitions: Elysian Fields.

                                     ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldElysian)

set gdata($World.is_invariant)     0 ; # Flag: Random maps are O.K.
set gdata($World.width)           25 ; # Default map width  (in cells)
set gdata($World.height)          20 ; # Default map height (in cells)

                                     ; # ockarkinos size class
set gdata($World.ockarkinos_size)  "medium"

set gdata($World.occar_minnum)     1 ; # Min. no. of occars
set gdata($World.occar_maxnum)     1 ; # Max. no. of occars
set gdata($World.ocintra_minnum)   1 ; # Min. no. of ocintra portals
set gdata($World.ocintra_maxnum)   3 ; # Max. no. of ocintra portals
set gdata($World.ocscroll_minnum)  1 ; # Min. no. of ocscrolls
set gdata($World.ocscroll_maxnum)  1 ; # Max. no. of ocscrolls
set gdata($World.octree_minnum)    1 ; # Min. no. of octrees
set gdata($World.octree_maxnum)    3 ; # Max. no. of octrees

                                     ; # Worlds that this one connects
                                     ; # forward to
set gdata($World.to_worlds) [list \
    $gdata(WorldMilk) $gdata(WorldCaspak) \
]

set    gdata($World.map_data) ""     ; # Default map data
append gdata($World.map_data) \
1111111111111111111111111 \
1-----------------------1 \
1-----1--------1111---1-1 \
1-----1------111--11111-1 \
1--1111------11---------1 \
1-------------1---------1 \
1--1--------111---------1 \
1-11-------11-----------1 \
1-----------------------1 \
1-11-----111------------1 \
1--11----------111------1 \
1---1-----------11------1 \
1-111----------11-----1-1 \
1------11111--------111-1 \
1------11-----------111-1 \
1-------1---------------1 \
1-------1111---111111---1 \
1--------111---11--11---1 \
1-----------------------1 \
1111111111111111111111111

#---------------------------------------------------------------------
# World definitions: Limbo.

                                     ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldLimbo)

set gdata($World.is_invariant)     1 ; # Flag: This map is invariant
set gdata($World.width)           25 ; # Default map width  (in cells)
set gdata($World.height)          25 ; # Default map height (in cells)

                                     ; # No. of karkinos to preload
set gdata($World.ockarkinos_preload)  2

set gdata($World.ocintra_minnum)   1 ; # Min. no. of ocintra portals
set gdata($World.ocintra_maxnum)   3 ; # Max. no. of ocintra portals

set gdata($World.occross_maxnum)   1 ; # This world has an occross
set gdata($World.occross_preload)  1

set gdata($World.ocscroll_minnum)  1 ; # Min. no. of ocscrolls
set gdata($World.ocscroll_maxnum)  1 ; # Max. no. of ocscrolls
set gdata($World.octree_minnum)    1 ; # Min. no. of octrees
set gdata($World.octree_maxnum)    3 ; # Max. no. of octrees

                                     ; # Worlds that this one connects
                                     ; # forward to (presently none)
set gdata($World.to_worlds) [list]

set    gdata($World.map_data) ""     ; # Map data
append gdata($World.map_data) ""     ; # This map is empty

#---------------------------------------------------------------------
# World definitions: Milk and Honey.

                                     ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldMilk)

set gdata($World.is_invariant)     0 ; # Flag: Random maps are O.K.
set gdata($World.width)           52 ; # Default map width  (in cells)
set gdata($World.height)          30 ; # Default map height (in cells)

set gdata($World.occar_minnum)     1 ; # Min. no. of occars
set gdata($World.occar_maxnum)     1 ; # Max. no. of occars
set gdata($World.ocintra_minnum)   1 ; # Min. no. of ocintra portals
set gdata($World.ocintra_maxnum)   3 ; # Max. no. of ocintra portals
set gdata($World.ocscroll_minnum)  1 ; # Min. no. of ocscrolls
set gdata($World.ocscroll_maxnum)  1 ; # Max. no. of ocscrolls
set gdata($World.octree_minnum)    1 ; # Min. no. of octrees
set gdata($World.octree_maxnum)    3 ; # Max. no. of octrees

                                     ; # Worlds that this one connects
                                     ; # forward to
set gdata($World.to_worlds) [list \
    $gdata(WorldLimbo) $gdata(WorldCaspak) \
]

set    gdata($World.map_data) ""     ; # Default map data
append gdata($World.map_data) \
1111111111111111111111111111111111111111111111111111 \
1--------------------------------------------------1 \
1--11111111----------1---------------------111-----1 \
1-----111111-------------------------------111-----1 \
1--1-------11-----------------------11-----111-----1 \
1---------111----------11---111-----11-------1-----1 \
1--------------------111------1-----11-111---1-----1 \
1------1111---------11------1------------1--11-----1 \
1------------------------11-1-------1---11--1111---1 \
1------1-111--------1---11----------111------1111--1 \
1----------1111-----1-----111---------111------11--1 \
1--------111--1-----1-------1--1----1--------------1 \
1-1--11-------1-----11--111---------111------------1 \
1-1111111--1111-----11----------------111----------1 \
1------11-----111-------11--------------1-----1111-1 \
1-1--------1--111---111--1--------------1111-----1-1 \
1-111-11---11111---1111--1-----------------1-11--1-1 \
1---1-1----11--1---11---11----111111-------1-------1 \
1--------------111-11--11-----1111-1----11-111-----1 \
1----------------------1-----------1---111-------1-1 \
1------------------111-------------1---------11111-1 \
1----------------------------------1-111111--------1 \
1----------------------------------1------1--11----1 \
1-------------------11-------------111----1---1111-1 \
1-----------111---111---------------------11-------1 \
1-------------1----------------------------1-------1 \
1----------1111---111-------------111------1-------1 \
1-------------------1----------------------1---111-1 \
1--------------------------------------------------1 \
1111111111111111111111111111111111111111111111111111

#---------------------------------------------------------------------
# World definitions: Eternia.

                                     ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldEternia)

set gdata($World.is_invariant)     0 ; # Flag: Random maps are O.K.
set gdata($World.width)           54 ; # Default map width  (in cells)
set gdata($World.height)          29 ; # Default map height (in cells)

set gdata($World.ocintra_minnum)   1 ; # Min. no. of ocintra portals
set gdata($World.ocintra_maxnum)   3 ; # Max. no. of ocintra portals
set gdata($World.ocscroll_minnum)  1 ; # Min. no. of ocscrolls
set gdata($World.ocscroll_maxnum)  1 ; # Max. no. of ocscrolls
set gdata($World.octree_minnum)    1 ; # Min. no. of octrees
set gdata($World.octree_maxnum)    3 ; # Max. no. of octrees

                                     ; # Worlds that this one connects
                                     ; # forward to
set gdata($World.to_worlds) [list \
    $gdata(WorldCaspak) \
]

set    gdata($World.map_data) ""     ; # Default map data
append gdata($World.map_data) \
111111111111111111111111111111111111111111111111111111 \
1----------------------------------------------------1 \
1------------1111--11-----------11------111----------1 \
1--------11111111---1-----------11-------------------1 \
1-1------111---11---11------------------1-1111-------1 \
1-1------111----1--111------------------1------------1 \
1-1--------1----1-----------------------1--1111-1111-1 \
1----------1----1-11--------------------11----1-1--1-1 \
1----------1----1-------1111----------1--1-----------1 \
1--------111---------1--1111-----1111---11-----------1 \
1-----111111---------1111--1111-----1---111111-------1 \
1--------111-----------11---111--1--1----11--1111----1 \
1-1---11111-------11-1--------1111-11---------111----1 \
1-1---11111-------11-11-------------------------1----1 \
1-----111------11111--11-----------1------------11---1 \
1----------------------111---------111---------111---1 \
1------------------------11----------1---------111---1 \
1-------------------------1-------1111-----------1---1 \
1------------------------11-------11111----1111111---1 \
1-------------------------------------1--------------1 \
1------1111--------------1--------111-1----1---------1 \
1---------1--------------11---------111----1111111---1 \
1---------111---------11--1---------------111--------1 \
1-11-------11------11111-11--------------11----------1 \
1-11-------11----111-------------------111-----------1 \
1-11--------1---11-------------------111-------------1 \
1-----------1--11------------------------------------1 \
1----------------------------------------------------1 \
111111111111111111111111111111111111111111111111111111

#---------------------------------------------------------------------
# World definitions: Caspak.

                                     ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldCaspak)

set gdata($World.is_invariant)     1 ; # Flag: This map is invariant
set gdata($World.width)           43 ; # Map width  (in cells)
set gdata($World.height)          27 ; # Map height (in cells)

                                     ; # No. of karkinos to preload
set gdata($World.ockarkinos_preload) 10
                                     ; # ockarkinos size class
set gdata($World.ockarkinos_size)  "large"

set gdata($World.ocintra_minnum)   1 ; # Min. no. of ocintra portals
set gdata($World.ocintra_maxnum)   3 ; # Max. no. of ocintra portals
set gdata($World.ocscroll_minnum)  1 ; # Min. no. of ocscrolls
set gdata($World.ocscroll_maxnum)  1 ; # Max. no. of ocscrolls
set gdata($World.octree_minnum)    1 ; # Min. no. of octrees
set gdata($World.octree_maxnum)    3 ; # Max. no. of octrees
set gdata($World.occow_maxnum)     0 ; # This world has no occows
set gdata($World.ocdog_maxnum)     0 ; # This world has no ocdogs

                                     ; # Worlds that this one connects
                                     ; # forward to
set gdata($World.to_worlds) [list \
    $gdata(WorldEternia) \
    $gdata(WorldHeaven) \
]

set    gdata($World.map_data) ""     ; # Map data
append gdata($World.map_data) \
1111111111111111111111111111111111111111111 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1-----------------------------------------1 \
1111111111111111111111111111111111111111111

#---------------------------------------------------------------------
# World definitions: Heaven.

                                      ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldHeaven)

set gdata($World.is_invariant)      1 ; # Flag: This map is invariant
set gdata($World.width)            19 ; # Map width  (in cells)
set gdata($World.height)           13 ; # Map height (in cells)

                                      ; # World has one ocflames
set gdata($World.ocflames_minnum)   1
set gdata($World.ocflames_maxnum)   1
set gdata($World.ocflames_preload)  1

set gdata($World.ocintra_maxnum)    0 ; # No ocintra portals
set gdata($World.occow_maxnum)      0 ; # No occows
set gdata($World.ockarkinos_maxnum) 0 ; # No ockarkinos
set gdata($World.ocscroll_maxnum)   0 ; # No ocscrolls
set gdata($World.octree_maxnum)     0 ; # No octrees

                                      ; # Worlds this connects forward
                                      ; # to
set gdata($World.to_worlds) [list \
    $gdata(WorldEndOfAllSongs) \
]

set    gdata($World.map_data) ""      ; # Map data
append gdata($World.map_data) \
1111111111111111111 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1-----------------1 \
1111111111111111111

#---------------------------------------------------------------------
# World definitions: End of All Songs.

                                     ; # "gdata" key prefix string
set World $WorldKeyStart.$gdata(WorldEndOfAllSongs)

set gdata($World.is_invariant)     1 ; # Flag: This map is invariant
set gdata($World.width)           20 ; # Map width  (in cells)
set gdata($World.height)          15 ; # Map height (in cells)

set gdata($World.occow_maxnum)     0 ; # Zero occows
set gdata($World.ocintra_maxnum)   0 ; # Zero ocintra portals
set gdata($World.ocscroll_maxnum)  0 ; # Zero ocscrolls
set gdata($World.octree_maxnum)    0 ; # Zero octrees

                                     ; # Worlds that this one connects
                                     ; # forward to (none)
set gdata($World.to_worlds) [list]

set    gdata($World.map_data) ""     ; # Map data
append gdata($World.map_data) ""     ; # This map is empty

#---------------------------------------------------------------------

# Routine:    random_direction
# Purpose:    Returns a random direction number
# Arguments:  None

# "random_direction"  returns a  random direction number. For the pur-
# poses  of this  routine,  directions  are  numbered from 0 to 7  and
# should be interpreted as follows:
#
#     0: NorthWest   3: North   5: NorthEast
#     1: West                   6: East
#     2: SouthWest   4: South   7: SouthEast

#---------------------------------------------------------------------

dmproc 10 random_direction {} { return [expr { int (rand() * 8) }] }

#---------------------------------------------------------------------

# Routine:    (xproc) get_dir_vx_vy
# Purpose:    Translates a direction number to X-Y deltas
# Arguments:  dir = Direction number (see below)
#             vx  = X-delta output (passed by reference)
#             vy  = Y-delta output (passed by reference)

# This is  an  "xproc" routine;  i.e.,  it supports  "&variable"-style
# pass-by-reference.

# "dir" should be a direction number of the type returned by  "random_
# direction".

# This routine translates "dir" to X-Y deltas that represent a step of
# one unit in the  specified direction.  It sets vx  (in  the caller's
# scope) to the resulting X-delta (-1, 0, or 1).  It sets vy  (in  the
# caller's scope) to the resulting Y-delta (-1, 0, or 1).

#---------------------------------------------------------------------

if { $DebugLevel > 1 } { puts "define get_dir_vx_vy" }

xproc get_dir_vx_vy { dir &vx &vy } {
    switch $dir {
        0 { set vx -1; set vy -1 }
        1 { set vx -1; set vy  0 }
        2 { set vx -1; set vy  1 }
        3 { set vx  0; set vy -1 }
        4 { set vx  0; set vy  1 }
        5 { set vx  1; set vy -1 }
        6 { set vx  1; set vy  0 }
        7 { set vx  1; set vy  1 }
    }
}

#---------------------------------------------------------------------

# Routine:    random_int
# Purpose:    Returns a random integer in a specified range
# Arguments:  min_int = First (lower ) integer in a range
#             max_int = Last  (higher) integer in a range

# "random_int" returns a random integer that  ranges from  $min_int to
# $max_int inclusive. Special case: If $max_int is less than $min_int,
# this routine returns $max_int.

#---------------------------------------------------------------------

dmproc 10 random_int { min_int max_int } {
    set min_int [expr { int ($min_int + 0.5) }]
    set max_int [expr { int ($max_int + 0.5) }]

    if { $max_int < $min_int } { return $max_int }
    set num_int [expr $max_int - $min_int + 1]
    return [expr { $min_int + int (rand() * $num_int) }]
}

#---------------------------------------------------------------------

# Routine:    random_real
# Purpose:    Returns a random real in a specified range
# Arguments:  min_real  = First (lower ) real in a range
#             max_real  = Last  (higher) real in a range

# "random_real" returns a random real that ranges from just over $min_
# real to just under $max_real.  Special case:  If $max_real  is  less
# than or equal to $min_real, this routine returns $max_real.

#---------------------------------------------------------------------

dmproc 10 random_real { min_real max_real } {
    if { $max_real <= $min_real } { return $max_real }
    set delta [expr $max_real - $min_real]
    return [expr { $min_real + (rand() * $delta) }]
}

#---------------------------------------------------------------------

# Routine:    get_sprite_class
# Purpose:    Returns a sprite's object-class name
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 10 get_sprite_class { id } {
    global sdata
    if { ![info exists sdata($id.)]  } { puts "$IE-01" ; exit 1 }
    set callback      $sdata($id.)
    if { ![regexp {^run_} $callback] } { puts "$IE-02" ; exit 1 }
    regsub        {^run_} $callback "" objclass
    return $objclass
}

#---------------------------------------------------------------------

# Routine:    get_world_param
# Purpose:    Retrieves a world-specific variable
# Arguments:  name = Variable name

# If the  given variable  has been  set in the  context of the current
# world,  this routine returns the stored world-specific value.  Note:
# This may be anything; an integer, a list, etc.

# Otherwise, this routine returns the integer 0.

#---------------------------------------------------------------------

dmproc 100 get_world_param { name } {
    if { $DebugLevel >= 2 } { puts "$rtn $name" }
    global gdata lv WorldKeyStart
    set world_key  $WorldKeyStart.$lv

    if [info exists gdata($world_key.$name)] {
            return $gdata($world_key.$name)
    }

    return 0
}

#---------------------------------------------------------------------

# Routine:    set_world_param
# Purpose:    Sets a world-specific variable
# Arguments:  name  = Variable name
#             value = Arbitrary value

# This routine sets the given variable  to the specified value for the
# current world.  Instances of the variable that were set in  the con-
# texts of other worlds aren't affected.

#---------------------------------------------------------------------

dmproc 100 set_world_param { name value } {
    if { $DebugLevel >= 2 } { puts "$rtn $name" }
    global gdata lv WorldKeyStart
    set world_key  $WorldKeyStart.$lv
    set gdata($world_key.$name) $value
}

#---------------------------------------------------------------------

# Routine:    get_class_param
# Purpose:    Retrieves a specified parameter based on context
# Arguments:  objclass = Object-class name
#             param    = Parameter    name

# "param" may be the name of any parameter that may be associated with
# objects in the specified class.  Examples include "maxnum", "zhint",
# etc.

# If the given parameter  has been set for the given  object class  in
# the context of the current world,  this routine  returns  the stored
# world-specific  value.  Note:  This may be  anything;  an integer, a
# list, etc.

# Otherwise, if a global default setting exists for the  given  object
# class, this routine returns the stored global default value.

# Otherwise, this routine returns the integer 0.

# For more information  about  global and  per-world  parameters,  see
# "Object-class parameters".

#---------------------------------------------------------------------

dmproc 100 get_class_param { objclass param } {
    if { $DebugLevel >= 2 } { puts "$rtn $objclass $param" }
    global gdata lv WorldKeyStart

    if { [info exists lv] } {
        set world_key $WorldKeyStart.$lv
        if [info exists gdata($world_key.${objclass}_${param})] {
                return $gdata($world_key.${objclass}_${param})
        }
    }

    if { [info exists gdata(Default_${objclass}_${param})] } {
              return $gdata(Default_${objclass}_${param})
    }

    return 0
}

#---------------------------------------------------------------------

# Routine:    get_class_counter
# Purpose:    Per-world sprite counter utility routine
# Arguments:  objclass = Object-class name

# This routine returns the value of a counter that tracks  the  number
# of instances of the specified object class that exist in the current
# world.

# The counter doesn't need  to be  initialized.  If it doesn't already
# exist, this routine creates it.

#---------------------------------------------------------------------

dmproc 10 get_class_counter { objclass } {
    global gdata lv
    if { ![info exists gdata($lv,num_$objclass)] } {
                   set gdata($lv,num_$objclass) 0
    }

    return $gdata($lv,num_$objclass)
}

#---------------------------------------------------------------------

# Routine:    get_class_counter
# Purpose:    Per-world sprite counter utility routine
# Arguments:  objclass = Object-class name

# This routine returns the value of a counter that tracks  the  number
# of instances of the specified object class that exist in the current
# world.

# The counter doesn't need  to be  initialized.  If it doesn't already
# exist, this routine creates it.

#---------------------------------------------------------------------

dmproc 10 get_class_counter { objclass } {
    global gdata lv
    if { ![info exists gdata($lv,num_$objclass)] } {
                   set gdata($lv,num_$objclass) 0
    }

    return $gdata($lv,num_$objclass)
}

#---------------------------------------------------------------------

# Routine:    incr_class_counter
# Purpose:    Per-world sprite counter utility routine
# Arguments:  objclass = Object-class name

# This routine  increments  a counter  that  tracks  the number of in-
# stances  of  the specified object class  that exist  in the  current
# world and returns the result.

#---------------------------------------------------------------------

dmproc 10 incr_class_counter { objclass } {
    global gdata lv
    set n [expr [get_class_counter $objclass] + 1]
    set gdata($lv,num_$objclass) $n
    return $n
}

#---------------------------------------------------------------------

# Routine:    decr_class_counter
# Purpose:    Per-world sprite counter utility routine
# Arguments:  objclass = Object-class name

# This routine  decrements  a counter  that  tracks  the number of in-
# stances  of  the specified  object class that exist  in the  current
# world and returns the result.

#---------------------------------------------------------------------

dmproc 10 decr_class_counter { objclass } {
    global gdata lv
    set n [expr [get_class_counter $objclass] - 1]
    if { $n < 0 } { set n 0 }
    set gdata($lv,num_$objclass) $n
    return $n
}

#---------------------------------------------------------------------

# Routine:    get_object_param
# Purpose:    Gets a specified variable for a specified object
# Arguments:  id   = Sprite ID
#             name = Flag name

# This routine returns  the  value of the specified variable  for  the
# object  associated  with the specified sprite.  The variable doesn't
# need to be initialized;  if it doesn't  already exist,  this routine
# initializes it to the integer 0.

#---------------------------------------------------------------------

dmproc 10 get_object_param { id name } {
    global sdata
    if { ![info exists sdata($id.$name)] } {
                   set sdata($id.$name) 0
    }
    return            $sdata($id.$name)
}

#---------------------------------------------------------------------

# Routine:    set_object_param
# Purpose:    Sets a specified variable for a specified object
# Arguments:  id    = Sprite ID
#             name  = Flag name
#             value = Arbitrary value

# This routine  sets the  specified variable for the object associated
# with the  specified  sprite to the specified value.  It  returns the
# value in question.

#---------------------------------------------------------------------

dmproc 10 set_object_param { id name value } {
    global sdata
    set sdata($id.$name) $value
    return $value
}

#---------------------------------------------------------------------

# Routine:    get_object_name_random
# Purpose:    Selects a random name
# Arguments:  objclass = Object-class name

# If a list of possible names has been specified for  the given object
# class,  this routine returns a random name from the list. Otherwise,
# this routine returns the string "none".

# Note: Name lists specified at the  world-definitions level take pre-
# cedence over name lists specified at the global level.

# For more information  about  global and  per-world  parameters,  see
# "Object-class parameters".

#---------------------------------------------------------------------

dmproc 10 get_object_name_random { objclass } {
    set name_list [get_class_param $objclass name]
    if { $name_list eq "0" } { return "none" }
    set name [lrandom $name_list]
    regsub -all {\*} $name "" name
    return $name
}

#---------------------------------------------------------------------

# Routine:    get_object_name_current
# Purpose:    Gets the game-level name of an individual sprite
# Arguments:  id = Sprite ID

# If the  specified sprite was assigned a  game-level name when it was
# created, this routine returns the name.  Otherwise, this routine re-
# returns the string "none".

#---------------------------------------------------------------------

dmproc 10 get_object_name_current { id } {
    global sdata
    if { ![info exists sdata($id.name)] } { return "none" }
    return            $sdata($id.name)
}

#---------------------------------------------------------------------

# Routine:    destroy_sprite
# Purpose:    Destroys a specified sprite
# Arguments:  objclass = Object-class name
#             id       = Sprite ID

# The specified sprite must exist in the current world.  Additionally,
# it must be of the specified class.  This routine destroys the sprite
# at all applicable code levels.

#---------------------------------------------------------------------

dmproc 10 destroy_sprite { objclass id } {
    global gdata layers lv sdata
    set callback $sdata($id.)
                                # Consistency check
    if { $callback ne "run_$objclass" } { puts "$IE-01" ; exit 1 }

    br::list remove $layers($lv.spr-list) $id
    br::sprite delete $id
    array unset sdata $id.*
    decr_class_counter $objclass
                                # Remove any associated collision lock
    set ocplayer_id $gdata($lv,ocplayer_id)
    set xlock_id $ocplayer_id.${objclass}_id
    if { [info exists gdata($lv,$xlock_id)] } {
                unset gdata($lv,$xlock_id)
    }
}

#---------------------------------------------------------------------

# Routine:    verify_sprite_exists
# Purpose:    Used for sanity checks
# Arguments:  msg = Base message string
#             id  = Sprite ID

# This routine  verifies that the specified  sprite exists in the cur-
# rent world. To do this, it checks for the existence of:
#
#     sdata($id.)

# If  the sprite doesn't exist,  this routine prints  an error message
# and terminates the caller.  The error message includes both $msg and
# $id.

#---------------------------------------------------------------------

dmproc 10 verify_sprite_exists { msg id } {
    global lv sdata
    if { ![info exists sdata($id.)] } {
        puts "$IE-01: $msg lv=$lv id=$id" ; exit 1
    }
}

#---------------------------------------------------------------------

# Routine:    collision_sprites
# Purpose:    Sprite collision utility routine
# Arguments:  id = Sprite ID

# This routine returns a list of zero or more  sprite IDs  for sprites
# that presently overlap the specified sprite.

#---------------------------------------------------------------------

dmproc 10 collision_sprites { id } {
    global layers lv
    return [br::collision sprites $id $layers($lv.spr-list)]
}

#---------------------------------------------------------------------

# Routine:    inventory_ocmoney_get
# Purpose:    Returns player's ocmoney counter
# Arguments:  None

#---------------------------------------------------------------------

dmproc 10 inventory_ocmoney_get {} {
    global gdata
    if { ![info exists gdata(ocmoney)] } { set gdata(ocmoney) 0 }
    return $gdata(ocmoney)
}

#---------------------------------------------------------------------

# Routine:    inventory_ocmoney_add
# Purpose:    Increments player's ocmoney counter
# Arguments:  num = Number to add to ocmoney counter (may be negative)

#---------------------------------------------------------------------

dmproc 10 inventory_ocmoney_add { num } {
    global gdata
    inventory_ocmoney_get
    incr gdata(ocmoney) $num
}

#---------------------------------------------------------------------

# Routine:    inventory_get
# Purpose:    Gets description of player's inventory
# Arguments:  None

# This routine returns a list that describes the player's  current in-
# ventory. The list contains one entry per item (treating groups simi-
# lar to "50 gold coins" as single items).  If the inventory is empty,
# the list returned contains the single string "Empty".

#---------------------------------------------------------------------

dmproc 10 inventory_get {} {
    set iv [list]
    set n  [inventory_ocmoney_get]
    if { $n > 0 } { lappend iv "$n gold coins" }
    if { [llength $iv] == 0 } { lappend iv Empty }
    return $iv
}

#---------------------------------------------------------------------

# Routine:    show_msg
# Purpose:    Displays a message and waits for a keypress
# Arguments:  text = Message text (may be multi-line)

#---------------------------------------------------------------------

dmproc 1 show_msg { text xpos ypos } {
    global layers lv
    global KeyH_Button KeyH_Input
    global KeyI_Button KeyI_Input
    global KeyQ_Button KeyQ_Input
    set stglist [list]

    foreach line [split $text "\n"] {
        regsub -all {\015*\012} $line "" line
        set stg [br::string create]
        set stglist [concat $stglist $stg]
        br::string position $stg $xpos $ypos
        br::string text $stg $line
        br::list add $layers($lv.str-list) $stg
        incr ypos 8
    }

    set done        0
    set arrow_state 1

    while { $done < 1 } {
        set io(1) [br::io fetch 1]
        set io(0) [br::io fetch 0]
        set hkey  [lindex $io($KeyH_Input) 2 $KeyH_Button]
        set ikey  [lindex $io($KeyI_Input) 2 $KeyI_Button]
        set qkey  [lindex $io($KeyQ_Input) 2 $KeyQ_Button]

        if { [lindex $io(0) 7] || $qkey || \
             [br::io has-quit] } { quit_program }
        if { [lindex $io(0) 5] } { set done 1 }

        set horiz [lindex $io(0) 0 0]
        set vert  [lindex $io(0) 0 1]
        set vx [expr { $horiz < 0 ? -1 : ($horiz > 0 ? 1 : 0) }]
        set vy [expr { $vert  < 0 ? -1 : ($vert  > 0 ? 1 : 0) }]

# Undocumented feature:  Some regular keys  will  close the  displayed
# message.

        if { $vx || $vy || $hkey || $ikey } {
            if { $arrow_state == 2 } { set done 1 }
        } else {
            set arrow_state 2
        }

        br::render display
        after 25
    }

    foreach stg $stglist {
        br::list remove $layers($lv.str-list) $stg
        br::string delete $stg
    }

    after 250                 ; # Allow a moment for key to be releas-
                              ; # ed
}

#---------------------------------------------------------------------

# Routine:    display_help
# Purpose:    Displays runtime-help message
# Arguments:  None

# This routine  displays the program's runtime-help message and  waits
# for a keypress.  Enter (or an arrow key)  causes a return  to normal
# operation. Escape or Q quits the program.

#---------------------------------------------------------------------

dmproc 1 display_help {} {
    set    msg ""
    append msg \
" Help:  H  Inventory: I         \r\n"  \
" Pause: H                       \r\n"  \
" Quit:  Escape or Q             \r\n"  \
"                                \r\n"  \
" Press Enter or arrow to resume "

    show_msg $msg 10 50
}

#---------------------------------------------------------------------

# Routine:    display_inventory
# Purpose:    Displays the player's inventory
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 display_inventory {} {
    set InventoryTextWidth 30
    set msg ""
    set inventory [inventory_get]
    lappend inventory ""
    lappend inventory "Press Enter or arrow to resume"

    foreach entry $inventory {
        append msg [format " %-${InventoryTextWidth}s \r\n" $entry]
    }

    show_msg $msg 10 50
}

#---------------------------------------------------------------------

# Routine:    display_msg_startup
# Purpose:    Displays startup-time message
# Arguments:  None

# This routine  displays the program's startup-time message and  waits
# for a keypress.  Enter (or an arrow key)  causes a return  to normal
# operation. Escape or Q quits the program.

#---------------------------------------------------------------------

dmproc 1 display_msg_startup {} {
    global NameAndRevision
    set FmtName [format " %-20s " $NameAndRevision]

    set    msg ""
    append msg \
"$FmtName\r\n"                \
"\r\n"                        \
" Welcome to Hell!     \r\n"  \
" Use  arrow  keys  to \r\n"  \
" move,  Ctrl or Space \r\n"  \
" to shoot, and Esc or \r\n"  \
" Q to quit.  Find the \r\n"  \
" exit to win.         \r\n"  \
"\r\n"                        \
" Press Enter to begin "

    show_msg $msg 75 70
}

#---------------------------------------------------------------------

# Routine:    display_wisdom
# Purpose:    Displays random wisdom
# Arguments:  None

# This routine displays a random quote (or "fortune") and  waits for a
# keypress.  Enter (or an arrow key) causes a return  to normal opera-
# tion. Escape or Q quits the program.

#---------------------------------------------------------------------

dmproc 1 display_wisdom {} {
    global wisdom_list wisdom_num wisdom_lz77_base64

    if { ![info exists wisdom_list] } {
        set wisdom_txt [lz77_base64_decode $wisdom_lz77_base64]
        regsub -all {\n%%\n}    $wisdom_txt "\001" wisdom_txt
        regsub -all {\015*\012} $wisdom_txt "\012" wisdom_txt
        regsub -all {[\001]+$}  $wisdom_txt ""     wisdom_txt
        set wisdom_list [split  $wisdom_txt "\001"]
        set wisdom_num  [llength $wisdom_list]
    }

    set wisdom_idx [expr  [random_int 1 $wisdom_num] - 1]
    set text       [lindex $wisdom_list $wisdom_idx]
    set lines      [split $text "\012"]

    set msg ""
    append msg [format " %-36s\r\n" "Contents of scroll:"     ]
    append msg [format " %-36s\r\n" ""                        ]

    foreach line $lines {
        append msg [format " %-36s" $line]
        append msg "\r\n"
    }

    append msg [format " %-36s\r\n" ""                        ]
    append msg [format " %-36s\r\n" "Press Enter to continue" ]

    show_msg $msg 10 60
}

#---------------------------------------------------------------------

# Routine:    (xproc) get_target_dx_dy
# Purpose:    Gets X-Y sprite deltas
# Arguments:  base_id   = Sprite ID for a base   object
#             target_id = Sprite ID for a target object
#             dx        = X output (passed by reference)
#             dy        = Y output (passed by reference)

# This is  an  "xproc" routine;  i.e.,  it supports  "&variable"-style
# pass-by-reference.

# This routine sets dx (in the caller's scope) equal to the target ob-
# ject's  X-coordinate minus the base object's  X-coordinate.  It also
# sets dy (in the  caller's scope)  equal  to the  target object's  Y-
# coordinate minus the base object's Y-coordinate.

#---------------------------------------------------------------------

if { $DebugLevel > 1 } { puts "define get_target_dx_dy" }

xproc get_target_dx_dy { base_id target_id &dx &dy } {
    global sdata
    set base_position [br::sprite pos $base_id]
    set base_x [lindex $base_position 0]
    set base_y [lindex $base_position 1]

    set target_x $sdata($target_id.px)
    set target_y $sdata($target_id.py)
    set dx [expr $target_x - $base_x]
    set dy [expr $target_y - $base_y]
}

#---------------------------------------------------------------------

# Routine:    random_position_sprite
# Purpose:    Randomly positions a sprite
# Arguments:  id = Sprite ID

# This routine randomly positions the specified sprite.  The new loca-
# tion is guaranteed not to intersect  any  walls.  Additionally,  the
# move is guaranteed not to produce a  collision  where  either sprite
# involved  belongs to any  of the  classes  listed in  "list_classes_
# bounce".

#---------------------------------------------------------------------

dmproc 5 random_position_sprite { id } {
    global gdata layers lv sdata
    verify_sprite_exists $rtn $id

    set isolate_this 0        ; # Flag: Must isolate this object
                              ; # Get sprite class
    set objclass [get_sprite_class $id]

                                # Future change: This loop could prob-
                                # ably be replaced with "lsearch" code
    foreach callbase $gdata(list_classes_bounce) {
        if { $objclass eq $callbase } { set isolate_this 1 }
    }
                                # Is position predetermined?
    set forceposn [get_object_param $id forceposn]

# The loop-count limit used here is arbitrary.  However,  it should be
# an integer, and it should probably lie somewhere in the range of 100
# to 1000.

    for { set ii 1 } { $ii <= 500 } { incr ii } {
        if { $forceposn > 0 } {
            set xpos [get_object_param $id xpos]
            set ypos [get_object_param $id ypos]
        } else {
            set xpos [expr { int(rand()*($layers($lv.width)  * 8)) }]
            set ypos [expr { int(rand()*($layers($lv.height) * 8)) }]
        }

        br::sprite pos $id $xpos $ypos

        if { [lindex [br::collision map \
            $id $layers($lv.map) 1] 0] } { continue }
        set okay 1
        set nobounce1 [get_object_param $id nobounce]

        foreach tgt [collision_sprites $id] {
            if { $nobounce1 } { break }
            set tgt_id [lindex $tgt 1]
            set otherclass [get_sprite_class $tgt_id]
            set nobounce2 [get_object_param $tgt_id nobounce]
            if { $nobounce2 } { continue }
            if { $isolate_this } { set okay 0 }
            if { !$okay } { break }

            foreach callbase $gdata(list_classes_bounce) {
                if { $otherclass eq $callbase } {
                    set okay 0 ; break
                }
            }
        }

        if { $okay } { return }
    }

    puts "$IE-01"             ; # Shouldn't reach this point
    exit 1
}

#---------------------------------------------------------------------

# Routine:    handle_limbo
# Purpose:    Handles a special case
# Arguments:  id = Sprite ID

# This is a support routine  for "move_sprite" and "run_ocplayer".  It
# handles special cases related to the Limbo world  and/or  situations
# where the player can travel through walls.

#---------------------------------------------------------------------

dmproc 10 handle_limbo { id } {
    global gdata layers lv sdata WorldKeyStart

    if { ![info exists gdata($lv.is_empty)] || \
                     !$gdata($lv.is_empty) } {
        set ocplayer_id $gdata($lv,ocplayer_id)
        if { $id ne $ocplayer_id    } { return }
        if { ![is_ocplayer_driving] } { return }
    }

    while { 1 } {
        set max_x [expr ($layers($lv.width)  * 8) - 1]
        set max_y [expr ($layers($lv.height) * 8) - 1]

        set MyPosition [br::sprite pos $id]
        set my_x [lindex $MyPosition 0]
        set my_y [lindex $MyPosition 1]

        if { ($my_x > 0) && ($my_x < $max_x) && \
             ($my_y > 0) && ($my_y < $max_y) } { return }
        random_position_sprite $id
    }
}

#---------------------------------------------------------------------

# Routine:    move_sprite
# Purpose:    Moves an autonomous sprite
# Arguments:  id = Sprite ID

# $id should specify a sprite ID for a mobile autonomous sprite; i.e.,
# a mobile non-player  sprite such as an ockarkinos, an ocmedical,  or
# an ocbullet.

# This routine  uses "br::motion single" to move the specified sprite.
# It also  handles some  special cases  (through a  call  to  "handle_
# limbo"; for more information, see that routine).

#---------------------------------------------------------------------

dmproc 100 move_sprite { id } {
    br::motion single $id
    handle_limbo $id
}

#---------------------------------------------------------------------

# Routine:    setup_map_fixup_table
# Purpose:    Support routine for "make_random_map"
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 setup_map_fixup_table {} {
    global MapFixupTable
    set    MapFixupTable(initialized)  1

    set MapFixupTable(1--1)             {   ; # Edits a 2x2 square
        set x0y0 "-" ; set newmap($x0:$y0) "-"
    }
    set MapFixupTable(-11-)             {   ; # Edits a 2x2 square
        set x0y1 "-" ; set newmap($x0:$y1) "-"
    }
    set MapFixupTable(-11-1-)           {   ; # Edits a 3x2 rectangle
        set x1y0 "-" ; set newmap($x1:$y0) "-"
    }
    set MapFixupTable(1111-1111)        {   ; # Edits a 3x3 square
        set x1y1 "1" ; set newmap($x1:$y1) "1"
    }
    set MapFixupTable(11-1-1111)        {   ; # Edits a 3x3 square
        set x1y1 "1" ; set newmap($x1:$y1) "1"
    }
    set MapFixupTable(1-1111---)        {   ; # Edits a 3x3 square
        set x1y1 "1" ; set newmap($x1:$y1) "1"
    }
    set MapFixupTable(1--1-1111)        {   ; # Edits a 3x3 square
        set x1y0 "-" ; set newmap($x1:$y0) "-"
    }
    set MapFixupTable(1-11-1111)        {   ; # Edits a 3x3 square
        set x0y1 "-" ; set newmap($x0:$y1) "-"
        set x2y1 "-" ; set newmap($x2:$y1) "-"
    }
    set MapFixupTable(11111--11111)     {   ; # Edits a 4x3 rectangle
        set x1y1 "1" ; set newmap($x1:$y1) "1"
        set x2y1 "1" ; set newmap($x2:$y1) "1"
    }
    set MapFixupTable(1-11111-----)     {   ; # Edits a 4x3 rectangle
        set x2y1 "-" ; set newmap($x2:$y1) "-"
    }
    set MapFixupTable(----111-1-11)     {   ; # Edits a 4x3 rectangle
        set x2y1 "-" ; set newmap($x2:$y1) "-"
    }
    set MapFixupTable(11--1111----)     {   ; # Edits a 4x3 rectangle
        set x1y1 "-" ; set newmap($x1:$y1) "-"
    }
    set MapFixupTable(----111---1---11) {   ; # Edits a 4x4 square
        set x1y1 "-" ; set newmap($x1:$y1) "-"
    }
    set MapFixupTable(111---1--11-11--) {   ; # Edits a 4x4 square
        set x1y2 "-" ; set newmap($x1:$y2) "-"
    }
    set MapFixupTable(111---1--11-1---) {   ; # Edits a 4x4 square
        set x1y2 "-" ; set newmap($x1:$y2) "-"
    }
    set MapFixupTable(-11---1-111-----) {   ; # Edits a 4x4 square
        set x2y1 "-" ; set newmap($x2:$y1) "-"
    }
    set MapFixupTable(-1---1---111----) {   ; # Edits a 4x4 square
        set x2y2 "-" ; set newmap($x2:$y2) "-"
    }
    set MapFixupTable(11111--11--11111) {   ; # Edits a 4x4 square
        set x1y1 "1" ; set newmap($x1:$y1) "1"
        set x1y2 "1" ; set newmap($x1:$y2) "1"
        set x2y1 "1" ; set newmap($x2:$y1) "1"
        set x2y2 "1" ; set newmap($x2:$y2) "1"
    }
}

#---------------------------------------------------------------------

# Routine:    make_random_map
# Purpose:    Creates a random map
# Arguments:  width  = Map width  (in cells)
#             height = Map height (in cells)

# "make_random_map" returns a random map as a text string.  The string
# contains $width * $height characters.  Each character  indicates the
# contents of one map cell.  "1" represents a wall cell and "-" repre-
# sents an empty cell.

# The string is organized as follows: row 1, col 1; row 1, col 2; etc.
# through row 1, col $width;  row 2, col 1; row 2, col 2; etc. through
# row $height, col $width.

#---------------------------------------------------------------------

dmproc 1 make_random_map { width height } {
    global RandomMapFollow  RandomMapPoints
    global RandomMapMinSep1 RandomMapMinSep2
    global MapFixupTable

    if { ![info exists MapFixupTable(initialized)] } {
        setup_map_fixup_table
    }

    set area [expr $width * $height]
    set np   [expr int (($area / 100) * $RandomMapPoints)]

    for { set y 1 } { $y <= $height } { incr y } {
        for { set x 1 } { $x <= $width } { incr x } {
            set newmap($x:$y) "-"
        }
    }

    for { set x 1 } { $x <= $width   } { incr x } \
        { set newmap($x:1)       "1" }
    for { set x 1 } { $x <= $width   } { incr x } \
        { set newmap($x:$height) "1" }
    for { set y 1 } { $y <= $height  } { incr y } \
        { set newmap(1:$y)       "1" }
    for { set y 1 } { $y <= $height  } { incr y } \
        { set newmap($width:$y)  "1" }

    for { set p 1 } { $p <= $np } { incr p } {
        set x  [expr 1 + int (rand() * $width  )]
        set y  [expr 1 + int (rand() * $height )]
        set nf [expr 1 + int (rand() * $RandomMapFollow )]
        set reject 0

        if { ($x == 1) || ($x == $width ) ||
             ($y == 1) || ($y == $height) } { continue }

        for { set dx -$RandomMapMinSep1 } \
            { $dx  <= $RandomMapMinSep1 } { incr dx } {
            for { set dy -$RandomMapMinSep1 } \
                { $dy  <= $RandomMapMinSep1 } { incr dy } {

                set nx [expr $x + $dx]
                set ny [expr $y + $dy]

                if { ($nx <= 1) || ($nx >= $width  ) ||
                     ($ny <= 1) || ($ny >= $height ) } {
                    continue
                }

                if { $newmap($nx:$ny) eq "1" } {
                    set reject 1; break
                }
            }
        }

        if {$reject} { continue }
        set newmap($x,$y) "1"

        for { set i 1 } { $i < $nf } { incr i } {
            set reject 0
            set dir [expr int (rand() * 4)]

            switch $dir {
                0 { set vx -1; set vy  0 }
                1 { set vx  1; set vy  0 }
                2 { set vx  0; set vy -1 }
                3 { set vx  0; set vy  1 }
            }

            if { $vx < 0 } {
                set xa [expr $x - 1]
                set xz [expr $x - $RandomMapMinSep2]
                if { $xa <= 1 } { set reject 1; break }

                for { set nx $xa } { $nx >= $xz } { incr nx -1 } {
                    if { $nx <= 1 } { break }
                    set ya [expr $y - 1]; set yz [expr $y + 1]

                    for { set ny $ya } { $ny < $yz } { incr ny } {
                        if { ($ny >= 1) && ($ny <= $height) &&
                             $newmap($nx:$ny) eq "1" } {
                            set reject 1; break
                        }
                    }
                }
            }

            if { $vx > 0 } {
                set xa [expr $x + 1]
                set xz [expr $x + $RandomMapMinSep2]
                if { $xa >= $width } { set reject 1; break }

                for { set nx $xa } { $nx < $xz } { incr nx } {
                    if { $nx >= $width } { break }
                    set ya [expr $y - 1]; set yz [expr $y + 1]

                    for { set ny $ya } { $ny < $yz } { incr ny } {
                        if { ($ny >= 1) && ($ny <= $height) &&
                             $newmap($nx:$ny) eq "1" } {
                            set reject 1; break
                        }
                    }
                }
            }

            if { $vy < 0 } {
                set ya [expr $y - 1]
                set yz [expr $y - $RandomMapMinSep2]
                if { $ya <= 1 } { set reject 1; break }

                for { set ny $ya } { $ny >= $yz } { incr ny -1 } {
                    if { $ny <= 1 } { break }
                    set xa [expr $x - 1]; set xz [expr $x + 1]

                    for { set nx $xa } { $nx < $xz } { incr nx } {
                        if { ($nx >= 1) && ($nx <= $width) &&
                             $newmap($nx:$ny) eq "1" } {
                            set reject 1; break
                        }
                    }
                }
            }

            if { $vy > 0 } {
                set ya [expr $y + 1]
                set yz [expr $y + $RandomMapMinSep2]
                if { $ya >= $width } { set reject 1; break }

                for { set ny $ya } { $ny < $yz } { incr ny } {
                    if { $ny >= $height } { break }
                    set xa [expr $x - 1]; set xz [expr $x + 1]

                    for { set nx $xa } { $nx < $xz } { incr nx } {
                        if { ($nx >= 1) && ($nx <= $width) &&
                             $newmap($nx:$ny) eq "1" } {
                            set reject 1; break
                        }
                    }
                }
            }

            if { $reject == 0 } {
                incr x $vx
                incr y $vy
                set newmap($x:$y) "1"
            }

            if { ($x <= 1) || ($x >= $width ) ||
                 ($y <= 1) || ($y >= $height) } { break }
        }
    }

    set hm1 [expr $height - 1]
    set wm1 [expr $width  - 1]

    for { set x 2 } { $x < $width  } { incr x } \
        { set newmap($x:2)    "-"  }
    for { set x 2 } { $x < $width  } { incr x } \
        { set newmap($x:$hm1) "-"  }
    for { set y 2 } { $y < $height } { incr y } \
        { set newmap(2:$y)    "-"  }
    for { set y 2 } { $y < $height } { incr y } \
        { set newmap($wm1:$y) "-"  }

    set pass  0
    set retry 1

    if { $DebugLevel > 1 } {
        set tmpx ""
        for { set y 1 } { $y <= $height } { incr y } {
            for { set x 1 } { $x <= $width } { incr x } {
                append tmpx $newmap($x:$y)
            }

            append tmpx "\n"
        }

        puts "$rtn: pre-cleanup map:"
        puts $tmpx
    }

    while 1 {
        incr pass
        if { ($retry == 0) || ($pass > 3) } { break }
        set retry 0

        for { set y 3 } { $y < $height } { incr y } {
            for { set x 3 } { $x < $width } { incr x } {

set x3y3 "?" ; set x2y3 "?" ; set x1y3 "?" ; set x0y3 "?"
set x3y2 "?" ; set x2y2 "?" ; set x1y2 "?" ; set x0y2 "?"
set x3y1 "?" ; set x2y1 "?" ; set x1y1 "?" ; set x0y1 "?"
set x3y0 "?" ; set x2y0 "?" ; set x1y0 "?" ; set x0y0 "?"

                set x0 $x
                set y0 $y
                set x1 [expr $x - 1]
                set y1 [expr $y - 1]
                set x2 [expr $x - 2]
                set y2 [expr $y - 2]

                set x1y1 $newmap($x1:$y1)
                set x0y1 $newmap($x0:$y1)
                set x1y0 $newmap($x1:$y0)
                set x0y0 $newmap($x0:$y0)

                set x2y2 $newmap($x2:$y2)
                set x2y1 $newmap($x2:$y1)
                set x2y0 $newmap($x2:$y0)
                set x1y2 $newmap($x1:$y2)
                set x0y2 $newmap($x0:$y2)

                if { $x > 3 } {
                    set x3 [expr $x - 3]
                    set x3y2 $newmap($x3:$y2)
                    set x3y1 $newmap($x3:$y1)
                    set x3y0 $newmap($x3:$y0)
                }

                if { $y > 3 } {
                    set y3 [expr $y - 3]
                    set x2y3 $newmap($x2:$y3)
                    set x1y3 $newmap($x1:$y3)
                    set x0y3 $newmap($x0:$y3)
                }

                if { ($x > 3) && ($y > 3) } {
                    set x3 [expr $x - 3]
                    set y3 [expr $y - 3]
                    set x3y3 $newmap($x3:$y3)
                }

# The cleanup algorithm used below is based on  squares and horizontal
# rectangles.  Presently, there's no provision for working with verti-
# cal rectangles here.

# BlockOf04 is a string that represents the 2x2 square of 4 characters
# whose lower-right corner is at $x,$y.

# BlockOf06H  is a string that represents the 3x2 horizontal rectangle
# of 6 characters whose lower-right corner is at $x,$y.

# BlockOf09 is a string that represents the 3x3 square of 9 characters
# whose lower-right corner is at $x,$y.

# BlockOf12H  is a string that represents the 4x3 horizontal rectangle
# of 12 characters whose lower-right corner is at $x,$y.

# BlockOf16  is a string that represents the  4x4 square of 16 charac-
# ters whose lower-right corner is at $x,$y.

# The loop-count limit used here is arbitrary.  However,  it should be
# an integer, and it should probably lie somewhere in the range of  25
# to 100.

                for { set ii 1 } { $ii <= 50 } { incr ii } {

                    set    BlockOf04    ""
                    append BlockOf04    $x1y1 $x0y1 \
                                        $x1y0 $x0y0

                    set    BlockOf06H   ""
                    append BlockOf06H   $x2y1 $x1y1 $x0y1 \
                                        $x2y0 $x1y0 $x0y0

                    set    BlockOf09    ""
                    append BlockOf09    $x2y2 $x1y2 $x0y2 \
                                        $x2y1 $x1y1 $x0y1 \
                                        $x2y0 $x1y0 $x0y0

                    set    BlockOf12H   ""
                    append BlockOf12H   $x3y2 $x2y2 $x1y2 $x0y2 \
                                        $x3y1 $x2y1 $x1y1 $x0y1 \
                                        $x3y0 $x2y0 $x1y0 $x0y0

                    set    Blockof16    ""
                    append BlockOf16    $x3y3 $x2y3 $x1y3 $x0y3 \
                                        $x3y2 $x2y1 $x1y2 $x0y1 \
                                        $x3y1 $x2y1 $x1y1 $x0y1 \
                                        $x3y0 $x2y0 $x1y0 $x0y0

                    set modified 0

                    foreach block {
                        $BlockOf16  $BlockOf12H $BlockOf09
                        $BlockOf06H $BlockOf04
                    } {
                        set block [expr $block]
                        if { [info exists MapFixupTable($block)] } {
                                   eval  $MapFixupTable($block)
                                   set modified 1
                                   break
                        }
                    }

                    if { !$modified } break
                }
            }
        }
    }

    if { $DebugLevel > 1 } {
        set tmpx ""
        for { set y 1 } { $y <= $height } { incr y } {
            for { set x 1 } { $x <= $width } { incr x } {
                append tmpx $newmap($x:$y)
            }

            append tmpx "\n"
        }

        puts "$rtn: final map:"
        puts $tmpx
    }

    set tmp ""
    for { set y 1 } { $y <= $height } { incr y } {
        for { set x 1 } { $x <= $width } { incr x } {
            append tmp $newmap($x:$y)
        }
    }

    return $tmp
}

#---------------------------------------------------------------------

# Routine:    setup_background
# Purpose:    Sets up the program's "background" layer
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 setup_background {} {
    global fr1data
    global BGTileWidth BGTileHeight BGWidth BGHeight
    global BRICKAPI FRAFMTRGB NRDIGITS

    set n1  [string length $fr1data]
    set n2  [expr $BGTileWidth * $BGTileHeight * $NRDIGITS]
    if { $n1 != $n2 } {
        puts "$IE-01" ; exit 1
    }

    set t1  [br::tile create]
    set fr1 [br::frame create $FRAFMTRGB \
                $BGTileWidth $BGTileHeight \
                [binary format H$n1 $fr1data]]
    br::tile add-frame $t1 $fr1

    set layer_id   [br::layer add]
    set layers(bg) $layer_id

    if { $BRICKAPI < 5300 } {
        set info_list           [br::layer info $layer_id]
        set layers(bg.spr-list) [lindex $info_list 0]
        set layers(bg.map)      [lindex $info_list 1]
        set layers(bg.str-list) [lindex $info_list 2]
    } else {
        set layers(bg.spr-list) [br::layer sprite-list $layer_id]
        set layers(bg.map)      [br::layer map         $layer_id]
        set layers(bg.str-list) [br::layer string-list $layer_id]
    }

    br::map tile-size $layers(bg.map) $BGTileWidth $BGTileHeight
    br::map tile      $layers(bg.map) 1 $t1
    br::map size      $layers(bg.map) $BGWidth $BGHeight

    br::map set-data $layers(bg.map) \
        [binary format H[expr {4 * $BGWidth * $BGHeight}] \
        [string repeat 0100 [expr {$BGWidth * $BGHeight}]]]
}

#---------------------------------------------------------------------

# Routine:    setup_keyboard
# Purpose:    Sets up keyboard operations
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 setup_keyboard {} {
                                # Watch for the "h" key
    global         KeyH_Input         KeyH_Button  KeyH_SDLCode
    br::io assign $KeyH_Input button $KeyH_Button $KeyH_SDLCode

                                # Watch for the "i" key
    global         KeyI_Input         KeyI_Button  KeyI_SDLCode
    br::io assign $KeyI_Input button $KeyI_Button $KeyI_SDLCode

                                # Watch for the "q" key
    global         KeyQ_Input         KeyQ_Button  KeyQ_SDLCode
    br::io assign $KeyQ_Input button $KeyQ_Button $KeyQ_SDLCode
                                # Watch for the space key
    global         KeySpace_Input        \
                   KeySpace_Button KeySpace_SDLCode
    br::io assign $KeySpace_Input button \
                  $KeySpace_Button $KeySpace_SDLCode
}

#---------------------------------------------------------------------

# Routine:    make_proto_sprite
# Purpose:    Creates a sprite prototype
# Arguments:  Explained below

#---------------------------------------------------------------------

# 1. Usage is straightforward. Use calls similar to the following:
#
# make_proto_sprite square 4 4 1 1 \
#     [list $TRANSPARRGB $RED] move {
# ****
# *..*
# ****
# }

# 2. Arguments are:
#
# Sprite-type name.  Presently,  this should be an  object-class name,
# though special cases may arise in the future.
#
# Width in pixels and height in pixels
# Initial X-scale factor
# Initial Y-scale factor
# A list of color values    as explained below
# A motion-related argument as explained below
# A sprite drawn as inline text as shown above

# 3. Use "*" to represent a foreground pixel, "." to represent a back-
# ground pixel, and/or digits "0" through "9", lower-case letters  "a"
# through  "z", and upper-case letters  "A" through "Z"  to  represent
# pixels of up to 62 additional types, for a total of 64 possible col-
# ors.

# The terms  "foreground" and "background" are simply  convenient lab-
# els. In this context, they have no fixed meaning.

# Restrictions:  A digit can't be used in the inline-text  drawing un-
# less all preceding digits are also used.  A lower-case  letter can't
# be used unless all digits and all preceding lower-case  letters  are
# also used. An upper-case letter can't be used unless all digits, all
# lower-case letters,  and all preceding  upper-case letters  are also
# used.

# The color list  should contain a set of  six-digit  hex color codes.
# The list may be from 2 to 38 elements long. The first element speci-
# fies  the background color and the  second one specifies  the  fore-
# ground color. If subsequent elements are present,  they  specify the
# colors associated   with digits  "0",  "1", "2", etc.  through  "9",
# "a", "b", "c", etc. through  "z", and  "A", "B",  "C", etc.  through
# "Z".

# 4. For a normal mobile sprite, the motion argument should be "move".
# This installs the following Brick Engine motion program:
#
#     { add xpos, xvel
#       add ypos, yvel }

# For a  stationary sprite, the argument should be either  "nomove" or
# "stationary", though "move" presently works as well.

# For special cases,  pass any  desired  motion program instead of one
# of these keywords.  The  motion program should  consist of  a curly-
# brace block  that contains  appropriate  commands  (see the  example
# shown above).  For more information,  see the Brick Engine API docu-
# mentation.

# 5. Two or more  "make_proto_sprite" calls  may be made  for the same
# sprite type.  If this is done, the result is a sprite prototype that
# contains multiple frames (one frame per call).

# 6. On exit from a  "make_proto_sprite" call,  the  following  global
# variables are set ($name stands for the sprite-type name):
#
#     proto($name)              # Sprite prototype
#
#     gdata($name.num_frames)   # Number of frames in sprite (1+)
#
#                               # Frame index for the first frame that
#                               # was added to the current sprite pro-
#                               # totype  (subsequent calls don't cha-
#                               # nge this)
#     gdata($name.frame_index.default)
#
#                               # Frame index  for the  frame that was
#                               # just added
#     gdata($name.frame_index.newest)
#
#     gdata($name.frame_index)  # Current frame index (same as default
#                               # index until higher-level code chang-
#                               # es it)

#---------------------------------------------------------------------

dmproc 1 make_proto_sprite { \
    name width height x_scale y_scale colors move drawing } {
    global proto BRICKAPI FRAFMTTRA NRDIGITS TRANSPARRGB
    global gdata
                                # Remove white space  and quotes  from
                                # the sprite drawing
    regsub -all {[ "'\n\r\t]+}  $drawing  "" drawing

# This block is a  safety measure. It verifies that the dimensions and
# drawing provided are consistent.

    set area [expr $width * $height  ]
    set xlen [string length $drawing ]

    if { $area != $xlen } {
        puts "$IE-01: $rtn:\nDimensions and drawing\
specified for"
        puts "$name are inconsistent:"
        puts "Width: $width Height: $height Text: $drawing"
        exit 1
    }

# This block  is a  safety measure.  It verifies that  all elements in
# $colors are integers and converts  them to the appropriate number of
# hex digits.

    set clen [llength $colors]

    for { set ii 0 } { $ii < $clen } { incr ii } {
        set color [lindex $colors $ii]
        regsub {^0x} $color "" color
        set decimal_value [expr 0x$color]

        set OPACITY FF
        if { $color eq $TRANSPARRGB } { set OPACITY 00 }
        if { $BRICKAPI < 5400 } { set OPACITY "" }

        set color [format "%0${NRDIGITS}x${OPACITY}" $decimal_value]
        set colors [lreplace $colors $ii $ii $color]
    }
                                # Build a character-to-color map
    set CharMap [list "." [lindex $colors 0] "*" [lindex $colors 1]]

    set lcaval [scan a %c]    ; # ASCII value of letter "a"
    set ucaval [scan A %c]    ; # ASCII value of letter "A"
    set NumDigits    10       ; # No. of decimal digits     (10)
    set NumLCLetters 26       ; # No. of lower-case letters (26)
    set NumUCLetters 26       ; # No. of upper-case letters (26)
                              ; # No. of  possible  color chars  below
                              ; # the upper-case letters
    set NumCharsBelowUpper [expr $NumDigits + $NumLCLetters]
                              ; # No. of possible color chars (64)
    set NumColorChars \
        [expr $NumDigits + $NumLCLetters + $NumUCLetters]

    for { set ii 1 } { $ii <= $NumColorChars } { incr ii } {
        set jj [expr $ii + 1]
        set ColorHex [lindex $colors $jj]
        if { $ColorHex eq "" } { break }
        set ColorChar [expr $ii - 1]

        if { $ii > $NumDigits } {
            set ColorChar [format %c \
                [expr $lcaval + $ii - ($NumDigits + 1)]]
        }

        if { $ii > $NumCharsBelowUpper } {
            set ColorChar [format %c \
                [expr $ucaval + $ii - ($NumCharsBelowUpper + 1)]]
        }

        set CharMap [concat $CharMap $ColorChar $ColorHex]
    }
                                # Create hex version of sprite shape
    set drawing_hex [string map $CharMap $drawing]
                                # Create a frame for the sprite
    if { $BRICKAPI < 5400 } {
        global CHROMA_R CHROMA_G CHROMA_B
        set frame [br::frame create $FRAFMTTRA $width $height  \
            [binary format H* $drawing_hex] \
            $CHROMA_R $CHROMA_G $CHROMA_B]
    } else {
        set frame [br::frame create $FRAFMTTRA $width $height  \
            [binary format H* $drawing_hex]]
    }
                                # Flag: New sprite
    set is_new [expr [info exists proto($name)] ? 0 : 1]

                                # Set up the requested prototype
    if { $is_new } {
        set proto($name) [br::sprite create]
        if { $DebugLevel } { puts "proto($name)=$proto($name)" }
        if { $BRICKAPI >= 5400 } {
            br::sprite scale $proto($name) $x_scale $y_scale
        }

        br::sprite collides $proto($name) box
        set  gdata($name.num_frames) 1
    } else {
        incr gdata($name.num_frames)
    }

    set frame_index [br::sprite add-frame $proto($name) $frame]
    set gdata($name.frame_index.newest) $frame_index

    if { ![info exists gdata($name.frame_index)] } {
                   set gdata($name.frame_index)         $frame_index
                   set gdata($name.frame_index.default) $frame_index
    }

    set LocalShadows [get_class_param $name dropshadow]

    if { ($BRICKAPI >= 5400) && $LocalShadows } {
        br::sprite add-subframe $proto($name) \
        $frame_index \
        [br::frame effect $frame dropshadow 2 2 4 40 40 40]
    }

    br::sprite bound $proto($name) $frame_index 0 0 $width $height

    if { $is_new } {

        if { $move eq "move" } {
            br::sprite load-program $proto($name) \
                { add xpos, xvel
                  add ypos, yvel }
        } elseif { $move eq "nomove"     } {
        } elseif { $move eq "stationary" } {
        } else {
            br::sprite load-program $proto($name) $move"
        }
    }

    return $frame_index
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocbullet
# Purpose:    Creates a sprite prototype: ocbullet class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocbullet

dmproc 1 make_proto_ocbullet {} {
    global BG_BULLET FG_BULLET
    make_proto_sprite ocbullet \
        1 1 1 1 [list 0 0] move {
*
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_occar
# Purpose:    Creates a sprite prototype: occar class
# Arguments:  None

# Note: The associated sprite should be a small car driving left.  See
# "make_proto_ocplayer".

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) occar

dmproc 1 make_proto_occar {} {
    global TRANSPARRGB
    make_proto_sprite occar \
        22 9 1 1 [list $TRANSPARRGB \
        3A6D89  A2A2A3  4F778E  4A7C98  8E9EA9  161514 \
        035D88  094B71  9F9FA0  445058  233845  87959F \
        476472  718693  9AA6AE  3D7594  2E7295  0B4A6D \
        1D313D  4F5A62  34617E  01628B  1F6182  34444C \
        1F5874  2F4B59  0C3244  628CA0  648699  145C81 \
        365063] \
    move {
........r*******q.....
........*..**...b*r...
.....3a*c..**...12*r..
..dr1e11222**e222efsq.
.2t9n5555k55555k*9hjl0
cp44n*5555kk5555p44nlj
84ma4msg6666g6gb4m34lo
.4i84m70707000704i84..
..44.............44...
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_occow
# Purpose:    Creates a sprite prototype: occow class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) occow

dmproc 1 make_proto_occow {} {
    global TRANSPARRGB
    make_proto_sprite occow \
        12 7 1 1 [list $TRANSPARRGB 000000 FFFFFF 808080] \
    move {
*1..........
.*..........
*0********1.
****00***.*1
..*0**00*..*
..*******...
..*.....*...
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_occross
# Purpose:    Creates a sprite prototype: occross class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) occross

dmproc 1 make_proto_occross {} {
    global TRANSPARRGB
    make_proto_sprite occross \
        8 13 1 1 [list $TRANSPARRGB CCCC00] move {
...**...
...**...
...**...
********
********
...**...
...**...
...**...
...**...
...**...
...**...
...**...
...**...
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocdog
# Purpose:    Creates a sprite prototype: ocdog class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocdog

dmproc 1 make_proto_ocdog {} {
    global TRANSPARRGB
    make_proto_sprite ocdog \
        17 13 1 1 [list $TRANSPARRGB \
        FFFFFF  D2A394  C68A79  AA0000  E8CAC1  FFEFE8 \
        FFEBE4  F1CFC4  EDCFC6  CB9C8D  C39B8E  BB9488 \
        AD796A  D3AEA3  FFFAF8  2B0300  C09183  A43C1D \
        8A4A36  FAE0D9  B88879  AF877A  D8B4AA  E0BCB2 \
        C79F94  8E4E3A  000000] \
    move {
.....pppp........
.....pppp........
pp.....ppooo.....
ppooooo189nbo....
ppkalf3pp**5joppp
oi5**d*po***4oppp
o*********pp*oepp
o*********po*o.pp
o************o.pp
ocm0*********o...
.22h********7o...
.22hooo****6oo...
.22h..oooogoo....
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocflames
# Purpose:    Creates a sprite prototype: ocflames class
# Arguments:  None

#---------------------------------------------------------------------

# This is a multi-frame sprite. The sprite's frames are used for anim-
# ation, in this case, as opposed to multiple shapes.

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocflames

dmproc 1 make_proto_ocflames {} {
    global TRANSPARRGB

    # Frame #1, index 0
    make_proto_sprite ocflames \
        45 27 1 1 [list $TRANSPARRGB \
        FF0000  800000  808000  FFFF00  CCCCCC  FFFFFF \
        000000] \
    move {
.............................................
.............................................
.......000...................................
......0000..........0..................0.....
.000000000....0...0000............000.000....
0000000*00...00000000..........00000000000.00
000000*000..000000000..........00000000000000
000000000000000000000.........000000000000000
0000**000000000000000...0000.0000000000000000
000***00000*000000000000000000000000000*00000
00****000****0000**000000000000*0000000*00000
00****000******0***00**0000000**0000000**0000
******************000**0000000**000000***000*
******************00***00***00***0**00**0000*
******************00*********0******00*00000*
***********************************000000*00*
*****************0*************1*****0****00*
*****221*********0*********1***********22*00*
*****222****************1*22***2******222****
*0****22*22***12**21**22222***2221***2221****
*0***122*22*2222*121*222222**2222***22221*212
1*****2222222222*222222122**12222***2222*1*22
******2222222222*222222*22*212222*222221***22
2122222222**122*222322212**222221222222***2**
2222224222***222322222222*1*2*22**2222221*222
22*2224*22***22232222*22*20*024***222223*1222
2214*24*42*004114222*0*25350*34*22312***02222
    }

    # Frame #2, index 1
    make_proto_sprite ocflames \
        45 27 1 1 [list $TRANSPARRGB \
        FF0000  800000  808000  FFFF00  CCCCCC  FFFFFF \
        000000] \
    move {
.............................................
.............................................
.............................................
..............................0..............
...0000...000.....00.........000.............
..000000.00000...0000........000000..000.....
.0000000.0**00..00000.00....000000000000.....
0000000000**00.00*0000000...00000000000000000
0*0000000***000**00000000.00000**00000*000000
**0000000***000**0000000000000***00000*000***
**0000000**0000*0000000000000****00000*0*****
*00000000**000**0000000*00*******00000*******
*000*0000*000**0000000***********0050********
000***000*00***000000**0*********0000********
00****00*********000***0**********00******000
00****0**********000***0*****************000*
***************2*00****0*********1**2****00**
**************22*0*******2*******2**2***00***
**************22*0*******2******22221****0***
*******1******22***2*****1***12*2222****0**0*
*******21***2122**12*****12*222**22***2*0****
2******22**2222***22222**222222**22***2***2**
***11*222*22222*222222222122221**222*22**12**
22*222222*232*1222222222222222*222222222*222*
222222*222321*222332232*222222*222222222*3222
*1222*2*224***22242234*0222*222212*12*322232*
**22222*213*2***24*32300223*2*2201*22*4442420
    }

    # Frame #3, index 2
    make_proto_sprite ocflames \
        45 27 1 1 [list $TRANSPARRGB \
        FF0000  800000  808000  FFFF00  CCCCCC  FFFFFF \
        000000] \
    move {
.............................................
.........0.....0.............................
.......000.....00..................0.........
.......000.....00............................
..0000000.....000......00........0...........
.00000000....0000....0000...000000...........
000005000.00.0000..000000..0000000.......0...
000005500.0000000.0000**0000000000..0..000000
0**05500000000**0000****0000000**000000000000
0*005500000000***000***0000*00***000000000000
0000550000000****00****0000*********000000000
0005500000000****00***0000**********000000000
000000000000**********0000**********000000000
***0000000************0*******0*****000*00000
****000000********************00****00***000*
*1**00000****************0000*0000***0****0**
******000****************000****00***********
******00*2******0***************0************
******00*2**22**************22***********1***
*****0*0***222*221*2*12**2222*******1***12***
222**0*0***222222*12*22*2222***221**22*122**1
222*0**000*232232*21*2222222**1222**22*221122
222**1*00*0*32222*212222222**22222*222222*222
222*2210**0*222222*12222121*22222*2122222221*
*21*212****22*2*2202222**2*232221*22*2*22*211
*2*23222*2222*3*22*2222****22*12*2232**12*222
2*2222232232212*22222*222*2222*2*04235*212242
    }

    # Frame #4, index 3
    make_proto_sprite ocflames \
        45 27 1 1 [list $TRANSPARRGB \
        FF0000  800000  808000  FFFF00  CCCCCC  FFFFFF \
        000000] \
    move {
.............................................
.............................................
.............................................
.............................................
..00.....000............000..............0...
.000...0000000.........00000.......00000000..
0000000000000000......000*00.....000000000000
000000000*0000000....0000*00...00000000000000
0000000***000*0000..000000050000*00**00000000
0000000***00**0000000000000000*******00**0000
0000000***00**0000000*0000000********00**0000
0***000***0***000**00*000000*************0000
****00********000**00000000**************000*
****00*************00**000****************0**
****00*************00*********************0**
******************00**********************0**
*00**************00**************************
*00******************************************
*0*1****0****1*******************************
**22***00***22***1******11********22*****2***
122222*0****22*221**********0****222****22***
222222**2***21*221**********0**2*22*****22**2
***22******122222221*1***1*1***2122***2*22*22
**12*2****222232*222*2222*22***2222**22*222**
*222*2***232222*222*2222222**1224*222220*3221
2*34*21*124222*222222122222**2*22*332220*2222
*242*22*32222**22*322*21****02**124222**2222*
    }

    # Frame #5, index 4
    make_proto_sprite ocflames \
        45 27 1 1 [list $TRANSPARRGB \
        FF0000  800000  808000  FFFF00  CCCCCC  FFFFFF \
        000000] \
    move {
.............................................
.............................................
.............................................
.................0000.........0..............
.......0000......00000.......00000...........
00000..00000....000000......0000000..000.0000
000000000000...0000000....000000000.000000000
0000000000000..00000000..00000000000000000000
0000000000000.000000000.000000000000000000000
0000**0000*0000*000*0000000000000000**0000550
00*****00**000**00**000000000000000****000000
00*****00*******00**000000000000000****000000
******00********0*****00000**00000****000000*
******0*********0*****0000***00*******00*000*
******0***************000****0*******000*00**
0************************************00******
**********12************1********************
******221*11*****211***221***11********22****
******2*******1*12221**111**122********22****
121**22*******222222222222**222*************1
*2**122***0***221222222222*222****1*1********
*2*222*******12222*2222*22*222**222*2*****2**
*22222*12**122222**2222*2*2222*221**22***22**
222222**22***12220**22222*222222****22*1**222
222*22*222***122**21222212222222*22222222*222
2***22*22*22*2***22*2*2222223****2222421222**
222222*222222****2**00224*224222323*4323*22**
    }

    # Frame #6, index 5
    make_proto_sprite ocflames \
        45 27 1 1 [list $TRANSPARRGB \
        FF0000  808000  800000  FFFFFF  CCCCCC  FFFF00] \
    move {
.............................................
.............................................
.............................................
.............................................
.11.............111111...1111................
11...111.......11111111.11111..111.1.........
11..11111....1111111111111111.1111111......11
11..11111..11111111111111111111111111.....111
111111111.1111111111111***1111**111111...1111
111111111.1111111111111***1111**11111111.1111
111111111111111*1111111**11111*111*11111.1111
11111111111111*11111111**11111*1****111111111
11*****11111***11111111**111*11*****11111*111
11*******111***11*1111***11**11******1*1**111
1*********1****1***111***11**11***********111
*******************111***1**111***********111
***************1****1*******11*****0******11*
******40***************************4**0******
******44****************4*********0444444****
0*****44*4*****4***440**4*********04444444**0
4**0**4044*0*1*44*444**44***********444444**4
4*44*0444004*1*404444**44*4***44****0444***44
40444444**4***0**4*4***4**4***440****440**444
443444**04****4*44*4*****44**04444****04*44**
*4244***4**4444*4**4*4*0*4*40**444*****0*****
*44404444*4444*43**4440*440*4***43*1*04*41*4*
44444040444244**24*0314*4*4*444144*41*424134*
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocinter
# Purpose:    Creates a sprite prototype: ocinter class
# Arguments:  None

#---------------------------------------------------------------------

# This is a  multi-frame sprite.  The frames are used as shapes as op-
# posed to animation. When the class is instantiated, individual shap-
# es may be selected explicitly as follows:
#
#     set frame_index $gdata(CLASSNAME.frame_index.SHAPENAME)
#
# where CLASSNAME is the object-class name (ocinter) and SHAPENAME is
# a shape keyword (forward or reverse).

# Alternatively, a shape may be selected randomly:
#
#     set frame_index \
#         [random_int 0 [expr $gdata(CLASSNAME.num_frames) - 1]]

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocinter

dmproc 1 make_proto_ocinter {} {
    global gdata
    global BG_PORTAL_FORWARD FG_PORTAL_FORWARD
    global BG_PORTAL_REVERSE FG_PORTAL_REVERSE

                                # Inter-world "forward" portal
    make_proto_sprite ocinter \
        5 5 1 1 [list $BG_PORTAL_FORWARD $FG_PORTAL_FORWARD] \
    nomove {
.*...
..*..
...*.
..*..
.*...
    }
                                # Make "forward" shape addressable
    set gdata(ocinter.frame_index.forward) \
       $gdata(ocinter.frame_index.newest)

                                # Inter-world "reverse" portal
    make_proto_sprite ocinter \
        5 5 1 1 [list $BG_PORTAL_REVERSE $FG_PORTAL_REVERSE] \
    nomove {
...*.
..*..
.*...
..*..
...*.
    }
                                # Make "reverse" shape addressable
    set gdata(ocinter.frame_index.reverse) \
       $gdata(ocinter.frame_index.newest)
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocintra
# Purpose:    Creates a sprite prototype: ocintra class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocintra

dmproc 1 make_proto_ocintra {} {
    global BG_PORTAL_INTRA FG_PORTAL_INTRA
    make_proto_sprite ocintra \
        4 4 1 1 [list $BG_PORTAL_INTRA $FG_PORTAL_INTRA] nomove {
****
*..*
*..*
****
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_ockarkinos
# Purpose:    Creates a sprite prototype: ockarkinos class
# Arguments:  None

#---------------------------------------------------------------------

# This is a  multi-frame sprite.  The frames are used as shapes as op-
# posed to animation. When the class is instantiated, individual shap-
# es may be selected explicitly as follows:
#
#     set frame_index $gdata(CLASSNAME.frame_index.SHAPENAME)
#
# where CLASSNAME is the object-class name (ockarkinos) and  SHAPENAME
# is a shape keyword (small, medium, large).

# Alternatively, a shape may be selected randomly:
#
#     set frame_index \
#         [random_int 0 [expr $gdata(CLASSNAME.num_frames) - 1]]

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ockarkinos

dmproc 1 make_proto_ockarkinos {} {
    global BG_KARKINOS FG_KARKINOS TRANSPARRGB gdata

                                # Start with a small version
    make_proto_sprite ockarkinos \
        3 3 1 1 [list $BG_KARKINOS $FG_KARKINOS] move {
*.*
...
***
    }
                                # Make "small" shape addressable
    set gdata(ockarkinos.frame_index.small) \
       $gdata(ockarkinos.frame_index.newest)

                                # Add a medium-size version
    make_proto_sprite ockarkinos \
        8 8 1 1 [list $BG_KARKINOS $FG_KARKINOS] move {
**....**
**....**
........
........
........
........
........
********
    }
                                # Make "medium" shape addressable
    set gdata(ockarkinos.frame_index.medium) \
       $gdata(ockarkinos.frame_index.newest)

                                # Add a large version
    make_proto_sprite ockarkinos \
        20 20 1 1 [list $BG_KARKINOS $FG_KARKINOS] move {
***..............***
***..............***
***..............***
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
....................
********************
********************
    }
                                # Make "large" shape addressable
    set gdata(ockarkinos.frame_index.large) \
       $gdata(ockarkinos.frame_index.newest)
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocmedical
# Purpose:    Creates a sprite prototype: ocmedical class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocmedical

dmproc 1 make_proto_ocmedical {} {
    global BG_MEDICAL FG_MEDICAL
    make_proto_sprite ocmedical \
        2 2 1 1 [list $BG_MEDICAL $FG_MEDICAL] move {
**
**
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocmoney
# Purpose:    Creates a sprite prototype: ocmoney class
# Arguments:  None

#---------------------------------------------------------------------

# This is a  multi-frame sprite.  The frames are used as shapes as op-
# posed to animation. When the class is instantiated, individual shap-
# es may be selected explicitly as follows:
#
#     set frame_index $gdata(CLASSNAME.frame_index.SHAPENAME)
#
# where CLASSNAME is the object-class name (ocmoney) and  SHAPENAME is
# a shape keyword (dollar, cent, pound, yen).

# Alternatively, a shape may be selected randomly:
#
#     set frame_index \
#         [random_int 0 [expr $gdata(CLASSNAME.num_frames) - 1]]

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocmoney

dmproc 1 make_proto_ocmoney {} {
    global gdata TRANSPARRGB
                                # Start with the U.S. dollar
    make_proto_sprite ocmoney \
        5 7 1 1 [list $TRANSPARRGB 008800] \
    move {
..*..
*****
*.*..
*****
..*.*
*****
..*..
    }
                                # Make "dollar" shape addressable
    set gdata(ocmoney.frame_index.dollar) \
       $gdata(ocmoney.frame_index.newest)

                                # Alternate: U.S. cent
    make_proto_sprite ocmoney \
        5 7 1 1 [list $TRANSPARRGB 008800] \
    move {
..*..
*****
*.*..
*.*..
*.*..
*****
..*..
    }
                                # Make "cent" shape addressable
    set gdata(ocmoney.frame_index.cent) \
       $gdata(ocmoney.frame_index.newest)

                                # Alternate: British pound
    make_proto_sprite ocmoney \
        5 7 1 1 [list $TRANSPARRGB 008800] \
    move {
.****
.*..*
.*...
****.
.*...
.*..*
*****
    }
                                # Make "pound" shape addressable
    set gdata(ocmoney.frame_index.pound) \
       $gdata(ocmoney.frame_index.newest)

                                # Alternate: Japanese yen
    make_proto_sprite ocmoney \
        5 7 1 1 [list $TRANSPARRGB 008800] \
    move {
*...*
.*.*.
..*..
*****
..*..
*****
..*..
    }
                                # Make "yen" shape addressable
    set gdata(ocmoney.frame_index.yen) \
       $gdata(ocmoney.frame_index.newest)
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocpig
# Purpose:    Creates a sprite prototype: ocpig class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocpig

dmproc 1 make_proto_ocpig {} {
    global TRANSPARRGB
    make_proto_sprite ocpig \
        12 13 1 1 [list $TRANSPARRGB \
        F0BEBE  B18A89  A0878A  918486  775D5F  E4A6B2 \
        BE8F92  CC9E96  D6A9B4  715F5E  B79A9A  C89C9F \
        FFCACD  999192  442622  AC9699  372023  F9BEBD \
        D09E9E  DCB5B2  FFFFFF  DB6C6D] \
    move {
...ffff.ffff
...f2c..f2c.
...fdce1cfc.
888776g6b3..
******ff*ff.
******9fi9f.
*********kkk
***5****4fkf
***0*****fkf
***ah*8ii8..
******8jj8..
***2223888..
***2........
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocplayer
# Purpose:    Creates a sprite prototype: ocplayer class
# Arguments:  None

#---------------------------------------------------------------------

# This is a  multi-frame sprite.  The frames are used as shapes as op-
# posed to animation. When the class is instantiated, individual shap-
# es may be selected explicitly as follows:
#
#     set frame_index $gdata(CLASSNAME.frame_index.SHAPENAME)
#
# where CLASSNAME is the object-class name (ocplayer) and SHAPENAME is
# a shape keyword (normal, godmode, driving_left, or driving_right).

# Alternatively, a shape may be selected randomly:
#
#     set frame_index \
#         [random_int 0 [expr $gdata(CLASSNAME.num_frames) - 1]]

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocplayer

dmproc 1 make_proto_ocplayer {} {
    global BG_PLAYER FG_PLAYER TRANSPARRGB gdata
                                # Normal player shape
    make_proto_sprite ocplayer \
        6 6 1 1 [list $BG_PLAYER $FG_PLAYER] move {
**..**
**..**
......
......
******
******
    }
                                # Make "normal" shape addressable
    set gdata(ocplayer.frame_index.normal) \
       $gdata(ocplayer.frame_index.newest)

                                # Player in "God" mode
    make_proto_sprite ocplayer \
        6 6 1 1 [list FFFF00 8800FF] move {
**..**
**..**
......
......
******
******
    }
                                # Make "God mode" shape addressable
    set gdata(ocplayer.frame_index.godmode) \
       $gdata(ocplayer.frame_index.newest)

                                # Player driving a  car  left  (sprite
                                # should be the  same  here as  for an
                                # occar)
    make_proto_sprite ocplayer \
        22 9 1 1 [list $TRANSPARRGB \
        3A6D89  A2A2A3  4F778E  4A7C98  8E9EA9  161514 \
        035D88  094B71  9F9FA0  445058  233845  87959F \
        476472  718693  9AA6AE  3D7594  2E7295  0B4A6D \
        1D313D  4F5A62  34617E  01628B  1F6182  34444C \
        1F5874  2F4B59  0C3244  628CA0  648699  145C81 \
        365063] \
    move {
........r*******q.....
........*..**...b*r...
.....3a*c..**...12*r..
..dr1e11222**e222efsq.
.2t9n5555k55555k*9hjl0
cp44n*5555kk5555p44nlj
84ma4msg6666g6gb4m34lo
.4i84m70707000704i84..
..44.............44...
    }
                                # Make "driving left"  shape  address-
                                # able
    set gdata(ocplayer.frame_index.driving_left) \
       $gdata(ocplayer.frame_index.newest)

                                # Player driving a  car  facing  right
                                # (should be the  previous  shape  re-
                                # versed)
    make_proto_sprite ocplayer \
        22 9 1 1 [list $TRANSPARRGB \
        3A6D89  A2A2A3  4F778E  4A7C98  8E9EA9  161514 \
        035D88  094B71  9F9FA0  445058  233845  87959F \
        476472  718693  9AA6AE  3D7594  2E7295  0B4A6D \
        1D313D  4F5A62  34617E  01628B  1F6182  34444C \
        1F5874  2F4B59  0C3244  628CA0  648699  145C81 \
        365063] \
    move {
.....q*******r........
...r*b...**..*........
..r*21...**..c*a3.....
.qsfe222e**22211e1rd..
0ljh9*k55555k5555n9t2.
jln44p5555kk5555*n44pc
ol43m4bg6g6666gsm4am48
..48i40700070707m48i4.
...44.............44..
    }
                                # Make  "driving right" shape address-
                                # able
    set gdata(ocplayer.frame_index.driving_right) \
       $gdata(ocplayer.frame_index.newest)
}

#---------------------------------------------------------------------

# Routine:    make_proto_ocscroll
# Purpose:    Creates a sprite prototype: ocscroll class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) ocscroll

dmproc 1 make_proto_ocscroll {} {
    global BG_SCROLL FG_SCROLL
    make_proto_sprite ocscroll \
        5 5 1 1 [list $BG_SCROLL $FG_SCROLL FFFFFF] \
    nomove {
*****
.*0*.
.*0*.
.*0*.
*****
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_octiger
# Purpose:    Creates a sprite prototype: octiger class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) octiger

dmproc 1 make_proto_octiger {} {
    global TRANSPARRGB
    make_proto_sprite octiger \
        12 12 1 1 [list $TRANSPARRGB \
        F6FBDB  A34F07  8E7354  DA7117  5E4F3F  794718 \
        FF8919  8F531C  6B4D2F  A98C65  DF9F58  824813 \
        E6710C  A09782  151615  332F24  EFF4D4  E7E9CD \
        2E1A0A  240C00  DF6E0E  603E1B  EEEED6  904E11 \
        FFDDA1  4B4643  909285  AF580D  84867B  C8CCB3 \
        543212] \
    move {
22........22
261666666162
.43t0kak0o34
.b9f*qaq**9b
.bne*j5j*enb
.b9**m5m**9b
.bcs*ith*scb
.bs*fpdp**gb
.1b***rlf*b1
..bg81718gb.
...g5bbb5g..
...g.111.g..
    }
}

#---------------------------------------------------------------------

# Routine:    make_proto_octree
# Purpose:    Creates a sprite prototype: octree class
# Arguments:  None

#---------------------------------------------------------------------

lappend gdata(list_classes_proto) octree

dmproc 1 make_proto_octree {} {
    global TRANSPARRGB
    make_proto_sprite octree \
        12 12 1 1 [list $TRANSPARRGB \
        00AA35  606000  00B83A  00842B  7F7F00  007826 \
        00C43E  00952F  00CD42  656500  898A00  18AB2F \
        2CA626  009E32  006C2B] \
    move {
...22**777..
...***1777..
...*111*157.
..5*11642*7.
..5**1*6*57.
..**11*6c**.
...2*ba2d25.
....999d2...
....999.....
....999.....
...99399....
...999880...
    }
}

#---------------------------------------------------------------------

# Routine:    setup_sprite_prototypes
# Purpose:    Sets up sprite prototypes
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 setup_sprite_prototypes {} {
    global gdata
    foreach objclass $gdata(list_classes_proto) {
        set   cmd make_proto_$objclass
        eval $cmd
    }
}

#---------------------------------------------------------------------

# Routine:    set_world_name
# Purpose:    Set current world name
# Arguments:  name = World name

# When a new world is activated,  this routine is called to record the
# change.

#---------------------------------------------------------------------

dmproc 1 set_world_name { name } {
    global gdata lv

# Note: We'd like to  get rid of gdata(lv) and use lv exclusively, but
# this would require changes to the game's "trace" code.

    set lv        $name
    set gdata(lv) $name
}

#---------------------------------------------------------------------

# Routine:    track_sprite
# Purpose:    Camera-related utility routine
# Arguments:  xpos = X-position (in sprite coordinate system)
#             ypos = Y-position (in sprite coordinate system)

# This routine  centers the program's  virtual camera on the specified
# position.

#---------------------------------------------------------------------

dmproc 5 track_sprite { xpos ypos } {
    global GAME_WIDTH GAME_HEIGHT
    global layers lv
    set WX [expr int ($GAME_WIDTH  / 2) ]
    set HX [expr int ($GAME_HEIGHT / 2) ]

    br::layer camera $layers($lv) \
        [expr { $xpos - $WX }] [expr { $ypos - $HX }]
}

#---------------------------------------------------------------------

# Routine:    account_ocplayer_position
# Purpose:    Player-related utility routine
# Arguments:  None

# This routine  updates various records based on the ocplayer sprite's
# current position.  It also repositions the  program's virtual camera
# based on the position in question.

#---------------------------------------------------------------------

dmproc 5 account_ocplayer_position {} {
    global gdata layers lv sdata

    set id $gdata($lv,ocplayer_id)
    set PlayerPosition [br::sprite pos $id]
    set ocplayer_x [lindex $PlayerPosition 0]
    set ocplayer_y [lindex $PlayerPosition 1]

                                # Update  ocplayer's internal coordin-
                                # ates
    set sdata($id.px) $ocplayer_x
    set sdata($id.py) $ocplayer_y
                                # Track ocplayer with camera
    track_sprite $ocplayer_x $ocplayer_y
}

#---------------------------------------------------------------------

# Routine:    (xproc) check_force_create
# Purpose:    Checks a global flag
# Arguments:  FlagCreate = Output flag (passed by reference)

# This is  an  "xproc" routine;  i.e.,  it supports  "&variable"-style
# pass-by-reference.

# If the following flag exists and is true, this routine sets the spe-
# cified output variable to true (in the caller's scope):
#
#     gdata(force_create)
#
# Otherwise, the output flag isn't modified.  This routine doesn't re-
# turn anything (except through the output flag).

#---------------------------------------------------------------------

xproc check_force_create { &FlagCreate } {
    global gdata
    if { [info exists gdata(force_create)] && \
                     $gdata(force_create) } { set FlagCreate 1 }
    set gdata(force_create) 0
}

#---------------------------------------------------------------------

# Routine:    group_generic_new
# Purpose:    Object creation support routine
# Arguments:  objclass = Object class (for example, occow)

# This is a generic object  creation routine suitable for  "barnyard"-
# group classes and, if class parameters are set appropriate, for some
# of the other classes.

#---------------------------------------------------------------------

dmproc 2 group_generic_new { objclass } {
    global layers lv proto sdata ParamBlock WorldKeyStart
    global  BRICKAPI
                                # Get class parameters
    foreach param [list \
            divmax        divmin        forceposn     frequency \
            heffect       maxnum        nobounce      scalemin \
            scalemax      shoot_can     shoot_effect  shoot_score \
            xpos          ypos] {
        set $param [get_class_param $objclass $param]
    }
                                # Select a scale factor
    set   scale_factor  [random_real $scalemin $scalemax]
    if { $scale_factor  < 0.75 } { set scale_factor  1.00 }

                                # Select a speed divisor
    set   speed_divisor [random_int $divmin $divmax]
    if { $speed_divisor < 1    } { set speed_divisor 1    }

                                # Determine whether or not to create a
                                # new instance
    set FlagCreate 0
    if { rand() >= (1 - $frequency) } { set FlagCreate 1 }
    check_force_create FlagCreate
    if { [get_class_counter $objclass] >= $maxnum } \
        { set FlagCreate 0 }
                                # Create a new instance?
    if { $FlagCreate } {      ; # Yes
        set id [br::sprite copy $proto($objclass)]
        incr_class_counter $objclass
        if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
        set zhint [get_class_param $objclass zhint]
        br::sprite z-hint $id $zhint
                                # Scale the sprite if appropriate
        if { ($BRICKAPI >= 5400) && ($scale_factor != 1) } {
            br::sprite scale $id $scale_factor $scale_factor
        }
                                # Select object name
        set name [get_object_name_random $objclass]

        array set sdata [list \
            $id.               run_$objclass        \
            $id.ct             0                    \
            $id.dir            [random_direction]   \
            $id.forceposn      $forceposn           \
            $id.heffect        $heffect             \
            $id.name           $name                \
            $id.nobounce       $nobounce            \
            $id.shoot_can      $shoot_can           \
            $id.shoot_effect   $shoot_effect        \
            $id.shoot_score    $shoot_score         \
            $id.smart          1                    \
            $id.speed_divisor  $speed_divisor       \
            $id.xpos           $xpos                \
            $id.ypos           $ypos                \
        ]
        verify_sprite_exists $rtn $id
        br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
        random_position_sprite $id
        return $id
    }

    return 0
}

#---------------------------------------------------------------------

# Routine:    new_occar
# Purpose:    Objection creation: occar class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_occar {} {
    return [group_generic_new occar]
}

#---------------------------------------------------------------------

# Routine:    new_occow
# Purpose:    Objection creation: occow class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_occow {} {
    return [group_generic_new occow]
}

#---------------------------------------------------------------------

# Routine:    new_occross
# Purpose:    Objection creation: occross class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_occross {} {
    return [group_generic_new occross]
}

#---------------------------------------------------------------------

# Routine:    new_ocdog
# Purpose:    Objection creation: ocdog class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocdog {} {
    return [group_generic_new ocdog]
}

#---------------------------------------------------------------------

# Routine:    new_ocflames
# Purpose:    Object creation: ocflames class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocflames {} {
    return [group_generic_new ocflames]
}

#---------------------------------------------------------------------

# Routine:    new_ocinter
# Purpose:    Objection creation: ocinter class
#
# Arguments:  PortalType  = "forward" or "reverse".
#
#             ToWorldName = Name of the destination world.
#
#             ToPortalID  = If $PortalType is  "reverse",  $ToPortalID
#             specifies  the  sprite ID  of  the  destination  portal.
#             Otherwise, this argument should be "none".

# For  an explanation of  inter-world portals,  see  the documentation
# section named "Inter-world portals".

# This routine creates  one inter-world  portal of the specified type.
# It returns the associated sprite ID.  Note: This routine should only
# be used by "make_world" and "run_ocinter".

#---------------------------------------------------------------------

dmproc 2 new_ocinter { PortalType ToWorldName ToPortalID } {
    global lv gdata proto sdata layers

    set id [br::sprite copy $proto(ocinter)]
    set frame_index $gdata(ocinter.frame_index.$PortalType)
    br::sprite frame $id $frame_index

    if { $DebugLevel >= 2 } {
        puts "$rtn: $lv,$id $ToWorldName,$ToPortalID"
    }

    array set sdata [list $id. run_ocinter \
        $id.to_world  $ToWorldName \
        $id.to_portal $ToPortalID  \
    ]

    verify_sprite_exists new_ocinter $id
    br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
    random_position_sprite $id
    return $id
}

#---------------------------------------------------------------------

# Routine:    new_ocintra
# Purpose:    Objection creation: ocintra class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocintra {} {
    global lv proto sdata layers
    set id [br::sprite copy $proto(ocintra)]
    if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
    set zhint [get_class_param ocintra zhint]
    br::sprite z-hint $id $zhint

    array set sdata [list $id. run_ocintra]
    br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
    random_position_sprite $id
    return $id
}

#---------------------------------------------------------------------

# Routine:    new_ockarkinos
# Purpose:    Objection creation: ockarkinos class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ockarkinos {} {
    global gdata layers lv proto sdata
                                # Get class parameters
    foreach param [list \
            divmax  divmin     frequency     heffect \
            maxnum  shoot_can  shoot_effect  shoot_score \
            size    smartmax   smartmin      zhint] {
        set $param [get_class_param ockarkinos $param]
    }
                                # Select smart percentage
    set smart_percent [random_int $smartmin $smartmax ]
    if { $smart_percent > 100 } { set smart_percent 100 }

                                # Select speed divisor
    set speed_divisor [random_int $divmin   $divmax   ]
    if { $speed_divisor < 1 } { set speed_divisor 1 }

                                # Determine whether or not to create a
                                # new instance
    set FlagCreate 0
    if { rand() >= (1 - $frequency) } { set FlagCreate 1 }
    check_force_create FlagCreate
    if { [get_class_counter ockarkinos] >= $maxnum } \
        { set FlagCreate 0 }
                                # Create a new instance?
    if { $FlagCreate } {      ; # Yes
        set id [br::sprite copy $proto(ockarkinos)]
        if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
        br::sprite z-hint $id $zhint
                                # Select appropriate frame
        if { ($size ne "medium") && ($size ne "large") } \
            { set size small }
        set frame_index $gdata(ockarkinos.frame_index.$size)
        br::sprite frame $id $frame_index

        incr_class_counter ockarkinos
                                # $smart:  1 for a hunter and  0 for a
                                # grazer
        set smart \
            [ expr (int (rand() * 101) < $smart_percent) ? 1 : 0 ]
                                # Select name
        set name [get_object_name_random ockarkinos]

        array set sdata [list \
            $id.               run_ockarkinos       \
            $id.ct             0                    \
            $id.dir            [random_direction]   \
            $id.heffect        $heffect             \
            $id.name           $name                \
            $id.shoot_can      $shoot_can           \
            $id.shoot_effect   $shoot_effect        \
            $id.shoot_score    $shoot_score         \
            $id.smart          $smart               \
            $id.speed_divisor  $speed_divisor       \
        ]
        br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
        random_position_sprite $id
    }

    return 0
}

#---------------------------------------------------------------------

# Routine:    new_ocmedical
# Purpose:    Objection creation: ocmedical class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocmedical {} {
    global gdata layers lv proto sdata

    set objclass ocmedical      ; # Object class
                                # Get class parameters
    foreach param [list \
            cautious  divmax     divmin        frequency \
            maxnum    shoot_can  shoot_effect  shoot_score \
            zhint] {
        set $param [get_class_param $objclass $param]
    }
                                # Select a speed divisor
    set   speed_divisor [random_int $divmin $divmax]
    if { $speed_divisor < 1 } { set speed_divisor 1 }

                                # Determine whether or not to create a
                                # new instance
    set FlagCreate 0
    if { rand() >= (1 - $frequency) } { set FlagCreate 1 }
    check_force_create FlagCreate
    if { [get_class_counter $objclass] >= $maxnum } { set FlagCreate 0 }

                                # Create a new instance?
    if { $FlagCreate } {      ; # Yes
        set id [br::sprite copy $proto($objclass)]
        if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
        incr_class_counter $objclass
        br::sprite z-hint $id $zhint
                                # Select object name
        set name [get_object_name_random $objclass]

        array set sdata [list \
            $id.               run_$objclass        \
            $id.cautious       $cautious            \
            $id.ct             0                    \
            $id.dir            [random_direction]   \
            $id.name           $name                \
            $id.shoot_can      $shoot_can           \
            $id.shoot_effect   $shoot_effect        \
            $id.shoot_score    $shoot_score         \
            $id.smart          1                    \
            $id.speed_divisor  $speed_divisor       \
        ]
        verify_sprite_exists $rtn $id
        br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
        random_position_sprite $id
        return $id
    }

    return 0
}

#---------------------------------------------------------------------

# Routine:    new_ocmoney
# Purpose:    Object creation: ocmoney class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocmoney {} {
    global gdata lv proto sdata layers
    set objclass ocmoney      ; # Object class
                              ; # Get class parameters
    foreach param [list \
            cautious      divmax       divmin    shoot_can  \
            shoot_effect  shoot_score  smartmax  smartmin   \
            valmax        valmin       zhint] {
        set $param [get_class_param $objclass $param]
    }
                                # Select a value
    set value [random_int $valmin $valmax]
                                # This  simplifies  text output  else-
                                # where
    if { $value < 2 } { set value 2 }

    set id [br::sprite copy $proto($objclass)]

                                # Set money shape  displayed to a ran-
                                # dom shape selected  from  all  money
                                # frames
    set n [random_int 0 [expr $gdata(ocmoney.num_frames) - 1]]
    br::sprite frame $id $n

    if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
    incr_class_counter $objclass
    br::sprite z-hint $id $zhint
                                # Is this object smart?
    set smart_percent [random_int $smartmin $smartmax ]
    if { $smart_percent > 100 } { set smart_percent 100 }
    set smart \
        [ expr (int (rand() * 101) < $smart_percent) ? 1 : 0 ]

                                # Select speed divisor
    set   speed_divisor [random_int $divmin $divmax]
    if { $speed_divisor < 1 } { set speed_divisor 1 }

                                # Select object name
    set name [get_object_name_random $objclass]

    array set sdata [list \
        $id.               run_$objclass        \
        $id.cautious       $cautious            \
        $id.ct             0                    \
        $id.dir            [random_direction]   \
        $id.name           $name                \
        $id.shoot_can      $shoot_can           \
        $id.shoot_effect   $shoot_effect        \
        $id.shoot_score    $shoot_score         \
        $id.smart          $smart               \
        $id.speed_divisor  $speed_divisor       \
        $id.value          $value               \
    ]
    verify_sprite_exists $rtn $id
    br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
    random_position_sprite $id
    return $id
}

#---------------------------------------------------------------------

# Routine:    new_ocpig
# Purpose:    Objection creation: ocpig class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocpig {} {
    return [group_generic_new ocpig]
}

#---------------------------------------------------------------------

# Routine:    new_ocplayer
# Purpose:    Objection creation: ocplayer class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocplayer {} {
    global gdata layers lv proto sdata

    set ocplayer [br::sprite copy $proto(ocplayer)]
    if { $DebugLevel >= 2 } { puts "$rtn: $lv,$ocplayer" }
    set gdata($lv,ocplayer_id) $ocplayer

    array set sdata [list $ocplayer. run_ocplayer \
        $ocplayer.px  10  $ocplayer.py 10 \
        $ocplayer.gx   0  $ocplayer.gy  0 \
        $ocplayer.shot 0 \
    ]

    br::list add $layers($lv.spr-list) $ocplayer
    random_position_sprite             $ocplayer
    account_ocplayer_position
    return $ocplayer
}

#---------------------------------------------------------------------

# Routine:    new_ocscroll
# Purpose:    Object creation: ocscroll class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_ocscroll {} {
    global layers lv proto sdata
    set id [br::sprite copy $proto(ocscroll)]
    if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
    set zhint [get_class_param ocscroll zhint]
    br::sprite z-hint $id $zhint

    array set sdata [list $id. run_ocscroll]
    verify_sprite_exists $rtn $id
    br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
    random_position_sprite $id
    return $id
}

#---------------------------------------------------------------------

# Routine:    new_octiger
# Purpose:    Creates an object: octiger class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_octiger {} {
    if  { $DebugLevel > 1 } { puts "$rtn" }
    global layers lv proto sdata ParamBlock WorldKeyStart

    set objclass octiger      ; # Object class
                                # Get class parameters
    foreach param [list \
            divmax     divmin health  heffect      maxnum \
            shoot_can  shoot_effect   shoot_score  sound_destroy \
            sound_hit  zhint] {
        set $param [get_class_param $objclass $param]
    }
                                # Select a speed divisor
    set   speed_divisor [random_int $divmin $divmax]
    if { $speed_divisor < 1 } { set speed_divisor 1 }

    set FlagCreate 0          ; # Determine whether or not to create a
                              ; # new instance
    if { [get_class_counter $objclass] < $maxnum } {
        set FlagCreate 1
    }

    check_force_create FlagCreate
                                # Create a new instance?
    if { $FlagCreate } {      ; # Yes
        set id [br::sprite copy $proto($objclass)]
        incr_class_counter $objclass
        if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
        br::sprite z-hint $id $zhint
                                # Select object name
        set name [get_object_name_random $objclass]

        array set sdata [list \
            $id.               run_$objclass        \
            $id.ct             0                    \
            $id.dir            [random_direction]   \
            $id.health         $health              \
            $id.heffect        $heffect             \
            $id.name           $name                \
            $id.shoot_can      $shoot_can           \
            $id.shoot_effect   $shoot_effect        \
            $id.shoot_score    $shoot_score         \
            $id.smart          1                    \
            $id.sound_destroy  $sound_destroy       \
            $id.sound_hit      $sound_hit           \
            $id.speed_divisor  $speed_divisor       \
        ]

        verify_sprite_exists $rtn $id
        br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
        random_position_sprite $id
        return $id
    }

    return 0
}

#---------------------------------------------------------------------

# Routine:    new_octree
# Purpose:    Object creation: octree class
# Arguments:  None

#---------------------------------------------------------------------

dmproc 2 new_octree {} {
    global layers lv proto sdata ParamBlock WorldKeyStart

    set id [br::sprite copy $proto(octree)]
    if { $DebugLevel >= 2 } { puts "$rtn: $lv,$id" }
    set zhint [get_class_param octree zhint]
    br::sprite z-hint $id $zhint

    set add_octiger 0
    if { ![get_world_param has_octiger] } {
        set add_octiger 1
        set_world_param has_octiger 1
    }

    array set sdata [list \
        $id. run_octree \
        $id.add_octiger $add_octiger \
    ]
    verify_sprite_exists $rtn $id
    br::list add $layers($lv.spr-list) $id
                                # Randomly position the sprite
    random_position_sprite $id
    return $id
}

#---------------------------------------------------------------------

# Routine:    make_upfront
# Purpose:    Support routine for "make_world"
# Arguments:  objclass = Object-class name

# "objclass" may be any "upfront" class name. Examples include:
#
#     ocintra  ocscroll  octree

# "make_world"  calls this routine  during the world-generation proce-
# dure to add zero or more instances of an "upfront" class.

#---------------------------------------------------------------------

dmproc 2 make_upfront { objclass } {
    global gdata
    set minnum [get_class_param $objclass minnum]
    set maxnum [get_class_param $objclass maxnum]
    set num    [random_int $minnum $maxnum]

    for { set ii 1 } { $ii <= $num } { incr ii } {
        set gdata(force_create) 1
        set   cmd new_$objclass
        eval $cmd
    }
}

#---------------------------------------------------------------------

# Routine:    make_world
# Purpose:    Creates a new world
#
# Arguments:  NewWorldName = Name of  new world.  For  the  first  (or
#             main) world,  this should be equal to the following par-
#             ameter: $gdata(WorldMain)
#
#             FromPortalID = Sprite ID of the inter-world portal  that
#             led "forward" to the new world.  If the  main  world  is
#             being created, this parameter should be equal to "none".

# "make_world" creates the specified world and calls  "set_world_name"
# to assert that the active world name has changed.

# This  routine creates  "forward" portals,  intra-world portals,  and
# ocscrolls as  requested by the  world-definitions section associated
# with the specified world.

# "Reverse" portals are handled specially:

# If the new world is the  main world,  no  "reverse" portals are cre-
# ated. "make_world" returns an empty string, in this case.

# If the new world is a deeper world,  this routine assumes that world
# creation was  triggered by the use of a  "forward" portal located in
# the previous world, and that $FromPortalID specifies  the sprite  ID
# for the "forward" portal.  In this case,  this routine  adds exactly
# one "reverse" portal to the new world and  connects it to  the "for-
# ward" portal specified by $FromPortalID.  It then returns the sprite
# ID of the new "reverse" portal.

#---------------------------------------------------------------------

dmproc 100 make_world { NewWorldName FromPortalID } {
    if  { $DebugLevel >= 1 } {
        puts "$rtn $NewWorldName $FromPortalID"
    }

    global gdata layers lv BRICKAPI FRAFMTRGB NRDIGITS
    global fr2data fr3data MaxNumPortal WorldKeyStart

    global RandomMapEnable
    global RandomMapWidthMin RandomMapHeightMin
    global RandomMapWidthMax RandomMapHeightMax
    global BaseMapWidth      BaseMapHeight

# Note: This code is biased towards the creation of horizontal worlds,
# but vertical worlds may be created as well.

    for { set ii 1 } { $ii <= 3 } { incr ii } {
        set RandomMapWidth  [random_int \
           $RandomMapWidthMin  $RandomMapWidthMax  ]

        set RandomMapHeight [random_int \
           $RandomMapHeightMin $RandomMapHeightMax ]

        if { $RandomMapWidth >= $RandomMapHeight } { break }
    }

    if { $NewWorldName eq $gdata(WorldMain) } {
        set FromWorldName none
    } else {
        set FromWorldName $lv
    }

    set_world_name      $NewWorldName
    set world_key       $WorldKeyStart.$NewWorldName
    set is_invariant    0

    if { [info exists  gdata($world_key.is_invariant)] && \
                      $gdata($world_key.is_invariant) } {
        set is_invariant 1
    }

    if { $is_invariant } {      # Special case - Predefined map is re-
                                # quired
        if { [info exists  gdata($world_key.map_data)] } {
            set width     $gdata($world_key.width)
            set height    $gdata($world_key.height)
            set MapString $gdata($world_key.map_data)

            if { ![string length $MapString] } {
                set gdata($NewWorldName.is_empty) 1
            }
        } else {
            puts "$IE-01: World $lv is flagged as invariant,\
but no map is provided"
            puts "Either provide a map for the level or disable\
is is_invariant flag"
            exit 1
        }
    } elseif { $RandomMapEnable } {
                                # Use a random map
        set width     $RandomMapWidth
        set height    $RandomMapHeight
        set MapString [make_random_map $width $height]
    } else {
                                # Use a predefined map
        if { [info exists  gdata($world_key.map_data) ] } {
            set width     $gdata($world_key.width)
            set height    $gdata($world_key.height)
            set MapString $gdata($world_key.map_data)
        } else {
            puts "$IE-02: Random maps are disabled, but no\
default map is"
            puts "provided for the following level: $lv"
            puts "Either enable random maps or add a default map\
for the level in question"
            exit 1
        }
    }

    set layer_id             [br::layer add]
    set layers($lv)          $layer_id
    set layers($lv.width)    $width
    set layers($lv.height)   $height

    if { $BRICKAPI < 5300 } {
        set info_list            [br::layer info $layer_id]
        set layers($lv.spr-list) [lindex $info_list 0]
        set layers($lv.map)      [lindex $info_list 1]
        set layers($lv.str-list) [lindex $info_list 2]
    } else {
        set layers($lv.spr-list) [br::layer sprite-list $layer_id]
        set layers($lv.map)      [br::layer map         $layer_id]
        set layers($lv.str-list) [br::layer string-list $layer_id]
    }

    br::layer sorted $layer_id 1

# This code is an attempt to keep the  "info" layer  (i.e., the trans-
# parent layer that contains the game's information display) on top.

    if [info exists layers(info)] {
        set old_info     $layers(info)
        set old_lv       $layers($lv)
        br::layer swap   $old_info $old_lv
        set layers(info) $old_lv
        set layers($lv)  $old_info
    }

    set t2 [br::tile create]
    set t3 [br::tile create]

    set n1  [expr 8 * 8 * $NRDIGITS]
    set n2  [string length $fr2data]
    set n3  [string length $fr3data]
    if { ($n1 != $n2) || ($n1 != $n3) } {
        puts "$IE-03" ; exit 1
    }

    set fr2 [br::frame create $FRAFMTRGB 8 8 \
        [binary format H$n2 $fr2data]]
    set fr3 [br::frame create $FRAFMTRGB 8 8 \
        [binary format H$n3 $fr3data]]

    br::tile add-frame $t2 $fr2
    br::tile add-frame $t3 $fr3
    br::tile collides  $t3 box

    br::map tile-size $layers($lv.map) 8 8
    br::map tile      $layers($lv.map) 1 $t2
    br::map tile      $layers($lv.map) 2 $t3
    br::map size      $layers($lv.map) $width $height

    set ExpectedSize [expr $width * $height * 4]
    br::map set-data $layers($lv.map) \
        [binary format H$ExpectedSize \
            [string map {"-" 0100 "1" 0200} $MapString]]

                                # Create  "upfront" objects  as appro-
                                # priate
    foreach objclass $gdata(list_classes_upfront) {
        make_upfront $objclass
    }
                                # Preload "periodic" objects as appro-
                                # priate
    foreach objclass $gdata(list_classes_periodic) {
        set prenum [get_class_param $objclass preload ]
        set maxnum [get_class_param $objclass maxnum  ]
        if { $prenum > $maxnum } { set $prenum $maxnum }

        for { set ii 1 } { $ii <= $prenum } { incr ii } {
            set gdata(force_create) 1
            set cmd new_$objclass
            eval $cmd
        }
    }
                                # Create inter-world "forward" portals
    set to_worlds $gdata($world_key.to_worlds)

    foreach world $to_worlds {
        new_ocinter "forward" $world none
    }
                              ; # Creating the main level?
    if { $lv eq $gdata(WorldMain) } {
                              ; # Yes - Presently,  there's no reverse
                              ; # portal in the main level
        set PortalUpID ""
    } else {                  ; # No  - Add  a reverse portal that re-
                              ; # turns to the  "forward" portal which
                              ; # led here
        set PortalUpID \
            [new_ocinter "reverse" $FromWorldName $FromPortalID]
    }

    return $PortalUpID
}

#---------------------------------------------------------------------

# Routine:    is_ocplayer_driving
# Purpose:    Determines whether or not ocplayer is driving
# Arguments:  None

# This routine returns  nonzero  if the ocplayer is driving  and  zero
# otherwise.

#---------------------------------------------------------------------

dmproc 5 is_ocplayer_driving {} {
    global gdata
    set frame_index   $gdata(ocplayer.frame_index)
    set driving_left  $gdata(ocplayer.frame_index.driving_left)
    set driving_right $gdata(ocplayer.frame_index.driving_right)
    if { ($frame_index == $driving_left) || \
         ($frame_index == $driving_right) } { return 1 }
    return 0
}

#---------------------------------------------------------------------

# Routine:    cycle_smart
# Purpose:    Motion-related support routine
# Arguments:  id = Sprite ID

# This is a support routine  that may be used by  "run_" routines that
# switch occasionally between  intelligent and  unintelligent  motion.
# For usage examples, see "run_ockarkinos" and "group_avoid_run".

#---------------------------------------------------------------------

dmproc 5 cycle_smart { id } {
    global sdata
    if { [info exists sdata($id.smart)] } {
            if     { $sdata($id.smart) <  0 } {
                incr  sdata($id.smart) 1
                if { $sdata($id.smart) == 0 } {
                incr  sdata($id.smart) 1
            }
        }
    }
}

#---------------------------------------------------------------------

# Routine:    group_avoid_run
# Purpose:    "run_..." support routine
# Arguments:  id       = Sprite ID
#             objclass = Object-class name

# This  routine may be used  to  handle  "run_..." actions for classes
# similar to "ocmedical" or "ocmoney" at "run_..." time.  Changes  may
# be needed as new classes are added.

# Common characteristics of the supported classes:  Avoidance of play-
# er. Collision with player destroys object and  produces  a bonus for
# player.

#---------------------------------------------------------------------

dmproc 100 group_avoid_run { id objclass } {
    if { $DebugLevel >= 2 } { puts "$rtn $id $objclass" }
    global gdata layers lv sdata
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]          } { return }
    set   callback    $sdata($id.)
    if { $callback ne "run_$objclass"        } { return }
    if { $objclass ne [get_sprite_class $id] } { return }

                                # Identify sprite class
    set iddot "$sdata($id.)"
    regsub -all {^run_} $iddot "" sprite_class

    set is_ocmedical  \
        [if { $sprite_class eq "ocmedical" } {expr 1} {expr 0}]
    set is_ocmoney    \
        [if { $sprite_class eq "ocmoney"   } {expr 1} {expr 0}]

    incr sdata($id.ct)        ; # Increment timeline counter
    set vx 0                  ; # Reset velocity components
    set vy 0
                                # Move the sprite periodically
    if { !($sdata($id.ct) % $sdata($id.speed_divisor)) } {

        set ocplayer_id $gdata($lv,ocplayer_id)
        get_target_dx_dy $id $ocplayer_id dx dy
        if {$dx < 0} { set dx [expr -$dx] }
        if {$dy < 0} { set dy [expr -$dy] }
        set cautious [get_object_param $id cautious]

        if { ($dx > $cautious) || ($dy > $cautious) } {
                                # Object  isn't cautious at  this dis-
                                # tance
            get_dir_vx_vy $sdata($id.dir) vx vy

        } elseif { $sdata($id.smart) > 0 } {
                                # Moving intelligently - Avoid ocplayer
            set ocplayer_id $gdata($lv,ocplayer_id)
            get_target_dx_dy $id $ocplayer_id dx dy
            if {$dx < 0} { set vx  1 }
            if {$dx > 0} { set vx -1 }
            if {$dy < 0} { set vy  1 }
            if {$dy > 0} { set vy -1 }
        } else {
                                # No: Random-motion mode
            get_dir_vx_vy $sdata($id.dir) vx vy

            cycle_smart $id   ; # Return to intelligent mode eventual-
                                # ly
        }
                                # Set sprite velocity
        br::sprite vel $id $vx $vy
                                # Check to  see  if  we've  hit a wall
                                # Note:  This  sprite  doesn't  change
                                # direction  randomly  except  when  a
                                # collision occurs
        if { [lindex [br::collision map $id \
                 $layers($lv.map) 1] 0] == 1 } {

                                # Hit a wall:  Pick a new direction at
                                # random
            set sdata($id.dir) [random_direction]

                                # Override  intelligent behavior temp-
                                # orarily
            if { $sdata($id.smart) > 0 } { set sdata($id.smart) -10 }
        } else {
            move_sprite $id   ; # Move the sprite
        }
    }
                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]
                                # Collided with ocplayer?
        if { $other_class eq "ocplayer" } {
                                # Yes
            if { $is_ocmedical } {
                set name [get_object_name_current $id]
                if { ($name ne "none") } {
                                # Update the status line
                    set gdata(infomsg) "You ate $name"
                }
                                # Adjust health level
                set ocmedical_health \
                    [get_class_param ocmedical health]
                set n [expr $gdata(health) + $ocmedical_health]
                                # Limit  health to 100
                if { $n > 100 } { set n 100 }
                set gdata(health) $n
            }

            if { $is_ocmoney } {
                                # Value of ocmoney
                set value $sdata($id.value)
                                # Update the status line
                set gdata(infomsg) "Picked up $value coins"
                                # Adjust ocplayer's inventory
                inventory_ocmoney_add $value
            }
                                # Play the appropriate sound
            play_sound bonus 0
                                # Destroy the affected sprite
            destroy_sprite $sprite_class $id
        }
    }
}

#---------------------------------------------------------------------

# Routine:    group_barnyard_run
# Purpose:    Runs an object: classes in "barnyard" category
# Arguments:  id       = Sprite ID
#             objclass = Object-class name

#---------------------------------------------------------------------

dmproc 100 group_barnyard_run { id objclass } {
    if { $DebugLevel >= 2 } { puts "$rtn $id $objclass" }
    global BRICKAPI
    global gdata layers lv sdata level_list LevelToSData
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]          } { return }
    set   callback    $sdata($id.)
    if { $callback ne "run_$objclass"        } { return }
    if { $objclass ne [get_sprite_class $id] } { return }

                              ; # Player ID
    set ocplayer_id $gdata($lv,ocplayer_id)
    set ocplayer_collide 0    ; # Flag: Player is at same position

    incr sdata($id.ct)        ; # Increment timeline counter
    set vx 0                  ; # Reset velocity components
    set vy 0
                                # Move the sprite periodically
    if { !($sdata($id.ct) % $sdata($id.speed_divisor)) } {
        get_dir_vx_vy $sdata($id.dir) vx vy
        br::sprite vel $id $vx $vy
                                # Check to see if we've  hit a wall or
                                # if we're changing  direction at ran-
                                # dom
        set rthreshold 0.99

        if { [lindex [br::collision map $id \
             $layers($lv.map) 1] 0] == 1 || rand() > $rthreshold } {

                                # Yes: Pick a new direction at random
            set sdata($id.dir) [random_direction]
        } else {
            move_sprite $id   ; # Move the sprite
        }
    }
                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]

        if { $other_class eq "ocplayer" } {
                                # Assert collision with ocplayer
            set ocplayer_collide 1
                                # Set  a collision lock to  limit  re-
                                # peated processing of the same colli-
                                # sion
            if { ![info exists \
                    gdata($lv,$ocplayer_id.${objclass}_id) ] } {
                set gdata($lv,$ocplayer_id.${objclass}_id) $id
                                # This code is  executed once per col-
                                # lision
                                # Name of  sound  to play  (may change
                                # before it's actually played)
                set sound $objclass
                                # Check collision type
                if { $objclass eq "occar" } {
                                # occar-ocplayer collision
                                # Change ocplayer  sprite  into  occar
                                # sprite (as player is now driving)
                    set gdata(ocplayer.frame_index)  \
                       $gdata(ocplayer.frame_index.driving_left)
                    br::sprite frame $ocplayer_id \
                       $gdata(ocplayer.frame_index.driving_left)

                                # Update the status line
                    set name [get_object_name_current $id]
                    if { $name eq "none" } { set name "the car" }
                    set gdata(infomsg) "You drive $name"

                                # Destroy the occar sprite
                    destroy_sprite $objclass $id
                                # Reset  collision flag as  the sprite
                                # is now gone
                    set ocplayer_collide 0

                                # Prevent the creation of more cars in
                                # this world
                    set gdata(WORLD_PARAM.$lv.occar_minnum) 0
                    set gdata(WORLD_PARAM.$lv.occar_maxnum) 0

                } elseif { $objclass eq "occross" } {
                                # occross -ocplayer collision
                                # Destroy the affected sprite
                    destroy_sprite $objclass $id
                                # Reset  collision flag as  the sprite
                                # is now gone
                    set ocplayer_collide 0
                                # Embracing God is healthy
                    set gdata(health) 100
                                # Switch to "God" mode
                    if { $BRICKAPI >= 5400 } {
                        set godtime [expr int ([br::clock ms] / 1000)]
                        set gdata(godtime) $godtime
                        set gdata(ocplayer.frame_index)  \
                           $gdata(ocplayer.frame_index.godmode)
                        br::sprite frame $ocplayer_id \
                           $gdata(ocplayer.frame_index.godmode)
                    }
                }
                                # Play the appropriate sound
                play_sound $sound 0
            }

        } elseif { $other_class eq "ockarkinos" } {
                                # Object eats an ockarkinos
                                # Update the status line
            set name1 [get_object_name_current $id     ]
            set name2 [get_object_name_current $tgt_id ]
            if { ($name1 ne "none") && ($name2 ne "none") } {
                set gdata(infomsg) "$name1 ate $name2"
            }
                                # Play the appropriate sound
            play_sound pop 0
                                # Destroy the affected sprite
            destroy_sprite $other_class $tgt_id
        }
    }

# If an  ocplayer  collided with an object  supported by  this routine
# previously, a collision  lock was set to  limit  repeated processing
# of the (same) collision.  The following code releases the lock after
# the ocplayer leaves the object's position.

    set xlock_id $ocplayer_id.${objclass}_id

    if { !$ocplayer_collide } {
        if { [info exists  gdata($lv,$xlock_id) ] } {
             set glock_id $gdata($lv,$xlock_id)
             if { $id eq $glock_id } {
                    unset  gdata($lv,$xlock_id)
             }
        }
    }
}

#---------------------------------------------------------------------

# Routine:    group_hunter_run
# Purpose:    Runs an object (multiple hunter classes)
# Arguments:  id       = Sprite ID
#             objclass = Object-class name

# This routine handles object actions for hunter-group objects such as
# the following:
#
#     ocdog ockarkinos octiger
#
# The common characteristic is that these  objects  seek  the ocplayer
# (either to attack him/her or simply to follow).

#---------------------------------------------------------------------

dmproc 100 group_hunter_run { id objclass } {
    if  { $DebugLevel >= 2 } { puts "$rtn $id $objclass" }
    global gdata layers lv sdata
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]          } { return }
    set   callback    $sdata($id.)
    if { $callback ne "run_$objclass"        } { return }
    if { $objclass ne [get_sprite_class $id] } { return }

                                # Set object-class flags
    set is_ocdog      0 ; set is_ockarkinos 0 ; set is_octiger    0
    if { $objclass eq "ocdog"      } { set is_ocdog      1 }
    if { $objclass eq "ockarkinos" } { set is_ockarkinos 1 }
    if { $objclass eq "octiger"    } { set is_octiger    1 }
    if { !$is_ocdog && !$is_ockarkinos && !$is_octiger } { return }

    incr sdata($id.ct)        ; # Increment timeline counter
    set is_hunter 0           ; # Reset "hunter" flag
    set vx 0                  ; # Reset velocity components
    set vy 0

    set ocplayer_collide 0    ; # Flag: Collided with ocplayer
                              ; # ocplayer sprite id
    set ocplayer_id $gdata($lv,ocplayer_id)
                              ; # Check to see  if ocplayer is  hiding
                              ; # behind a tree
    if { [info exists gdata($lv,$ocplayer_id.octreehide_id) ] } {
        set ocplayer_hidden 1
    } else {
        set ocplayer_hidden 0
    }
                                # Move the sprite periodically
    if { !($sdata($id.ct) % $sdata($id.speed_divisor)) } {
                                # Is this a hunter?
        if { ($sdata($id.smart) > 0) && !$ocplayer_hidden } {
                                # Yes - Hunt the ocplayer!
            set is_hunter 1
            get_target_dx_dy $id $ocplayer_id dx dy
            if {$dx < 0} { set vx -1 }
            if {$dx > 0} { set vx  1 }
            if {$dy < 0} { set vy -1 }
            if {$dy > 0} { set vy  1 }

# An "ocdog" seeks the "ocplayer" until the two are  reasonably close.
# Then the  "ocdog" reverts to  random motion  until  the distance in-
# creases  again.  The net effect is that the  "ocdog" tends to follow
# the "ocplayer".

            if { $is_ocdog } {
                if {$dx < 0} { set dx [expr -$dx] }
                if {$dy < 0} { set dy [expr -$dy] }
                if { ($dx < 25) && ($dy < 25) } {
                    set sdata($id.smart) -8
                }
            }

        } else {
                                # No: It's a grazer
            get_dir_vx_vy $sdata($id.dir) vx vy
            cycle_smart $id   ; # Or maybe a hunter in explorer mode
        }

        br::sprite vel $id $vx $vy
        set rthreshold 0.99
        if { $is_hunter } { set rthreshold 1.00 }

                                # Check to see if we've  hit a wall or
                                # if we're changing  direction at ran-
                                # dom
        if { [lindex [br::collision map $id \
             $layers($lv.map) 1] 0] == 1 || rand() > $rthreshold } {

                                # Yes: Pick a new direction at random
            set sdata($id.dir) [random_direction]
                                # Override  intelligent behavior temp-
                                # orarily
            if { $sdata($id.smart) > 0 } { set sdata($id.smart) -8 }
        } else {
            move_sprite $id   ; # Move the sprite
        }
    }
                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]

        set a_eats_b 0        ; # Flag: Active object eats struck one
        set b_eats_a 0        ; # Flag: Struck object eats active one
                                # octigers eat occows
        if { $is_octiger && ($other_class eq "occow") } {
            set a_eats_b 1
        }
                                # octiger and ocdog are evenly matched
        if { ($is_octiger && ($other_class eq "ocdog"  )) || \
             ($is_ocdog   && ($other_class eq "octiger")) } {
            set n [random_int 1 2]
            if { $n == 1 } { set a_eats_b 1 }
            if { $n == 2 } { set b_eats_a 1 }
        }

        if { $other_class eq "ocplayer" } {
                                # Collided with an ocplayer
                                # Effect on ocplayer's health
            set heffect [get_object_param $id heffect]

                                # Assert collision with ocplayer
            set ocplayer_collide 1
                                # Set a collision lock to limit object
                                # class sounds to once per collision
            if { ![info exists \
                    gdata($lv,$ocplayer_id.${objclass}_id) ] } {
                set gdata($lv,$ocplayer_id.${objclass}_id) $id
                                # Play  object-class  sound  once  per
                                # collision
                play_sound $objclass 0
            } elseif { $heffect != 0 } {
                                # "Hit" sound may be played repeatedly
                                # while a collision continues
                play_sound hit 5
            }
                                # Determine effect on ocplayer health
            set heffect [get_object_param  $id heffect]
            if { [is_ocplayer_driving] } { set heffect 0 }

                                # Update the status line
            set name [get_object_name_current $id]
            if { $is_ockarkinos } {
                set gdata(infomsg) "$name attacks"
            } elseif { $is_octiger } {
                set gdata(infomsg) "$name is hungry"
            }
                                # Adjust ocplayer health
            incr gdata(health) $heffect

                                # "God" mode prevents damage
            if { [info exists gdata(godtime)] } {
                set gdata(health) 100
            }

        } elseif { $a_eats_b } {
                                # Active object eats other one
                                # Update the status line
            set name1 [get_object_name_current $id     ]
            set name2 [get_object_name_current $tgt_id ]
            if { ($name1 ne "none") && ($name2 ne "none") } {
                set gdata(infomsg) "$name1 ate $name2"
            }
                                # Play the appropriate sound
            play_sound $other_class 0
                                # Destroy the affected sprite
            destroy_sprite $other_class $tgt_id

        } elseif { $b_eats_a } {
                                # Other object eats active one
                                # Update the status line
            set name1 [get_object_name_current $id     ]
            set name2 [get_object_name_current $tgt_id ]
            if { ($name1 ne "none") && ($name2 ne "none") } {
                set gdata(infomsg) "$name2 ate $name1"
            }
                                # Play the appropriate sound
            play_sound $objclass 0
                                # Destroy the affected sprite
            destroy_sprite $objclass $id
        }
    }

# If an  ocplayer  collided with an object  supported by  this routine
# previously, a collision lock  was set to  limit  repeated processing
# of the (same) collision.  The following code releases the lock after
# the ocplayer leaves the object's position.

    set xlock_id $ocplayer_id.${objclass}_id

    if { !$ocplayer_collide } {
        if { [info exists  gdata($lv,$xlock_id) ] } {
             set glock_id $gdata($lv,$xlock_id)

             if { $id eq $glock_id } {
                    unset  gdata($lv,$xlock_id)
             }
        }
    }
}

#---------------------------------------------------------------------

# Routine:    run_ocbullet
# Purpose:    Runs an object: ocbullet class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocbullet { id } {
    if { $DebugLevel >= 2 } { puts "$rtn $id" }
    global gdata layers lv sdata
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]           } { return }
    set   callback    $sdata($id.)
    if { $callback  ne "run_ocbullet"         } { return }
    if { "ocbullet" ne [get_sprite_class $id] } { return }

    move_sprite $id           ; # Move the sprite
                                # Check for collisions with  shootable
                                # sprites
    foreach tgt [collision_sprites $id] {

        set tgt_id [lindex $tgt 1]
        set tgt_type "$sdata($tgt_id.)"
        regsub -all {^run_} $tgt_type "" objclass

                                # Was a shootable sprite hit?
        if { [get_object_param $tgt_id shoot_can] } {
                                # Yes
                                # Display a status message
            set name [get_object_name_current $tgt_id]
            if { $name ne "none" } {
                                # Update the status line
                set gdata(infomsg) "You shot $name"
            }
                                # Get object parameters
            foreach param [list \
                    health         shoot_score  shoot_effect \
                    sound_destroy  sound_hit] {
                set $param [get_object_param $tgt_id $param]
            }
                                # Update object health
            set new_health [expr $health + $shoot_effect]
            set_object_param $tgt_id health $new_health

# Some  sound-related conventions:  If an object is  hit or  destroyed
# here, an associated sound  may be  played.  The  "destroy" sound de-
# faults to the object's main class  sound  (if any).  The "hit" sound
# has no default.

                                # Has object been destroyed?
            if { $new_health < 0 } {
                                # Yes - Play appropriate sounds
                if { $sound_destroy eq "0" } {
                     set sound_destroy $objclass
                }

                play_sound $sound_destroy 100
                play_sound pop 0
                                # Update score appropriately
                incr gdata(score) $shoot_score
                                # Destroy the affected sprite
                destroy_sprite $objclass $tgt_id

            } elseif { $sound_hit ne "0" } {
                                # Play appropriate sound if it exists
                play_sound $sound_hit 100
            }
                                # Flag this ocbullet for removal
            set remove_ocbullet YES
        }
    }
                                # Remove this ocbullet?
    if { [info exists remove_ocbullet] || \
         [lindex [br::collision map $id $layers($lv.map) 1] 0] } {
                                # Yes
        destroy_sprite ocbullet $id
    }
}

#---------------------------------------------------------------------

# Routine:    run_occar
# Purpose:    Runs an object: occar class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_occar { id } {
    group_barnyard_run $id occar
}

#---------------------------------------------------------------------

# Routine:    run_occow
# Purpose:    Runs an object: occow class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_occow { id } {
    group_barnyard_run $id occow
}

#---------------------------------------------------------------------

# Routine:    run_occross
# Purpose:    Runs an object: occross class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_occross { id } {
    group_barnyard_run $id occross
}

#---------------------------------------------------------------------

# Routine:    run_ocdog
# Purpose:    Runs an object: ocdog class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocdog { id } {
    group_hunter_run $id ocdog
}

#---------------------------------------------------------------------

# Routine:    run_ocflames
# Purpose:    Runs an object: ocflames class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocflames { id } {
    if { $DebugLevel >= 2 } { puts "$rtn $id" }
    global gdata layers lv sdata level_list LevelToSData
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]           } { return }
    set   callback    $sdata($id.)
    if { $callback  ne "run_ocflames"         } { return }
    if { "ocflames" ne [get_sprite_class $id] } { return }

    if { ![info exists sdata($id.frametick)] } {
                   set sdata($id.frametick) 0
    }

    set FPSDIV 10             ; # This should be changed into  a class
                              ; # parameter

    if { [incr sdata($id.frametick)] == $FPSDIV } {
        set    sdata($id.frametick) 0
        set n [expr $gdata(ocflames.frame_index) + 1]
        if { $n >=  $gdata(ocflames.num_frames) } { set n 0 }
        set gdata(ocflames.frame_index) $n
        br::sprite frame $id $n
    }
                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]

        if { $other_class eq "ocplayer" } {
                                # Player hit! Adjust health
            incr gdata(health) [get_object_param $id heffect]

                                # "God" mode prevents damage
            if { [info exists gdata(godtime)] } {
                set gdata(health) 100
            }
                                # Play appropriate sound
            if { $sdata($id.frametick) == 0 } {
                play_sound ocflames 0
            }
        }
    }
}

#---------------------------------------------------------------------

# Routine:    run_ocinter
# Purpose:    Runs an object: ocinter class
# Arguments:  id = Sprite ID

# This  routine  runs two different  (but related)  types  of objects:
# inter-world forward and reverse portals.

#---------------------------------------------------------------------

dmproc 100 run_ocinter { id } {
    if { $DebugLevel >= 2 } { puts "$rtn $id" }

    global gdata layers lv sdata level_list
    global LevelToSData WorldKeyStart
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]          } { return }
    set   callback    $sdata($id.)
    if { $callback ne "run_ocinter"          } { return }
    if { "ocinter" ne [get_sprite_class $id] } { return }

    set FromWorldName $lv
    set FromPortalID  $id
    set ocplayer_id $gdata($lv,ocplayer_id)
                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]

                                # Player-portal collision?
        if { $other_class eq "ocplayer" } {
                                # Yes
                                # Consistency check
            if { $ocplayer_id ne $tgt_id } {
                puts "$IE-01: $rtn: Inconsistent ocplayer IDs"
                exit 1
            }
                                # Did player  get  here  by using  the
                                # portal (or its other side) ?
            if { [info exists gdata($lv.$tgt_id.$id.portal_lock)] } {
                                # Yes - So the portal shouldn't  acti-
                                # vate again immediately
                return
            } else {
                                # No  - Lock the portal to prevent in-
                                # finite loops
                set gdata($lv.$tgt_id.$id.portal_lock) 1
            }

            if { $DebugLevel } {
                puts "$rtn: ocplayer $lv,$tgt_id collided with\
portal $lv,$id"
            }
                                # Update the status line
            set gdata(infomsg) "Used a world portal"
                                # Play the appropriate sound
            play_sound ocinter 0

            set to_world  $sdata($id.to_world)
            set to_portal $sdata($id.to_portal)

            if {[info exists LevelToSData($to_world)]} {
                if { $DebugLevel > 2 } {
                    puts "$rtn: to_world $to_world exists"
                }

                array set xdata [array get sdata]
                unset sdata
                array set sdata $LevelToSData($to_world)
                set_world_name $to_world

                if { $to_portal eq "none" } {
                    set to_portal [new_ocinter \
                        "reverse" $FromWorldName $FromPortalID]
                    verify_sprite_exists "$rtn-1000"   $to_portal
                    set xdata($FromPortalID.to_portal) $to_portal
                }

                set LevelToSData($FromWorldName) [array get xdata]
                set PortalIdExit $to_portal
                verify_sprite_exists "$rtn-1001" $PortalIdExit
            } else {
                                # Consistency check
                if { $to_world eq $gdata(WorldMain) } {
                    puts "$IE-02" ; exit 1
                }

                array set xdata [array get sdata]
                unset sdata
                                # Note: "make_world" sets $lv equal to
                                # $to_world
                set PortalIdExit [make_world $to_world $id]
                verify_sprite_exists $rtn $PortalIdExit
                new_ocplayer

                set xdata($FromPortalID.to_portal) $PortalIdExit
                set LevelToSData($FromWorldName)   [array get xdata]
                set LevelToSData($to_world)        [array get sdata]
            }
                                # Consistency check
            if { $lv ne $to_world } { puts "$IE-03" ; exit 1 }

            set MyPosition [br::sprite pos $PortalIdExit]
            set my_x [lindex $MyPosition 0]
            set my_y [lindex $MyPosition 1]
            set ocplayer_id $gdata($lv,ocplayer_id)

            set frame_index   $gdata(ocplayer.frame_index)
            set frame_godmode $gdata(ocplayer.frame_index.godmode)
            set frame_normal  $gdata(ocplayer.frame_index.normal)
            if { ($frame_index != $frame_godmode) &&
                 ($frame_index != $frame_normal) } {
                set gdata(ocplayer.frame_index) $frame_normal
                br::sprite frame $ocplayer_id   $frame_normal
            }

            set gdata($lv.$ocplayer_id.$PortalIdExit.portal_lock) 1

            if { ![info exists gdata(ocplayer.frame_index)] } {
                puts "$IE-03"
                exit 1
            }

            br::sprite frame $ocplayer_id $gdata(ocplayer.frame_index)
            br::sprite pos   $ocplayer_id $my_x $my_y
            br::sprite vel   $ocplayer_id 0 0

# The following block is an attempt  to prevent a problem.  Under some
# conditions, the player may overlap a wall as soon as he/she  emerges
# from a portal. If this happens, and isn't corrected here, collision-
# detection code in "run_ocplayer"  may  be confused  and  prevent the
# player from moving. To address the issue, if the player intersects a
# wall  after arrival through a portal, this code bounces him/her to a
# random (but collision-free) location.

                                # Colliding on arrival?
            set colls [br::collision map $ocplayer_id \
                      $layers($lv.map) 1]
            if { [lindex $colls 0] } {
                                # Yes - Bounce to a better location
                random_position_sprite $ocplayer_id
            }
                                # Account for player's position
            account_ocplayer_position

            foreach name [array names LevelToSData] {
                if { $name ne $to_world } {
                    br::layer visible $layers($name) 0
                }
            }
                                # Make world layer visible
            br::layer visible $layers($to_world) 1

                                # Made it to the exit?
            if { $to_world eq $gdata(WorldEndOfAllSongs) } {
                                # Yes - Play appropriate sound
                play_sound win 2600
                                # Disable normal "exit" sound
                unset gdata(sound_exit)
                                # Update the status line
                set gdata(infomsg) "Winner!"
                                # Display a farewell message
                show_msg " Made it to the exit " 70 80

                quit_program  ; # Quit the program
            }

            return
        }
    }

# If we make it to this point,  the ocplayer sprite ($ocplayer_id)  in
# the current world ($lv) isn't  standing on the current portal ($id),
# so the portal should be  unlocked.  The following code addresses the
# issue.

    if { [info exists gdata($lv.$ocplayer_id.$id.portal_lock)] } {
                unset gdata($lv.$ocplayer_id.$id.portal_lock)
    }
}

#---------------------------------------------------------------------

# Routine:    run_ocintra
# Purpose:    Runs an object: ocintra class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocintra { id } {
    if { $DebugLevel >= 2 } { puts "$rtn $id" }
    global gdata layers lv sdata
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]          } { return }
    set   callback    $sdata($id.)
    if { $callback ne "run_ocintra"          } { return }
    if { "ocintra" ne [get_sprite_class $id] } { return }

                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]
                                # Collided with ocplayer?
        if { $other_class eq "ocplayer" } {
                                # Yes
                                # Update the status line
            set gdata(infomsg) "Used a local portal"
                                # Play the appropriate sound
            play_sound ocintra 0
                                # Set new position
            random_position_sprite $tgt_id
                                # Account for new ocplayer position
            account_ocplayer_position
        }
    }
}

#---------------------------------------------------------------------

# Routine:    run_ockarkinos
# Purpose:    Runs an object: ockarkinos class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ockarkinos { id } {
    group_hunter_run $id ockarkinos
}

#---------------------------------------------------------------------

# Routine:    run_ocmedical
# Purpose:    Runs an object: ocmedical class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocmedical { id } {
    group_avoid_run $id ocmedical
}

#---------------------------------------------------------------------

# Routine:    run_ocmoney
# Purpose:    Runs an object: ocmoney class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocmoney { id } {
    group_avoid_run $id ocmoney
}

#---------------------------------------------------------------------

# Routine:    run_ocpig
# Purpose:    Runs an object: ocpig class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocpig { id } {
    group_barnyard_run $id ocpig
}

#---------------------------------------------------------------------

# Routine:    run_ocplayer
# Purpose:    Runs an object: ocplayer class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocplayer { id } {
    if { $DebugLevel >= 2 } { puts "$rtn $id" }

    global gdata layers lv proto sdata
    global KeyH_Button      KeyH_Input
    global KeyI_Button      KeyI_Input
    global KeyQ_Button      KeyQ_Input
    global KeySpace_Button  KeySpace_Input
    global BRICKAPI MaxGodTime

    set ocbullet_maxnum [get_class_param ocbullet maxnum]
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]           } { return }
    set   callback    $sdata($id.)
    if { $callback  ne "run_ocplayer"         } { return }
    if { "ocplayer" ne [get_sprite_class $id] } { return }

                                # Fetch input
    set io(1) [br::io fetch 1]
    set io(0) [br::io fetch 0]
    set hkey  [lindex $io($KeyH_Input) 2 $KeyH_Button]
    set ikey  [lindex $io($KeyI_Input) 2 $KeyI_Button]
    set qkey  [lindex $io($KeyQ_Input) 2 $KeyQ_Button]
    set spkey [lindex $io($KeySpace_Input) 2 $KeySpace_Button ]

    set horiz [lindex $io(0) 0 0]
    set vert  [lindex $io(0) 0 1]

    if { [lindex $io(0) 7] || $qkey || [br::io has-quit] } {
        quit_program
    }
    if { $hkey } { display_help      ; return }
    if { $ikey } { display_inventory ; return }

                                # Get ocplayer movement
    set vx [expr { $horiz < 0 ? -1 : ($horiz > 0 ? 1 : 0) }]
    set vy [expr { $vert  < 0 ? -1 : ($vert  > 0 ? 1 : 0) }]
    br::sprite vel $id $vx $vy

# Note: If the ocplayer  is driving, he/she  can  pass through  walls.
# This is a kludge;  it's necessary (or may be necessary) to  keep the
# ocplayer  (in driving mode) from getting stuck  behind passages that
# are too narrow for an occar to use.

                                # Check for collision with walls
    if { ![is_ocplayer_driving] } {
        set colls [br::collision map $id $layers($lv.map) 1]
        set vx [expr {[lindex $colls 1] + [lindex $colls 3]}]
        set vy [expr {[lindex $colls 2] + [lindex $colls 4]}]
    }
                                # Set new position
    incr sdata($id.px) $vx
    incr sdata($id.py) $vy
    br::sprite pos $id $sdata($id.px) $sdata($id.py)

    handle_limbo $id
    account_ocplayer_position ; # Needed  because  "handle_limbo"  may
                                # have moved the ocplayer

                                # If  there's  any movement,  save the
                                # direction  for  use   in  subsequent
                                # shooting operations
    if { $horiz || $vert } {
        set sdata($id.gx) $vx
        set sdata($id.gy) $vy
    }
                                # "God mode" code
    if { $BRICKAPI >= 5400 } {
        if { [info exists gdata(godtime)] } {
            set gdata(health) 100
                                # Has time in "God mode" ended?
            set godtime  $gdata(godtime)
            set curtime  [expr int ([br::clock ms] / 1000)]

            if { ($curtime - $godtime) > $MaxGodTime } {
                                # Yes
                unset gdata(godtime)
                set   gdata(ocplayer.frame_index) \
                     $gdata(ocplayer.frame_index.default)
                br::sprite frame $id \
                     $gdata(ocplayer.frame_index.default)
            }
        }
    }

    set frame_index   $gdata(ocplayer.frame_index)
    set driving_left  $gdata(ocplayer.frame_index.driving_left)
    set driving_right $gdata(ocplayer.frame_index.driving_right)

    if { ($frame_index == $driving_left) && ($vx > 0) } {
        set gdata(ocplayer.frame_index) $driving_right
        br::sprite frame $id            $driving_right
    } elseif { ($frame_index == $driving_right) && ($vx < 0) } {
        set gdata(ocplayer.frame_index) $driving_left
        br::sprite frame $id            $driving_left
    }
                                # Handle a shot (if any)
    if { [lindex $io(0) 2 0] || $spkey } {
                                # If  the ocplayer  is  driving,  just
                                # beep the horn
        if { [is_ocplayer_driving] } {
            play_sound occar 250
        } elseif { ([get_class_counter ocbullet] \
                       < $ocbullet_maxnum) && \
             !$sdata($id.shot) && \
             ($sdata($id.gx) || $sdata($id.gy)) } {

                                # Create an ocbullet
            incr_class_counter ocbullet
            set ocbullet [br::sprite copy $proto(ocbullet)]
            if { $DebugLevel } { puts "new ocbullet: $lv,$id" }

            br::sprite pos $ocbullet [expr {$sdata($id.px) + 1}] \
                                     [expr {$sdata($id.py) + 1}]

            br::sprite vel $ocbullet [expr {$sdata($id.gx) * 2}] \
                                     [expr {$sdata($id.gy) * 2}]

                                # Add it to the lists
            br::list add $layers($lv.spr-list) $ocbullet
            set sdata($ocbullet.) run_ocbullet
            set sdata($id.shot) 1
                                # Play the appropriate sound
            play_sound gunshot 0
                                # Shooting   while  hiding  behind  an
                                # octree breaks cover
            if { [info exists gdata($lv,$id.octreehide_id) ] } {
                        unset gdata($lv,$id.octreehide_id)
            }
        }
    } else {
        set sdata($id.shot) 0 ; # Reset trigger for next shot
    }
                                # Track ocplayer with camera
    track_sprite $sdata($id.px) $sdata($id.py)
}

#---------------------------------------------------------------------

# Routine:    run_ocscroll
# Purpose:    Runs an object: ocscroll class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_ocscroll { id } {
    if { $DebugLevel >= 2 } { puts "$rtn $id" }
    global gdata layers lv sdata level_list LevelToSData
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]           } { return }
    set   callback    $sdata($id.)
    if { $callback  ne "run_ocscroll"         } { return }
    if { "ocscroll" ne [get_sprite_class $id] } { return }

                                # Player sprite ID
    set ocplayer_id $gdata($lv,ocplayer_id)
                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]
                                # Player-portal collision?
        if { $other_class eq "ocplayer" } {
                                # Yes
                                # Consistency check
            if { $ocplayer_id ne $tgt_id } {
                puts "$IE-01: $rtn: Inconsistent ocplayer IDs"
                exit 1
            }

            if { $DebugLevel } {
                puts "$rtn: ocplayer $lv,$tgt_id collided with\
ocscroll $lv,$id"
            }
                                # Destroy the affected sprite
            destroy_sprite ocscroll $id
                                # Update the status line
            set gdata(infomsg) "You read a scroll"
            display_wisdom    ; # Display contents of ocscroll
        }
    }
}

#---------------------------------------------------------------------

# Routine:    run_octiger
# Purpose:    Runs an object: octiger class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_octiger { id } {
    group_hunter_run $id octiger
}

#---------------------------------------------------------------------

# Routine:    run_octree
# Purpose:    Runs an object: octree class
# Arguments:  id = Sprite ID

#---------------------------------------------------------------------

dmproc 100 run_octree { id } {
    if { $DebugLevel >= 2 } { puts "$rtn $id" }
    global gdata layers lv sdata level_list LevelToSData
                                # Safety measure; see comments in main
                                # routine
    if { ![info exists sdata($id.)]          } { return }
    set   callback    $sdata($id.)
    if { $callback ne "run_octree"           } { return }
    if { "octree"  ne [get_sprite_class $id] } { return }

                                # Player sprite ID
    set ocplayer_id $gdata($lv,ocplayer_id)
    set ocplayer_collide 0
                                # Instantiate a tiger if appropriate
    if { [get_object_param $id add_octiger] } {
        get_target_dx_dy $id $ocplayer_id dx dy
        if {$dx < 0} { set dx [expr -$dx] }
        if {$dy < 0} { set dy [expr -$dy] }
        set octigerdelta [get_class_param octree octigerdelta]

        if { ($dx < $octigerdelta) && ($dy < $octigerdelta) } {
            set octiger_id [new_octiger]

            if { $octiger_id ne "0" } {
                set MyPosition [br::sprite pos $id]
                set my_x [lindex $MyPosition 0]
                set my_y [lindex $MyPosition 1]
                br::sprite pos $octiger_id $my_x $my_y
                set_object_param $id add_octiger 0
                play_sound octiger 0
            }
        }
    }
                                # Check for collisions
    foreach tgt [collision_sprites $id] {
                                # Process next collided object
        set tgt_id [lindex $tgt 1]
                                # Class of other object involved
        set other_class [get_sprite_class $tgt_id]
                                # Player-octree collision?
        if { $other_class eq "ocplayer" } {
                                # Yes
                                # Consistency check
            if { $ocplayer_id ne $tgt_id } {
                puts "$IE-01: Inconsistent ocplayer IDs"
                exit 1
            }
                                # Player  can  hide here,  subject  to
                                # limitations  (this only  works  once
                                # per octree, and shooting breaks con-
                                # cealment)
            if { ![info exists \
                    gdata($lv,$id,$ocplayer_id.octreehide_flag) ] } {
                set gdata($lv,$id,$ocplayer_id.octreehide_flag) 1
                set gdata($lv,$ocplayer_id.octreehide_id) $id
            }
                                # Assert collision with ocplayer
            set ocplayer_collide 1
        }
    }

# If an  ocplayer collided with an octree previously, a collision lock
# was set to limit repeated  processing of the  (same) collision.  The
# following  code  releases  the lock  after  the  ocplayer leaves the
# octree's position.

    if { !$ocplayer_collide } {
        if { [info exists gdata($lv,$ocplayer_id.octreehide_id) ] } {
         set octreehide_id $gdata($lv,$ocplayer_id.octreehide_id)
            if { $id eq $octreehide_id } {
                    unset gdata($lv,$ocplayer_id.octreehide_id)
            }
        }
    }
}

#---------------------------------------------------------------------

# Routine:    setup_info_display
# Purpose:    Sets up program's information display
# Arguments:  None

#---------------------------------------------------------------------

dmproc 1 setup_info_display {} {
    global gdata layers
    global BGHeight BGWidth
    global BGTileWidth BGTileHeight
    global BRICKAPI FRAFMTTRA NCDIGITS TRANSPARFRA

    set foo ""
    set nn [expr $BGTileWidth * $BGTileHeight]
    for { set ii 1 } { $ii <= $nn } { incr ii } \
        { append foo $TRANSPARFRA }
                                # Total number of hex digits
    set NumHexDigits [expr $nn * $NCDIGITS]
                                # Consistency check
    if { $NumHexDigits != [string length $foo] } {
        puts "$IE-01" ; exit 1
    }

    set t1 [br::tile create]

    if { $BRICKAPI < 5400 } {
        global CHROMA_R CHROMA_G CHROMA_B
        set fr1 [br::frame create $FRAFMTTRA \
                $BGTileWidth $BGTileHeight \
                [binary format H$NumHexDigits $foo] \
                $CHROMA_R $CHROMA_G $CHROMA_B]
    } else {
        set fr1 [br::frame create $FRAFMTTRA \
                $BGTileWidth $BGTileHeight \
                [binary format H$NumHexDigits $foo]]
    }

    br::tile add-frame $t1 $fr1
    set layer_id              [br::layer add]
    set layers(info)          $layer_id

    if { $BRICKAPI < 5300 } {
        set info_list             [br::layer info $layer_id]
        set layers(info.spr-list) [lindex $info_list 0]
        set layers(info.map)      [lindex $info_list 1]
        set layers(info.str-list) [lindex $info_list 2]
    } else {
        set layers(info.spr-list) [br::layer sprite-list $layer_id]
        set layers(info.map)      [br::layer map         $layer_id]
        set layers(info.str-list) [br::layer string-list $layer_id]
    }

    br::map tile-size $layers(info.map) $BGTileWidth $BGTileHeight
    br::map tile      $layers(info.map) 1 $t1
    br::map size      $layers(info.map) \
        $BGWidth $BGHeight
    br::map set-data $layers(info.map) \
        [binary format H[expr {4 * $BGWidth * $BGHeight}] \
        [string repeat 0100 [expr {$BGWidth * $BGHeight}]]]

    set stg_x 10
    set stg_y 10

    set mxpos(time)      10 ; set mypos(time)      10
    set mxpos(health)   120 ; set mypos(health)    10
    set mxpos(score)     10 ; set mypos(score)     18
    set mxpos(lv)       120 ; set mypos(lv)        18
    set mxpos(infomsg)   10 ; set mypos(infomsg)   26

    foreach stg { time health score lv infomsg } {
        set gdata(stg.$stg) [br::string create]
        set stg_x $mxpos($stg)
        set stg_y $mypos($stg)
        br::string position $gdata(stg.$stg) $stg_x $stg_y
        br::list add $layers(info.str-list) $gdata(stg.$stg)
    }

    global col2fmt
    set    col2fmt "%-16s"

    trace add variable gdata(time)   write {apply {{a1 a2 op} { \
        global idsfmt  ; upvar 1 $a1 a ; \
        br::string text $a(stg.time)    [format $idsfmt \
        "Time  |[clock format $a(time) -format %M:%S]"] }}}

    trace add variable gdata(health) write {apply {{a1 a2 op} { \
        global col2fmt ; upvar 1 $a1 a ; \
        br::string text $a(stg.health)  [format $col2fmt \
        "Health|$a(health)"] }}}

    trace add variable gdata(score)   write {apply {{a1 a2 op} { \
        global idsfmt  ; upvar 1 $a1 a ; \
        br::string text $a(stg.score)   [format $idsfmt \
        "Score |$a(score)"] }}}

    trace add variable gdata(lv)      write {apply {{a1 a2 op} { \
        global col2fmt ; upvar 1 $a1 a ; \
        br::string text $a(stg.lv)      [format $col2fmt \
        "World |$a(lv)"] }}}

    trace add variable gdata(infomsg) write {apply {{a1 a2 op} { \
        global idsfmt  ; upvar 1 $a1 a ; \
        br::string text $a(stg.infomsg) [format $idsfmt \
        "Info  |$a(infomsg)"] }}}
}

#---------------------------------------------------------------------

# Routine:    start_traces
# Purpose:    Starts traces associated with info display
# Arguments:  None

# This routine initializes some  global variables  associated with the
# program's  information display.  As a side effect,  this  starts the
# Tcl-level traces that run the display.

#---------------------------------------------------------------------

dmproc 1 start_traces {} {
    global gdata lv
                                # Global data connected to traces
    set gdata(health)     100
    set gdata(score)        0
    set gdata(start_time) [clock seconds]
    set gdata(lv)         $lv
    set gdata(infomsg)    "Press h for help"
}

#---------------------------------------------------------------------

# Routine:    setup_program
# Purpose:    Sets up the program
# Arguments:  None

# This routine should be called once, immediately before the program's
# main loop is started.  It handles all program-setup operations  that
# aren't addressed by "non-proc" code.

#---------------------------------------------------------------------

dmproc 1 setup_program {} {
    global gdata
    setup_graphics            ; # Set up graphics
    setup_audio               ; # Set up audio
    setup_keyboard            ; # Set up keyboard
    setup_background          ; # Set up background
    setup_sprite_prototypes   ; # Set up sprite prototypes
                              ; # Make main world
    make_world $gdata(WorldMain) none

    new_ocplayer              ; # Create an ocplayer
    setup_info_display        ; # Set up info display
    display_msg_startup       ; # Display a startup message
    start_traces              ; # Make info display active
}

#---------------------------------------------------------------------

# Routine:    main_routine
# Purpose:    Program's main routine
# Arguments:  None

# This routine handles almost everything:
#
#     (a) Most program-setup operations (*)
#     (b) Main loop
#     (c) Farewell message

# (*) Presently,  some  program-setup operations are handled by  "non-
# proc" code.

#---------------------------------------------------------------------

dmproc 1 main_routine {} {
    global BRICKAPI FPS lv gdata sdata
    setup_program             ; # Set up the program

    while { $gdata(health) > 0 } {
                                # Run callbacks for sprites
        foreach { id callback } [array get sdata *.] {

# The "info exists" test below is  an attempt to prevent callbacks re-
# lated to sprites  that are  removed from  play mid-loop.  It appears
# that the test may not be completely reliable. A sprite that's remov-
# ed may apparently be replaced with a  different sprite which has the
# same sprite ID. If the removal and replacement occur during the same
# iteration, erroneous callbacks may be made. To reduce the chances of
# problems,  the callback routines  have  been  modified  so that they
# simply return if an inconsistency of this type is detected.

            if { [info exists sdata($id)] } {
                set oldlv $lv
                $callback [string trim $id .]
                                # If we've changed worlds,  we need to
                                # exit the inner loop immediately
                if { $oldlv ne $lv } { break }
            }
        }
                                # Take care of necessary business
        foreach objclass $gdata(list_classes_periodic) {
            set cmd new_$objclass
            eval $cmd
        }

        set gdata(time) [expr {[clock seconds] - $gdata(start_time)}]
        br::render display

        if { $BRICKAPI < 5400 } {
            br::delay $FPS
        } else {
            br::clock wait $FPS
        }
    }

    play_sound loser 2600     ; # Play an appropriate sound
    play_sound loser 2600     ; # Twice
    unset gdata(sound_exit)   ; # Disable the normal "exit" sound
                                # Update the status line
    set gdata(infomsg) "Loser!"
                              ; # Display a farewell message
    show_msg " You have perished " 80 80
    quit_program              ; # Quit the program
}

#---------------------------------------------------------------------
# Main program.

# This is the main program.  It simply calls the  main routine,  which
# doesn't return.

main_routine
