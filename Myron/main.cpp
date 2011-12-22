//
//  main.cpp
//  Myron
//
//  Created by Jeffrey Drake on 11-12-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#include <iostream>
#include <functional>
#include <string>
#include <type_traits>

#include "Myron.h"

bool setup();
bool Resize(Myron::Window *win, int &width, int &height);
bool Close(Myron::Window &win);
bool Render(Myron::Window &win, float dt);

bool setup()
{
    using namespace std::placeholders;
    
    std::cout << "setup()" << std::endl;
    Myron::Window &main = Myron::createWindow(640, 480);
    
    main.events.resize = std::bind(Resize, &main, _1, _2);
    main.events.close = std::bind(Close, std::ref(main));
    main.events.render = std::bind(Render, std::ref(main), _1);
    
    main.setRenderRate();
    
    return true;
}

bool Close(Myron::Window &win)
{
    std::cout << "Window Closed" << std::endl;
    return true;
}

bool Resize(Myron::Window *win, int &width, int &height)
{
//    float ar = (float)width / (float)height;
    height = (int)(width / 1.66);

    std::cout << "Resize: " << width << ", " << height << std::endl;
    return true;
}

bool Render(Myron::Window &win, float dt)
{
    std::cout << "Render!" << std::endl;
    return true;
}

int main(int argc, char**argv)
{
    std::cout << "Initialize..." << std::endl;
    
    Myron::Init(setup);
    
    std::cout << "Done Initialize." << std::endl;
}