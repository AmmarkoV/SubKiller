#include "wxGLLoadTextures.h"
#include <wx/image.h>

#include <cmath>

static bool is_first_time = true;


inline wxString _U(const char String[] = "")
{
  return wxString(String, wxConvUTF8);
}

int WxLoadImage(char * filename,struct Picture * pic)
{

 wxImage new_img;
 if (! new_img.LoadFile(_U(filename)) )
  {
      fprintf(stderr,"Could not load file %s \n",filename);
      return 0;
  } else
  {
      fprintf(stderr,"Loaded file %s \n",filename);
  }

 unsigned int width = new_img.GetWidth();
 unsigned int height = new_img.GetHeight();
 pic->initial_width=width;
 pic->initial_height=height;
 unsigned int rescale_ratio=100;//PickPictureRescaleRatio(width,height);

 width  = (unsigned int) (width  * rescale_ratio / 100);
 height = (unsigned int) (height * rescale_ratio / 100);
 new_img.Rescale(width,height);

 unsigned char * data = new_img.GetData();

 //if ( pic->rgb_data!=0 ) { free(pic->rgb_data); pic->rgb_data=0; }

 pic->rgb_data = (char * ) malloc (width*height*3*sizeof(char) );


 memcpy(pic->rgb_data,data,width*height*3);
 pic->width=width;   // Width has been changed!
 pic->height=height; // Height has been changed!


 return 1;
}



int complain_about_errors()
{
  int err=glGetError();
  if  ( err!=0 ) fprintf(stderr,"OpenGL Error %u ",(unsigned int )err);
  return err;
}


int printoutOGLErr(unsigned int errnum)
{
  switch (errnum)
  {
     case GL_NO_ERROR          : fprintf(stderr,"No Error\n"); break;
     case GL_INVALID_ENUM      : fprintf(stderr,"An unacceptable value is specified for an enumerated argument. The offending command is ignored and has no other side effect than to set the error flag.\n");  break;
     case GL_INVALID_VALUE     : fprintf(stderr,"A numeric argument is out of range. The offending command is ignored and has no other side effect than to set the error flag. \n");  break;
     case GL_INVALID_OPERATION : fprintf(stderr,"The specified operation is not allowed in the current state.The offending command is ignored and has no other side effect than to set the error flag.\n");  break;
     case GL_STACK_OVERFLOW    : fprintf(stderr,"This command would cause a stack overflow. The offending command is ignored and has no other side effect than to set the error flag. \n");  break;
     case GL_STACK_UNDERFLOW   : fprintf(stderr,"This command would cause a stack underflow. The offending command is ignored and has no other side effect than to set the error flag. \n");  break;
     case GL_OUT_OF_MEMORY     : fprintf(stderr,"There is not enough memory left to execute the command. The state of the GL is undefined, except for the state of the error flags, after this error is recorded. \n");  break;
     case GL_TABLE_TOO_LARGE   : fprintf(stderr,"The specified table exceeds the implementation's maximum supported table size.  The offending command is ignored and has no other side effect than to set the error flag. \n");  break;
  };
  return 1;
}

