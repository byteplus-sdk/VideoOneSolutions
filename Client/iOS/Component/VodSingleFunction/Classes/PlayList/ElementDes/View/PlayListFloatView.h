// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "PlayListDelegate.h"

NS_ASSUME_NONNULL_BEGIN
@class VEVideoModel, VEEventMessageBus, VEEventPoster;


@interface PlayListFloatView : UIView

@property (nonatomic, strong) NSArray<VEVideoModel *> *playList;

@property (nonatomic, assign) NSInteger currentPlayViewIndex;

@property (nonatomic, weak) id<PlayListDelegate> delegate;

- (void)show;

@end

NS_ASSUME_NONNULL_END
