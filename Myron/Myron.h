//
//  Myron.h
//  Myron
//
//  Created by Jeffrey Drake on 11-12-16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Myron_Myron_h
#define Myron_Myron_h

#include <functional>

namespace Myron 
{
    class Context
    {
        int nothing;
    };

    struct Events
    {
        std::function<bool(int&,int&)> resize;
        std::function<bool(void)> close;
        std::function<bool(float)> render;
    };
    
    class Window
    {
        friend Window &createWindow(int width, int height);
    public:
        virtual int width() = 0;
        virtual int height() = 0;
        
        virtual void setFrame(int x, int y, int cx, int cy) = 0;
        virtual void setFocus() = 0;
        virtual void setRenderRate(float rate = 60) = 0;
        
        Events events;
    };
    
    void Init(std::function<bool()> setup);
    Window &createWindow(int width, int height);
}


#endif
