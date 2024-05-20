// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELDeviceRotateHelper.h"
#import "UIResponder+VELAdd.h"
#import <objc/runtime.h>
#import <ToolKit/ToolKit.h>

@interface VELDeviceRotateHelper ()
@property (nonatomic, assign, readwrite) UIDeviceOrientation orientation;
@property (nonatomic, assign) UIDeviceOrientation orientationBeforeRotate;
@property (nonatomic, assign) UIInterfaceOrientationMask supportInterfaceMask;
@end
@implementation VELDeviceRotateHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VELDeviceRotateHelper *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _supportInterfaceMask = UIInterfaceOrientationMaskPortrait;
        _orientationBeforeRotate = UIDeviceOrientationUnknown;
    }
    return self;
}

+ (UIInterfaceOrientationMask)supportInterfaceMask {
    return [[self sharedInstance] supportInterfaceMask];
}

+ (void)setSupportInterfaceMask:(UIInterfaceOrientationMask)interfaceMask {
    [[self sharedInstance] setSupportInterfaceMask:interfaceMask];
}
+ (UIDeviceOrientation)currentDeviceOrientation {
    UIDeviceOrientation orientation = [[VELDeviceRotateHelper sharedInstance] orientation];
    if (orientation == UIDeviceOrientationUnknown) {
        return UIDeviceOrientationPortrait;
    }
    return orientation;
}
- (void)postInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [[NSNotificationCenter defaultCenter] postNotificationName:SetInterfaceOrientationNotification
                                                        object:self
                                                      userInfo:@{InterfaceOrientationUserInfoKey: @(interfaceOrientation)}];
}

+ (BOOL)rotateToDeviceOrientation:(UIDeviceOrientation)orientation {
    return [[self sharedInstance] rotateToDeviceOrientation:orientation];
}

- (BOOL)rotateToDeviceOrientation:(UIDeviceOrientation)orientation {
    _orientation = orientation;
    return [self _rotateToDeviceOrientation:orientation];
}
- (BOOL)_rotateToDeviceOrientation:(UIDeviceOrientation)orientation {
    [self postInterfaceOrientation:[self interfaceOrientationWithDeviceOrientation:orientation]];
    self.supportInterfaceMask = [self interfaceMaskForDeviceOrientation:orientation];

    if (@available(iOS 16.0, *)) {
        UIWindowSceneGeometryPreferences *pre = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:self.supportInterfaceMask];
        [UIApplication.sharedApplication.keyWindow.windowScene requestGeometryUpdateWithPreferences:pre errorHandler:nil];
        [UIApplication.sharedApplication.keyWindow.vel_topViewController setNeedsStatusBarAppearanceUpdate];
    } else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
            [UIViewController attemptRotationToDeviceOrientation];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIViewController attemptRotationToDeviceOrientation];
    });
    return YES;
}

+ (void)autoRotateWhenViewWillAppear {
    [[self sharedInstance] autoRotateWhenViewWillAppear];
}

- (void)autoRotateWhenViewWillAppear {
    UIInterfaceOrientation statusBarOrientation = UIApplication.sharedApplication.statusBarOrientation;
    BOOL shouldRecoverBeforeChanging = self.orientationBeforeRotate != UIDeviceOrientationUnknown;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (statusBarOrientation == UIInterfaceOrientationUnknown || deviceOrientation == UIDeviceOrientationUnknown) {
        return;
    }
    if (deviceOrientation != (UIDeviceOrientation)statusBarOrientation) {
        deviceOrientation = (UIDeviceOrientation)statusBarOrientation;
    }
    UIDeviceOrientation rotateOrientation = [self recommendOrientationFor:deviceOrientation];
    if (!shouldRecoverBeforeChanging) {
        if ([self _rotateToDeviceOrientation:rotateOrientation]) {
            self.orientationBeforeRotate = deviceOrientation;
        } else {
            self.orientationBeforeRotate = UIDeviceOrientationUnknown;
        }
        self.supportInterfaceMask = [self interfaceMaskForDeviceOrientation:rotateOrientation];
        return;
    }
    rotateOrientation = [self recommendOrientationFor:self.orientationBeforeRotate];
    self.supportInterfaceMask = [self interfaceMaskForDeviceOrientation:rotateOrientation];
    [self _rotateToDeviceOrientation:rotateOrientation];
}
- (UIInterfaceOrientationMask)interfaceMaskForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    UIInterfaceOrientation interfaceOrientation = [self interfaceOrientationWithDeviceOrientation:deviceOrientation];
    return (1 << interfaceOrientation);
}
- (UIInterfaceOrientation)interfaceOrientationWithDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationUnknown;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            interfaceOrientation = UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            interfaceOrientation = UIInterfaceOrientationLandscapeRight;
            break;
        default:
            break;
    }
    return interfaceOrientation;
}

- (UIDeviceOrientation)recommendOrientationFor:(UIDeviceOrientation)deviceOrientation {
    return [self shouldRotateToOrientation:deviceOrientation] ? deviceOrientation : self.supportedDeviceOrientation;
}

- (UIDeviceOrientation)supportedDeviceOrientation {
    UIInterfaceOrientationMask interfaceMask = [self supportedInterfaceOrientations];
    if ((interfaceMask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return [UIDevice currentDevice].orientation;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return [UIDevice currentDevice].orientation;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIDeviceOrientationPortrait;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIDeviceOrientationLandscapeRight;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIDeviceOrientationLandscapeLeft;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIDeviceOrientationPortraitUpsideDown;
    }
    return [UIDevice currentDevice].orientation;
}

- (BOOL)shouldRotateToOrientation:(UIDeviceOrientation)deviceOrientation {
    UIInterfaceOrientationMask interfaceMask = [self supportedInterfaceOrientations];
    if (deviceOrientation == UIDeviceOrientationUnknown) {
        return YES;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return YES;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown != deviceOrientation;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait == deviceOrientation;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation || UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((interfaceMask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown == deviceOrientation;
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientation interFaceOrientation = UIInterfaceOrientationUnknown;
    if (_orientation != UIDeviceOrientationUnknown) {
        interFaceOrientation = [self interfaceOrientationWithDeviceOrientation:_orientation];
    } else if (_orientationBeforeRotate != UIDeviceOrientationUnknown) {
        interFaceOrientation = [self interfaceOrientationWithDeviceOrientation:_orientationBeforeRotate];
    }
    if (interFaceOrientation != UIInterfaceOrientationUnknown) {
        return (1 << interFaceOrientation);
    }
    return UIInterfaceOrientationMaskPortrait;
}
@end
