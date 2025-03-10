// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDPlayerGestureHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface MDPlayerGestureDisableHandler : NSObject <MDPlayerGestureHandlerProtocol>

@property (nonatomic, assign, readonly) MDGestureType gestureType;
@property (nonatomic, copy, readonly) NSString *scene;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGestureType:(MDGestureType)gestureType scene:(NSString *)scene NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
