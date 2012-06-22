#include "Simple2DGameEngine.h"
#include "visuals.h"


/** Inits the OpenGL viewport for drawing in 3D. */
void prepare3DViewport(int topleft_x, int topleft_y, int bottomrigth_x, int bottomrigth_y)
{

    glClearColor(0.0f, 0.0f, 0.98f, 1.0f); // Black Background
    glClearDepth(1.0f);	// Depth Buffer Setup
    glEnable(GL_DEPTH_TEST); // Enables Depth Testing
    glDepthFunc(GL_LEQUAL); // The Type Of Depth Testing To Do
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

    glEnable(GL_COLOR_MATERIAL);

    glViewport(topleft_x, topleft_y, bottomrigth_x-topleft_x, bottomrigth_y-topleft_y);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    float ratio_w_h = (float)(bottomrigth_x-topleft_x)/(float)(bottomrigth_y-topleft_y);
    gluPerspective(45 /*view angle*/, ratio_w_h, 0.1 /*clip close*/, 200 /*clip far*/);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

}

/** Inits the OpenGL viewport for drawing in 2D. */
void prepare2DViewport(int topleft_x, int topleft_y, int bottomrigth_x, int bottomrigth_y)
{
    //glClearColor(0.0f, 0.0f, 0.98f , 1.0f); // Black Background
    glEnable(GL_TEXTURE_2D);   // textures
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

    glViewport(topleft_x, topleft_y, bottomrigth_x-topleft_x, bottomrigth_y-topleft_y);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    gluOrtho2D(topleft_x, bottomrigth_x, bottomrigth_y, topleft_y);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}



void DrawSprite(float x,float y,float size_x,float size_y,GLuint * texture,unsigned char flip_x)
{
 glBindTexture(GL_TEXTURE_2D, *texture );
 glBegin( GL_QUADS );
  glTexCoord2f(0.0,0.0); glVertex2f(x,y+size_y);
  glTexCoord2f(1.0,0.0); glVertex2f(x+size_x,y+size_y);
  glTexCoord2f(1.0,1.0); glVertex2f(x+size_x,y);
  glTexCoord2f(0.0,1.0); glVertex2f(x,y);
 glEnd();
}



void DrawGameFrame()
{
 unsigned int cur_obj=0;
 for (cur_obj=0; cur_obj<LoadedObjects; cur_obj++)
  {
    DrawSprite
     ( obj[cur_obj].pos_x,
       obj[cur_obj].pos_y,
       obj[cur_obj].pos_x+obj[cur_obj].size_x,
       obj[cur_obj].pos_y+obj[cur_obj].size_y,
       &obj[cur_obj].texture,
       0
     );
  }
}
