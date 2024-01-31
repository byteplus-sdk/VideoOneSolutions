// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PIPAVPlayerView.h"

@interface PIPAVPlayerView ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, copy) void (^prepareToPlayBlock)(BOOL result);

@end

@implementation PIPAVPlayerView

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)prepareToPlay:(NSString *)videoURL
           completion:(void (^)(BOOL result))block {
    self.prepareToPlayBlock = block;
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:videoURL] options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:asset];
    [playItem addObserver:self
               forKeyPath:@"status"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                  context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playItem];

    self.player = [AVPlayer playerWithPlayerItem:playItem];
    [self.player play];
    [self enterForeground];
}

#pragma mark - Publish Action

- (void)enterBackground {
    self.player.muted = NO;
}

- (void)enterForeground {
    self.player.muted = YES;
}

- (void)seekToTime:(NSTimeInterval)interval {
    CMTime time = CMTimeMakeWithSeconds(interval, 600);
    [self.player seekToTime:time completionHandler:^(BOOL finished){

    }];
}

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(self.player.currentTime);
}

#pragma mark - NSNotification

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    if (self.playerEndBlock) {
        self.playerEndBlock();
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay: {
                // 播放器已准备好播放
                if (self.prepareToPlayBlock) {
                    self.prepareToPlayBlock(YES);
                }
            } break;
            case AVPlayerStatusFailed:
                // 播放器播放失败
                if (self.prepareToPlayBlock) {
                    self.prepareToPlayBlock(NO);
                }
                break;
            case AVPlayerStatusUnknown:
                // 播放器状态未知

                break;
            default:
                break;
        }
    }
}

- (void)dealloc {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
}

@end
