// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveJoinRTSInputModel.h"
#import <AppConfig/BuildConfig.h>
#import "ToolKit.h"

@implementation LiveJoinRTSInputModel

+ (NSDictionary *)getLiveJoinRTSInputInfo:(NSString *)scenesName {
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setValue:scenesName forKey:@"scenes_name"];
    [dic setValue:[LocalUserComponent userModel].loginToken forKey:@"login_token"];
    [dic setValue:LivePullDomain forKey:@"live_pull_domain"];
    [dic setValue:LivePushDomain forKey:@"live_push_domain"];
    [dic setValue:LivePushKey forKey:@"live_push_key"];
    [dic setValue:LiveAppName forKey:@"live_app_name"];
    return [dic copy];
}

@end
