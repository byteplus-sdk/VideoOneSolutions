//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface VECommentModel : NSObject <YYModel>

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, assign) NSUInteger likeCount;

@property (nonatomic, assign, getter=isSelfLiked) BOOL selfLiked;

@end

NS_ASSUME_NONNULL_END
