//
//  MyronView.m
//  Myron
//
//  Created by Jeffrey Drake on 11-12-22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <map>

#include "Myron.h"
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

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *chars = [theEvent charactersIgnoringModifiers];
    
    if ([chars length] == 1)
    {
        char c = [chars cStringUsingEncoding: NSUTF8StringEncoding][0];
        
        std::cout << " Char: " << (unsigned)c << std::endl;
    }
    //    std::cout << "Length of chars: " << [[theEvent charactersIgnoringModifiers] length] << std::endl;
    
}

- (void)keyUp:(NSEvent *)theEvent
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

