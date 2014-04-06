//
//  NASAImagesAppDelegate.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "NASAImagesAppDelegate.h"

@implementation NASAImagesAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)dealloc {
	[tabBarController release];
    [window release];
    [super dealloc];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	tabBarController.selectedIndex = [defaults integerForKey:@"SELECTED_INDEX"];
    [window addSubview:tabBarController.view];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:tabBarController.selectedIndex forKey:@"SELECTED_INDEX"];
}

@end
