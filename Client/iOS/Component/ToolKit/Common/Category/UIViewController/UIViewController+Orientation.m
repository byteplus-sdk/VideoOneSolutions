// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NotificationConstans.h"
#import "UIViewController+Orientation.h"

@implementation UIViewController (Orientation)

- (void)addOrientationNotice {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationDidChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)postInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [[NSNotificationCenter defaultCenter] postNotificationName:SetInterfaceOrientationNotification
                                                        object:self
                                                      userInfo:@{InterfaceOrientationUserInfoKey: @(interfaceOrientation)}];
    // Update AppDelegate -supportedInterfaceOrientationsForWindow proxy information
}

- (void)onDeviceOrientationDidChange {
    [self orientationDidChang:self.isLandscape];
}

- (void)orientationDidChang:(BOOL)isLandscape {
    // Rewrite in UIViewController
}

- (BOOL)isLandscape {
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationUnknown;
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        interfaceOrientation = windowScene.interfaceOrientation;
    } else {
        interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setDeviceInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [self postInterfaceOrientation:orientation];
    if (@available(iOS 16.0, *)) {
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        if (![windowScene isKindOfClass:[UIWindowScene class]]) {
            return;
        }
        UIInterfaceOrientationMask mask = (1 << orientation);
        UIWindowSceneGeometryPreferencesIOS *preferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask];
        [windowScene requestGeometryUpdateWithPreferences:preferences errorHandler:^(NSError *_Nonnull error){

        }];
    } else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            NSNumber *orientationUnknown = @(0);
            [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];

            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
        }
    }
}

@end
