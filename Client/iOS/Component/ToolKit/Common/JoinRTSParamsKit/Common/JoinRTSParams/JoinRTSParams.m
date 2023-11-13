// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "JoinRTSParams.h"
#import "NetworkingManager+joinRTSParams.h"
#import "ToastComponent.h"
#import "BuildConfig.h"
#import "Localizator.h"
#import "PublicParameterComponent.h"
#import "LocalUserComponent.h"
#import <YYModel/YYModel.h>

@implementation JoinRTSParams

+ (void)getJoinRTSParams:(NSDictionary *)inputInfo
                   block:(void (^)(JoinRTSParamsModel *model))block {
    NSMutableDictionary *dic = [inputInfo mutableCopy];
    if(NOEmptyStr(RTCAPPID)) {
        NSString *errorMessage = @"";
        [dic setValue:RTCAPPID forKey:@"app_id"];
       
        if (NOEmptyStr(RTCAPPKey)) {
            [dic setValue:RTCAPPKey forKey:@"app_key"];
        } else {
            errorMessage = @"APPKey";
        }
        if (NOEmptyStr(AccessKeyID)) {
            [dic setValue:AccessKeyID forKey:@"access_key"];
        } else {
            errorMessage = @"AccessKeyID";
        }
        
        if (NOEmptyStr(SecretAccessKey)) {
            [dic setValue:SecretAccessKey forKey:@"secret_access_key"];
        } else {
            errorMessage = @"SecretAccessKey";
        }
        
        if (NOEmptyStr(errorMessage)) {
            errorMessage = [NSString stringWithFormat:LocalizedStringFromBundle(@"join_rts_error", ToolKitBundleName), errorMessage];
            [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
            if (block) {
                block(nil);
            }
            return;
        }
        [PublicParameterComponent share].appId = RTCAPPID;
    }
    [NetworkingManager joinRTS:[dic copy]
                         block:^(NetworkingResponse * _Nonnull response) {
        if (response.result) {
            JoinRTSParamsModel *paramsModel = [JoinRTSParamsModel yy_modelWithJSON:response.response];
            [PublicParameterComponent share].appId = paramsModel.appId;
            if (block) {
                block(paramsModel);
            }
        } else {
            if (block) {
                block(nil);
            }
        }
    }];
}
                          
+ (NSDictionary *)addTokenToParams:(NSDictionary *)dic {
    NSMutableDictionary *tokenDic = nil;
    if (dic && [dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
        tokenDic = [dic mutableCopy];
    } else {
        tokenDic = [[NSMutableDictionary alloc] init];
    }
    if (NOEmptyStr([LocalUserComponent userModel].uid)) {
        [tokenDic setValue:[LocalUserComponent userModel].uid
                    forKey:@"user_id"];
    }
    if (NOEmptyStr([LocalUserComponent userModel].loginToken)) {
        [tokenDic setValue:[LocalUserComponent userModel].loginToken
                    forKey:@"login_token"];
    }
    if (NOEmptyStr([PublicParameterComponent share].appId)) {
        [tokenDic setValue:[PublicParameterComponent share].appId
                    forKey:@"app_id"];
    }
    if (NOEmptyStr([PublicParameterComponent share].roomId)) {
        [tokenDic setValue:[PublicParameterComponent share].roomId
                    forKey:@"room_id"];
    }
    
    return [tokenDic copy];
}

@end
