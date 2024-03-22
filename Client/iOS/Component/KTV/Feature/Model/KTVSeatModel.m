//
//  KTVSeatModel.m
//  veRTC_Demo
//
//  Created by on 2021/11/23.
//  
//

#import "KTVSeatModel.h"

@implementation KTVSeatModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userModel" : @"guest_info"};
}

@end
