// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusRoomModel.h"

@implementation ChorusRoomModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"appID" : @"app_id",
             @"roomID" : @"room_id",
             @"roomName" : @"room_name",
             @"hostUid" : @"host_user_id",
             @"hostName" : @"host_user_name",
             @"audienceCount" : @"audience_count",
             @"enableAudienceApply" : @"enable_audience_interact_apply",
    };
}

- (void)setExt:(NSString *)ext {
    if (_ext != ext) {
        _ext = ext;
        if (NOEmptyStr(ext)) {
            self.extDic = [ChorusRoomModel dictionaryWithJsonString:ext];
        } else {
            self.extDic = @{};
        }
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
   if (jsonString == nil) {
       return nil;
   }

   NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
   NSError *err;
   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&err];
   if(err) {
       return nil;
   }
   return dic;
}


@end
