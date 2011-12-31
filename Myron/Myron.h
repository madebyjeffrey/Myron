//
//  Myron.h
//  Myron
//
//  Created by Jeffrey Drake on 11-12-16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Myron_h
#define Myron_h

#include <functional>

namespace Myron 
{
    struct Events
    {
        std::function<bool(int&,int&)> resize;
        std::function<bool(void)> close;
        std::function<bool(float)> render;
    };
    
#ifdef _MSC_VER
    // MSC has an issue with std::ref and abstract base class
    class Window
    {
    
        friend Window &createWindow(int width, int height);
    protected:
        Window() {}; // apparently can't use = default; either.
    public:
        virtual int width() { return 0;};
        virtual int height() { return 0;};

        virtual void showWindow() {};
        
        virtual void setBounds(int x, int y, int cx, int cy) {};
        virtual void setFocus() {};
        virtual void setRenderRate(float rate = 60) {};
        
        virtual void makeContextCurrent() { };
        
        Events events;
    };
#else
    class Window
    {
        friend Window &createWindow(int width, int height);
    public:
        virtual int width() = 0;
        virtual int height() = 0;

        virtual void showWindow() = 0;
        
        virtual void setBounds(int x, int y, int cx, int cy) = 0;
        virtual void setFocus() = 0;
        virtual void setRenderRate(float rate = 60) = 0;
        
        virtual void makeContextCurrent() = 0;
        
        Events events;
    };
#endif
    
    void Init(std::function<bool()> setup);
    Window &createWindow(int width, int height);
    
    namespace Keys
    {
        // catagories of keys
        const uint32_t function_key = 2;
        
        constexpr uint32_t Fn(uint32_t n);
    }
}


#endif
