// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDDramaEpisodeInfoModel.h"
#import <YYModel/YYModel.h>
#import "MDTTVideoEngineSourceCategory.h"
#import "MDDramaInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * Drama Feed Data for ChannelPage
 */
@interface MDDramaFeedInfo :NSObject<YYModel>

@property (nonatomic, strong) MDDramaInfoModel* dramaInfo;

@property (nonatomic, strong) MDDramaEpisodeInfoModel* videoInfo;

@end

NS_ASSUME_NONNULL_END
