// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceProtocol.h"
#import "MiniDramaBaseVideoModel.h"
#import "DramaSubtitleManage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaLandscapeSceneConf : NSObject<MDInterfaceElementDataSource>

@property (nonatomic, strong) MiniDramaBaseVideoModel *videoModel;

@property (nonatomic, assign) NSInteger videoCount;

- (void)refreshSubtitleButton:(DramaSubtitleModel *)model;

- (void)updatePlayButton:(BOOL)isPlaying;
@end

NS_ASSUME_NONNULL_END
