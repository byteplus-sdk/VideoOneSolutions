// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PIPManager.h"
#import "PIPAVPlayerView.h"
#import "PIPModel.h"
#import <Masonry/Masonry.h>
#import <objc/message.h>

@interface PIPManager () <AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) PIPAVPlayerView *playerView;
@property (nonatomic, strong) AVPictureInPictureController *pipController;

@property (nonatomic, copy) void (^prepareCompletionBlock)(PIPManagerStatus status);
@property (nonatomic, assign) CGFloat avPlayerInterval;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, assign) BOOL isRestore;

@end

@implementation PIPManager

+ (PIPManager *_Nullable)sharePIPManager {
    static PIPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PIPManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Publish Action

- (void)prepare:(UIView *)contentView
       videoURL:(NSString *)videoURL
       interval:(NSTimeInterval)interval
     completion:(void (^)(PIPManagerStatus status))block {
    [self cancelPrepare];
    self.prepareCompletionBlock = block;
    self.contentView = contentView;

    if (videoURL.length <= 0) {
        self.status = PIPManagerStatusParameterFailed;
        if (block) {
            block(PIPManagerStatusParameterFailed);
        }
        return;
    }

    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        @try {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            if (error) {
                self.status = PIPManagerStatusPermissionFailed;
                if (block) {
                    block(PIPManagerStatusPermissionFailed);
                }
                return;
            }
        } @catch (NSException *exception) {
            self.status = PIPManagerStatusExceptionFailed;
            if (block) {
                block(PIPManagerStatusExceptionFailed);
            }
            return;
        }
    } else {
        self.status = PIPManagerStatusDeviceSupportFailure;
        if (block) {
            block(PIPManagerStatusDeviceSupportFailure);
        }
        return;
    }

    self.playerView = [[PIPAVPlayerView alloc] init];
    [self didStopPictureInPicture];
    [contentView addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];

    __weak __typeof(self) wself = self;
    [self.playerView seekToTime:interval];
    [self.playerView prepareToPlay:videoURL completion:^(BOOL result) {
        if (result) {
            [wself initPipController];
        } else {
            wself.status = PIPManagerStatusExceptionFailed;
            if (block) {
                block(PIPManagerStatusExceptionFailed);
            }
        }
    }];
    self.playerView.playerEndBlock = ^{
        [wself stopPictureInPictureEvenWhenInBackground];
    };
}

- (void)cancelPrepare {
    self.status = PIPManagerStatusNone;
    [self removePlayerView];
    [self removePipController];
}

- (void)updatePlaybackStatus:(BOOL)isPlaying atRate:(CGFloat)rate{
    if (isPlaying) {
        [self seekToCurrentTime];
        [self.pipController.playerLayer.player playImmediatelyAtRate:rate];
    } else {
        [self.pipController.playerLayer.player pause];
    }
}

- (void)setRate:(CGFloat)rate{
    if (self.pipController.playerLayer.player) {
        [self seekToCurrentTime];
        [self.pipController.playerLayer.player setRate:rate];
    }
}

- (BOOL)enablePictureInPicture {
    return [PIPModel getPictureInPicture];
}

- (void)setEnablePictureInPicture:(BOOL)enablePictureInPicture {
    [PIPModel setPictureInPicture:enablePictureInPicture];
}

#pragma mark - Notification

- (void)didBecomeActiveNotification {
    if (self.pipController.isPictureInPictureActive) {
        [self.pipController stopPictureInPicture];
    }
}

- (void)willResignActiveNotification {
    [self seekToCurrentTime];
}

#pragma mark - Private Action

- (void)initPipController {
    [self removePipController];
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.playerView.layer;
    self.pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:playerLayer];
    self.pipController.delegate = self;
    if (@available(iOS 14.2, *)) {
        self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
    }
    self.status = PIPManagerStatusStartSuccess;
    if (self.prepareCompletionBlock) {
        self.prepareCompletionBlock(PIPManagerStatusStartSuccess);
    }
}

- (void)removePipController {
    if (self.pipController) {
        self.pipController = nil;
    }
}

- (void)removePlayerView {
    if (self.playerView) {
        [self.playerView removeFromSuperview];
        self.playerView = nil;
    }
}

- (void)willStartPictureInPicture {
    [self.playerView enterBackground];
    self.playerView.hidden = NO;
    self.pipController.playerLayer.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:27 / 255.0 blue:30 / 255.0 alpha:1].CGColor;
}

- (void)didStopPictureInPicture {
    [self.playerView enterForeground];
    self.playerView.hidden = YES;
    self.pipController.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
}

- (void)stopPictureInPictureEvenWhenInBackground {
    if ([self.pipController respondsToSelector:@selector(stopPictureInPictureEvenWhenInBackground)]) {
        ((void (*)(id, SEL))objc_msgSend)(_pipController, @selector(stopPictureInPictureEvenWhenInBackground));
    } else {
        [self.pipController stopPictureInPicture];
    }
}

- (void)seekToCurrentTime {
    NSTimeInterval currentProgress = -1;
    if ([self.dataSource respondsToSelector:@selector(currentVideoPlaybackProgress:)]) {
        currentProgress = [self.dataSource currentVideoPlaybackProgress:self];
    }
    if (currentProgress >= 0) {
        // seek
        [self.playerView seekToTime:(currentProgress)];
    }
}

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self willStartPictureInPicture];
    if (self.startCompletionBlock) {
        self.startCompletionBlock();
    }
}
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    self.status = PIPManagerStatusExceptionFailed;
    if (self.prepareCompletionBlock) {
        self.prepareCompletionBlock(PIPManagerStatusExceptionFailed);
    }
}
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
}
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self didStopPictureInPicture];
    if (self.isRestore) {
        BOOL isPlaying = self.pipController.playerLayer.player.rate > 0 ? YES : NO;
        if (self.restoreCompletionBlock) {
            self.restoreCompletionBlock(self.playerView.currentTime, isPlaying);
        }
    } else {
        if (self.closeCompletionBlock) {
            self.closeCompletionBlock(self.playerView.currentTime);
        }
    }
    self.isRestore = NO;
}
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    self.isRestore = YES;
}

@end
