//
//  MiniDramaRecommendViewListCell.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/20.
//

#import <Foundation/Foundation.h>
#import "MDDramaFeedInfo.h"

extern NSString *const MiniDramaRecommendViewListCellIdentify;

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaRecommendViewListCell : UITableViewCell
@property (nonatomic, strong) MDDramaFeedInfo *model;

@end

NS_ASSUME_NONNULL_END
