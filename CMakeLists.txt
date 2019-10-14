cmake_minimum_required( VERSION 3.11 )

project( cmake-hammer VERSION 0.1.0 )

set( EP_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/Install )

function ( external_add  FOLDER_NAME )
include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)
	ExternalProject_Add( 
		${FOLDER_NAME}
	SOURCE_DIR 
		${CMAKE_CURRENT_SOURCE_DIR}/${FOLDER_NAME}
	CMAKE_ARGS
		-DCMAKE_INSTALL_PREFIX=${EP_INSTALL_DIR}
	)
endfunction()

external_add( 01_simple_executable )
external_add( 02_simple_library )
external_add( 03_library_and_executable )
