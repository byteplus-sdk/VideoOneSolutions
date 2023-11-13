// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEVideoModel.h"
#import "VEVideoPlayerController+Resolution.h"
#import "NSString+VE.h"
#import "VESettingManager.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/Localizator.h>

@implementation VEVideoModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return  @{
        @"videoId": @"vid",
        @"title": @"caption",
        @"subTitle": @"subtitle",
        @"createTime": @"createTime",
        @"coverUrl": @"coverUrl",
        @"playTimes": @"playTimes",
        @"playAuthToken": @"playAuthToken",
        @"duration": @"duration"
    };
}

- (NSString *)playTimeToString {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    if ([[Localizator getCurrentLanguage] isEqualToString:@"en"]) {
        if (_playTimes < 1000) {
            return [NSString stringWithFormat:@"%ld %@",_playTimes, LocalizedStringFromBundle(@"views", @"VEVodApp")];
        } else if (_playTimes < 1e6) {
            NSNumber *result = [NSNumber numberWithInteger:_playTimes];
            float times = [result floatValue] / 1000;
            NSString *playTimeString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:times]];
            return [NSString stringWithFormat:@"%@K %@",playTimeString, LocalizedStringFromBundle(@"views", @"VEVodApp")];
        } else {
            NSNumber *result = [NSNumber numberWithInteger:_playTimes];
            float times = [result floatValue] / (1e6);
            NSString *playTimeString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:times]];
            return [NSString stringWithFormat:@"%@M %@",playTimeString, LocalizedStringFromBundle(@"views", @"VEVodApp")];
        }
    } else {
        if (_playTimes < 10000) {
            return [NSString stringWithFormat:@"%ld %@", _playTimes, LocalizedStringFromBundle(@"views", @"VEVodApp")];
        } else {
            NSNumber *result = [NSNumber numberWithInteger:_playTimes];
            float times = [result floatValue] / 10000;
            NSString *playTimeString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:times]];
            return [NSString stringWithFormat:@"%@万 %@",playTimeString, LocalizedStringFromBundle(@"views", @"VEVodApp")];
        }
    }
}

- (NSString *)createTime {
    if (_createTime) {
        NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
        [utcFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [utcFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
        NSDate *date = [utcFormatter dateFromString:_createTime];
        NSDateFormatter *ymdFormatter = [[NSDateFormatter alloc] init];
        [ymdFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString *ymdDateStr = [ymdFormatter stringFromDate:date];
        if (!ymdDateStr) {
            NSArray *components = [_createTime componentsSeparatedByString:@"T"];
            return components[0];
        }
        return ymdDateStr;
    }
    return _createTime;
}


+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+ (TTVideoEngineVidSource *)videoEngineVidSource:(VEVideoModel *)videoModel {
    VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
    TTVideoEngineEncodeType codec = h265.open ? TTVideoEngineh265 : TTVideoEngineH264;
    TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[VEVideoPlayerController getPlayerCurrentResolution] encodeType:codec isDash:NO isHLS:NO];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(VEVideoModel *)videoModel {
    TTVideoEngineUrlSource *source = [[TTVideoEngineUrlSource alloc] initWithUrl:videoModel.playUrl cacheKey:videoModel.playUrl.vloc_md5String videoId:videoModel.videoId];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}



@end
