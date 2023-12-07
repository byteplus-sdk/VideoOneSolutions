//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

@class VEEventMessageBus, VEVideoModel, VEEventPoster;

NS_ASSUME_NONNULL_BEGIN

@interface VEInterfaceCommentView : UIView

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@property (nonatomic, weak) VEEventPoster *eventPoster;

- (instancetype)initWithFrame:(CGRect)frame axis:(UILayoutConstraintAxis)axis;

- (void)showInView:(UIView *)superview;

- (void)close;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
