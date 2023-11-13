// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import <ToolKit/NotificationConstans.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        self.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationSupportsShakeToEdit = NO;
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    MenuViewController *menuVC = [[MenuViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menuVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setInterfaceOrientationNotification:)
                                                 name:SetInterfaceOrientationNotification
                                               object:nil];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - UISceneSession lifecycle

- (void)setInterfaceOrientationNotification:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [notification.userInfo[InterfaceOrientationUserInfoKey] integerValue];
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
            self.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            self.supportedInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            self.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
            break;
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return self.supportedInterfaceOrientations;
}

@end
