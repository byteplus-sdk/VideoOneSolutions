// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <YYModel/YYModel.h>
#import "MDTTVideoEngineSourceCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaBaseVideoModel : NSObject<YYModel>

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *playAuthToken;
@property (nonatomic, copy) NSString *videoTitle;
@property (nonatomic, copy) NSString *videoDescription;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *videoWidth;
@property (nonatomic, copy) NSString *videoHeight;
@property (nonatomic, assign) NSInteger playTimes;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *authorId;
@property (nonatomic, assign) NSUInteger likeCount;
@property (nonatomic, assign) NSUInteger commentCount;

@property (nonatomic, assign, getter=isSelfLiked) BOOL selfLiked;

+ (TTVideoEngineVidSource *)videoEngineVidSource:(MiniDramaBaseVideoModel *)videoModel;

@end

NS_ASSUME_NONNULL_END
