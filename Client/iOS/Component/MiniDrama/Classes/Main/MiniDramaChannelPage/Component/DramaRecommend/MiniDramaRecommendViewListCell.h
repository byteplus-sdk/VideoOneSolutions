// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDDramaFeedInfo.h"

extern NSString *const MiniDramaRecommendViewListCellIdentify;

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaRecommendViewListCell : UITableViewCell
@property (nonatomic, strong) MDDramaFeedInfo *model;

@end

NS_ASSUME_NONNULL_END
