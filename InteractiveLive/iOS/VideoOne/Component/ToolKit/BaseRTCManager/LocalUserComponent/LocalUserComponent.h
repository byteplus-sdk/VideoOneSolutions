// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import "BaseUserModel.h"

@interface LocalUserComponent : NSObject

+ (BaseUserModel *)userModel;

+ (BOOL)isLogin;

+ (void)updateLocalUserModel:(BaseUserModel *)userModel;

+ (BOOL)isMatchUserName:(NSString *)userName;

+ (BOOL)isMatchRoomID:(NSString *)roomid;

+ (BOOL)isMatchNumber:(NSString *)number;

@end
