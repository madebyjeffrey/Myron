//
//  Myron-Mac.cpp
//  Myron
//
//  Created by Jeffrey Drake on 11-12-16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#include <Cocoa/Cocoa.h>
#include <iostream>
#include <setjmp.h>
#include <stdlib.h>
#include <string.h>


#include "Myron.h"
#include "NSApp.h"

jmp_buf jmpbuf1; // don't ask


CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    static double prev = 0.0;
    
    
    double freq = CVGetHostClockFrequency();
    double now = inOutputTime->hostTime / freq;
    
    if (prev != 0)
    {
        Myron::MacWindow *window = static_cast<Myron::MacWindow*>(displayLinkContext);
        try
        {
            window->makeContextCurrent();
            window->events.render(now - prev);
            [[window->windowView() context] flushBuffer];
        }
        catch (std::bad_function_call)
        {
            std::cout << "No render event set." << std::endl;
        }
    }
    
    prev = now;
    
    return kCVReturnSuccess;
}



namespace Myron
{
    AppDelegate *appDelegate;
    std::vector<Myron::MacWindow*> windowList;

    MacWindow::MacWindow(int width, int height)
    {
        NSScreen *screen = [NSScreen mainScreen];
        NSRect frame = [screen frame];
        NSRect content = NSMakeRect((frame.size.width + width) / 2, 
                                    (frame.size.height + height) / 2, 
                                    width, 
                                    height);
         
        win = [[NSWindow alloc] initWithContentRect: content
                                          styleMask: NSTitledWindowMask |  
                                                     NSClosableWindowMask | 
                                                     NSMiniaturizableWindowMask | 
                                                     NSResizableWindowMask 
                                            backing: NSBackingStoreBuffered 
                                              defer: NO];
        
        view = [[MyronView alloc] initWithFrame: [[win contentView] bounds]];

        std::cout << "Bounds: " << [view frame].origin.x << " " 
                                << [view frame].origin.y << " " 
                                << [view frame].size.width << " " 
                                << [view frame].size.height << " " 
                                << std::endl;
        
        [[win contentView] addSubview: view];
        
        [view setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

        [win makeKeyAndOrderFront: nil];            
        [win makeMainWindow];
        
        [win setDelegate: appDelegate];
        
        keymap = new std::unordered_map<unichar, uint32_t>();
        updateKeyList();
//            [appDelegate createMenu];

    }
    
    void MacWindow::updateKeyList()
    {
        if (keymap)
        {
            std::unordered_map<unichar, uint32_t> &keys = *keymap;
            
            keys[NSUpArrowFunctionKey] = Myron::Keys::ArrowUp;
            keys[NSDownArrowFunctionKey] = Myron::Keys::ArrowDown;
            keys[NSLeftArrowFunctionKey] = Myron::Keys::ArrowLeft;
            keys[NSRightArrowFunctionKey] = Myron::Keys::ArrowRight;
            keys[NSHomeFunctionKey] = Myron::Keys::Home;
            keys[NSEndFunctionKey] = Myron::Keys::End;
            keys[NSPageUpFunctionKey] = Myron::Keys::PageUp;
            keys[NSPageDownFunctionKey] = Myron::Keys::PageDown;
            keys[NSDeleteFunctionKey] = Myron::Keys::ForwardDelete;
            keys[3] = Myron::Keys::Enter; // same as return on PC
            keys[13] = Myron::Keys::Return;
            keys[9] = Myron::Keys::Tab;
            keys[27] = Myron::Keys::Escape;
            keys[127] = Myron::Keys::BackDelete;
            
            for (unichar i = 32; i < 127; i++)
            {
                keys[i] = (uint32_t)i; 
                Keys::names[(uint32_t)i] = std::string(1, (char)(i&0x7F));
            }
            
            for (unichar i = NSF1FunctionKey; i <= NSF35FunctionKey; i++)
            {
                keys[i] = Keys::Fn(i - NSF1FunctionKey + 1);
                Keys::names[Keys::Fn(i - NSF1FunctionKey + 1)] = "F" + std::to_string(i - NSF1FunctionKey + 1);
            }
            
            Keys::names[32] = "Space";
            Keys::names[Keys::ArrowLeft] = "Left Arrow";
            Keys::names[Keys::ArrowRight] = "Right Arrow";
            Keys::names[Keys::ArrowUp] = "Up Arrow";
            Keys::names[Keys::ArrowDown] = "Down Arrow";
            Keys::names[Keys::PageUp] = "Page Up";
            Keys::names[Keys::PageDown] = "Page Down";
            Keys::names[Keys::Home] = "Home";
            Keys::names[Keys::End] = "End";
            Keys::names[Keys::BackDelete] = "Delete";
            Keys::names[Keys::ForwardDelete] = "Forward Delete";
            Keys::names[Keys::Tab] = "Tab";
            Keys::names[Keys::Return] = "Return";
            Keys::names[Keys::Escape] = "Escape";
            Keys::names[Keys::Shift] = "Shift";
            Keys::names[Keys::Control] = "Control";
            Keys::names[Keys::Alt] = "Option";
            Keys::names[Keys::Command] = "Command";
            Keys::names[Keys::NoKey] = "NoKey";
        }
    }
    
    void MacWindow::makeContextCurrent()
    {
        if (view != nullptr)
        {
            @autoreleasepool {
                [view.context setView: view];
                [view.context makeCurrentContext];
            }
        }
    }
        
    int MacWindow::width() 
    {
        NSRect r = [win frame];
        
        return (int)r.size.width;
    }
    
    int MacWindow::height() 
    {
        NSRect r = [win frame];
        
        return (int)r.size.height;
    }
    
    void MacWindow::setBounds(int x, int y, int cx, int cy)
    {
        NSRect r = NSMakeRect(x, y, cx, cy);
        
        [win setFrame: r display: YES animate: YES];
    }
    
    void MacWindow::setFocus()
    {
        [win makeKeyAndOrderFront: win];
    }
    
    void MacWindow::setRenderRate(float rate)
    {
        if (rate == 0)
        { // turn off
            
        } else
        { // we don't care what rate is because we can't control it

            // create updater link
            CGDirectDisplayID displayID = CGMainDisplayID();
            CVReturn error = CVDisplayLinkCreateWithCGDisplay(displayID, &link);
            
            if (error == kCVReturnSuccess)
            {
                CVDisplayLinkSetOutputCallback(link, displayCallback, static_cast<void*>(this));
                CVDisplayLinkStart(link);
            }
            else
            {
                std::cout << "Display Link created with error: %d" << error << std::endl;
                link = NULL;
            }

        }
    }

    void MacWindow::showWindow()
    {
        setFocus();
    }
    
    void Init(std::function<bool()> setup)
    {
        appDelegate = [[AppDelegate alloc] init];
        
        appDelegate->setupFunc = setup;
        
        NSApplication *app = [NSApplication sharedApplication];
        
        [app setDelegate: appDelegate];
        
        if (!setjmp(jmpbuf1))
        {      
            [app run];
        }
        
    }
    
    Window &createWindow(int width, int height)
    {
        
        std::cout << "Create Window" << std::endl;
        std::cout << "Number of Windows: " << windowList.size() << std::endl;
        MacWindow *a = new MacWindow(width, height);
        windowList.push_back(a);
        
        std::cout << "Number of Windows: " << windowList.size() << std::endl;
        
        return *a;
    }
    
    MacWindow* windowForHandle(NSWindow *win)
	{
		for (auto i = begin(windowList); i != end(windowList); i++)
		{
			MacWindow *w = *i;
            
			if (w->windowObject() == win) return w;
		}
		return NULL;
	}

    uint32_t CocoaFlagstoMyron(NSUInteger flags)
    {
        return((flags & NSAlphaShiftKeyMask) ? Myron::Keys::CapsLock : 0) |
        ((flags & NSShiftKeyMask) ? Myron::Keys::Shift : 0) |
        ((flags & NSAlternateKeyMask) ? Myron::Keys::Option : 0) |
        ((flags & NSCommandKeyMask) ? Myron::Keys::Command : 0) |
        ((flags & NSControlKeyMask) ? Myron::Keys::Control : 0);
    }
    
}


