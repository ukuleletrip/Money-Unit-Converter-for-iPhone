//
//  main.m
//  MoneyUnitConverter
//
//  Created by Ukulele Trip on 09/12/28.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUtil.h"
#import "MoneyUnitConverterController.h"

@interface MoneyUnitConverterAppDelegate : NSObject <UIApplicationDelegate> {
	UINavigationController *nav;
    MoneyUnitConverterController *vController;
}
@property (nonatomic, retain)		UINavigationController *nav;
@end

@implementation MoneyUnitConverterAppDelegate
@synthesize nav;
// On launch, create a basic window
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    vController = [[MoneyUnitConverterController alloc] init];
	self.nav = [[UINavigationController alloc] initWithRootViewController:vController];
	[window addSubview:self.nav.view];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application  {
	// handle any final state matters here
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    NSLOG(@"will enter foreground..");
    [vController update];
}


- (void)dealloc {
    [vController release];
	[self.nav release];
	[super dealloc];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"MoneyUnitConverterAppDelegate");
	[pool release];
	return retVal;
}
