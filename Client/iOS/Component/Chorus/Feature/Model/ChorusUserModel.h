// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "BaseUserModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChorusUserStatus) {
    ChorusUserStatusDefault = 1,
    ChorusUserStatusActive,
    ChorusUserStatusApply,
    ChorusUserStatusInvite,
};

typedef NS_ENUM(NSInteger, ChorusUserRole) {
    ChorusUserRoleNone = 0,
    ChorusUserRoleHost = 1,
    ChorusUserRoleAudience,
};

typedef NS_ENUM(NSInteger, ChorusUserMic) {
    ChorusUserMicOff = 0,
    ChorusUserMicOn = 1,
};

typedef NS_ENUM(NSInteger, ChorusUserCamera) {
    ChorusUserCameraOff = 0,
    ChorusUserCameraOn = 1,
};

@interface ChorusUserModel : BaseUserModel

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, assign) ChorusUserRole userRole;

@property (nonatomic, assign) ChorusUserStatus status;

@property (nonatomic, assign) ChorusUserMic mic;

@property (nonatomic, assign) ChorusUserCamera camera;

@property (nonatomic, assign) NSInteger volume;

@property (nonatomic, assign) BOOL isSpeak;

@end

NS_ASSUME_NONNULL_END
