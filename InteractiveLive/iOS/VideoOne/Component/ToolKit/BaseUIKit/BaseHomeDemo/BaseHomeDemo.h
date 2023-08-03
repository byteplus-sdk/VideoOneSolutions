// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseHomeDemo : NSObject

@property (nonatomic, copy) NSString *scenesName;

- (void)pushDemoViewControllerBlock:(void (^)(BOOL result))block;

@end

NS_ASSUME_NONNULL_END
