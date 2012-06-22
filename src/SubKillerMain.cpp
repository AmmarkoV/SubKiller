/***************************************************************
 * Name:      SubKillerMain.cpp
 * Purpose:   Code for Application Frame
 * Author:    Ammar Qammaz (ammarkov@gmail.com)
 * Created:   2012-06-19
 * Copyright: Ammar Qammaz (http://ammar.gr)
 * License:
 **************************************************************/

#include "SubKillerMain.h"
#include <wx/msgdlg.h>

#include "Simple2DGameEngine/Simple2DGameEngine.h"
#include "wxGLLoadTextures.h"

#include <iostream>
#include <string>
#include <cassert>
#include <cmath>

#include <wx/wx.h>
#include <wx/glcanvas.h>
#include <wx/notebook.h>


// include OpenGL
#ifdef __WXMAC__
#include "OpenGL/glu.h"
#include "OpenGL/gl.h"
#else
#include <GL/glu.h>
#include <GL/gl.h>
#endif



//(*InternalHeaders(SubKillerFrame)
#include <wx/string.h>
#include <wx/intl.h>
//*)

//helper functions
enum wxbuildinfoformat {
    short_f, long_f };

wxString wxbuildinfo(wxbuildinfoformat format)
{
    wxString wxbuild(wxVERSION_STRING);

    if (format == long_f )
    {
#if defined(__WXMSW__)
        wxbuild << _T("-Windows");
#elif defined(__UNIX__)
        wxbuild << _T("-Linux");
#endif

#if wxUSE_UNICODE
        wxbuild << _T("-Unicode build");
#else
        wxbuild << _T("-ANSI build");
#endif // wxUSE_UNICODE
    }

    return wxbuild;
}

//(*IdInit(SubKillerFrame)
const long SubKillerFrame::ID_STATICTEXT1 = wxNewId();
const long SubKillerFrame::ID_STATICTEXT2 = wxNewId();
const long SubKillerFrame::ID_GLCANVAS1 = wxNewId();
const long SubKillerFrame::idMenuQuit = wxNewId();
const long SubKillerFrame::idMenuAbout = wxNewId();
const long SubKillerFrame::ID_STATUSBAR1 = wxNewId();
//*)

BEGIN_EVENT_TABLE(SubKillerFrame,wxFrame) //
    //(*EventTable(SubKillerFrame)
    //*)
    EVT_IDLE(SubKillerFrame::OnIdle)
    EVT_MOTION(SubKillerFrame::mouseMoved)
    EVT_LEFT_DOWN(SubKillerFrame::mouseDown)
    EVT_LEFT_UP(SubKillerFrame::mouseReleased)
    EVT_RIGHT_DOWN(SubKillerFrame::rightClick)
    EVT_LEAVE_WINDOW(SubKillerFrame::mouseLeftWindow)
    EVT_SIZE(SubKillerFrame::resized)
    EVT_CHAR(SubKillerFrame::keyPressed)
    EVT_KEY_DOWN(SubKillerFrame::keyPressed)
    EVT_KEY_UP(SubKillerFrame::keyReleased)
    EVT_MOUSEWHEEL(SubKillerFrame::mouseWheelMoved)
    EVT_PAINT(SubKillerFrame::render)
END_EVENT_TABLE()

unsigned int x=50;
int init_textures=0;
struct Picture airplane={0};
struct Picture barrel={0};
struct Picture boat={0};
struct Picture sub={0};
struct Picture sky={0};
struct Picture rock_bottom={0};

int SubKillerFrame::getWidth()
{
    return GetSize().x;
}

int SubKillerFrame::getHeight()
{
    return GetSize().y;
}



/** Inits the OpenGL viewport for drawing in 3D. */
void SubKillerFrame::prepare3DViewport(int topleft_x, int topleft_y, int bottomrigth_x, int bottomrigth_y)
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
void SubKillerFrame::prepare2DViewport(int topleft_x, int topleft_y, int bottomrigth_x, int bottomrigth_y)
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


