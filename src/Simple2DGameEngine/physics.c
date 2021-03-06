#include "Simple2DGameEngine.h"
#include "physics.h"


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned long tick=0;
unsigned long last_msec_passed=0;

void RunPhysics(unsigned long msec_passed)
{
  tick=msec_passed-last_msec_passed;
  last_msec_passed=msec_passed;

  unsigned int cur_obj=0;
  for (cur_obj=0; cur_obj<LoadedObjects; cur_obj++)
  {

  if ((obj[cur_obj].velocity_x!=0)||(obj[cur_obj].velocity_y))
    {
        fprintf(stderr,"Velocity %0.2f - %0.2f \n",obj[cur_obj].velocity_x,obj[cur_obj].velocity_y);
    }

  if ((obj[cur_obj].acc_x!=0)||(obj[cur_obj].acc_y))
    {
        fprintf(stderr,"Acceleration %0.2f - %0.2f \n",obj[cur_obj].acc_x,obj[cur_obj].acc_y);
    }


     obj[cur_obj].velocity_x = obj[cur_obj].acc_x*tick/1000;
     obj[cur_obj].velocity_y = obj[cur_obj].acc_y*tick/1000;


     if (obj[cur_obj].speed_limit)
      {
          if ( ( obj[cur_obj].velocity_x > 0 ) && ( obj[cur_obj].velocity_x > obj[cur_obj].term_velocity_x ) ) { obj[cur_obj].velocity_x=obj[cur_obj].term_velocity_x; } else
          if ( ( obj[cur_obj].velocity_x < 0 ) && ( obj[cur_obj].velocity_x < (-1)*obj[cur_obj].term_velocity_x ) ) { obj[cur_obj].velocity_x=(-1)*obj[cur_obj].term_velocity_x; }

          if ( ( obj[cur_obj].velocity_y > 0 ) && ( obj[cur_obj].velocity_y > obj[cur_obj].term_velocity_y ) ) { obj[cur_obj].velocity_y=obj[cur_obj].term_velocity_y; } else
          if ( ( obj[cur_obj].velocity_y < 0 ) && ( obj[cur_obj].velocity_y < (-1)*obj[cur_obj].term_velocity_y ) ) { obj[cur_obj].velocity_y=(-1)*obj[cur_obj].term_velocity_y; }

      }

     obj[cur_obj].pos_x+= obj[cur_obj].velocity_x*tick/1000;
     obj[cur_obj].pos_y+= obj[cur_obj].velocity_y*tick/1000;



  if (obj[cur_obj].acc_x==0.0) { } else
  if (obj[cur_obj].acc_x > 0 )
   {
     if (obj[cur_obj].acc_x>obj[cur_obj].natural_dec_x) { obj[cur_obj].acc_x-=obj[cur_obj].natural_dec_x; } else
                                                        { obj[cur_obj].acc_x=0.0; fprintf(stderr,"Breaking..!"); }
   } else
    if (obj[cur_obj].acc_x < 0 )
   {
     if (obj[cur_obj].acc_x<(-1*obj[cur_obj].natural_dec_x)) { obj[cur_obj].acc_x+=obj[cur_obj].natural_dec_x; } else
                                                             { obj[cur_obj].acc_x=0.0; fprintf(stderr,"Breaking..!"); }

   }

  if (obj[cur_obj].acc_y==0.0) { } else
  if (obj[cur_obj].acc_y > 0 )
   {
     if (obj[cur_obj].acc_y>obj[cur_obj].natural_dec_y) { obj[cur_obj].acc_y-=obj[cur_obj].natural_dec_y; } else
                                                        { obj[cur_obj].acc_y=0.0; fprintf(stderr,"Breaking..!"); }
   } else
    if (obj[cur_obj].acc_y < 0 )
   {
     if (obj[cur_obj].acc_y<(-1*obj[cur_obj].natural_dec_y)) { obj[cur_obj].acc_y+=obj[cur_obj].natural_dec_y; } else
                                                             { obj[cur_obj].acc_y=0.0; fprintf(stderr,"Breaking..!"); }

   }


  }

}


void StartPhysics()
{

}
