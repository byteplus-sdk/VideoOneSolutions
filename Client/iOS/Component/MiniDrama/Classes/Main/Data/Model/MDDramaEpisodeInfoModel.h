// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import "MDSimpleEpisodeInfoModel.h"
#import "MiniDramaBaseVideoModel.h"
#import <MDTTVideoEngineSourceCategory.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MDDisplayCardType) {
    MDDisplayCardTypeDefault,
    MDDisplayCardTypeCard,
};

@interface MDDramaEpisodeInfoModel : MiniDramaBaseVideoModel
@property (nonatomic, copy) NSString *dramaTitle;
@property (nonatomic, copy) NSString *dramaId;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) BOOL vip;
@property (nonatomic, assign) MDDisplayCardType displayType;
@property (nonatomic, assign) NSInteger playTimes;

@property (nonatomic, copy) NSString *subtitleToken;

@property (nonatomic, assign) CGFloat startTime;

+ (TTVideoEngineVidSource *)videoEngineVidSource:(MDDramaEpisodeInfoModel *)videoModel;
@end

NS_ASSUME_NONNULL_END