SubKillerFrame::SubKillerFrame(wxWindow* parent,wxWindowID id)
{
    //(*Initialize(SubKillerFrame)
    wxMenuItem* MenuItem2;
    wxMenuItem* MenuItem1;
    wxMenu* Menu1;
    wxMenuBar* MenuBar1;
    wxMenu* Menu2;

    Create(parent, id, _("Sub-Killer!"), wxDefaultPosition, wxDefaultSize, wxDEFAULT_FRAME_STYLE, _T("id"));
    SetClientSize(wxSize(860,565));
    StaticText1 = new wxStaticText(this, ID_STATICTEXT1, _("Label"), wxPoint(24,16), wxDefaultSize, 0, _T("ID_STATICTEXT1"));
    StaticText2 = new wxStaticText(this, ID_STATICTEXT2, _("Label"), wxPoint(80,16), wxDefaultSize, 0, _T("ID_STATICTEXT2"));
    int GLCanvasAttributes_1[] = {
    	WX_GL_RGBA,
    	WX_GL_DOUBLEBUFFER,
    	WX_GL_DEPTH_SIZE,      16,
    	WX_GL_STENCIL_SIZE,    0,
    	0, 0 };
    GLCanvas1 = new wxGLCanvas(this, ID_GLCANVAS1, wxPoint(16,40), wxSize(640,480), 0, _T("ID_GLCANVAS1"), GLCanvasAttributes_1);
    MenuBar1 = new wxMenuBar();
    Menu1 = new wxMenu();
    MenuItem1 = new wxMenuItem(Menu1, idMenuQuit, _("Quit\tAlt-F4"), _("Quit the application"), wxITEM_NORMAL);
    Menu1->Append(MenuItem1);
    MenuBar1->Append(Menu1, _("&File"));
    Menu2 = new wxMenu();
    MenuItem2 = new wxMenuItem(Menu2, idMenuAbout, _("About\tF1"), _("Show info about this application"), wxITEM_NORMAL);
    Menu2->Append(MenuItem2);
    MenuBar1->Append(Menu2, _("Help"));
    SetMenuBar(MenuBar1);
    StatusBar1 = new wxStatusBar(this, ID_STATUSBAR1, 0, _T("ID_STATUSBAR1"));
    int __wxStatusBarWidths_1[1] = { -1 };
    int __wxStatusBarStyles_1[1] = { wxSB_NORMAL };
    StatusBar1->SetFieldsCount(1,__wxStatusBarWidths_1);
    StatusBar1->SetStatusStyles(1,__wxStatusBarStyles_1);
    SetStatusBar(StatusBar1);

    Connect(idMenuQuit,wxEVT_COMMAND_MENU_SELECTED,(wxObjectEventFunction)&SubKillerFrame::OnQuit);
    Connect(idMenuAbout,wxEVT_COMMAND_MENU_SELECTED,(wxObjectEventFunction)&SubKillerFrame::OnAbout);
    //*)

    sw.Start();

    Show(); // This apparently initializes the OpenGL COntext
    GLCanvas1->SetCurrent();


    prepare3DViewport(getWidth()/2,0,getWidth(), getHeight());


       GLCanvas1->SetFocus();

       Connect(this->GetId(),wxEVT_MOTION,wxMouseEventHandler(SubKillerFrame::mouseMoved));
       GLCanvas1->Connect(wxEVT_MOTION,wxMouseEventHandler(SubKillerFrame::mouseMoved));

       this->Connect( wxEVT_KEY_DOWN, wxKeyEventHandler(SubKillerFrame::keyPressed));
       GLCanvas1->Connect( wxEVT_KEY_DOWN, wxKeyEventHandler(SubKillerFrame::keyPressed));


     if (!init_textures)
      {
       InitGameEngine();

       if (!LoadTexture((char *) "textures/airplane.png",&airplane) ) { fprintf(stderr,"Could not load airplane.png..!\n"); }
       if (!LoadTexture((char *) "textures/boat.png",&boat) ) { fprintf(stderr,"Could not load boat.png..!\n"); }
       if (!LoadTexture((char *) "textures/barrel.png",&barrel) ) { fprintf(stderr,"Could not load barrel.png..!\n"); }
       if (!LoadTexture((char *) "textures/sub.png",&sub) ) { fprintf(stderr,"Could not load submarine.png..!\n"); }
       if (!LoadTexture((char *) "textures/sky.png",&sky) ) { fprintf(stderr,"Could not load sky.png..!\n"); }
       if (!LoadTexture((char *) "textures/rock_bottom.png",&rock_bottom) ) { fprintf(stderr,"Could not load rock_bottom.png..!\n"); }
        init_textures=1;

       /* OpenAL Initialization >>>>>>>>>>>>>>>>> */
       char base_directory[256]={0}; strcpy(base_directory,"sounds");
       char filename[256]={0};


       sprintf(filename,"%s/start.wav",base_directory);
       LoadSound((char *)filename); //LOADED_PICTURE

       sprintf(filename,"%s/sonar.wav",base_directory);
       LoadSound((char *)filename); //LOADED_PICTURE

       sprintf(filename,"%s/seadrop.wav",base_directory);
       LoadSound((char *)filename); //SLIDESHOW_START

       sprintf(filename,"%s/explosion.wav",base_directory);
       LoadSound((char *)filename); //SLIDESHOW_STOP


       StartGameEngine();

       PlaySound(0);
      /*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

       AddObject(320,60,96,30,&boat.gl_rgb_texture);
      }


}


void SubKillerFrame::resized(wxSizeEvent& evt)
{
//	wxGLCanvas::OnSize(evt);

    Refresh();
}

void SubKillerFrame::mouseMoved(wxMouseEvent& event) { fprintf(stderr,"-"); }
void SubKillerFrame::mouseDown(wxMouseEvent& event) {}
void SubKillerFrame::mouseWheelMoved(wxMouseEvent& event) {}
void SubKillerFrame::mouseReleased(wxMouseEvent& event) {}
void SubKillerFrame::rightClick(wxMouseEvent& event) {}
void SubKillerFrame::mouseLeftWindow(wxMouseEvent& event) {}

void SubKillerFrame::keyPressed(wxKeyEvent& event)
{
   fprintf(stderr,".");
   int key=event.GetKeyCode();
   if (key==WXK_LEFT) { x-=2; } else
   if (key==WXK_RIGHT) { x+=2; }

}
void SubKillerFrame::keyReleased(wxKeyEvent& event)
{

   fprintf(stderr,"*");
   int key=event.GetKeyCode();
   if (key==WXK_LEFT)  { x-=2; } else
   if (key==WXK_RIGHT) { x+=2; } else
   if (key=='1') {    PlaySound(2); } else
   if (key=='3') {    PlaySound(2); }
}



void DrawSprite(unsigned int x,unsigned int y,unsigned int size_x,unsigned int size_y,struct Picture * pic,unsigned char flip_x)
{
 glBindTexture(GL_TEXTURE_2D, pic->gl_rgb_texture );
 glBegin( GL_QUADS );
  glTexCoord2f(0.0,0.0); glVertex2d(x,y+size_y);
  glTexCoord2f(1.0,0.0); glVertex2d(x+size_x,y+size_y);
  glTexCoord2f(1.0,1.0); glVertex2d(x+size_x,y);
  glTexCoord2f(0.0,1.0); glVertex2d(x,y);
 glEnd();
}



void SubKillerFrame::draw()
{

 GLCanvas1->SetCurrent();


       prepare2DViewport(0,0,640,480);

       glClearColor(0.0, 0.0, 0.98f , 0.0);
	   glClear(GL_COLOR_BUFFER_BIT);


		glLoadIdentity();
      glPushMatrix();

       glEnable(GL_NORMALIZE);
       glShadeModel(GL_SMOOTH);
       glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
       glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
       glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
       glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
       glEnable(GL_COLOR_MATERIAL);

       glEnable(GL_LINE_SMOOTH);
       glEnable (GL_POLYGON_SMOOTH);
       glEnable(GL_ALPHA_TEST);
       glAlphaFunc(GL_GREATER, 0.1);
       glEnable(GL_BLEND);
       glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

  glEnable(GL_CULL_FACE);

glDisable(GL_BLEND);
glDisable ( GL_TEXTURE_2D );
      glColor4f( 0.0, 0.0, 0.98f , 1.0f );
      glBegin( GL_QUADS );
      glVertex2d(0,425);
      glVertex2d(640,425);
      glVertex2d(640,91);
      glVertex2d(0,91);
      glEnd();

glEnable ( GL_TEXTURE_2D );
 glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glColor3f(1.0,1.0,1.0);
      DrawSprite(0,0,640,90,&sky,0);
      DrawSprite(0,426,640,54,&rock_bottom,1);


     DrawGame();

      DrawSprite(320,30,64,16,&airplane,0);;


      DrawSprite(GetObjectX(0),GetObjectY(0),96,30,&boat,0);
      DrawSprite(60,90,4,6,&barrel,0);

      //glColor4f(1.0,1.0,1.0,0.4);
      //DrawSprite(50,110,64,16,&sub,0);
      DrawSprite(50,110,44,20,&sub,0);
      DrawSprite(90,300,44,20,&sub,0);
      DrawSprite(120,140,64,32,&sub,0);

glDisable(GL_BLEND);
glDisable ( GL_TEXTURE_2D );


  glPopMatrix();
  GLCanvas1->SwapBuffers();
}

void SubKillerFrame::OnIdle(wxIdleEvent & event)
{
  RunGame(sw.Time());
		draw();
		event.RequestMore();
}

void SubKillerFrame::render(wxPaintEvent& evt)
{
  RunGame(sw.Time());
		draw();
//		event.RequestMore();
}
SubKillerFrame::~SubKillerFrame()
{
    //(*Destroy(SubKillerFrame)
    //*)
}

void SubKillerFrame::OnQuit(wxCommandEvent& event)
{
    Close();
}

void SubKillerFrame::OnAbout(wxCommandEvent& event)
{
    wxString msg = wxbuildinfo(long_f);
    wxMessageBox(msg, _("Welcome to..."));
}
