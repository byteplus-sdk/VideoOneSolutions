//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AirPlayManager;

@protocol AirPlayManagerDelegate <NSObject>
@optional
- (void)airPlayManager:(AirPlayManager *)manager didChangeAirPlayingState:(BOOL)isAirPlaying;
- (void)airPlayManager:(AirPlayManager *)manager didFailWithError:(nullable NSError *)error;
- (void)airPlayManagerDidFinishPlayback:(AirPlayManager *)manager;
@end

@interface AirPlayManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign, readonly) BOOL isAirPlaying;

@property (nonatomic, copy, readonly, nullable) NSString *currentVideoIdentifier;

@property (nonatomic, weak, nullable) id<AirPlayManagerDelegate> delegate;

- (void)startWithURL:(NSURL *)url
          identifier:(nullable NSString *)identifier
            fromTime:(NSTimeInterval)startSeconds;

- (void)stop;

- (NSTimeInterval)currentTime;

- (nullable NSString *)currentAirPlayDeviceName;

@end

NS_ASSUME_NONNULL_END
