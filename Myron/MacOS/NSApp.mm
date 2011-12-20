//
//  NSApplication.mm
//  Myron
//
//  Created by Jeffrey Drake on 11-12-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//  Menu creation functions from: http://lapcatsoftware.com/main/Home.html

#include <iostream>
#include <setjmp.h>

#include <Cocoa/Cocoa.h>

#include "NSApp.h"
#include "NSApp-Menus.h"

#include "Myron.h"

static jmp_buf jmpbuf2;
extern jmp_buf jmpbuf1;

static void restoreApp()
{
    longjmp(jmpbuf2, 1);
}


@implementation AppDelegate

- (id) init
{
    self = [super init];
    
    if (self)
    {
        windowList = new std::vector<Myron::MacWindow*>();
    
    }

    return self;
    
}

- (void) dealloc
{
    delete windowList;
}

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
    [self createMenu];
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


-(NSString *) applicationName
{
	static NSString * applicationName = nil;
	
	if (applicationName == nil)
	{
		applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
		if (applicationName == nil)
		{
			NSLog(@"[[NSBundle mainBundle] objectForInfoDictionaryKey:@\"CFBundleName\"] == nil");
			applicationName = NSLocalizedString(@"Nibless", @"The name of this application");
		}
	}
	
	return applicationName;
}


- (void) createMenu
{
    // from lapcat software sample
    
    NSMenu * mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];
	
	NSMenuItem * menuItem;
	NSMenu * submenu;
	
	// The titles of the menu items are for identification purposes only and shouldn't be localized.
	// The strings in the menu bar come from the submenu titles,
	// except for the application menu, whose title is ignored at runtime.
	menuItem = [mainMenu addItemWithTitle:@"Apple" action:NULL keyEquivalent:@""];
	submenu = [[NSMenu alloc] initWithTitle:@"Apple"];
	[NSApp performSelector:@selector(setAppleMenu:) withObject:submenu];
	[self populateApplicationMenu:submenu];
	[mainMenu setSubmenu:submenu forItem:menuItem];
	
	menuItem = [mainMenu addItemWithTitle:@"Window" action:NULL keyEquivalent:@""];
	submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Window", @"The Window menu")];
	[self populateWindowMenu:submenu];
	[mainMenu setSubmenu:submenu forItem:menuItem];
	[NSApp setWindowsMenu:submenu];
	
	menuItem = [mainMenu addItemWithTitle:@"Help" action:NULL keyEquivalent:@""];
	submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Help", @"The Help menu")];
	[self populateHelpMenu:submenu];
	[mainMenu setSubmenu:submenu forItem:menuItem];
	
	[NSApp setMainMenu:mainMenu];
}


/**************** NS WINDOW DELEGATE ****************/

- (Myron::MacWindow *) windowObjectFor: (NSWindow*) window
{
    for (Myron::MacWindow * n : *windowList)
    {
        NSWindow *win = n->windowObject();
        if (win == window)
        {
            return n;
        }
    }
    return nullptr;
    
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    Myron::MacWindow *win = [self windowObjectFor: sender];
    
    if (win != nullptr)
    {
        int x = (int)frameSize.width;
        int y = (int)frameSize.height;
        
        try {
            auto result = win->events.resize(x,y);
            
            if (result)
            {
                return NSMakeSize((float)x, (float)y);
            }

        } catch (std::bad_function_call) {
            
            std::cout << "No registered resize event." << std::endl;
        }
    }
    return frameSize;
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *obj = [notification object];
    
    for (Myron::MacWindow* n : *windowList)
    {
        NSWindow *win = n->windowObject();
        if (win == obj)
        {
            NSRect r = [win frame];
            // n is our object!
            int x = (int)r.size.width;
            int y = (int)r.size.height;
            
            try {
                n->events.resize(x,y);
            }
            catch (std::bad_function_call)
            {
                std::cout << "No resize function registered" << std::endl;
            }
        }
    }    
}

- (void)windowWillClose:(NSNotification *)notification
{
    Myron::MacWindow *win = [self windowObjectFor: notification.object];
    
    try {
        win->events.close();
    } 
    catch (std::bad_function_call)
    {
        std::cout << "No registered close function" << std::endl;
    }
}

@end
