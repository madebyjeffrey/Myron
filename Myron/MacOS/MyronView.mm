//
//  MyronView.m
//  Myron
//
//  Created by Jeffrey Drake on 11-12-22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <map>
#include <stdexcept>

#include "Myron.h"
#include "Myron-Mac.h"

#import "MyronView.h"

uint32_t cocoaKeyToMyronKey(unichar c);

@implementation MyronView

@synthesize context;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // create the basic context
        
        NSOpenGLPixelFormatAttribute att[] = 
        {
            NSOpenGLPFAWindow,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADepthSize, 24,
            NSOpenGLPFANoRecovery,
            NSOpenGLPFAAccelerated,
            0
        };
        
        NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:att]; 
        
        self.context = [[NSOpenGLContext alloc] initWithFormat: pixelFormat shareContext: nil];

        GLint swapInterval = 1; // request synchronization 
        //long swapInterval = 0; // disable synchronization  
        
        [self.context setValues:&swapInterval forParameter: NSOpenGLCPSwapInterval];        
        
        return self;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

#pragma mark Keyboard Events

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *chars = [theEvent charactersIgnoringModifiers];
    
    if ([chars length] == 1)
    {
        unichar c = [[theEvent charactersIgnoringModifiers] characterAtIndex: 0];
        Myron::MacWindow *win = Myron::windowForHandle([self window]);
        
        if (win && win->keys())
        {
            auto haveKey = win->keys()->find(c);
            
            if (haveKey != win->keys()->end()) // have a key
            {
                if (win->events.keyDown)
                {
                    win->events.keyDown(haveKey->second);
                }
                else
                {
                    std::cout << "No key down event" << std::endl;
                }
            }
            else {
                std::cout << "Out of Range Char: " << (unsigned)c << std::endl;
            }
        }
    }
}

- (void)keyUp:(NSEvent *)theEvent
{
    NSString *chars = [theEvent charactersIgnoringModifiers];
    
    if ([chars length] == 1)
    {
        unichar c = [[theEvent charactersIgnoringModifiers] characterAtIndex: 0];
        Myron::MacWindow *win = Myron::windowForHandle([self window]);
        
        if (win && win->keys())
        {
            auto haveKey = win->keys()->find(c);
            
            if (haveKey != win->keys()->end()) // have a key
            {
                if (win->events.keyUp)
                {
                    win->events.keyUp(haveKey->second | Myron::CocoaFlagstoMyron([theEvent modifierFlags]));   
                }
                else
                {
                    std::cout << "No key up event" << std::endl;
                }

            }
            else {
                std::cout << "Out of Range Char: " << (unsigned)c << std::endl;
            }
        }
    }
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    Myron::MacWindow *win = Myron::windowForHandle([self window]);
    
    if (win)
    {
        if ((bool)win->events.keyDown)
        {
            win->events.keyDown(Myron::CocoaFlagstoMyron([theEvent modifierFlags]));   
        }
        else
        {
            std::cout << "No key down event" << std::endl;
        }
    }
}

#pragma mark Mouse Events

- (void)mouseDown:(NSEvent *)theEvent
{
    [self otherMouseDown: theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self otherMouseUp: theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self otherMouseDragged: theEvent];
}


- (void)rightMouseDown:(NSEvent *)theEvent
{
    [self otherMouseDown: theEvent];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [self otherMouseUp: theEvent];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    [self otherMouseDragged: theEvent];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
    Myron::MacWindow *win = Myron::windowForHandle([self window]);
    
    if (win)
    {
        if ((bool)win->events.mouseUp)
        {
            NSPoint loc = [NSEvent mouseLocation];
            unsigned count = [theEvent clickCount];
            unsigned button = [theEvent buttonNumber];
            
            win->events.mouseUp(static_cast<unsigned>(loc.x), static_cast<unsigned>(loc.y),
                                button, count);
            
        }
        else
        {
            std::cout << "No mouse up event" << std::endl;
        }
    }
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    Myron::MacWindow *win = Myron::windowForHandle([self window]);
    
    if (win)
    {
        if ((bool)win->events.mouseDown)
        {
            NSPoint loc = [NSEvent mouseLocation];
            unsigned count = [theEvent clickCount];
            unsigned button = [theEvent buttonNumber];
            
            win->events.mouseDown(static_cast<unsigned>(loc.x), 
                                  static_cast<unsigned>(loc.y),
                                  button, count);
            
        }
        else
        {
            std::cout << "No mouse down event" << std::endl;
        }
    }    
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    Myron::MacWindow *win = Myron::windowForHandle([self window]);
    
    if (win)
    {
        if ((bool)win->events.mouseDrag)
        {
            NSPoint loc = [NSEvent mouseLocation];
            unsigned button = [theEvent buttonNumber];
            
            win->events.mouseDrag(static_cast<unsigned>(loc.x), 
                                  static_cast<unsigned>(loc.y),
                                  button);
        }
        else
        {
            std::cout << "No mouse drag event" << std::endl;
        }
    }    
}

- (void) mouseMoved:(NSEvent *)theEvent
{
    Myron::MacWindow *win = Myron::windowForHandle([self window]);
    
    if (win)
    {
        if ((bool)win->events.mouseMove)
        {
            NSPoint loc = [NSEvent mouseLocation];
            
            win->events.mouseMove(static_cast<unsigned>(loc.x), 
                                  static_cast<unsigned>(loc.y));
        }
        else
        {
            std::cout << "No mouse move event" << std::endl;
        }
    }    
    
}


#pragma mark Mouse Gestures

- (void)magnifyWithEvent:(NSEvent *)event
{
    
}

- (void)rotateWithEvent:(NSEvent *)event
{
    
}

- (void)swipeWithEvent:(NSEvent *)event
{
    
}


- (BOOL)acceptsFirstResponder
{
    return YES;
}


@end

uint32_t cocoaKeyToMyronKey(unichar c)
{
    
    return 0;
}

