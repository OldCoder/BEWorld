prefix=${CMAKE_INSTALL_PREFIX}
exec_prefix=${CMAKE_INSTALL_PREFIX}/bin
libdir=${CMAKE_INSTALL_PREFIX}/lib
includedir=${CMAKE_INSTALL_PREFIX}/include

Name: The brick engine
Description: The brick engine is a fast, simple, and powerful lo-fi game engine.
URL: http://rs.tc/br/
Version: ${brick_version}
Requires:
Conflicts:
Libs: -L${CMAKE_INSTALL_PREFIX}/lib -lbr
Cflags: -I${CMAKE_INSTALL_PREFIX}/include
