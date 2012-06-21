#ifndef WXGLLOADTEXTURES_H_INCLUDED
#define WXGLLOADTEXTURES_H_INCLUDED

#include <GL/glu.h>


struct Picture
{
  unsigned int height,width,depth;
  unsigned int initial_height,initial_width;

  unsigned char is_jpeg;
  unsigned char mirror;

  float default_rotate,rotate,target_rotate;

  float transparency; /* 0.0 -> 1.0 */


  unsigned int failed_to_load;


  unsigned long rgb_data_size;
  char * rgb_data;
  GLuint gl_rgb_texture;

};

int LoadTexture(char * filename,struct Picture * pic);

#endif // WXGLLOADTEXTURES_H_INCLUDED
