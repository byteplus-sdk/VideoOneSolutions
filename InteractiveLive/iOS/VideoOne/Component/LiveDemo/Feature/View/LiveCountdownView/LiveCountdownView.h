// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveCountdownView : UIView

- (void)start:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
