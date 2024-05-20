// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "VELDeviceHelper.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>
#import "VELAlertManager.h"
#import <ToolKit/Localizator.h>
@implementation VELDeviceHelper

+ (CGFloat)statusBarHeight {
    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    if (statusBarHeight == 0) {
        statusBarHeight = [self isNotchScreen] ? 44 : 20;
    }
    return statusBarHeight;
}

+ (BOOL)isNotchScreen {
    BOOL isNotch = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return isNotch;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            isNotch = YES;
        }
    }
    return isNotch;
}

+ (BOOL)isLandSpace {
    return UIScreen.mainScreen.bounds.size.width > UIScreen.mainScreen.bounds.size.height
    || UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
}

+ (CGFloat)navigationBarHeight {
    return [self isNotchScreen] ? 88 : 64;
}

+ (UIEdgeInsets)safeAreaInsets {
    if (![self isNotchScreen]) {
        return UIEdgeInsetsZero;
    }
    
    NSDictionary<NSNumber *, NSValue *> *value = [self deviceNotchSizeForKey:[self deviceModel]];
    
    NSNumber *orientationKey = nil;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            orientationKey = @(UIInterfaceOrientationLandscapeLeft);
            break;
        default:
            orientationKey = @(UIInterfaceOrientationPortrait);
            break;
    }
    
    UIEdgeInsets insets = value[orientationKey].UIEdgeInsetsValue;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        insets = UIEdgeInsetsMake(insets.bottom, insets.left, insets.top, insets.right);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        insets = UIEdgeInsetsMake(insets.top, insets.right, insets.bottom, insets.left);
    }
    return insets;
}

+ (NSString *)deviceModel {
    static NSString *deviceModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct utsname systemInfo;
        uname(&systemInfo);
        deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    });
    return deviceModel;
}

+ (NSDictionary<NSNumber *, NSValue *> *)deviceNotchSizeForKey:(NSString *)key {
    return [[self deviceNotchSize] objectForKey:key] ?: [self defaultDeviceNotchSize];
}

+ (NSDictionary<NSNumber *, NSValue *> *)defaultDeviceNotchSize {
    return [[self deviceNotchSize] objectForKey:@"iPhone14,3"];
}

+ (NSDictionary<NSString *, NSDictionary<NSNumber *, NSValue *> *> *)deviceNotchSize {
    static NSDictionary<NSString *, NSDictionary<NSNumber *, NSValue *> *> *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{
            // iPhone 13 mini
            @"iPhone14,4": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(50, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 50, 21, 50)],
            },
            // iPhone 13
            @"iPhone14,5": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 13 Pro
            @"iPhone14,2": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 13 Pro Max
            @"iPhone14,3": @{
                @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 12 mini
            @"iPhone13,1": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(50, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 50, 21, 50)],
            },
            // iPhone 12
            @"iPhone13,2": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 12 Pro
            @"iPhone13,3": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 12 Pro Max
            @"iPhone13,4": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(47, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 47, 21, 47)],
            },
            // iPhone 11
            @"iPhone12,1": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(48, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 48, 21, 48)],
            },
            // iPhone 11 Pro Max
            @"iPhone12,5": @{
                    @(UIInterfaceOrientationPortrait): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(44, 0, 34, 0)],
                    @(UIInterfaceOrientationLandscapeLeft): [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 44, 21, 44)],
            }
        };
    });
    return dict;
}


+ (void)requestCameraAuthorization:(void (^)(BOOL granted))handler {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        [self showSettingAlertWithTitle:LocalizedStringFromBundle(@"medialive_camera_privilege_ask", @"MediaLive") completion:^{
                    
        }];
        return;
    }
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            handler(granted);
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        handler(YES);
    } else {
        handler(NO);
    }
}

+ (void)requestMicrophoneAuthorization:(void (^)(BOOL granted))handler {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusDenied) {
        [self showSettingAlertWithTitle:LocalizedStringFromBundle(@"medialive_microphone_privilege_ask", @"MediaLive") completion:^{
                    
        }];
        return;
    }
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            handler(granted);
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        handler(YES);
    } else {
        handler(NO);
    }
}

+ (void)showSettingAlertWithTitle:(NSString *)title completion:(void (^)(void))completion {
    VELAlertAction *cancel = [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_cancel", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }];
    VELAlertAction *go = [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_go_setting", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
#pragma clang diagnostic pop
        }
    }];
    [[VELAlertManager shareManager] showWithMessage:title actions:@[cancel, go]];
}

+ (void)sendFeedback {
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
        [feedback prepare];
        [feedback impactOccurred];
    }
}

+ (void)setPlaybackAudioSessionWithOptions:(AVAudioSessionCategoryOptions)options {
    if (options <= 0) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        return;
    }
    if (@available(iOS 10.0, *)) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                mode:AVAudioSessionModeMoviePlayback
                                             options:(options)
                                               error:nil];
    } else if (@available(iOS 11.0, *)) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                mode:AVAudioSessionModeMoviePlayback
                                  routeSharingPolicy:(AVAudioSessionRouteSharingPolicyDefault)
                                             options:(options)
                                               error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                         withOptions:(options)
                                               error:nil];
    }
}
@end
