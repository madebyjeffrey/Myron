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
        
//            [appDelegate createMenu];

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

    
}


