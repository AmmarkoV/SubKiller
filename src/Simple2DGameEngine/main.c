#include "Simple2DGameEngine.h"
#include "sound.h"
#include "visuals.h"


int TotalObjects=100;
int LoadedObjects=0;

struct GameObject obj[100];

float meters_per_pixel=11;

int AddObject(float pos_x,float pos_y,float size_x,float size_y,GLuint * texture)
{
  unsigned int cur_obj=LoadedObjects;
  ++LoadedObjects;
  obj[cur_obj].pos_x=pos_x;
  obj[cur_obj].pos_y=pos_y;
  obj[cur_obj].size_x=size_x;
  obj[cur_obj].size_y=size_y;
  obj[cur_obj].texture=*texture;


  return cur_obj;
}

float GetObjectX(unsigned int cur_obj)
{
  return obj[cur_obj].pos_x;
}

float GetObjectY(unsigned int cur_obj)
{
  return obj[cur_obj].pos_y;
}


void AccelerateObject(unsigned int cur_obj,float acc_x,float acc_y)
{
  obj[cur_obj].acc_x=acc_x;
  obj[cur_obj].acc_y=acc_y;

}

void LoadSound(char * path)
{
  AddSoundBufferForLoad(path);
}

void PlaySound(unsigned int sound_id)
{
  SoundLibrary_PlaySound(sound_id);
}



void DrawGame()
{
  DrawGameFrame();
}

void RunGame(unsigned long msec_passed)
{



}


void InitGameEngine()
{
  StartSoundLibrary();
}

void StartGameEngine()
{
  LoadSoundBuffers();
}

