#!/bin/bash
echo "Making SubKiller.."

Optimizations="-s -O3 -fexpensive-optimizations"
CPU="-mfpmath=sse -mtune=core2 -msse -msse2 -msse3"
 
LIBRARIES="-lglut -lGL -lGLU -lXxf86vm -lopenal -lalut"

cd src
 
g++ $Optimizations SubKillerApp.cpp SubKillerMain.cpp wxGLLoadTextures.cpp sound.cpp $LIBRARIES `wx-config --libs --gl-libs` `wx-config --cxxflags` -L. -o bin/Debug/SubKiller
  
cd ..

echo "Done.."

exit 0