int make_texture(struct Picture * picturedata,int enable_mipmaping)
{

	if ( picturedata == 0 ) { fprintf(stderr,"Error making texture from picture , accomodation structure is not allocated\n");
	                          return 0; }

    glEnable(GL_TEXTURE_2D);

    GLuint new_tex_id=0;
    glGenTextures(1,&new_tex_id);
    if ( complain_about_errors() ) { return 0; }

    glBindTexture(GL_TEXTURE_2D,new_tex_id);
    if ( complain_about_errors() ) { return 0; }
    glFlush();

    picturedata->gl_rgb_texture=new_tex_id;
	if ( new_tex_id == 0 ) { fprintf(stderr,"Error making texture from picture glGenTextures returned zero \n");
	                          return 0; }

    unsigned int depth_flag=GL_RGB;
    char * rgba_data = picturedata->rgb_data;

  unsigned int error_num=0;
  fprintf(stderr,"Making texture .. ");
  if (  enable_mipmaping == 1  )
   {
      /* LOADING TEXTURE --WITH-- MIPMAPING */
      glPixelStorei(GL_UNPACK_ALIGNMENT,1);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);                      // GL_RGB
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, picturedata->width , picturedata->height, 0, depth_flag, GL_UNSIGNED_BYTE, (const GLvoid *) rgba_data);
      error_num=glGetError();
      if  ( error_num!=0 ) { printoutOGLErr(error_num); fprintf(stderr,"Creating texture %ux%u:%u ( initial %ux%u )\n",picturedata->width,picturedata->height,depth_flag,picturedata->initial_width,picturedata->initial_height); return 0; }
   } else
   {
      /* LOADING TEXTURE --WITHOUT-- MIPMAPING - IT IS LOADED RAW*/
      glPixelStorei(GL_UNPACK_ALIGNMENT,1);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);                       //GL_RGB
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, picturedata->width , picturedata->height, 0, depth_flag, GL_UNSIGNED_BYTE,(const GLvoid *) rgba_data);
      error_num=glGetError();
      if  ( error_num!=0 ) { printoutOGLErr(error_num); fprintf(stderr,"Creating texture %ux%u:%u ( initial %ux%u )\n",picturedata->width,picturedata->height,depth_flag,picturedata->initial_width,picturedata->initial_height); return 0; }
   }

    /* PICTURE IS LOADED IN GPU SO WE CAN UNLOAD IT FROM MAIN RAM MEMORY */
      if ( picturedata->rgb_data != 0 )
        {
          free(picturedata->rgb_data);
          picturedata->rgb_data=0;
          picturedata->rgb_data_size=0;
        }

    if ( complain_about_errors() ) { return 0; }

    glFlush();
    fprintf(stderr,"done\n");
    return 1;
}


int LoadTextureNONAlpha(char * filename,struct Picture * pic)
{
  if (WxLoadImage(filename,pic))
   {
      return make_texture(pic,0);
   }
 return 0;
}




