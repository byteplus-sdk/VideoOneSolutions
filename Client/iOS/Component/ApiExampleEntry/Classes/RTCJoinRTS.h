// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCJoinRTS : NSObject

+ (void)joinRTS:(UIViewController *)vc block:(void (^)(BOOL result))block;

@end

NS_ASSUME_NONNULL_END
