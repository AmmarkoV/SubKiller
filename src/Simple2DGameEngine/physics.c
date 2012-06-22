#include "Simple2DGameEngine.h"
#include "physics.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void RunPhysics(unsigned long msec_passed)
{

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


     obj[cur_obj].velocity_x = obj[cur_obj].acc_x*msec_passed/1000;
     obj[cur_obj].velocity_y = obj[cur_obj].acc_y*msec_passed/1000;

     obj[cur_obj].pos_x+= obj[cur_obj].velocity_x*msec_passed/1000;
     obj[cur_obj].pos_y+= obj[cur_obj].velocity_y*msec_passed/1000;



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
