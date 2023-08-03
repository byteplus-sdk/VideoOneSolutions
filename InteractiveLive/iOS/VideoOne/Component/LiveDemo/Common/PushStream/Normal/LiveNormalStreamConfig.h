// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveNormalStreamConfig : NSObject

@property (nonatomic, copy) NSString *rtmpUrl;
@property (nonatomic, copy) NSArray<NSString *> *URLs;


/**
 Scheduling parameters
 */
@property (nonatomic, copy) NSDictionary *sdkParams;

@property (nonatomic, assign) CGSize outputSize;


/**
 Video initial bit rate defaults to 800 * 1000
 */
@property (nonatomic, assign) NSUInteger bitrate;

/**
 Maximum increase rate for video by default 1024 * 1000
 */
@property (nonatomic, assign) NSUInteger maxBitrate;

/**
 Minimum decrease rate for video defaults to 512 * 1000
 */
@property (nonatomic, assign) NSUInteger minBitrate;

/**
 Video FPS, default 18
 */
@property (nonatomic, assign) NSUInteger videoFPS;

+ (instancetype)defaultConfig;


@end

NS_ASSUME_NONNULL_END
