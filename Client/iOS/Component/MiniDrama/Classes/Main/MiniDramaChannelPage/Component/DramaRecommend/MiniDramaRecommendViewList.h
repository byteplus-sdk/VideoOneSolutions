// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDDramaFeedInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MiniDramaRecommendViewListDelegate <NSObject>

- (void)onClickRecommendVideoCallback:(MDDramaFeedInfo*)videoModel;

@end

@interface MiniDramaRecommendViewList : UIView

@property (nonatomic, strong) NSArray<MDDramaFeedInfo *> *playList;

@property (nonatomic, weak) id<MiniDramaRecommendViewListDelegate>delegate;

- (void)showInView:(UIView *)superview;

@end
NS_ASSUME_NONNULL_END
