// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MiniDramaBaseVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaCommentView : UIView

@property (nonatomic, strong) MiniDramaBaseVideoModel *videoModel;

- (instancetype)initWithFrame:(CGRect)frame axis:(UILayoutConstraintAxis)axis;

- (void)showInView:(UIView *)superview;

- (void)close;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
