// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import "TTVideoEngineSourceCategory.h"
#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@class VECommentModel;

@interface VEVideoModel : NSObject <YYModel>

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, copy) NSString *h265PlayUrl;

@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, copy) NSString *playAuthToken;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, copy) NSString *detail;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, assign) NSUInteger playTimes;

@property (nonatomic, copy) NSString *coverUrl;

@property (nonatomic, copy) NSString *duration;

@property (nonatomic, copy) NSString *width;

@property (nonatomic, copy) NSString *height;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) NSUInteger likeCount;

@property (nonatomic, assign) NSUInteger commentCount;

@property (nonatomic, assign, getter=isSelfLiked) BOOL selfLiked;

- (NSString *)playTimeToString;

+ (TTVideoEngineVidSource *)videoEngineVidSource:(VEVideoModel *)videoModel;

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(VEVideoModel *)videoModel;

@end

NS_ASSUME_NONNULL_END
