//
//  Myron.h
//  Myron
//
//  Created by Jeffrey Drake on 11-12-16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Windows_Myron_h
#define Windows_Myron_h

#include <vector>
#include <functional>
#include <Windows.h>
#include <tchar.h>
#include <iostream>


#include "../Myron.h"

namespace Myron 
{
 	const _TCHAR *className = _T("WinWindow");
    

    class WinWindow : public Window
    {
		HINSTANCE hInstance;
		HWND hWnd;
        friend Window &createWindow(int width, int height);
    public:
		WinWindow() : hInstance(NULL), hWnd(NULL) { }
        WinWindow(int width, int height);
		bool registerClass();
		bool createWindow(int width, int height);

		HWND handle() { return hWnd; }
        virtual void showWindow();

        virtual int width();
        virtual int height();
        
        virtual void setFrame(int x, int y, int cx, int cy);
        virtual void setFocus();
        virtual void setRenderRate(float rate = 60);
    };

	std::vector<WinWindow*> windowList;
    
    void Init(std::function<bool()> setup);
    Window &createWindow(int width, int height);
	Window* windowForHandle(HWND hWnd);
}


#endif
