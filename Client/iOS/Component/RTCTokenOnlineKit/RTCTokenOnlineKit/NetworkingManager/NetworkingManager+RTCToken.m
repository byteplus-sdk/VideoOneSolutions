// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "NetworkingManager+Login.h"
#import <ToolKit/LocalUserComponent.h>
#import <YYModel/YYModel.h>

@implementation NetworkingManager (RTCToken)

#pragma mark - Login

+ (void)tokenWithAppID:(NSString *)appId
                appKey:(NSString *)appKey
                roomId:(NSString *)roomId
                   uid:(NSString *)userId
                 block:(void (^__nullable)(NSString *_Nullable errorDescription,
                                           NSString *_Nullable RTCToken))block {
    NSDictionary *param = @{
        @"os": @"iOS",
        @"login_token": [LocalUserComponent userModel].loginToken ?: @"",
        @"app_key": appKey ?: @"",
        @"app_id": appId ?: @"",
        @"room_id": roomId ?: @"",
        @"user_id": userId ?: @"",
    };
    [NetworkingManager postWithPath:@"getRTCJoinRoomToken"
                         parameters:param
                            headers:nil
                           progress:nil
                              block:^(NetworkingResponse *_Nonnull response) {
        if (response.result) {
            NSString *RTCToken = @"";
            if ([response.response isKindOfClass:[NSDictionary class]]) {
                RTCToken = [NSString stringWithFormat:@"%@", response.response[@"Token"]];
            }
            
            if (block) {
                block([NetworkingTool messageFromResponseCode:response.code], RTCToken);
            }
        } else {
            if (block) {
                block(response.error.localizedDescription, @"");
            }
        }
    }];
}

@end
