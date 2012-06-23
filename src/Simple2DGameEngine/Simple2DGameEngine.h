#ifndef SIMPLE2DGAMEENGINE_H_INCLUDED
#define SIMPLE2DGAMEENGINE_H_INCLUDED


#include <GL/glu.h>
#include <GL/gl.h>

#ifdef __cplusplus
extern "C" {
#endif

struct GameObject
{
  float pos_x,pos_y;
  float size_x,size_y;

  float acc_x,acc_y; // meters per second^2
  float natural_dec_x,natural_dec_y; // meters per second^2
  float velocity_x,velocity_y; // meters per second

  unsigned char speed_limit;
  float term_velocity_x,term_velocity_y; // meters per second

  float weight; //kg

  GLuint texture;
};


extern float meters_per_pixel;

extern int TotalObjects;
extern int LoadedObjects;
extern struct GameObject obj[100];




int AddObject(float pos_x,float pos_y,float size_x,float size_y,GLuint * texture);


float GetObjectX(unsigned int cur_obj);
float GetObjectY(unsigned int cur_obj);
void AccelerateObject(unsigned int cur_obj,float acc_x,float acc_y);
void SetNaturalDeccelerationObject(unsigned int cur_obj,float dec_x,float dec_y);


void LoadSound(char * path);
void PlaySound(unsigned int sound_id);

void DrawGame();
void RunGame(unsigned long msec_passed);

void InitGameEngine();
void StartGameEngine();


#ifdef __cplusplus
}
#endif

#endif // SIMPLE2DGAMEENGINE_H_INCLUDED