GLuint* loadImage(wxString path, int* imageWidth, int* imageHeight, int* textureWidth, int* textureHeight)
{

	GLuint* ID=new GLuint[1];
	glGenTextures( 1, &ID[0] );

	glBindTexture( GL_TEXTURE_2D, *ID );

	// the first time, init image handlers (remove this part if you do it somewhere else in your app)

	if(is_first_time)
	{
		wxInitAllImageHandlers();

		is_first_time = false;
	}

	// check the file exists
	if(!wxFileExists(path)) { return(0); }

	wxImage* img=new wxImage( path );

	(*imageWidth)=img->GetWidth();
	(*imageHeight)=img->GetHeight();

	glPixelStorei(GL_UNPACK_ALIGNMENT,   1   );

    /*
     * Many graphics card require that textures be power of two.
     * Below is a simple implementation, probably not optimal but working.
     * If your texture sizes are not restricted to power of 2s, you can
     * of course adapt the bit below as needed.
     */

    if (img->HasAlpha()) {fprintf(stderr,"Image has alpha channel!\n");}

	float power_of_two_that_gives_correct_width=std::log((float)(*imageWidth))/std::log(2.0);
	float power_of_two_that_gives_correct_height=std::log((float)(*imageHeight))/std::log(2.0);

        // check if image dimensions are a power of two
        if( (int)power_of_two_that_gives_correct_width == power_of_two_that_gives_correct_width &&
            (int)power_of_two_that_gives_correct_height == power_of_two_that_gives_correct_height)
        {
                // note: must make a local copy before passing the data to OpenGL, as GetData() returns RGB
                // and we want the Alpha channel if it's present. Additionally OpenGL seems to interpret the
                // data upside-down so we need to compensate for that.
                GLubyte *bitmapData=img->GetData();
                GLubyte *alphaData=img->GetAlpha();

                int bytesPerPixel = img->HasAlpha() ?  4 : 3;

                int imageSize = (*imageWidth) * (*imageHeight) * bytesPerPixel;
                GLubyte *imageData=new GLubyte[imageSize];

                int rev_val=(*imageHeight)-1;

                for(int y=0; y<(*imageHeight); y++)
                {
                        for(int x=0; x<(*imageWidth); x++)
                        {
                                imageData[(x+y*(*imageWidth))*bytesPerPixel+0]=
                                        bitmapData[( x+(rev_val-y)*(*imageWidth))*3];

                                imageData[(x+y*(*imageWidth))*bytesPerPixel+1]=
                                        bitmapData[( x+(rev_val-y)*(*imageWidth))*3 + 1];

                                imageData[(x+y*(*imageWidth))*bytesPerPixel+2]=
                                        bitmapData[( x+(rev_val-y)*(*imageWidth))*3 + 2];

                                if(bytesPerPixel==4) imageData[(x+y*(*imageWidth))*bytesPerPixel+3]=
                                        alphaData[ x+(rev_val-y)*(*imageWidth) ];
                        }//next
                }//next

                // if yes, everything is fine
                glTexImage2D(GL_TEXTURE_2D,
                             0,
                             bytesPerPixel,
                             *imageWidth,
                             *imageHeight,
                             0,
                             img->HasAlpha() ?  GL_RGBA : GL_RGB,
                             GL_UNSIGNED_BYTE,
                             imageData);

                (*textureWidth)  = (*imageWidth);
                (*textureHeight) = (*imageHeight);

                delete [] imageData;
        }
	else // texture is not a power of two. We need to resize it
	{

		int newWidth=(int)std::pow( 2.0, (int)(std::ceil(power_of_two_that_gives_correct_width)) );
		int newHeight=(int)std::pow( 2.0, (int)(std::ceil(power_of_two_that_gives_correct_height)) );

		//printf("Unsupported image size. Recommand values: %i %i\n",newWidth,newHeight);

		GLubyte	*bitmapData=img->GetData();
		GLubyte        *alphaData=img->GetAlpha();

		int old_bytesPerPixel = 3;
		int bytesPerPixel = img->HasAlpha() ?  4 : 3;

		int imageSize = newWidth * newHeight * bytesPerPixel;
		GLubyte	*imageData=new GLubyte[imageSize];

		int rev_val=(*imageHeight)-1;

		for(int y=0; y<newHeight; y++)
		{
			for(int x=0; x<newWidth; x++)
			{

				if( x<(*imageWidth) && y<(*imageHeight) ){
					imageData[(x+y*newWidth)*bytesPerPixel+0]=
					bitmapData[( x+(rev_val-y)*(*imageWidth))*old_bytesPerPixel + 0];

					imageData[(x+y*newWidth)*bytesPerPixel+1]=
						bitmapData[( x+(rev_val-y)*(*imageWidth))*old_bytesPerPixel + 1];

					imageData[(x+y*newWidth)*bytesPerPixel+2]=
						bitmapData[( x+(rev_val-y)*(*imageWidth))*old_bytesPerPixel + 2];

					if(bytesPerPixel==4) imageData[(x+y*newWidth)*bytesPerPixel+3]=
						alphaData[ x+(rev_val-y)*(*imageWidth) ];

				}
				else
				{

					imageData[(x+y*newWidth)*bytesPerPixel+0] = 0;
					imageData[(x+y*newWidth)*bytesPerPixel+1] = 0;
					imageData[(x+y*newWidth)*bytesPerPixel+2] = 0;
					if(bytesPerPixel==4) imageData[(x+y*newWidth)*bytesPerPixel+3] = 0;
				}

			}//next
		}//next


		glTexImage2D(GL_TEXTURE_2D,
					 0,
					 img->HasAlpha() ?  4 : 3,
					 newWidth,
					 newHeight,
					 0,
					 img->HasAlpha() ?  GL_RGBA : GL_RGB,
					 GL_UNSIGNED_BYTE,
					 imageData);

		(*textureWidth)=newWidth;
		(*textureHeight)=newHeight;

		delete [] imageData;
	}

	// set texture parameters as you wish
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); // GL_LINEAR
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST); // GL_LINEAR

	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    //glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);

	return ID;

}


int LoadTexture(char * filename,struct Picture * pic)
{
  //return LoadTextureNONAlpha(filename,pic);

  int imageWidth, imageHeight, textureWidth, textureHeight;
  GLuint* tex =  loadImage(_U(filename), &imageWidth, &imageHeight,&textureWidth, &textureHeight);
  if (tex==0) { return 0; }
  pic->gl_rgb_texture = *tex;
  delete tex;

  fprintf(stderr,"Texture %s has a size of %ux%u and tex res %u \n",filename,textureWidth,textureHeight,pic->gl_rgb_texture);
  pic->width=textureWidth;
  pic->height=textureHeight;

  return 1;

}


