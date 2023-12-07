// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceFeedBlockSceneConf.h"
#import "Masonry.h"
#import "VEActionButton.h"
#import "VEDisplayLabel.h"
#import "VEEventMessageBus.h"
#import "VEInterfaceElementDescriptionImp.h"
#import "VEInterfacePlayElement.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEMultiStatePlayButton.h"
#import "VEPlayerUIModule.h"
#import "VEProgressView.h"

@interface VEInterfaceFeedBlockSceneConf ()

@property (nonatomic, strong) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong) VEEventPoster *eventPoster;

@end

@implementation VEInterfaceFeedBlockSceneConf

@synthesize deActive;

static NSString *playButtonIdentifier = @"playButtonIdentifier";

static NSString *progressViewIdentifier = @"progressViewIdentifier";

static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";

static NSString *maskViewIdentifier = @"maskViewIdentifier";

static NSString *fullScreenButtonIdentifier = @"fullScreenButtonIdentifier";

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventMessageBus = [[VEEventMessageBus alloc] init];
        self.eventPoster = [[VEEventPoster alloc] initWithEventMessageBus:self.eventMessageBus];
    }
    return self;
}

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup {
    for (UIView *aView in viewGroup) {
        if ([aView.elementID isEqualToString:identifier]) {
            return aView;
        }
    }
    return nil;
}

#pragma mark----- Element Statement

- (VEInterfaceElementDescriptionImp *)playButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *playBtnDes = [VEInterfaceElementDescriptionImp new];
        playBtnDes.elementID = playButtonIdentifier;
        playBtnDes.type = VEInterfaceElementTypeReplayButton;
        playBtnDes.elementDisplay = ^(VEMultiStatePlayButton *button) {
            VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
            if (playbackState == VEPlaybackStateStopped && [weak_self.eventPoster durationWatched] > 0.5) {
                button.playState = VEMultiStatePlayStateReplay;
            } else if (playbackState == VEPlaybackStatePlaying) {
                button.playState = VEMultiStatePlayStatePause;
            } else {
                button.playState = VEMultiStatePlayStatePlay;
            }
        };

        playBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
            if (playbackState == VEPlaybackStatePlaying) {
                return VEPlayEventPause;
            } else {
                return VEPlayEventPlay;
            }
        };
        playBtnDes.elementNotify = ^id(VEMultiStatePlayButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            if ([key isEqualToString:VEPlayEventStateChanged]) {
                VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
                if (playbackState == VEPlaybackStateStopped) {
                    button.playState = VEMultiStatePlayStateReplay;
                } else if (playbackState == VEPlaybackStatePlaying) {
                    button.playState = VEMultiStatePlayStatePause;
                } else {
                    button.playState = VEMultiStatePlayStatePlay;
                }
                if (screenIsClear) {
                    if (playbackState == VEPlaybackStateStopped) {
                        button.playState = VEMultiStatePlayStateReplay;
                        button.hidden = NO;
                    } else {
                        button.hidden = YES;
                    }
                }
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            }
            return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged];
        };
        playBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(groupContainer);
            }];
        };
        playBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)progressView {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *progressViewDes = [VEInterfaceElementDescriptionImp new];
        progressViewDes.elementID = progressViewIdentifier;
        progressViewDes.type = VEInterfaceElementTypeProgressView;
        progressViewDes.elementAction = ^NSDictionary *(VEProgressView *progressView) {
            return @{VEPlayEventSeek: @(progressView.currentValue)};
        };
        progressViewDes.elementNotify = ^id(VEProgressView *progressView, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                progressView.totalValue = [weak_self.eventPoster duration];
                progressView.currentValue = interval;
                progressView.bufferValue = [weak_self.eventPoster playableDuration];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                progressView.hidden = screenIsClear;
            } else if ([key isEqualToString:VEPlayEventStateChanged]) {
                if ([weak_self.eventPoster currentPlaybackState] == VEPlaybackStateStopped) {
                    progressView.hidden = NO;
                }
            }
            return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged, VEPlayEventStateChanged];
        };
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            ((VEProgressView *)elementView).currentOrientation = UIInterfaceOrientationPortrait;
            UIView *fullscreenBtn = [weak_self viewOfElementIdentifier:fullScreenButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(groupContainer).offset(12.0);
                make.centerY.equalTo(fullscreenBtn.mas_centerY);
                make.trailing.equalTo(fullscreenBtn.mas_leading).offset(-16.0);
                make.height.equalTo(@50.0);
            }];
        };
        progressViewDes;
    });
}

- (VEInterfaceElementDescriptionImp *)clearScreenGesture {
    return ({
        VEInterfaceElementDescriptionImp *clearScreenGestureDes = [VEInterfaceElementDescriptionImp new];
        clearScreenGestureDes.elementID = clearScreenGestureIdentifier;
        clearScreenGestureDes.type = VEInterfaceElementTypeGestureSingleTap;
        clearScreenGestureDes.elementAction = ^NSString *(id sender) {
            return VEUIEventClearScreen;
        };
        clearScreenGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)maskView {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *maskVewDes = [VEInterfaceElementDescriptionImp new];
        maskVewDes.elementID = maskViewIdentifier;
        maskVewDes.type = VEInterfaceElementTypeMaskView;
        maskVewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(groupContainer);
            }];
        };
        maskVewDes.elementNotify = ^id(UIView *elementView, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            elementView.hidden = screenIsClear;
            return VEUIEventScreenClearStateChanged;
        };
        maskVewDes;
    });
}

- (VEInterfaceElementDescriptionImp *)fullScreenButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *fullScreenBtnDes = [VEInterfaceElementDescriptionImp new];
        fullScreenBtnDes.elementID = fullScreenButtonIdentifier;
        fullScreenBtnDes.type = VEInterfaceElementTypeButton;
        fullScreenBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_portrait"] forState:UIControlStateNormal];
        };
        fullScreenBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventScreenRotation;
        };
        fullScreenBtnDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        fullScreenBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(groupContainer).offset(-6.0);
                    make.trailing.equalTo(groupContainer).offset(-10.0);
                    make.size.equalTo(@(CGSizeMake(28.0, 28.0)));
                }];
            } else {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            }
        };
        fullScreenBtnDes;
    });
}

#pragma mark----- VEInterfaceElementProtocol

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    return @[
        [self maskView],
        [self playButton],
        [self progressView],
        [self clearScreenGesture],
        [self fullScreenButton],
        [VEInterfacePlayElement autoHideControllerGesture],
    ];
}

@end
