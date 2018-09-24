project( subkillergame ) 
cmake_minimum_required( VERSION 2.8.7 ) 
# Extend cmake's module path
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/modules ${CMAKE_MODULE_PATH})
    
add_executable(subkillergame  
               SubKillerApp.cpp
               SubKillerMain.cpp
               wxGLLoadTextures.cpp 
              ) 
 

 SET(wxWidgets_USE_LIBS)   
 FIND_PACKAGE(wxWidgets COMPONENTS net gl core base)
 IF(wxWidgets_FOUND)
   INCLUDE("${wxWidgets_USE_FILE}") 
   target_link_libraries(subkillergame ${wxWidgets_LIBRARIES} Simple2DGameEngine )
   # and for each of your dependant executable/library targets: 
 ELSE(wxWidgets_FOUND)
   # For convenience. When we cannot continue, inform the user
   MESSAGE("wxWidgets not found!")
 ENDIF(wxWidgets_FOUND)


set_target_properties(subkillergame PROPERTIES 
                       DEBUG_POSTFIX "D"
                       ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                       LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                       RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                      )


#    install(TARGETS flashyslideshowsgui
#                    LIBRARY DESTINATION lib
#                    ARCHIVE DESTINATION lib
#                    RUNTIME DESTINATION bin)

