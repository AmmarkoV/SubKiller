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

void SetNaturalDeccelerationObject(unsigned int cur_obj,float dec_x,float dec_y)
{
  obj[cur_obj].natural_dec_x=dec_x;
  obj[cur_obj].natural_dec_y=dec_y;
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
  unsigned int cur_obj=0;
  for (cur_obj=0; cur_obj<LoadedObjects; cur_obj++)
  {
     obj[cur_obj].velocity_x = obj[cur_obj].acc_x*msec_passed/1000;
     obj[cur_obj].velocity_y = obj[cur_obj].acc_y*msec_passed/1000;


  if (obj[cur_obj].acc_x < 0 )
   {
     if (obj[cur_obj].acc_x>obj[cur_obj].natural_dec_x) { obj[cur_obj].acc_x-=obj[cur_obj].natural_dec_x; } else
                                                        { obj[cur_obj].acc_x=0; }
   } else
    if (obj[cur_obj].acc_x > 0 )
   {
     if (obj[cur_obj].acc_x<(-1*obj[cur_obj].natural_dec_x)) { obj[cur_obj].acc_x+=obj[cur_obj].natural_dec_x; } else
                                                             { obj[cur_obj].acc_x=0; }

   }

  if (obj[cur_obj].acc_y < 0 )
   {
     if (obj[cur_obj].acc_y>obj[cur_obj].natural_dec_y) { obj[cur_obj].acc_y-=obj[cur_obj].natural_dec_y; } else
                                                        { obj[cur_obj].acc_y=0; }
   } else
    if (obj[cur_obj].acc_y > 0 )
   {
     if (obj[cur_obj].acc_y<(-1*obj[cur_obj].natural_dec_y)) { obj[cur_obj].acc_y+=obj[cur_obj].natural_dec_y; } else
                                                             { obj[cur_obj].acc_y=0; }

   }
  }

}


void InitGameEngine()
{
  StartSoundLibrary();
}

void StartGameEngine()
{
  LoadSoundBuffers();
}

