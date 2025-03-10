// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerViewService.h"
#import "BTDMacros.h"
#import "MDPlayerModuleManager.h"

@interface MDPlayerViewService()

@property (nonatomic, strong) MDPlayerActionView *actionView;
@property (nonatomic, strong) MDPlayerControlView *underlayControlView;
@property (nonatomic, strong) MDPlayerControlView *playbackControlView;
@property (nonatomic, strong) MDPlayerControlView *playbackLockControlView;
@property (nonatomic, strong) MDPlayerControlView *overlayControlView;

@end

@implementation MDPlayerViewService

@synthesize playerContainerView;

#pragma mark - Getter && Setter

- (MDPlayerActionView *)actionView {
    if (!_actionView) {
        _actionView = [[MDPlayerActionView alloc] initWithFrame:CGRectZero];
    }
    return _actionView;
}

- (MDPlayerControlView *)underlayControlView {
    if (!_underlayControlView) {
        _underlayControlView = [[MDPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _underlayControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_underlayControlView viewType:MDPlayerControlViewType_Underlay];
    }
    return _underlayControlView;
}

- (MDPlayerControlView *)playbackControlView {
    if (!_playbackControlView) {
        _playbackControlView = [[MDPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _playbackControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_playbackControlView viewType:MDPlayerControlViewType_Playback];
    }
    return _playbackControlView;
}

- (MDPlayerControlView *)playbackLockControlView {
    if (_playbackLockControlView) {
        _playbackLockControlView = [[MDPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _playbackLockControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_playbackLockControlView viewType:MDPlayerControlViewType_PlaybackLock];
    }
    return _playbackLockControlView;
}

- (MDPlayerControlView *)overlayControlView {
    if (!_overlayControlView) {
        _overlayControlView = [[MDPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _overlayControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_overlayControlView viewType:MDPlayerControlViewType_Overlay];
    }
    return _overlayControlView;
}

@end
