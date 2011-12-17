//
//  Myron-Mac.cpp
//  Myron
//
//  Created by Jeffrey Drake on 11-12-16.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//  Menu creation functions from: http://lapcatsoftware.com/main/Home.html

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

-(void) populateSpellingMenu:(NSMenu *)aMenu;
- (void) createMenu;
-(void) populateApplicationMenu:(NSMenu *)aMenu;
-(void) populateEditMenu:(NSMenu *)aMenu;
-(void) populateFileMenu:(NSMenu *)aMenu;
-(void) populateFindMenu:(NSMenu *)aMenu;
-(void) populateWindowMenu:(NSMenu *)aMenu;
-(void) populateHelpMenu:(NSMenu *)aMenu;
-(NSString *) applicationName;

@end

namespace Myron
{
    AppDelegate *appDelegate;
    
    class MacWindow : public Window
    {
        NSWindow *win;
        std::function<bool(int,int)> resize;
        
        friend Window *createWindow(int, int);
        
        MacWindow(int width, int height)
        {
            NSScreen *screen = [NSScreen mainScreen];
            NSRect frame = [screen frame];
            NSRect content = NSMakeRect((frame.size.width + width) / 2, 
                                        (frame.size.height + height) / 2, 
                                        width, 
                                        height);
             
            win = [[NSWindow alloc] initWithContentRect: content
                                              styleMask: NSTitledWindowMask |  
                                                         NSClosableWindowMask | 
                                                         NSMiniaturizableWindowMask | 
                                                         NSResizableWindowMask 
                                                backing: NSBackingStoreBuffered 
                                                  defer: NO];
            

            [win makeKeyAndOrderFront: nil];            [win makeMainWindow];
            
//            [appDelegate createMenu];
   
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
        
        virtual void addEvent(Events e, std::function<bool(int, int)> binary) 
        {
            if (e == Events::Resize)
                resize = binary;
            
            resize(10, 10);
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
	
	menuItem = [mainMenu addItemWithTitle:@"File" action:NULL keyEquivalent:@""];
	submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"File", @"The File menu")];
	[self populateFileMenu:submenu];
	[mainMenu setSubmenu:submenu forItem:menuItem];
	
	menuItem = [mainMenu addItemWithTitle:@"Edit" action:NULL keyEquivalent:@""];
	submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Edit", @"The Edit menu")];
	[self populateEditMenu:submenu];
	[mainMenu setSubmenu:submenu forItem:menuItem];
	
	/* TODO
     menuItem = [mainMenu addItemWithTitle:@"View" action:NULL keyEquivalent:@""];
     submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"View", @"The View menu")];
     [self populateViewMenu:submenu];
     [mainMenu setSubmenu:submenu forItem:menuItem];
     */
	
	menuItem = [mainMenu addItemWithTitle:@"Window" action:NULL keyEquivalent:@""];
	submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Window", @"The Window menu")];
	[self populateWindowMenu:submenu];
	[mainMenu setSubmenu:submenu forItem:menuItem];
	[NSApp setWindowsMenu:submenu];
	
	menuItem = [mainMenu addItemWithTitle:@"Help" action:NULL keyEquivalent:@""];
	submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Help", @"The Help menu")];
	[self populateHelpMenu:submenu];
	[mainMenu setSubmenu:submenu forItem:menuItem];
	
	/* TODO
     menuItem = [mainMenu addItemWithTitle:@"Debug" action:NULL keyEquivalent:@""];
     submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Debug", @"The Debug menu")];
     [self populateDebugMenu:submenu];
     [mainMenu setSubmenu:submenu forItem:menuItem];
     */
	
	[NSApp setMainMenu:mainMenu];

}

-(void) populateApplicationMenu:(NSMenu *)aMenu
{
	NSString * applicationName = [self applicationName];
	NSMenuItem * menuItem;
	
	menuItem = [aMenu addItemWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"About", nil), applicationName]
								action:@selector(orderFrontStandardAboutPanel:)
						 keyEquivalent:@""];
	[menuItem setTarget:NSApp];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Preferences...", nil)
								action:NULL
						 keyEquivalent:@","];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Services", nil)
								action:NULL
						 keyEquivalent:@""];
	NSMenu * servicesMenu = [[NSMenu alloc] initWithTitle:@"Services"];
	[aMenu setSubmenu:servicesMenu forItem:menuItem];
	[NSApp setServicesMenu:servicesMenu];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Hide", nil), applicationName]
								action:@selector(hide:)
						 keyEquivalent:@"h"];
	[menuItem setTarget:NSApp];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Hide Others", nil)
								action:@selector(hideOtherApplications:)
						 keyEquivalent:@"h"];
	[menuItem setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
	[menuItem setTarget:NSApp];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Show All", nil)
								action:@selector(unhideAllApplications:)
						 keyEquivalent:@""];
	[menuItem setTarget:NSApp];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Quit", nil), applicationName]
								action:@selector(terminate:)
						 keyEquivalent:@"q"];
	[menuItem setTarget:NSApp];
}

