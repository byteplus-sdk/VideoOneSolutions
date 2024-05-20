// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VeLiveSolutionScreenCaptureManager.h"
#import "VeLiveSolutionSilentPlayer.h"

#ifdef VEL_PUSH_MODULE_NEW_API_ENABLE
@interface VeLiveSolutionScreenCaptureManager()<VeLiveScreenCaptureStatusObserver>
@property (nonatomic, strong) VeLivePusher *_pusher;
@property (nonatomic, strong) NSString *applicationGroupIdentifier;
@property (nonatomic, strong) VeLiveSolutionSilentPlayer *player;
@end

@implementation VeLiveSolutionScreenCaptureManager

- (instancetype)initWithApplicationGroupIdentifier:(NSString *)applicationGroupIdentifier pusherConfig:(VeLivePusherConfiguration *)pusherConfig {
    if (self = [super init]) {
        self.applicationGroupIdentifier = applicationGroupIdentifier;
        self._pusher = [[VeLivePusher alloc]initWithConfig:pusherConfig];
        [self._pusher setRenderView:nil];
        [self._pusher setScreenCaptureObserver:self];
        VeLiveVideoEncoderConfiguration *video = [[VeLiveVideoEncoderConfiguration alloc] initWithResolution:VeLiveVideoResolutionScreen];
        [self._pusher setVideoEncoderConfiguration:video];
        _appAudioVolumn = 1;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sessionInterrupt:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)sessionInterrupt:(NSNotification *)notification {
    NSDictionary* userInfo = notification.userInfo;
    if([userInfo[AVAudioSessionInterruptionTypeKey] intValue] == AVAudioSessionInterruptionTypeBegan) {
        __weak typeof(self) weak_self = self;
        __block UIBackgroundTaskIdentifier taskID = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            [UIApplication.sharedApplication endBackgroundTask:taskID];
            taskID = UIBackgroundTaskInvalid;
        }];
    }
}

- (VeLivePusher *)pusher {
    return self._pusher;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation {
    [self._pusher setOrientation:orientation];
}

- (void)setAppAudioVolumn:(float)appAudioVolumn {
    _appAudioVolumn = appAudioVolumn;
    [[self._pusher getMixerManager] setAudioStream:[[self._pusher getMixerManager] getAppAudioStream] volume:appAudioVolumn];
}

- (void)startScreenCapture {
    [self._pusher startScreenCapture:self.applicationGroupIdentifier];
}

- (void)stopScreenCapture {
    [self._pusher stopScreenCapture];
}

#pragma -- mark VeLiveScreenCaptureStatusObserver delegate

- (void)broadcastStarted {
    [self._pusher startAudioCapture:VeLiveAudioCaptureMicrophone];
    if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastStarted)]) {
        [self.delegate broadcastStarted];
    }
}

- (void)broadcastPaused {
    if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastPaused)]) {
        [self.delegate broadcastPaused];
    }
}

- (void)broadcastResumed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastResumed)]) {
        [self.delegate broadcastResumed];
    }
}

- (void)broadcastFinished {
    if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastFinishedBegin)]) {
        [self.delegate broadcastFinishedBegin];
    }
    [self._pusher stopAudioCapture];
    [self._pusher stopPush];
    if (self.delegate && [self.delegate respondsToSelector:@selector(broadcastFinishedEnd)]) {
        [self.delegate broadcastFinishedEnd];
    }
}

- (void)dealloc {
    [self._pusher stopScreenCapture];
    [self._pusher stopAudioCapture];
    [self._pusher stopPush];
}

-(void) applicationWillTerminate {
    [self._pusher stopScreenCapture];
}

@end
#endif
