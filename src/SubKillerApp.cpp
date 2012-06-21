/***************************************************************
 * Name:      SubKillerApp.cpp
 * Purpose:   Code for Application Class
 * Author:    Ammar Qammaz (ammarkov@gmail.com)
 * Created:   2012-06-19
 * Copyright: Ammar Qammaz (http://ammar.gr)
 * License:
 **************************************************************/

#include "SubKillerApp.h"

//(*AppHeaders
#include "SubKillerMain.h"
#include <wx/image.h>
//*)

IMPLEMENT_APP(SubKillerApp);

bool SubKillerApp::OnInit()
{
    //(*AppInitialize
    bool wxsOK = true;
    wxInitAllImageHandlers();
    if ( wxsOK )
    {
    	SubKillerFrame* Frame = new SubKillerFrame(0);
    	Frame->Show();
    	SetTopWindow(Frame);
    }
    //*)
    return wxsOK;

}
