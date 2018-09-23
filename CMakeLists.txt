project( SubKiller ) 
cmake_minimum_required( VERSION 2.8.7 )

OPTION (ENABLE_OPTIMIZATIONS OFF) 

add_subdirectory (src/Simple2DGameEngine)
#This is the core application 
add_subdirectory (src/) 
   


#INSTALL(PROGRAMS "src/flashyslideshows" DESTINATION "/usr/bin" ) 
#INSTALL(PROGRAMS "src/FlashySlideShowStarter/flashyslideshowsgui" DESTINATION "/usr/bin" ) 

#INSTALL(DIRECTORY "app_clipart" DESTINATION "/usr/share/flashyslideshows/" DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE )   
#INSTALL(DIRECTORY "sounds" DESTINATION "/usr/share/flashyslideshows/"  DIRECTORY_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE ) 
 

#INSTALL(FILES "app_clipart/flashyicon.png" DESTINATION "/usr/share/icons/" ) 
#INSTALL(FILES "FlashySlideshows.desktop" DESTINATION "/usr/share/applications/" ) 
 
