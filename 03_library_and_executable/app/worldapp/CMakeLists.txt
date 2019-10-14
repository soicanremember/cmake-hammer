add_executable( worldapp main.cpp )

target_link_libraries( worldapp world )

cmg_set_target_common_defaults( worldapp )