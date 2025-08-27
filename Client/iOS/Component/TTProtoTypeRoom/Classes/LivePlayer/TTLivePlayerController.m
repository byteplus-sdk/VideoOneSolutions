// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "TTLivePlayerController.h"
#import "TVLManager.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

@interface TTLivePlayerController () <VeLivePlayerObserver>

@property (nonatomic, strong) TVLManager *playerManager;

@property (nonatomic, strong) UIView *playerContainer;

@property (nonatomic, strong) TTLiveModel *liveModel;

@end

@implementation TTLivePlayerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupPlayer];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_applicationWillResignActive)
                                                   name:UIApplicationWillResignActiveNotification
                                                 object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_applicationDidBecomeActive)
                                                   name:UIApplicationDidBecomeActiveNotification
                                                 object:nil];
    }
    return self;
}

#pragma mark -- private method
- (void)_applicationWillResignActive {
    if (self.isActive) {
        VOLogI(VOTTProto, @"background, player stop");
        [self.playerManager stop];
    }
}

- (void)_applicationDidBecomeActive {
    if (self.isActive) {
        VOLogI(VOTTProto, @"foreground, player resume");
        [self.playerManager play];
    }
}

- (void)setupPlayer {
    _playerManager = [[TVLManager alloc] initWithOwnPlayer:YES];
    if (!_playerManager) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"tt_live_license_invalid", @"TTProto")];
    }
    
    VeLivePlayerConfiguration *config = [[VeLivePlayerConfiguration alloc] init];
    config.enableStatisticsCallback = YES;
    [self.playerManager setConfig:config];
    
    [self.playerManager setPlayerViewRenderType:(TVLPlayerViewRenderTypeMetal)];
    [self.playerManager setObserver:self];
    [self.playerManager setProjectKey:[NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"]];
    self.playerManager.playerView.frame = UIScreen.mainScreen.bounds;
    [self.playerContainer addSubview:self.playerManager.playerView];
    [self.playerManager.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playerContainer);
    }];
}

- (NSString *)getPlayerUrl:(TTLiveModel *)liveModel {
    NSArray *selectList = @[@"720", @"1080", @"540", @"360"];
    __block NSString *url = nil;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [selectList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (liveModel.streamDic[dic] != nil) {
            url = liveModel.streamDic[dic];
            *stop = YES;
        }
    }];
    if (url == nil) {
        if (liveModel.streamDic.allValues.count > 0) {
            url = [liveModel.streamDic.allValues firstObject];
        } else {
            VOLogE(VOTTProto, @"streamDic is empty");
        }
    }
    return url;
}

#pragma mark -- public method

- (void)playerStreamWith:(TTLiveModel *)liveModel {
    if (self.playerManager.isPlaying) {
        if ([self.liveModel.roomId isEqualToString:liveModel.roomId] && self.isActive) {
            return;
        } else {
            [self stopPlayerStream];
        }
    }
    _liveModel = liveModel;
    NSString *url = [self getPlayerUrl:liveModel];
    if (!url || [url isEqualToString:@""]) {
        [[ToastComponent shareToastComponent] showWithMessage:@"play url is empty"];
        return;
    }
    [self.playerManager setPlayUrl:url];
    [self.playerManager play];
    self.isActive = YES;
}

- (void)setMute:(BOOL)mute {
    [self.playerManager setMute:mute];
}

- (void)bindStreamView:(UIView *)streamView {
    VOLogI(VOTTProto, @"bindStreamView: playerAddress:%@", self);
    if (self.playerContainer.superview) {
        return;
    }
    [streamView addSubview:self.playerContainer];
    [self.playerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(streamView);
    }];
}

- (void)removeStreamView {
    if (self.playerContainer.superview) {
        VOLogI(VOTTProto, @"VOTTProto: playerAddress:%@", self);
        [self.playerContainer removeFromSuperview];
    }
}

- (void)stopPlayerStream {
    VOLogI(VOTTProto, @"playerContainerHidden: playerAddress: %@", self);
    self.playerContainer.hidden = YES;
    [self.playerManager stop];
    _liveModel = nil;
    self.isActive = NO;
}

- (void)destroy {
    [self removeStreamView];
    [self.playerManager destroy];
    self.playerManager = nil;
}

#pragma mark -- VeLivePlayerObserver
- (void)onError:(TVLManager *)player error:(VeLivePlayerError *)error {
    VOLogE(VOTTProto, @"VeLivePlayerObserver:onError, code: %ld, message: %@", error.errorCode, error.errorMsg);
}

- (void)onStatistics:(TVLManager *)player statistics:(VeLivePlayerStatistics *)statistics {

}

- (void)onStallStart:(TVLManager *)player {
    VOLogW(VOTTProto, @"VeLivePlayerObserver:onStallStart");
}

- (void)onStallEnd:(TVLManager *)player {
    VOLogI(VOTTProto, @"VeLivePlayerObserver:onStallEnd");
}

- (void)onFirstVideoFrameRender:(TVLManager *)player isFirstFrame:(BOOL)isFirstFrame {
    VOLogI(VOTTProto, @"VeLivePlayerObserver:onFirstVideoFrameRender, %d", isFirstFrame);
    VOLogI(VOTTProto, @"playerContainerShow: playerAddress: %@", self);
    self.playerContainer.hidden = NO;
}

- (void)onFirstAudioFrameRender:(TVLManager *)player isFirstFrame:(BOOL)isFirstFrame {
    VOLogI(VOTTProto, @"VeLivePlayerObserver:onFirstAudioFrameRender, %d", isFirstFrame);
}

- (void)onPlayerStatusUpdate:(TVLManager *)player status:(VeLivePlayerStatus)status {
    VOLogI(VOTTProto, @"VeLivePlayerObserver:onPlayerStatusUpdate, %ld", status);
}

- (void)onVideoSizeChanged:(TVLManager *)player width:(int)width height:(int)height {
    VOLogI(VOTTProto, @"VeLivePlayerObserver:onVideoSizeChanged, (%d,%d)", width, height);
}

#pragma mark -- getter
- (UIView *)playerContainer {
    if (!_playerContainer) {
        _playerContainer = [[UIView alloc] init];
        _playerContainer.backgroundColor = [UIColor blackColor];
    }
    return _playerContainer;
}
@end
