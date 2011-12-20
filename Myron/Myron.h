//
//  Myron.h
//  Myron
//
//  Created by Jeffrey Drake on 11-12-16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Myron_Myron_h
#define Myron_Myron_h

#include <boost/signals2.hpp>
#include <functional>

namespace bs2 = boost::signals2;

namespace Myron 
{
    class Context
    {
        int nothing;
    };
    
    class Window
    {
        friend Window &createWindow(int width, int height);
    public:
        virtual int width() = 0;
        virtual int height() = 0;
        
        bs2::signal<bool(int&,int&)> resize;
        bs2::signal<bool()> close;
        
//        virtual void addEvent(Events e, std::function<bool(int&, int&)> binary) = 0; // resize
//        virtual void addEvent(Events e, std::function<bool()> nullary) = 0;           // close
    };
    
    void Init(std::function<bool()> setup);
    Window &createWindow(int width, int height);
}


#endif
