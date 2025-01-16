//
//  MiniDramaRecommendView.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/20.
//

#import <Foundation/Foundation.h>
#import "MDDramaFeedInfo.h"
#import "MDDramaEpisodeInfoModel.h"
#import <UIkit/UIKit.h>

#define MiniDramaRecommendViewHeight 36

NS_ASSUME_NONNULL_BEGIN

@protocol MiniDramaRecommendViewDelegate <NSObject>

- (void)onShowRecommentList;


@end

@interface MiniDramaRecommendView : UIView

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo;

@property (nonatomic, weak) id<MiniDramaRecommendViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
