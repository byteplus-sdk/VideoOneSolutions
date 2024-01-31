// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "PlayListManager.h"
#import "VEVideoModel.h"
#import "PlayListView.h"
#import "PlayListFloatView.h"
#import "VEEventConst.h"
#import "VEEventMessageBus.h"
#import "VEVideoPlayerController+Strategy.h"

@interface PlayListManager ()<PlayListDelegate>

@end

@implementation PlayListManager

#pragma mark - Setter

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self openPreload];
    }
    return self;
}


- (void)dealloc {
    [VEVideoPlayerController clearAllEngineStrategy];
    [VEVideoPlayerController cancelPreloadVideoSources];
}

- (void)setEventMessageBus:(VEEventMessageBus *)eventMessageBus {
    _eventMessageBus = eventMessageBus;
    [eventMessageBus registEvent:VEUIEventShowPlayListMenu withAction:@selector(showPlayListFloatView) ofTarget:self];
    [eventMessageBus registEvent:VEUIEventPlayPreviousVideo withAction:@selector(playPreviousVideo) ofTarget:self];
    [eventMessageBus registEvent:VEUIEventPlayNextVideo withAction:@selector(playNextVideo) ofTarget:self];
    [eventMessageBus registEvent:VEUIEventPageBack withAction:@selector(scroll) ofTarget:self];
}

- (void)showPlayListFloatView {
    [self.eventPoster setScreenIsClear:YES];
    [self.playListFloatView show];
}

- (void)playPreviousVideo {
    if (self.currentPlayViewIndex != 0) {
        self.currentPlayViewIndex = self.currentPlayViewIndex - 1;
    }
}

- (void)playNextVideo {
    if (self.currentPlayViewIndex != self.playList.count) {
        self.currentPlayViewIndex = self.currentPlayViewIndex + 1;
    }
}

- (void)scroll {
    [self.playListView scroll:self.currentPlayViewIndex];
}
- (void) openPreload {
    [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
}
- (void)preloadVideoAtIndex:(NSUInteger)index {
    if (!self.playList.count || index == self.playList.count - 1) {
        return;
    }
    NSUInteger loc = index + 1;
    NSUInteger len = MIN(3, self.playList.count - loc);
    [[self.playList subarrayWithRange:NSMakeRange(loc, len)] enumerateObjectsUsingBlock:^(VEVideoModel *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [VEVideoPlayerController preloadVideoSource:[VEVideoModel videoEngineVidSource:obj]];
    }];
}


#pragma mark - PlayListDelegate
- (void)onChangeCurrentVideo:(VEVideoModel *)model index:(NSInteger)index {
    self.currentPlayViewIndex = index;
}

#pragma mark - Setter
- (void)setCurrentPlayViewIndex:(NSInteger)currentPlayViewIndex {
    _currentPlayViewIndex = currentPlayViewIndex;
    self.playListView.currentPlayViewIndex = currentPlayViewIndex;
    self.playListFloatView.currentPlayViewIndex = currentPlayViewIndex;
    [self preloadVideoAtIndex:currentPlayViewIndex];
    if([self.delegate respondsToSelector:@selector(updatePlayVideo:)]) {
        [self.delegate updatePlayVideo:self.playList[currentPlayViewIndex]];
    }
}

- (void)setPlayList:(NSArray<VEVideoModel *> *)playList {
    _playList = playList;
    self.playListView.playList = playList;
    self.playListFloatView.playList = playList;
}

#pragma mark - Getter
- (PlayListView *)playListView {
    if (!_playListView) {
        _playListView = [[PlayListView alloc] init];
        _playListView.delegate = self;
    }
    return _playListView;
}

- (PlayListFloatView *)playListFloatView {
    if (!_playListFloatView) {
        _playListFloatView = [[PlayListFloatView alloc] init];
        _playListFloatView.delegate = self;
    }
    return _playListFloatView;
}
@end
