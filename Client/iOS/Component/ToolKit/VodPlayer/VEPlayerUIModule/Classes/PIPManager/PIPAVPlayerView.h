// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PIPAVPlayerView : UIView

- (void)prepareToPlay:(NSString *)videoURL
           completion:(void (^)(BOOL result))block;

- (void)enterBackground;

- (void)enterForeground;

- (void)seekToTime:(NSTimeInterval)interval;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, copy, nullable) void (^playerEndBlock)(void);

@end

NS_ASSUME_NONNULL_END
