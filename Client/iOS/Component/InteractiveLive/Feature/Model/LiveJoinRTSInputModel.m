// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveJoinRTSInputModel.h"
#import "ToolKit.h"
#import <AppConfig/BuildConfig.h>

@implementation LiveJoinRTSInputModel
+ (NSDictionary *)getLiveJoinRTSInputInfo:(NSString *)scenesName {
    return @{
        @"scenes_name": scenesName,
        @"live_pull_domain": LivePullDomain,
        @"live_push_domain": LivePushDomain,
        @"live_push_key": LivePushKey,
        @"live_app_name": LiveAppName
    };
}

@end
