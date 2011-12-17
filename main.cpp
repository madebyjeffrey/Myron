//
//  main.cpp
//  Myron
//
//  Created by Jeffrey Drake on 11-12-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <iostream>

#include "Myron.h"

bool setup();

using namespace std;

bool setup()
{
    cout << "setup()" << endl;
    
    return false;
}

int main(int argc, char**argv)
{
    cout << "Initialize..." << endl;
    
    Myron::Init(setup);
    
    cout << "Done Initialize." << endl;
}