//
//  main.m
//  MoneyUnitConverter
//
//  Created by Ukulele Trip on 09/12/28.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoneyUnitConverterController.h"

@interface MoneyUnitConverterAppDelegate : NSObject <UIApplicationDelegate> {
	UINavigationController *nav;
}
@property (nonatomic, retain)		UINavigationController *nav;
@end

@implementation MoneyUnitConverterAppDelegate
@synthesize nav;
// On launch, create a basic window
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.nav = [[UINavigationController alloc]
                   initWithRootViewController:[[MoneyUnitConverterController alloc] init]];
	[window addSubview:self.nav.view];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application  {
	// handle any final state matters here
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
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
