cmake_policy( SET CMP0048  NEW )

set( cmake_gadgets_source_dir ${CMAKE_CURRENT_LIST_DIR} )

function( cmg_fatal_error MSG )
    message( FATAL_ERROR "[cmage_gadgets]: " ${MSG} )
endfunction()

function( cmg_redefinition_error VAR )
    message( FATAL_ERROR "[cmage_gadgets]: " "Attempt to redefine: ${VAR}"  )
endfunction()

function( cmg_redefinition_check VAR )
    if (DEFINED "${VAR}" )
        redefinition_error( ${VAR} )
    endif()
endfunction()


#! cmg_set_target_common_defaults : Will set common defaults using the current project properties
function ( cmg_set_target_common_defaults targetnames )

    message( STATUS "[cmage_gadgets]: Set EXPORT_NAME of target ${targetname}  to: ${PROJECT_NAME}::${targetname}" )

	# Not needed, covered by namespace in export: 
    # set_target_properties (${targetname} PROPERTIES EXPORT_NAME ${PROJECT_NAME}::${targetname})

    if ( NOT DEFINED "${PROJECT_NAME}_VERSION" )
        cmg_fatal_error( "${PROJECT_NAME}_VERSION is not defined. Please use project( <project-name> VERSION <major>.<minor>.<patch>)... ")
    endif()

    if ( NOT DEFINED "${PROJECT_NAME}_VERSION_MAJOR" )
        cmg_fatal_error( "${PROJECT_NAME}_VERSION_MAJOR is not defined. Please use cmg_generate_version_variables. ")
    endif()

	foreach( targetname ${targetnames} )
		set_target_properties (
			${targetname} 
			PROPERTIES 
				VERSION "${${PROJECT_NAME}_VERSION_MAJOR}"
				SOVERSION "${${PROJECT_NAME}_VERSION_STRING}"
		)
		message( STATUS "[cmage_gadgets]: Set VERSION of target ${targetname}  to: ${${PROJECT_NAME}_VERSION_MAJOR}" )
		message( STATUS "[cmage_gadgets]: Set SOVERSION of target ${targetname}  to: ${${PROJECT_NAME}_VERSION}" )

    endforeach()

    
endfunction()

function ( cmg_setup_package_common_install_and_export_targets cmg_package_name  )

	string(TOLOWER ${cmg_package_name} cmg_package_name_lower ) 
	if ( NOT ${cmg_package_name} STREQUAL ${cmg_package_name_lower} )
		cmg_fatal_error( "cmg_package_name (${cmg_package_name}) should be provided in lower-case.") # This is because cmake searches the config files like: <lower_case_package_name>-config.cmake
	endif()

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs TARGETS )
    cmake_parse_arguments(
	cmg_setup_package_common_install_and_export_targets "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    set( targetnames ${cmg_setup_package_common_install_and_export_targets_TARGETS} )
    
	foreach( t ${targetnames} )
		get_target_property( version ${t} VERSION )

		if ( NOT version AND NOT ${version} STREQUAL "0")
			cmg_fatal_error( "Target ${t} does not have VERSION set. Please manually set it or use: cmg_set_target_common_defaults( ${t} ) for reasonable defaults." )
		endif()

		get_target_property( soversion ${t} SOVERSION )
		if ( NOT soversion AND NOT ${soversion} STREQUAL "0")
			cmg_fatal_error( "Target ${t} does not have SOVERSION set. Please manually set it or use: cmg_set_target_common_defaults( ${t} ) for reasonable defaults." )
		endif()

	endforeach()

	message(STATUS "[cmake tools]: Setting up install and export for target(s):" )
    foreach( t ${targetnames} )
        message(STATUS "[cmake tools]:    " ${t} )
    endforeach()

    if( ${cmg_package_name}_LOCK )
        cmg_fatal_error( "Cannot run cmg_setup_common_install_targets on the same package twice (${cmg_package_name}). The need to do may indicate that you should not be using the simplification provided by cmake_gadgets.")
    endif()

    set( ${cmg_package_name}_LOCK TRUE PARENT_SCOPE)

    set( generated_dir ${CMAKE_CURRENT_BINARY_DIR} ) # TODO: IF WE SET THIS TO SOMETHING ELSE, THEN THE CMAKE CONFIG MAY NOT BE ABLE TO FIND THE TARGETS FILE. MAYBE DO SOMETHING LIKE $<INSTALL_INTERFACE:include> $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>

    set( targets_file_name ${cmg_package_name}-targets.cmake )

    set( package_config_file_name		${cmg_package_name}-config.cmake )
    set( package_config_full_file_name	${generated_dir}/${package_config_file_name})

    set( version_config_file_name		${cmg_package_name}-config-version.cmake )
    set( version_config_full_file_name	${generated_dir}/${version_config_file_name})

    set( config_install_dir				${CMAKE_INSTALL_LIBDIR}/cmake/${cmg_package_name} )

    foreach( target ${targetnames} )
        get_target_property( include_subfolder ${target} CMG_INSTALL_INCLUDE_DIR_SUBFOLDER )

        install (
			TARGETS ${target}
            EXPORT	${cmg_package_name}-targets
            PUBLIC_HEADER DESTINATION	${CMAKE_INSTALL_INCLUDEDIR}/${include_subfolder} COMPONENT Development
            RUNTIME DESTINATION			${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
            LIBRARY DESTINATION			${CMAKE_INSTALL_LIBDIR} COMPONENT Development
            ARCHIVE DESTINATION			${CMAKE_INSTALL_LIBDIR} COMPONENT Development
            )
    endforeach()

    message( STATUS "[cmage_gadgets]: Setup install targets: " ${targetnames} )
    message( STATUS "[cmage_gadgets]:     with an export of: " ${cmg_package_name}-targets)

    include (CMakePackageConfigHelpers)

    configure_package_config_file ( 
		${cmake_gadgets_source_dir}/cmake_gadgets_config.cmake.in
        ${package_config_full_file_name}
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${cmg_package_name} )

    message( STATUS "[cmage_gadgets]: Config file name: " ${package_config_file_name} )
    message( STATUS "[cmage_gadgets]:     with INSTALL_DESTINATION: " ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/cmake/${cmg_package_name})

    write_basic_package_version_file (
		${version_config_full_file_name} 
		COMPATIBILITY SameMajorVersion 
	)

    message( STATUS "[cmage_gadgets]: Package version file: " ${cmg_package_name}-config-version.cmake )

    export(
		TARGETS		${targetnames} 
		NAMESPACE	${cmg_package_name}:: 
		FILE		${targets_file_name} 
	)

    install (
		EXPORT		${cmg_package_name}-targets 
		NAMESPACE	${cmg_package_name}::
		DESTINATION "${config_install_dir}"
	)

    install( 
		FILES 
			${version_config_full_file_name}  
			${package_config_full_file_name} 
		DESTINATION   "${config_install_dir}"  
	)

endfunction()


