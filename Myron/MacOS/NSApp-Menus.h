//
//  NSApp-Menus.h
//  Myron
//
//  Created by Jeffrey Drake on 11-12-17.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Myron_NSApp_Menus_h
#define Myron_NSApp_Menus_h

#include <Cocoa/Cocoa.h>

@interface AppDelegate (Menus)
-(void) populateSpellingMenu:(NSMenu *)aMenu;
-(void) populateApplicationMenu:(NSMenu *)aMenu;
-(void) populateEditMenu:(NSMenu *)aMenu;
-(void) populateFileMenu:(NSMenu *)aMenu;
-(void) populateFindMenu:(NSMenu *)aMenu;
-(void) populateWindowMenu:(NSMenu *)aMenu;
-(void) populateHelpMenu:(NSMenu *)aMenu;
@end

#endif
