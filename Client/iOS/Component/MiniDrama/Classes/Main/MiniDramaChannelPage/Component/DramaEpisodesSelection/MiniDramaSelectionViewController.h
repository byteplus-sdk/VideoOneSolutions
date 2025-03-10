// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "MDDramaEpisodeInfoModel.h"
#import "MiniDramaEpisodeSelectionProtocol.h"

extern NSString *MiniDramaSelectionCellReuseID;
extern NSInteger EpisodeSectionSegmentCount;

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaSelectionViewController : UIViewController

@property (nonatomic, weak) id<MiniDramaSelectionViewDelegate> delegate;

@property (nonatomic, copy) NSString *dramaCoverUrl;

@property (nonatomic, copy) NSString *dramaTitle;

@property (nonatomic, strong) NSArray<MDDramaEpisodeInfoModel *> *dramaVideoModels;

- (instancetype)initWtihDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

- (void)updateCurrentDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
