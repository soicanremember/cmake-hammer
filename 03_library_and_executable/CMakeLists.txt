cmake_minimum_required( VERSION 3.11 )

include( ${CMAKE_CURRENT_LIST_DIR}/../cmake/cmake_gadgets.cmake )

project( say_world VERSION 0.2.0 )

include (GNUInstallDirs)

add_subdirectory( lib )
add_subdirectory( app )

#Think about breaking this up into two. It can possibly be done
cmg_setup_package_common_install_and_export_targets( say_world TARGETS world )

