//
//  MiniDramaVideoCellController.h
//  VOLCDemo
//

#import "MDPageViewController.h"

@import UIKit;

@class MDDramaFeedInfo;
@class MDDramaEpisodeInfoModel;
@class MDVideoPlayerController;

@protocol MiniDramaVideoCellControllerDelegate <NSObject>

- (void)onDramaDetailVideoPlayFinish:(MDDramaFeedInfo *)dramaVideoInfo;

- (void)dramaVideoWatchDetail:(MDDramaFeedInfo *)dramaVideoInfo;

//- (void)dramaVideoOnClickFullScreen:(MDDramaVideoInfoModel *)dramaVideoInfo player:(MDVideoPlayerController *)player;

@end

@interface MiniDramaVideoCellController : UIViewController <MiniDramaPageItem>

@property (nonatomic, weak) id<MiniDramaVideoCellControllerDelegate> delegate;

@property (nonatomic, strong, readonly) MDDramaFeedInfo *dramaVideoInfo;

- (void)playerResume;
- (void)playerPause;

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo;

@end
