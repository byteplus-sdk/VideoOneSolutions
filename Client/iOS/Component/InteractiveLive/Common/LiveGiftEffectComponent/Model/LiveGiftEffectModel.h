//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftModel.h"
#import "LiveMessageModel.h"
#import "LiveUserModel.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveGiftEffectModel : NSObject

- (instancetype)initWithMessage:(LiveMessageModel *)message sendUserModel:(LiveUserModel *)user;

@property (nonatomic, strong) NSString *userAvatar;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSString *sendMessage;

@property (nonatomic, strong) NSString *giftIcon;

@property (nonatomic, assign) NSInteger count;

@end

NS_ASSUME_NONNULL_END
