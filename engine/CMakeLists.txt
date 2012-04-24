# The project
project (brick C)
set (brick_version 5.4)

# Some cmake-directives
cmake_minimum_required(VERSION 2.6)

if (COMMAND cmake_policy)
    cmake_policy (SET CMP0003 OLD)
endif (COMMAND cmake_policy)

# Options
option (WITH_GL "Enable accelerated blit" ON)
option (WITH_SIMD "Enable SIMD-accelerated rendering" ON)
option (WITH_IMAGE "Include SDL_image support" ON)
option (WITH_SDL13 "Use SDL 1.3" OFF)

set (DISPLAY_MAX_WIDTH 640 CACHE STRING "Display width limit")
set (DISPLAY_MAX_HEIGHT 480 CACHE STRING "Display height limit")

mark_as_advanced (FORCE DISPLAY_MAX_WIDTH)
mark_as_advanced (FORCE DISPLAY_MAX_HEIGHT)

# Set platform-appropriate OpenGL flags
if (WITH_GL)
    if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	    set (OSX_BLIT on)
    else (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        set (GL_BLIT on)
    endif (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
endif (WITH_GL)

# Add subdirectories
add_subdirectory(src)
add_subdirectory(include)
add_subdirectory(extra)

# Check processor and endianness
include (TestBigEndian)
test_big_endian (is_big_endian)

# Prepare config file
configure_file (${CMAKE_SOURCE_DIR}/include/config.h.cmake ${CMAKE_SOURCE_DIR}/include/config.h)

# Prepare library header file
file (READ ${CMAKE_SOURCE_DIR}/src/defines.h pub-defines)
file (READ ${CMAKE_SOURCE_DIR}/src/types.h pub-types)
configure_file (${CMAKE_SOURCE_DIR}/include/brick.h.cmake ${CMAKE_SOURCE_DIR}/include/brick.h)

# Prepare pkgconfig file
configure_file (${CMAKE_SOURCE_DIR}/extra/brick.pc.cmake ${CMAKE_SOURCE_DIR}/extra/brick.pc)
