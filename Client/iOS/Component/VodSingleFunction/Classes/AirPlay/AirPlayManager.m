//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AirPlayManager.h"
#import <AVFoundation/AVFoundation.h>
#import <ToolKit/ToolKit.h>

@interface AirPlayManager ()

@property (nonatomic, strong, nullable) AVPlayer *avPlayer;
@property (nonatomic, strong, nullable) AVPlayerItem *observedItem;
@property (nonatomic, assign) BOOL isAirPlaying;
@property (nonatomic, copy, nullable) NSString *currentVideoIdentifier;

@property (nonatomic, copy, nullable) NSString *previousCategory;
@property (nonatomic, copy, nullable) NSString *previousMode;
@property (nonatomic, assign) AVAudioSessionCategoryOptions previousOptions;
@property (nonatomic, assign) BOOL audioSessionOverridden;

@end

static void *kAirPlayItemStatusCtx = &kAirPlayItemStatusCtx;

@implementation AirPlayManager

+ (instancetype)sharedManager {
    static AirPlayManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(routeChanged:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)activateAirPlayAudioSession {
    if (self.audioSessionOverridden) {
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    self.previousCategory = session.category;
    self.previousMode = session.mode;
    self.previousOptions = session.categoryOptions;

    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayback
                    mode:AVAudioSessionModeMoviePlayback
                 options:AVAudioSessionCategoryOptionAllowAirPlay
                   error:&error];
    if (error) {
        VOLogI(VOVideoPlayback, @"[AirPlay] setCategory error: %@", error);
        error = nil;
    }
    [session setActive:YES error:&error];
    if (error) {
        VOLogI(VOVideoPlayback, @"[AirPlay] setActive error: %@", error);
    }
    self.audioSessionOverridden = YES;
}

- (void)deactivateAirPlayAudioSession {
    if (!self.audioSessionOverridden) {
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setActive:NO
           withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                 error:&error];
    if (error) {
        VOLogI(VOVideoPlayback, @"[AirPlay] setActive:NO error: %@", error);
        error = nil;
    }
    if (self.previousCategory.length > 0) {
        [session setCategory:self.previousCategory
                        mode:(self.previousMode.length > 0 ? self.previousMode : AVAudioSessionModeDefault)
                     options:self.previousOptions
                       error:&error];
        if (error) {
            VOLogI(VOVideoPlayback, @"[AirPlay] restore setCategory error: %@", error);
        }
    }
    self.previousCategory = nil;
    self.previousMode = nil;
    self.previousOptions = 0;
    self.audioSessionOverridden = NO;
}

#pragma mark - Public

- (void)startWithURL:(NSURL *)url
          identifier:(nullable NSString *)identifier
            fromTime:(NSTimeInterval)startSeconds {
    if (!url) {
        VOLogI(VOVideoPlayback, @"[AirPlay] start failed: url is nil");
        return;
    }
    [self teardownAVPlayer];
    [self activateAirPlayAudioSession];
    self.currentVideoIdentifier = identifier;

    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    player.allowsExternalPlayback = YES;
    self.avPlayer = player;
    [self attachObserversToItem:item];

    if (startSeconds > 0) {
        CMTime t = CMTimeMakeWithSeconds(startSeconds, NSEC_PER_SEC);
        [player seekToTime:t toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [player play];
        }];
    } else {
        [player play];
    }
    VOLogI(VOVideoPlayback, @"[AirPlay] AVPlayer started, url=%@, t=%.2f, id=%@", url, startSeconds, identifier);
}

- (void)stop {
    [self teardownAVPlayer];
    [self deactivateAirPlayAudioSession];
    self.currentVideoIdentifier = nil;
    VOLogI(VOVideoPlayback, @"[AirPlay] AVPlayer stopped");
}

- (NSTimeInterval)currentTime {
    if (!self.avPlayer) {
        return 0;
    }
    CMTime t = self.avPlayer.currentTime;
    if (CMTIME_IS_VALID(t) && !CMTIME_IS_INDEFINITE(t)) {
        return CMTimeGetSeconds(t);
    }
    return 0;
}

- (NSString *)currentAirPlayDeviceName {
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    for (AVAudioSessionPortDescription *port in route.outputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortAirPlay]) {
            return port.portName;
        }
    }
    return @"";
}

#pragma mark - Private

