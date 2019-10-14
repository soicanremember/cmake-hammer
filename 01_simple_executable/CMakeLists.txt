cmake_minimum_required( VERSION 3.11 )

project( 01_simple_executable VERSION 1.0.0 LANGUAGES CXX )

add_executable( helloapp 
hello.hpp 
hello.cpp 
main.cpp 
)

include ( GNUInstallDirs )
install ( TARGETS helloapp RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} )