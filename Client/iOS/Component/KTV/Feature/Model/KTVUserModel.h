//
//  KTVUserModel.h
//  SceneRTCDemo
//
//  Created by on 2021/3/16.
//

#import "BaseUserModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KTVUserStatus) {
    KTVUserStatusDefault = 1,
    KTVUserStatusActive,
    KTVUserStatusApply,
    KTVUserStatusInvite,
};

typedef NS_ENUM(NSInteger, KTVUserRole) {
    KTVUserRoleNone = 0,
    KTVUserRoleHost = 1,
    KTVUserRoleAudience,
};

typedef NS_ENUM(NSInteger, KTVUserMic) {
    KTVUserMicOff = 0,
    KTVUserMicOn = 1,
};

@interface KTVUserModel : BaseUserModel

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, assign) KTVUserRole userRole;

@property (nonatomic, assign) KTVUserStatus status;

@property (nonatomic, assign) KTVUserMic mic;

@property (nonatomic, assign) NSInteger volume;

@property (nonatomic, assign) BOOL isSpeak;

@end

NS_ASSUME_NONNULL_END
