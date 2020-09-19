/***************************************************************
 * Name:      SubKillerMain.h
 * Purpose:   Defines Application Frame
 * Author:    Ammar Qammaz (ammarkov@gmail.com)
 * Created:   2012-06-19
 * Copyright: Ammar Qammaz (http://ammar.gr)
 * License:
 **************************************************************/

#ifndef SUBKILLERMAIN_H
#define SUBKILLERMAIN_H

//(*Headers(SubKillerFrame)
#include <wx/button.h>
#include <wx/frame.h>
#include <wx/glcanvas.h>
#include <wx/menu.h>
#include <wx/stattext.h>
#include <wx/statusbr.h>
#include <wx/timer.h>
//*)

#include <wx/stopwatch.h>

class SubKillerFrame: public wxFrame
{
    public:
        wxStopWatch sw;

        SubKillerFrame(wxWindow* parent,wxWindowID id = -1);
        virtual ~SubKillerFrame();

        int getWidth();
        int getHeight();

        void draw();
        void render(wxPaintEvent& evt);
        void OnIdle(wxIdleEvent & event);
        void prepare3DViewport(int topleft_x, int topleft_y, int bottomrigth_x, int bottomrigth_y);
        void prepare2DViewport(int topleft_x, int topleft_y, int bottomrigth_x, int bottomrigth_y);

        void resized(wxSizeEvent& evt);

        void mouseMoved(wxMouseEvent& event);
        void mouseDown(wxMouseEvent& event);
        void mouseWheelMoved(wxMouseEvent& event);
        void mouseReleased(wxMouseEvent& event);
        void rightClick(wxMouseEvent& event);
        void mouseLeftWindow(wxMouseEvent& event);
        void keyPressed(wxKeyEvent& event);
        void keyReleased(wxKeyEvent& event);
    private:

        //(*Handlers(SubKillerFrame)
        void OnQuit(wxCommandEvent& event);
        void OnAbout(wxCommandEvent& event);
        void OnTickTimerTrigger(wxTimerEvent& event);
        void OnButtonQuitClick(wxCommandEvent& event);
        //*)

        //(*Identifiers(SubKillerFrame)
        static const long ID_STATICTEXT1;
        static const long ID_STATICTEXT2;
        static const long ID_GLCANVAS1;
        static const long ID_BUTTON1;
        static const long idMenuQuit;
        static const long idMenuAbout;
        static const long ID_STATUSBAR1;
        static const long ID_TIMER1;
        //*)

        //(*Declarations(SubKillerFrame)
        wxButton* ButtonQuit;
        wxGLCanvas* GLCanvas1;
        wxStaticText* StaticText1;
        wxStaticText* StaticText2;
        wxStatusBar* StatusBar1;
        wxTimer TickTimer;
        //*)

        DECLARE_EVENT_TABLE()
};

#endif // SUBKILLERMAIN_H
