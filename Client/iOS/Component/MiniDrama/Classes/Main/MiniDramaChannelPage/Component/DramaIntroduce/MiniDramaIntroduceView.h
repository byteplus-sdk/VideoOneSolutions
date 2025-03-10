// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

@class MDDramaFeedInfo;

NS_ASSUME_NONNULL_BEGIN

#define MiniDramaIntroduceViewHeight 70

@interface MiniDramaIntroduceView : UIView

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
