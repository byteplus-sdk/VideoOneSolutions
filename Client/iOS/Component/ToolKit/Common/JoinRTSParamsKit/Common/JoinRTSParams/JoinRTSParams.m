// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "JoinRTSParams.h"
#import "BuildConfig.h"
#import "LocalUserComponent.h"
#import "Localizator.h"
#import "NetworkingManager.h"
#import "PublicParameterComponent.h"
#import "ToastComponent.h"
#import <YYModel/YYModel.h>

@implementation JoinRTSParams

+ (void)getJoinRTSParams:(NSDictionary *)inputInfo
                   block:(void (^)(JoinRTSParamsModel *model))block {
    NSMutableDictionary *dic = [inputInfo mutableCopy];
    if (NOEmptyStr(RTCAPPID)) {
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
            [[ToastComponent shareToastComponent] dismiss];
            [[ToastComponent shareToastComponent] showWithMessage:errorMessage];
            if (block) {
                block(nil);
            }
            return;
        }
        [PublicParameterComponent share].appId = RTCAPPID;
    }
    [NetworkingManager callHttpEvent:@"getAppInfo"
                             content:dic
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
@end
