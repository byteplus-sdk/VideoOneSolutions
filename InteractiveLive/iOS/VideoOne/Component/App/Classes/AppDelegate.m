// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import <TTSDK/TTSDKManager.h>
#import <ToolKit/LocalUserComponent.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupLogin];
    application.applicationSupportsShakeToEdit = NO;
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    MenuViewController *menuVC = [[MenuViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menuVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setAllowAutoRotateNotification:)
                                                 name:@"SetAllowAutoRotateNotification"
                                               object:nil];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}
- (void)setupLogin {
    Class loginCls = NSClassFromString(@"MenuLoginHome");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (loginCls != nil && [loginCls respondsToSelector:@selector(setup)]) {
        [loginCls performSelector:@selector(setup)];
    }
#pragma clang diagnostic pop
    
}

#pragma mark - UISceneSession lifecycle

- (void)setAllowAutoRotateNotification:(NSNotification *)sender {
    if ([sender.object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = sender.object;
        self.screenOrientation =  number.integerValue;
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.screenOrientation == ScreenOrientationLandscapeAndPortrait) {
        // Support Landscape Portrait
        return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
    } else if (self.screenOrientation == ScreenOrientationLandscape) {
        // Support Landscape
        return UIInterfaceOrientationMaskLandscape;
    } else {
        // Support Portrait
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
