//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveEndLiveModel : NSObject

@property (nonatomic, copy) NSString *userAvatarImageUrl;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, assign) NSUInteger viewers;
@property (nonatomic, assign) NSUInteger likes;
@property (nonatomic, assign) NSUInteger gifts;

@end

NS_ASSUME_NONNULL_END
