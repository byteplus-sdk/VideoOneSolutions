// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import <MediaLive/VELCore.h>
#ifdef VEL_PUSH_MODULE_NEW_API_ENABLE
@class VeLivePusher;
@class VeLivePusherConfiguration;

@protocol VeLiveSolutionScreenCaptureManagerDelegate <NSObject>
@optional
- (void)broadcastStarted;

- (void)broadcastPaused;

- (void)broadcastResumed;

- (void)broadcastFinishedBegin;

- (void)broadcastFinishedEnd;

@end

@interface VeLiveSolutionScreenCaptureManager : NSObject
@property (nonatomic, weak) id<VeLiveSolutionScreenCaptureManagerDelegate> delegate;
@property (nonatomic, assign) float appAudioVolumn;
@property (nonatomic, strong, readonly) VeLivePusher *pusher;
- (instancetype)initWithApplicationGroupIdentifier:(NSString*)applicationGroupIdentifier pusherConfig:(VeLivePusherConfiguration *)pusherConfig;
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (void)startScreenCapture;
- (void)stopScreenCapture;
@end
#endif
