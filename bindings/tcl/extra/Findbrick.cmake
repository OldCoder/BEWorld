# - Try to find brick
# Once done this will define
#
#  BRICK_FOUND - system has brick
#  BRICK_INCLUDE_DIRS - the brick include directory
#  BRICK_LIBRARIES - Link these to use brick
#  BRICK_DEFINITIONS - Compiler switches required for using brick
#
#  Copyright (c) 2009, 2010, 2011 Stephen Havelka <steve@rs.tc>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.

set(BRICK_LIBRARIES FALSE)
set(BRICK_INCLUDE_DIRS FALSE)

if (BRICK_LIBRARIES AND BRICK_INCLUDE_DIRS)
  # in cache already
  set(BRICK_FOUND TRUE)
else (BRICK_LIBRARIES AND BRICK_INCLUDE_DIRS)
  find_path(BRICK_INCLUDE_DIR
    NAMES
      brick.h
    PATHS
      __META_INCDIR__
    PATH_SUFFIXES
      brick
  )

  find_library(BR_LIBRARY
    NAMES
      br
    PATHS
      __META_LIBDIR__
  )

  set(BRICK_INCLUDE_DIRS
    ${BRICK_INCLUDE_DIR}
  )
  set(BRICK_LIBRARIES
    ${BR_LIBRARY}
)

  if (BRICK_INCLUDE_DIRS AND BRICK_LIBRARIES)
     set(BRICK_FOUND TRUE)
  endif (BRICK_INCLUDE_DIRS AND BRICK_LIBRARIES)

  if (BRICK_FOUND)
    if (NOT brick_FIND_QUIETLY)
      message(STATUS "Found brick: ${BRICK_LIBRARIES}")
    endif (NOT brick_FIND_QUIETLY)
  else (BRICK_FOUND)
    if (brick_FIND_REQUIRED)
      message(FATAL_ERROR "Could not find brick")
    endif (brick_FIND_REQUIRED)
  endif (BRICK_FOUND)

  # show the BRICK_INCLUDE_DIRS and BRICK_LIBRARIES variables only in the advanced view
  mark_as_advanced(BRICK_INCLUDE_DIRS BRICK_LIBRARIES)

endif (BRICK_LIBRARIES AND BRICK_INCLUDE_DIRS)
