#!/bin/bash
echo "Making SubKiller.."

Optimizations="-s -O3 -fexpensive-optimizations"
CPU="-mfpmath=sse -mtune=core2 -msse -msse2 -msse3"
 
LIBRARIES="-lm -lalut -lopenal -lGL -lGLU -lglut -lXxf86vm"

cd src
  
cd Simple2DGameEngine
./make
cd ..

g++ $Optimizations $CPU SubKillerApp.cpp SubKillerMain.cpp wxGLLoadTextures.cpp Simple2DGameEngine/libSimple2DGameEngine.a -L. $LIBRARIES `wx-config --libs --gl-libs` `wx-config --cxxflags`  -o bin/Debug/SubKiller
  
cd ..
echo "Done.."
exit 0
