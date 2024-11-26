// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveUserModel.h"
#import "LiveRTCManager.h"

@implementation LiveUserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"roomID": @"room_id",
        @"uid": @"user_id",
        @"role": @"user_role",
        @"status": @"linkmic_status",
        @"name": @"user_name",
        @"applyLinkTime": @"apply_link_time",
    };
}

- (BOOL)isLoginUser {
    if ([self.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *extra = dic[@"extra"];
    NSData *jsonData = [extra dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *extraDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
    if (err) {
        return YES;
    }
    self.videoWidth = [extraDic[@"width"] floatValue];
    self.videoHeight = [extraDic[@"height"] floatValue];
    self.videoSize = CGSizeMake(self.videoWidth, self.videoHeight);
    return YES;
}

@end
