//
//  TTMixModel.m
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import "TTMixModel.h"


@implementation TTMixModel

+ (NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
        @"modelType": @"video_type",
        @"userStatus": @"user_status",
        @"liveModel": @"room_info",
        @"videoModel": @"video_info"
    };
}

@end
