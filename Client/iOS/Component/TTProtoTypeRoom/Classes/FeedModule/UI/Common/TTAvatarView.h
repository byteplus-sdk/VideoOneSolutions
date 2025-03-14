// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTAvatarView : UIView

@property (nonatomic, assign) BOOL active;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) void (^didClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
