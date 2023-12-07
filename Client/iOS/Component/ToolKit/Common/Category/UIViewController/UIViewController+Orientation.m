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
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return YES;
        default:
            return NO;
    }
}

- (void)setDeviceInterfaceOrientation:(UIDeviceOrientation)orientation {
    [self postInterfaceOrientation:(UIInterfaceOrientation)orientation];
    if (@available(iOS 16.0, *)) {
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        if (![windowScene isKindOfClass:[UIWindowScene class]]) {
            return;
        }
        UIInterfaceOrientationMask mask = [self getOrientationMaskWithDeviceOrientation:orientation];
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

- (UIInterfaceOrientationMask)getOrientationMaskWithDeviceOrientation:(UIDeviceOrientation)orientation {
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskPortrait;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationMask = UIInterfaceOrientationMaskPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientationMask = UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientationMask = UIInterfaceOrientationMaskLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;

        default:

            break;
    }
    return orientationMask;
}

@end
