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
#include <unordered_map>
#include <string>

namespace Myron 
{
    struct Events
    {
        std::function<bool(int&,int&)> resize;
        std::function<bool(void)> close;
        std::function<bool(float)> render;
        std::function<bool(uint32_t)> keyDown;
        std::function<bool(uint32_t)> keyUp;
        // mouseDown :: x -> y -> button -> count
        std::function<bool(unsigned, unsigned, unsigned, unsigned)> mouseDown;
        std::function<bool(unsigned, unsigned, unsigned, unsigned)> mouseUp;
        std::function<bool(unsigned, unsigned)> mouseMove;
        std::function<bool(unsigned, unsigned, unsigned)> mouseDrag;
    };
    
#ifdef _MSC_VER
    // MSC has an issue with std::ref and abstract base class
    class Window
    {
    
        friend Window &createWindow(int width, int height);
    protected:
        Window() {}; // apparently can't use = default; either.
    public:
        virtual ~Window() { };
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
        virtual ~Window() { };
        virtual int width() = 0;
        virtual int height() = 0;

        virtual void showWindow() = 0;

        virtual void setBounds(int x, int y, int cx, int cy) = 0;
        virtual void setFocus() = 0;
        virtual void setRenderRate(float rate = 60) = 0;
        
        virtual void enableMouseMoveEvents() = 0;
        virtual void disableMouseMoveEvents() = 0;
        virtual bool receiveMouseMoveEvents() = 0;
        
        virtual void makeContextCurrent() = 0;
        
        Events events;
    };
#endif
    
    void Init(std::function<bool()> setup);
    Window &createWindow(int width, int height);
    
    namespace Keys
    {
        #ifdef _MSC_VER
            typedef unsigned long uint32_t;
            #define constexpr 
        #endif
        
        extern std::unordered_map<uint32_t, std::string> names;
        
        // catagories of keys
        const uint32_t nav_key = 1;
        const uint32_t function_key = 2;
        
        constexpr uint32_t Fn(uint32_t n);
        const uint32_t KeyMask = (0xFFF);

        const uint32_t ArrowLeft = (nav_key << 8) | 1;
        const uint32_t ArrowRight = (nav_key << 8) | 2;
        const uint32_t ArrowUp = (nav_key << 8) | 3;
        const uint32_t ArrowDown = (nav_key << 8) | 4;
        const uint32_t PageUp = (nav_key << 8) | 5;
        const uint32_t PageDown = (nav_key << 8) | 6;
        const uint32_t Home = (nav_key << 8) | 7;
        const uint32_t End = (nav_key << 8) | 8;
        const uint32_t BackDelete = (nav_key << 8) | 9;
        const uint32_t Backspace = BackDelete;
        const uint32_t ForwardDelete = (nav_key << 8) | 10;
        const uint32_t Tab = (nav_key << 8) | 11;
        const uint32_t Return = (nav_key << 8) | 12;
        const uint32_t Enter = Return;
        const uint32_t Escape = (nav_key << 8) | 13;
        const uint32_t NoKey = 0;
        
        const uint32_t Shift = 1 << 12;
        const uint32_t Control = 1 << 13;
        const uint32_t Alt = 1 << 14;
        const uint32_t Option = Alt;
        const uint32_t Meta = Alt;
        const uint32_t Command = 1 << 15;
        const uint32_t Win = Command;
        const uint32_t Super = Command;
        const uint32_t CapsLock = 1 << 16;
        
        
    }
}


#endif
