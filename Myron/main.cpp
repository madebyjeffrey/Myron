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

#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <windows.h>
#include <GL/glew.h>
#include <GL/gl.h>
#endif

#include "Myron.h"



bool setup();
bool Resize(Myron::Window &win, int &width, int &height);
bool Close(Myron::Window &win);
bool Render(Myron::Window &win, float dt);
bool KeyDown(Myron::Window &win, uint32_t key);
bool KeyUp(uint32_t key);
void RenderInfo();

bool MouseDown(unsigned x, unsigned y, unsigned button, unsigned count);
bool MouseUp(unsigned x, unsigned y, unsigned button, unsigned count);
bool MouseMove(unsigned x, unsigned y);
bool MouseDrag(unsigned x, unsigned y, unsigned button);


void RenderInfo()
{
	std::cout << "OpenGL Rendering Info" << std::endl;
//    check_error();
	if (glGetString(GL_VENDOR) == NULL) 
	{
		std::cout << "No Vendor String" << std::endl;
		return;
	}
  //  check_error();
	
	std::cout << "Vendor:" << glGetString(GL_VENDOR) << std::endl;
//    check_error();
	std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;
//    check_error();
	std::cout << "Version: " << glGetString(GL_VERSION) << std::endl;
//    check_error();
	std::cout << "Shading Language Version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl << std::endl;
//    check_error();
}

bool setup()
{
    using namespace std::placeholders;
    
    std::cout << "setup()" << std::endl;
    Myron::Window &main = Myron::createWindow(640, 480);
    
    main.events.resize = std::bind(Resize, std::ref(main), _1, _2);
    main.events.close = std::bind(Close, std::ref(main));
    main.events.render = std::bind(Render, std::ref(main), _1);
    main.events.keyDown = std::bind(KeyDown, std::ref(main), _1);
    main.events.mouseDown = MouseDown;
    main.events.mouseUp = MouseUp;
    main.events.mouseDrag = MouseDrag;
    main.events.mouseMove = MouseMove;
    
    main.setRenderRate();
    main.makeContextCurrent();
    
    std::cout << "Function Key F1: " << Myron::Keys::Fn(1) << std::endl;
    
    RenderInfo();
    
    return true;
}

bool KeyDown(Myron::Window &win, uint32_t key)
{
    if ((key & Myron::Keys::KeyMask) == Myron::Keys::Return)
    {
        win.enableMouseMoveEvents();
        std::cout << "Enable Mouse Move" << std::endl;
    }
    else if ((key & Myron::Keys::KeyMask) == 32)
    {
        win.disableMouseMoveEvents();
        std::cout << "Disable Mouse Move" << std::endl;
    }

    std::cout << "Key down: " << Myron::Keys::names.at(key) << std::endl;
    return true;
}

bool KeyUp(uint32_t key)
{
    std::cout << "Key up: " << Myron::Keys::names.at(key) << std::endl;
    return true;
}


bool MouseDown(unsigned x, unsigned y, unsigned button, unsigned count)
{
    std::cout << "Mouse " << button << " down, " << count << " times @ (" << x << ", " << y << ")" << std::endl;
    
    return true;
}

bool MouseUp(unsigned x, unsigned y, unsigned button, unsigned count)
{
    std::cout << "Mouse " << button << " up, " << count << " times @ (" << x << ", " << y << ")" << std::endl;
    
    return true;
}

bool MouseMove(unsigned x, unsigned y)
{
    std::cout << "Mouse moved @ (" << x << ", " << y << ")" << std::endl;
    
    return true;
}

bool MouseDrag(unsigned x, unsigned y, unsigned button)
{
    std::cout << "Mouse " << button << " drag, @ (" << x << ", " << y << ")" << std::endl;
    
    return true;
}


bool Close(Myron::Window &win)
{
    std::cout << "Window Closed" << std::endl;
    return true;
}

bool Resize(Myron::Window &win, int &width, int &height)
{
//    float ar = (float)width / (float)height;
    height = width / 1.66;


    std::cout << "Resize: " << width << ", " << height << std::endl;
    return true;
}

bool Render(Myron::Window &win, float dt)
{
//    std::cout << "Render!" << std::endl;
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1.0, 0, 0, 0);
    return true;
}

int main(int argc, char**argv)
{
    std::cout << "Initialize..." << std::endl;
    
    Myron::Init(setup);
    
    std::cout << "Done Initialize." << std::endl;
}