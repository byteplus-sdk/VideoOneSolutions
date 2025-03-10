// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDViewController.h"
#import "MDVideoPlayerController.h"
#import "MiniDramaBaseVideoModel.h"
#import "MDDramaEpisodeInfoModel.h"
#import "MDDramaInfoModel.h"
#import "MDDramaFeedInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MiniDramaLandscapeViewProtocol <NSObject>
// playing player
- (MDVideoPlayerController *)currentPlayerController:(MiniDramaBaseVideoModel *)videoModel;

@end

@interface MiniDramaLandscapeViewController : MDViewController

- (instancetype)initWithDramaInfo:(MDDramaInfoModel * )dramaInfo;

- (instancetype)initWithVideoInfo:(MDDramaFeedInfo *)videoInfo;

- (instancetype)initWithDramaList:(NSArray<MDDramaEpisodeInfoModel *>*)dramaModels dramaVideoInfo:(MDDramaFeedInfo *)dramaVideoInfo episodeInfo:(MDDramaEpisodeInfoModel *)episodeInfo;

@property (nonatomic, weak) id<MiniDramaLandscapeViewProtocol> delegate;

@property (nonatomic, copy) void (^closeCallback)(BOOL landscapeMode, MDVideoPlayerController *playerController);

@property (nonatomic, assign) BOOL landscapeMode;

@end

NS_ASSUME_NONNULL_END
