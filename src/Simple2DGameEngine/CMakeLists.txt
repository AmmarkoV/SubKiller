project( Simple2DGameEngine ) 
cmake_minimum_required( VERSION 2.8.7 ) 
# Extend cmake's module path
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/modules ${CMAKE_MODULE_PATH})
    


add_library(Simple2DGameEngine 
               main.c
               physics.c
               sound.c
               visuals.c 
            ) 
 
 
target_link_libraries(Simple2DGameEngine pthread glut GL GLU GLEW Xxf86vm openal alut rt  )
  


set_target_properties(Simple2DGameEngine PROPERTIES 
                       DEBUG_POSTFIX "D"
                       ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                       LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                       RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                      )
 
#add_dependencies(Simple2DGameEngine ${WEB_LIBS} Codecs)    


#    install(TARGETS AmmarServer
#                    LIBRARY DESTINATION lib
#                    ARCHIVE DESTINATION lib
#                    RUNTIME DESTINATION bin)