-(void) populateEditMenu:(NSMenu *)aMenu
{
	NSMenuItem * menuItem;
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Undo", nil)
								action:@selector(undo:)
						 keyEquivalent:@"z"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Redo", nil)
								action:@selector(redo:)
						 keyEquivalent:@"Z"];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Cut", nil)
								action:@selector(cut:)
						 keyEquivalent:@"x"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Copy", nil)
								action:@selector(copy:)
						 keyEquivalent:@"c"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Paste", nil)
								action:@selector(paste:)
						 keyEquivalent:@"v"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Paste and Match Style", nil)
								action:@selector(pasteAsPlainText:)
						 keyEquivalent:@"V"];
	[menuItem setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Delete", nil)
								action:@selector(delete:)
						 keyEquivalent:@""];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Select All", nil)
								action:@selector(selectAll:)
						 keyEquivalent:@"a"];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Find", nil)
								action:NULL
						 keyEquivalent:@""];
	NSMenu * findMenu = [[NSMenu alloc] initWithTitle:@"Find"];
	[self populateFindMenu:findMenu];
	[aMenu setSubmenu:findMenu forItem:menuItem];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Spelling", nil)
								action:NULL
						 keyEquivalent:@""];
	NSMenu * spellingMenu = [[NSMenu alloc] initWithTitle:@"Spelling"];
	[self populateSpellingMenu:spellingMenu];
	[aMenu setSubmenu:spellingMenu forItem:menuItem];
}

-(void) populateFileMenu:(NSMenu *)aMenu
{
	NSMenuItem * menuItem;
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"New", nil)
								action:NULL
						 keyEquivalent:@"n"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Open...", nil)
								action:NULL
						 keyEquivalent:@"o"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Open Recent", nil)
								action:NULL
						 keyEquivalent:@""];
	NSMenu * openRecentMenu = [[NSMenu alloc] initWithTitle:@"Open Recent"];
	[openRecentMenu performSelector:@selector(_setMenuName:) withObject:@"NSRecentDocumentsMenu"];
	[aMenu setSubmenu:openRecentMenu forItem:menuItem];
	
	menuItem = [openRecentMenu addItemWithTitle:NSLocalizedString(@"Clear Menu", nil)
										 action:@selector(clearRecentDocuments:)
								  keyEquivalent:@""];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Close", nil)
								action:@selector(performClose:)
						 keyEquivalent:@"w"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Save", nil)
								action:NULL
						 keyEquivalent:@"s"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Save As...", nil)
								action:NULL
						 keyEquivalent:@"S"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Revert", nil)
								action:NULL
						 keyEquivalent:@""];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Page Setup...", nil)
								action:@selector(runPageLayout:)
						 keyEquivalent:@"P"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Print...", nil)
								action:@selector(print:)
						 keyEquivalent:@"p"];
}

-(void) populateFindMenu:(NSMenu *)aMenu
{
	NSMenuItem * menuItem;
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Find...", nil)
								action:@selector(performFindPanelAction:)
						 keyEquivalent:@"f"];
	[menuItem setTag:NSFindPanelActionShowFindPanel];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Find Next", nil)
								action:@selector(performFindPanelAction:)
						 keyEquivalent:@"g"];
	[menuItem setTag:NSFindPanelActionNext];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Find Previous", nil)
								action:@selector(performFindPanelAction:)
						 keyEquivalent:@"G"];
	[menuItem setTag:NSFindPanelActionPrevious];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Use Selection for Find", nil)
								action:@selector(performFindPanelAction:)
						 keyEquivalent:@"e"];
	[menuItem setTag:NSFindPanelActionSetFindString];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Jump to Selection", nil)
								action:@selector(centerSelectionInVisibleArea:)
						 keyEquivalent:@"j"];
}

-(void) populateHelpMenu:(NSMenu *)aMenu
{
	NSMenuItem * menuItem;
	
	menuItem = [aMenu addItemWithTitle:[NSString stringWithFormat:@"%@ %@", [self applicationName], NSLocalizedString(@"Help", nil)]
								action:@selector(showHelp:)
						 keyEquivalent:@"?"];
	[menuItem setTarget:NSApp];
}

-(void) populateSpellingMenu:(NSMenu *)aMenu
{
	NSMenuItem * menuItem;
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Spelling...", nil)
								action:@selector(showGuessPanel:)
						 keyEquivalent:@":"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Check Spelling", nil)
								action:@selector(checkSpelling:)
						 keyEquivalent:@";"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Check Spelling as You Type", nil)
								action:@selector(toggleContinuousSpellChecking:)
						 keyEquivalent:@""];
}

-(void) populateViewMenu:(NSMenu *)aMenu
{
	// TODO
}

-(void) populateWindowMenu:(NSMenu *)aMenu
{
	NSMenuItem * menuItem;
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Minimize", nil)
								action:@selector(performMinimize:)
						 keyEquivalent:@"m"];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Zoom", nil)
								action:@selector(performZoom:)
						 keyEquivalent:@""];
	
	[aMenu addItem:[NSMenuItem separatorItem]];
	
	menuItem = [aMenu addItemWithTitle:NSLocalizedString(@"Bring All to Front", nil)
								action:@selector(arrangeInFront:)
						 keyEquivalent:@""];
}


@end
