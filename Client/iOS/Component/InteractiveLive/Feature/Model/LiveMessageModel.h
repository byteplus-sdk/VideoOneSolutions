//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LiveMessageModelState) {
    LiveMessageModelStateNormal = 1,
    LiveMessageModelStateGift = 2,
    LiveMessageModelStateLike = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface LiveMessageModel : NSObject

@property (nonatomic, assign) LiveMessageModelState type;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) NSInteger giftType;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, copy) NSString *user_id;

@property (nonatomic, copy) NSString *user_name;

@end

NS_ASSUME_NONNULL_END
