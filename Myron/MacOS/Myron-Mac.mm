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



namespace Myron
{
    AppDelegate *appDelegate;
    

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
        

        [win makeKeyAndOrderFront: nil];            
        [win makeMainWindow];
        
        [win setDelegate: appDelegate];
        
//            [appDelegate createMenu];

    }
        
    int MacWindow::width() 
    {
        return 0;
    }
    
    int MacWindow::height() 
    {
        return 0;
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
        std::cout << "Number of Windows: " << appDelegate->windowList->size() << std::endl;
        MacWindow *a = new MacWindow(width, height);
        appDelegate->windowList->push_back(a);
        
        std::cout << "Number of Windows: " << appDelegate->windowList->size() << std::endl;
        
        return *a;
    }
    
}


