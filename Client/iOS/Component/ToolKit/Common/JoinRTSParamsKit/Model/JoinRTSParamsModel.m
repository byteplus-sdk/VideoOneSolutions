// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "JoinRTSParamsModel.h"

@implementation JoinRTSParamsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"appId" : @"app_id",
             @"RTSToken" : @"rtm_token",
             @"serverUrl" : @"server_url",
             @"serverSignature" : @"server_signature",
             @"bid" : @"bid"
    };
}

@end
