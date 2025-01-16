//
//  MiniDramaDetailFeedViewController.h
//  MDPlayModule
//

#import <UIKit/UIKit.h>
#import "MDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class MDDramaFeedInfo;
@class MDDramaInfoModel;
@class MDDramaEpisodeInfoModel;

@protocol MiniDramaDetailFeedViewControllerDelegate <NSObject>

- (void)miniDramaDetailFeedViewWillback:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

- (void)miniDramaDetailFeedViewWillPlayNextDrama:(MDDramaEpisodeInfoModel *)nextDramaVideoInfo;

@end

@protocol MiniDramaDetailFeedViewControllerDataSource <NSObject>

- (NSString *)nextRecommondDramaIdForDramaDetailFeedPlay:(NSString *)currentDramaId;

@end

@interface MiniDramaDetailFeedViewController : MDViewController

@property (nonatomic, weak) id<MiniDramaDetailFeedViewControllerDelegate> delegate;

@property (nonatomic, weak) id<MiniDramaDetailFeedViewControllerDataSource> dataSource;

@property (nonatomic, assign) BOOL landscape;

@property (nonatomic, assign) BOOL autoPlayNextDaram;

- (instancetype)initWtihDramaVideoInfo:(MDDramaFeedInfo *)dramaVideoInfo;

- (instancetype)initWithDramaInfo:(MDDramaInfoModel *)dramaInfo;

@end

NS_ASSUME_NONNULL_END
