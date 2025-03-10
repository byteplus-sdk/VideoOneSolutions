// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MDPageViewController.h"
#import "MDDramaInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MDDramaEpisodeInfoModel;

@protocol MiniDramaDetailVideoCellControllerDelegate <NSObject>

- (void)onPlayNeedPayDramaVideo:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

- (void)onCurrentPlaybackSpeed:(CGFloat)speed;

@optional
- (void)onDramaDetailVideoPlayFinish:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

- (void)onDramaDetailVideoPlayStart:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

@end

@interface MiniDramaDetailVideoCellController : UIViewController <MiniDramaPageItem>

@property (nonatomic, weak) id<MiniDramaDetailVideoCellControllerDelegate> delegate;
@property (nonatomic, strong, readonly) MDDramaEpisodeInfoModel *dramaVideoInfo;

@property (nonatomic, strong) NSMutableArray<MDDramaEpisodeInfoModel *> *dramaVideoModels;

- (void)updatePlaybackSeed:(CGFloat)speed;

- (void)reloadData:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

- (void)updateForUnlock;
@end

NS_ASSUME_NONNULL_END
