// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDSimpleEpisodeInfoModel : NSObject<YYModel>

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, copy) NSString *playAuthToken;
@property (nonatomic, copy) NSString *subtitleToken;

@end

NS_ASSUME_NONNULL_END
