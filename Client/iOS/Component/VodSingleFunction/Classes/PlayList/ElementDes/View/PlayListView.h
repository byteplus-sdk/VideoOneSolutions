// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "PlayListDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class VEVideoModel;


@interface PlayListView : UIView

@property (nonatomic, strong) NSArray<VEVideoModel *> *playList;

@property (nonatomic, weak) id<PlayListDelegate> delegate;

@property (nonatomic, assign) NSInteger currentPlayViewIndex;

- (void)scroll:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
