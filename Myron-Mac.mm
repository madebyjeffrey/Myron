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

static jmp_buf jmpbuf1, jmpbuf2; // don't ask

static void restoreApp()
{
    longjmp(jmpbuf2, 1);
}

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    @public
    std::function<bool()> setupFunc;
}

@end

namespace Myron
{
    AppDelegate *appDelegate;
    
    class MacWindow : public Window
    {
        friend Window *createWindow(int, int);
        
        MacWindow(int width, int height)
        {
            
        }
        
    public:
        
        virtual int width() 
        {
            return 0;
        }
        virtual int height() 
        {
            return 0;
        }
        
        virtual void addEvent(Events e, std::function<bool(Context, int, int)> binary) 
        {
        }

    };
    
    
    
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
    
    Window *createWindow(int width, int height)
    {
        Window *win = new MacWindow(width, height);
        
        return win;
    }
    
}


@implementation AppDelegate

//@synthesize window, width, height;

- (void)application:(NSApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // nothing
}
- (void)application:(NSApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // nothing
}

- (void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // nothing
}

- (void)application:(NSApplication *)app didDecodeRestorableState:(NSCoder *)coder
{
    // nothing
}

- (void)application:(NSApplication *)app willEncodeRestorableState:(NSCoder *)coder
{
    // nothing
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
/*    NSScreen *screen = [NSScreen mainScreen];
    NSRect frame = [screen frame];
    NSRect content = NSMakeRect((frame.size.width + self.width) / 2, 
                                (frame.size.height + self.height) / 2, 
                                self.width, 
                                self.height);
    
    self.window = [NSWindow alloc] initWithContentRect:content styleMask:<#(NSUInteger)#> backing:<#(NSBackingStoreType)#> defer:<#(BOOL)#>*/
    
    if (!setupFunc())
    {
        NSLog(@"Setup returned error. Terminating.");
        [[NSApplication sharedApplication] terminate: nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if (!setjmp(jmpbuf2))
    {
        atexit(restoreApp); // make sure we return after the if statement in case NSApp cleans up other stuff
        
        longjmp(jmpbuf1, 1); // let the user clean up stuff in main()
    }
    
    std::cout << "Finish NSApp" << std::endl;

    
}

@end
