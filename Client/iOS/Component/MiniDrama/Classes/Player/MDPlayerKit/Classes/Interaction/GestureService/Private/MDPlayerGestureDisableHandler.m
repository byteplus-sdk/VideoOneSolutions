// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerGestureDisableHandler.h"

@implementation MDPlayerGestureDisableHandler

- (instancetype)initWithGestureType:(MDGestureType)gestureType scene:(nonnull NSString *)scene {
    self = [super init];
    if (self) {
        _gestureType = gestureType;
        _scene = scene;
    }
    return self;
}

#pragma mark - MDPlayerGestureHandlerProtocol
- (BOOL)gestureRecognizerShouldDisable:(UIGestureRecognizer *)gestureRecognizer gestureType:(MDGestureType)gestureType location:(CGPoint)location {
    if (self.gestureType & gestureType) {
        return YES;
    }
    return NO;
}

@end
