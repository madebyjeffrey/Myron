//
//  NSApp.h
//  Myron
//
//  Created by Jeffrey Drake on 11-12-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Myron_NSApp_h
#define Myron_NSApp_h

#include <vector>
#include "Myron.h"

#include "Myron-Mac.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
@public
    std::function<bool()> setupFunc;
}
-(void) createMenu;

-(NSString *) applicationName;
//- (Myron::MacWindow *) windowObjectFor: (NSWindow*) window;
@end


#endif
