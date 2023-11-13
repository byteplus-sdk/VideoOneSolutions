//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LiveSettingVideoFpsType) {
    LiveSettingVideoFpsType_15,
    LiveSettingVideoFpsType_20
};

typedef NS_ENUM(NSUInteger, LiveSettingVideoResolutionType) {
    LiveSettingVideoResolutionType_540P = 0,
    LiveSettingVideoResolutionType_720P,
    LiveSettingVideoResolutionType_1080P
};

@interface LiveSettingVideoConfig : NSObject

+ (instancetype)defultVideoConfig;

@property (nonatomic, assign) LiveSettingVideoFpsType fpsType;
@property (nonatomic, assign) LiveSettingVideoResolutionType resolutionType;

@property (nonatomic, copy) NSDictionary *resolutionDic;

// anchor resolution (setting panel can be modified)
@property (nonatomic, assign) CGSize videoSize;

// Guest resolution (unmodifiable)
@property (nonatomic, assign) CGSize guestVideoSize;

@property (nonatomic, assign) CGFloat fps;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger minBitrate;
@property (nonatomic, assign) NSInteger maxBitrate;
@property (nonatomic, assign) NSInteger defultBitrate;

@end

NS_ASSUME_NONNULL_END
