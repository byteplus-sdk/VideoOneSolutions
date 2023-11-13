// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseUserModel : NSObject <NSSecureCoding>

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *loginToken;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *avatarName;

+ (NSString *)getAvatarNameWithUid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
