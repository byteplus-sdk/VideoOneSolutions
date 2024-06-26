// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>
#import "ChorusSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicControlView : UIView

@property (nonatomic, assign) NSTimeInterval time;

- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
