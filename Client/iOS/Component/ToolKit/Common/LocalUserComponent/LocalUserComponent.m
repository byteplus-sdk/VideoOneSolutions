// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LocalUserComponent.h"

@implementation LocalUserComponent

#pragma mark - Publish Action

static BaseUserModel *_currentUser = nil;

+ (BaseUserModel *)userModel {
    if (_currentUser) {
        return _currentUser;
    }
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"KUserinfoDic"];
    BaseUserModel *user = nil;
    if (data) {
        user = [NSKeyedUnarchiver unarchivedObjectOfClass:[BaseUserModel class]
                                                 fromData:data
                                                    error:nil];
    }
    if (user == nil || ![user isKindOfClass:[BaseUserModel class]]) {
        user = [[BaseUserModel alloc] init];
    }
    _currentUser = user;
    return user;
}

+ (void)logout {
    [self updateLocalUserModel:nil];
}

+ (BOOL)isLogin {
    return [self userModel] != nil && [self userModel].loginToken != nil;
}

+ (void)updateLocalUserModel:(BaseUserModel *)userModel {
    _currentUser = userModel;
    if (userModel && [userModel isKindOfClass:[BaseUserModel class]]) {
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:userModel
                                                 requiringSecureCoding:NO
                                                                 error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"KUserinfoDic"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (userModel == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"KUserinfoDic"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Tool

+ (BOOL)isMatchUserName:(NSString *)userName {
    if (!userName || userName.length <= 0) {
        return YES;
    }
    NSString *match = @"^[\u4e00-\u9fa5a-zA-Z0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:userName];
}

+ (BOOL)isMatchRoomID:(NSString *)roomid {
    if (!roomid || roomid.length <= 0) {
        return YES;
    }
    NSString *match = @"^[A-Za-z0-9@._-]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:roomid];
}

+ (BOOL)isMatchNumber:(NSString *)number {
    if (!number || number.length <= 0) {
        return YES;
    }
    NSString *match = @"[0-9]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:number];
}

@end
