cmake_minimum_required( VERSION 3.11 )

include( ${CMAKE_CURRENT_LIST_DIR}/../cmake/cmake_gadgets.cmake )

project( say_hello VERSION 0.2.0 ) 

set( current_target_public_include_dir ${CMAKE_CURRENT_LIST_DIR}/include )

# set (CMAKE_DEBUG_POSTFIX d) # Todo: this should be an example set up in the cmake configuration step
include (GNUInstallDirs)

add_library( hello include/say_hello/hello.hpp src/hello.cpp )

target_include_directories( hello
	PUBLIC
		$<INSTALL_INTERFACE:include>				# After install, where will the public headers (used by this project, but also applications that may want to link to it) be found?
		$<BUILD_INTERFACE:${current_target_public_include_dir}>	# During build, where will the public headers be found?
	PRIVATE
		${CMAKE_CURRENT_LIST_DIR}/src			# During build, where will the private headers (only used by this porject) be found?
)

set_property( TARGET hello PROPERTY PUBLIC_HEADER  ${current_target_public_include_dir}/say_hello/hello.hpp )
set_property( TARGET hello PROPERTY CMG_INSTALL_INCLUDE_DIR_SUBFOLDER say_hello ) # Subfolder where the public headers will go (for example /usr/include/say_hello) 

cmg_set_target_common_defaults( hello )

# say_hello could be a different name here. Good practice is that it is the same as the project name
# Can use one or more targets
cmg_setup_package_common_install_and_export_targets( say_hello TARGETS hello  )