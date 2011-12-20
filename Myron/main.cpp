//
//  main.cpp
//  Myron
//
//  Created by Jeffrey Drake on 11-12-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#include <iostream>
#include <functional>

#include <boost/bind.hpp>

#include "Myron.h"

bool setup();
bool resize(Myron::Window &win, int &width, int &height);
bool close(Myron::Window &win);


bool setup()
{
//    namespace p = std::placeholders;
//    using namespace std::placeholders;
    
    std::cout << "setup()" << std::endl;
    Myron::Window &main = Myron::createWindow(640, 480);
//    main.addEvent(Myron::Events::Resize, std::bind(resize, std::ref(main), _1, _2));
//    main.resize.connect(std::bind(resize, std::ref(main), p::_1, p::_2));
    main.resize.connect(boost::bind(resize, std::ref(main), _1, _2));
//    if (main.resize.empty())
//    {
//        std::cout << "signal is empty" << std::endl;
//    }
    main.close.connect(std::bind(close, std::ref(main)));
    return true;
}

bool close(Myron::Window &win)
{
    std::cout << "Window Closed" << std::endl;
}

bool resize(Myron::Window &win, int &width, int &height)
{
    std::cout << "Resize: " << width << ", " << height << std::endl;
    return true;
}



int main(int argc, char**argv)
{
    std::cout << "Initialize..." << std::endl;
    
    Myron::Init(setup);
    
    std::cout << "Done Initialize." << std::endl;
}