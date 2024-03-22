// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RTSStatusCode) {
    RTSStatusCodeBadServerResponse = -1011,
    RTSStatusCodeSendMessageFaild = -101,
    RTSStatusCodeUnknown = -1,
    RTSStatusCodeSuccess = 200,
    RTSStatusCodeInvalidArgument = 400,
    RTSStatusCode402 = 402,
    RTSStatusCodeUserNotFound = 404,
    RTSStatusCodeOverRoomLimit = 406,
    RTSStatusCodeNotAuthorized = 416,
    RTSStatusCodeDisconnectTimeout = 418,
    RTSStatusCodeUserIsInactive = 419,
    RTSStatusCodeRoomDisbanded = 422,
    RTSStatusCodeSensitiveWords = 430,
    RTSStatusCodeVerificationCodeExpired = 440,
    RTSStatusCodeInvalidVerificationCode = 441,
    RTSStatusCodeTokenExpired = 450,
    RTSStatusCodeReachLinkmicUserCount = 472,
    RTSStatusCodeInviteOthersBeingError = 481,
    RTSStatusCodeInternalServerError = 500,
    RTSStatusCodeTransferHostFailed = 504,
    RTSStatusCodeRoleDontMatchFailed = 541,
    RTSStatusCodeTransferUserOnMicExceedLimit = 506,
    RTSStatusCodeLinkerParamError = 610,
    RTSStatusCodeLinkerNotExist = 611,
    RTSStatusCodeUserRoleNotAuthorized = 620,
    RTSStatusCodeUserIsInviting = 622,
    RTSStatusCodeUserIsNewInviting = 481,
    RTSStatusCodeRoomLinkmicSceneConflict = 630,
    RTSStatusHostHasReceivedOtherInvitationError = 634,
    RTSStatusCodeAudienceApplyOthersHost = 632,
    RTSStatusCodeHostLinkOtherAudience = 643,
    RTSStatusCodeHostLinkOtherHost = 642,
    RTSStatusHostInviteOtherHost = 645,
    RTSStatusCodeBuildTokenFaild = 702,
    RTSStatusCodeAPPInfoFaild = 800,
    RTSStatusCodeAPPInfoExistFaild = 801,
    RTSStatusCodeTrafficAPPIDFaild = 802,
    RTSStatusCodeTrafficFaild = 803,
    RTSStatusCodeVodFaild = 804,
    RTSStatusCodeTWFaild = 805,
    RTSStatusCodeBIDFaild = 806,
};

#define BadServerResponseMsg [NetworkingTool messageFromResponseCode:RTSStatusCodeBadServerResponse]

@interface NetworkingTool : NSObject

+ (NSString *)messageFromResponseCode:(RTSStatusCode)code;

+ (NSString *)getWisd;

+ (NSString *)getDeviceId;

+ (NSString *)MD5ForLower16Bate:(NSString *)str;

+ (NSString *)MD5ForLower32Bate:(NSString *)str;

+ (nullable NSDictionary *)decodeJsonMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
