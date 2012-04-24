
# use the local Findbrick.cmake for now ..
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/extra")


# include SDL .. (necessary for win32)
find_package(SDL REQUIRED)

# and Tcl ..
find_package(TCL REQUIRED)

# and of course Brick.
find_package(brick REQUIRED)

# and set up the include-directories
include_directories (${BRICK_INCLUDE_DIR} ${TCL_INCLUDE_PATH} ${SDL_INCLUDE_DIR})





# If building the module ..
if (TCL_MOD)

  # note: can't build an extension on os x ..
  if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    message (FATAL_ERROR "Can't be built as an extension on OS X")
  endif (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

  # find the stubs library
  find_package(TclStub REQUIRED)

  # add the source files
  add_library (tcl-mod SHARED tcl-mod.c tcl-common.c)

  # set some specific options for the module
  set_property (TARGET tcl-mod PROPERTY COMPILE_DEFINITIONS BUILD_DLL USE_TCL_STUBS)
  set_target_properties (tcl-mod PROPERTIES PREFIX "")
  set_target_properties (tcl-mod PROPERTIES OUTPUT_NAME "br")

  # and include the stubs library.
  target_link_libraries (tcl-mod ${BRICK_LIBRARIES} ${TCL_STUB_LIBRARY} ${SDL_LIBRARY})

  # last, deposit the library into the right place
  set_target_properties (tcl-mod PROPERTIES LIBRARY_OUTPUT_DIRECTORY ../src-out)


  # and, post-build, generate the pkgIndex.tcl !!  kind of hackish.
  add_custom_command (TARGET tcl-mod
                      POST_BUILD
                      COMMAND ${TCL_TCLSH} ../extra/mkpkg.tcl
                      WORKING_DIRECTORY src-out)

endif (TCL_MOD)



# If building the executable ..
if (TCL_EXE)

  # add the source files
  add_executable (tcl-exe main.c tcl-common.c)
  install_targets (/bin tcl-exe)

  # set some options for the executable
  set_target_properties (tcl-exe PROPERTIES OUTPUT_NAME "brick-tcl")

  # and include the tcl library.
  target_link_libraries (tcl-exe ${SDL_LIBRARY} ${SDLMAIN_LIBRARY} ${BRICK_LIBRARIES} ${TCL_LIBRARY})

  # last, deposit the executable into the right place
  set_target_properties (tcl-exe PROPERTIES RUNTIME_OUTPUT_DIRECTORY ../src-out)

endif (TCL_EXE)
