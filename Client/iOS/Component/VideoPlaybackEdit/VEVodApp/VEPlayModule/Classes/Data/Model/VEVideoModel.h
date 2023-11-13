// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;
#import "TTVideoEngineSourceCategory.h"
#import <YYModel/YYModel.h>

@interface VEVideoModel : NSObject<YYModel>

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, copy) NSString *h265PlayUrl;

@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, copy) NSString *playAuthToken;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, copy) NSString *detail;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, assign) NSInteger playTimes;

@property (nonatomic, copy) NSString *coverUrl;

@property (nonatomic, copy) NSString *duration;

- (NSString *)playTimeToString;

+ (TTVideoEngineVidSource *)videoEngineVidSource:(VEVideoModel *)videoModel;

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(VEVideoModel *)videoModel;



@end
