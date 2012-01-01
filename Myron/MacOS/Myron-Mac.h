//
//  Myron-Mac.h
//  Myron
//
//  Created by Jeffrey Drake on 11-12-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Myron_Myron_Mac_h
#define Myron_Myron_Mac_h

#include <Cocoa/Cocoa.h>
#include <functional>
#include <unordered_map>

#include <CoreVideo/CoreVideo.h>

#include "Myron.h"
#include "MyronView.h"

namespace Myron
{
    class MacWindow : public Window
    {
        NSWindow *win;
        MyronView *view;
        std::unordered_map<unichar, uint32_t> *keymap;

        CVDisplayLinkRef link;
        
        friend Window &createWindow(int, int);
        friend class std::vector<MacWindow>;
        
        MacWindow(int width, int height);

    public:
        MacWindow(const MacWindow&) = default;
        MacWindow() = default;
        
        virtual ~MacWindow()
        {
            delete keymap;
            std::cout << "Destroyed" << std::endl;
        }
        
        virtual int width();
        virtual int height();

        virtual void showWindow();
        
        virtual void setBounds(int x, int y, int cx, int cy);
        virtual void setFocus();
        virtual void setRenderRate(float rate = 60);
        
        virtual void makeContextCurrent();

        void updateKeyList();
        
        NSWindow *windowObject()
        {   return win; }
        MyronView *windowView()
        {   return view; }
    };
    
    MacWindow* windowForHandle(NSWindow *win);
}

#endif
