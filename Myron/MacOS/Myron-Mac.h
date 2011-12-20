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

#include "Myron.h"

namespace Myron
{
    class MacWindow : public Window
    {
        NSWindow *win;
        
        friend Window &createWindow(int, int);
        friend class std::vector<MacWindow>;
        
        MacWindow(int width, int height);

    public:
        MacWindow(const MacWindow&) = default;
        MacWindow() = default;
        
        virtual ~MacWindow()
        {
            std::cout << "Destroyed" << std::endl;
        }
        
        virtual int width();
        virtual int height();
        
        NSWindow *windowObject()
        {   return win; }
    };
}

#endif
