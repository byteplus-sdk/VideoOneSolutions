// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseUserModel.h"
#import <Foundation/Foundation.h>

@interface LocalUserComponent : NSObject

+ (BaseUserModel *)userModel;

+ (BOOL)isLogin;

+ (void)updateLocalUserModel:(BaseUserModel *)userModel;

+ (BOOL)isMatchUserName:(NSString *)userName;

+ (BOOL)isMatchRoomID:(NSString *)roomid;

+ (BOOL)isMatchNumber:(NSString *)number;

@end
