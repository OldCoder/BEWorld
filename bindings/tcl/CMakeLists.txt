# The project
project (tcl-br C)
set (tcl-br_version 5.4)
set(BRICK_INCLUDE_DIR __META_INCDIR__)

# Some cmake-directives
cmake_minimum_required(VERSION 2.6)

if (COMMAND cmake_policy)
    cmake_policy (SET CMP0003 OLD)
endif (COMMAND cmake_policy)

# Options
option (TCL_MOD "Build as Tcl extension" OFF)
option (TCL_EXE "Build as binary" ON)

# Catch a nonsensical error
if (NOT TCL_MOD AND NOT TCL_EXE)
    message (FATAL_ERROR "At least one build option must be selected")
endif (NOT TCL_MOD AND NOT TCL_EXE)

# Add subdirectory (or subdirectories)
add_subdirectory(src)
