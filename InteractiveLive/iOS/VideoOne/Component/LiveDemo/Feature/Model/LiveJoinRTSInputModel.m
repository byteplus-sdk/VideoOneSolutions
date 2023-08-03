// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveJoinRTSInputModel.h"
#import <Toolkit/BuildConfig.h>
#import "ToolKit.h"

@implementation LiveJoinRTSInputModel

+ (NSDictionary *)getLiveJoinRTSInputInfo:(NSString *)scenesName {
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    [dic setValue:scenesName forKey:@"scenes_name"];
    [dic setValue:[LocalUserComponent userModel].loginToken forKey:@"login_token"];
    [dic setValue:livePullDomain forKey:@"live_pull_domain"];
    [dic setValue:livePushDomain forKey:@"live_push_domain"];
    [dic setValue:livePushKey forKey:@"live_push_key"];
    [dic setValue:liveAppName forKey:@"live_app_name"];
    return [dic copy];
}

@end
