set( current_target world )

set(  current_target_public_headers ${current_project_public_include_dir}/say_world/world.hpp)
file( GLOB current_target_hpp_files *.hpp )
file( GLOB current_target_cpp_files *.cpp )

add_library( ${current_target} 	
	${current_target_public_headers} 
	${current_target_hpp_files} 
	${current_target_cpp_files} 
)

target_include_directories( ${current_target}
	PUBLIC
		$<BUILD_INTERFACE:${current_project_public_include_dir}>
		$<INSTALL_INTERFACE:include>
	PRIVATE
		${CMAKE_CURRENT_LIST_DIR}
)

set_property( TARGET ${current_target} PROPERTY PUBLIC_HEADER ${current_target_public_headers} )
set_property( TARGET ${current_target} PROPERTY CMG_INSTALL_INCLUDE_DIR_SUBFOLDER say_world )

cmg_set_target_common_defaults( ${current_target} )