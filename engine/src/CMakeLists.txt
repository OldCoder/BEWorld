
# Include SDL..
find_package(SDL REQUIRED)
find_package(SDL_mixer REQUIRED)



# Add the library sources ..
set (SRCS audio.c clock.c collision.c event.c font.c frame.c graphics.c
          init.c inspect.c io.c layers.c list.c map.c misc.c motion.c
          pixel.c pixel-le.c pixel-be.c render.c sprite.c string.c tile.c)
set (INCLUDES ${CMAKE_SOURCE_DIR}/include ${SDL_INCLUDE_DIR} ${SDLMIXER_INCLUDE_DIR})
set (LIBS ${SDL_LIBRARY} ${SDLMIXER_LIBRARY})



# Enable accelerated blit ..
if (WITH_GL)
  find_package (OpenGL REQUIRED)
  set (INCLUDES ${INCLUDES} ${OPENGL_INCLUDE_DIR})
  set (LIBS ${LIBS} ${OPENGL_gl_LIBRARY})
endif (WITH_GL)



# Enable SIMD ..
if (WITH_SIMD)
  add_definitions(-mmmx)
endif (WITH_SIMD)



# Enable SDL_image component ..
if (WITH_IMAGE)
  find_package(SDL_image REQUIRED)
  set (INCLUDES ${INCLUDES} ${SDLIMAGE_INCLUDE_DIR})
  set (LIBS ${LIBS} ${SDLIMAGE_LIBRARY})
endif (WITH_IMAGE)



# Prepare the target
add_library (br SHARED ${SRCS})
target_link_libraries (br ${LIBS})
include_directories (${INCLUDES})
install_targets (/lib br)



# Set the library version
if (brick_version)
  set_target_properties (br PROPERTIES SOVERSION ${brick_version})
endif (brick_version)