- (void)teardownAVPlayer {
    [self detachObserversFromItem];
    AVPlayer *player = self.avPlayer;
    if (player) {
        [player pause];
        player.allowsExternalPlayback = NO;
        [player replaceCurrentItemWithPlayerItem:nil];
    }
    self.avPlayer = nil;
}

- (void)attachObserversToItem:(AVPlayerItem *)item {
    if (!item) {
        return;
    }
    self.observedItem = item;
    [item addObserver:self
           forKeyPath:@"status"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:kAirPlayItemStatusCtx];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(itemFailedToPlayToEnd:)
               name:AVPlayerItemFailedToPlayToEndTimeNotification
             object:item];
    [nc addObserver:self
           selector:@selector(itemPlaybackStalled:)
               name:AVPlayerItemPlaybackStalledNotification
             object:item];
    [nc addObserver:self
           selector:@selector(itemDidPlayToEnd:)
               name:AVPlayerItemDidPlayToEndTimeNotification
             object:item];
}

- (void)detachObserversFromItem {
    AVPlayerItem *item = self.observedItem;
    if (!item) {
        return;
    }
    @try {
        [item removeObserver:self forKeyPath:@"status" context:kAirPlayItemStatusCtx];
    } @catch (__unused NSException *e) {}
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:item];
    [nc removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:item];
    [nc removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    self.observedItem = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context != kAirPlayItemStatusCtx) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    AVPlayerItem *item = (AVPlayerItem *)object;
    if (item.status == AVPlayerItemStatusFailed) {
        NSError *error = item.error ?: self.avPlayer.error;
        VOLogI(VOVideoPlayback, @"[AirPlay] item failed: %@", error);
        [self notifyPlaybackError:error];
    } else if (item.status == AVPlayerItemStatusReadyToPlay) {
        VOLogI(VOVideoPlayback, @"[AirPlay] item ready to play");
    }
}

- (void)itemFailedToPlayToEnd:(NSNotification *)note {
    NSError *error = note.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    VOLogI(VOVideoPlayback, @"[AirPlay] item failed to play to end: %@", error);
    [self notifyPlaybackError:error];
}

- (void)itemPlaybackStalled:(NSNotification *)note {
    VOLogI(VOVideoPlayback, @"[AirPlay] item playback stalled");
}

- (void)itemDidPlayToEnd:(NSNotification *)note {
    VOLogI(VOVideoPlayback, @"[AirPlay] item did play to end, loop restart");
    __weak typeof(self) weakSelf = self;
    dispatch_block_t work = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        AVPlayer *player = self.avPlayer;
        if (!player) {
            return;
        }
        [player seekToTime:kCMTimeZero
           toleranceBefore:kCMTimeZero
            toleranceAfter:kCMTimeZero
         completionHandler:^(BOOL finished) {
            if (finished) {
                [player play];
            }
        }];
    };
    if ([NSThread isMainThread]) {
        work();
    } else {
        dispatch_async(dispatch_get_main_queue(), work);
    }
}

- (void)notifyPlaybackError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    dispatch_block_t work = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }
        id<AirPlayManagerDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(airPlayManager:didFailWithError:)]) {
            [delegate airPlayManager:self didFailWithError:error];
        }
    };
    if ([NSThread isMainThread]) {
        work();
    } else {
        dispatch_async(dispatch_get_main_queue(), work);
    }
}

- (void)routeChanged:(NSNotification *)note {
    BOOL nowAirPlaying = [self isCurrentRouteAirPlay];
    dispatch_block_t work = ^{
        if (nowAirPlaying == self.isAirPlaying) {
            return;
        }
        self.isAirPlaying = nowAirPlaying;
        VOLogI(VOVideoPlayback, @"[AirPlay] route changed, isAirPlaying=%d", nowAirPlaying);
        id<AirPlayManagerDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(airPlayManager:didChangeAirPlayingState:)]) {
            [delegate airPlayManager:self didChangeAirPlayingState:nowAirPlaying];
        }
    };
    if ([NSThread isMainThread]) {
        work();
    } else {
        dispatch_async(dispatch_get_main_queue(), work);
    }
}

- (BOOL)isCurrentRouteAirPlay {
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    for (AVAudioSessionPortDescription *port in route.outputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortAirPlay]) {
            return YES;
        }
    }
    return NO;
}

@end
