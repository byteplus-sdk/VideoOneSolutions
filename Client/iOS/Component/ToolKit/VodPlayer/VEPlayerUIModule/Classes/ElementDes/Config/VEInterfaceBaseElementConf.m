//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceBaseElementConf.h"
#import "NSObject+ToElementDescription.h"
#import "VEEventMessageBus.h"
#import "VEEventPoster+Private.h"
#import "VEInterface.h"
#import "VEInterfaceElementDescriptionImp.h"
#import "VEMultiStatePlayButton.h"
#import "VEProgressView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

NSString *const VEInterPlayButtonIdentifier = @"VEInterPlayButtonIdentifier";

NSString *const VEProgressViewIdentifier = @"VEProgressViewIdentifier";

NSString *const VEInterFullScreenButtonIdentifier = @"VEInterFullScreenButtonIdentifier";

@implementation VEInterfaceBaseElementConf

- (VEInterfaceElementDescriptionImp *)playButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *playBtnDes = [VEInterfaceElementDescriptionImp new];
        playBtnDes.elementID = VEInterPlayButtonIdentifier;
        playBtnDes.type = VEInterfaceElementTypeReplayButton;
        playBtnDes.elementDisplay = ^(VEMultiStatePlayButton *button) {
            [weak_self updatePlayButtonState:button];
        };
        playBtnDes.elementAction = ^NSString *(VEMultiStatePlayButton *button) {
            VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
            if (playbackState == VEPlaybackStatePlaying) {
                return VEPlayEventPause;
            } else {
                return VEPlayEventPlay;
            }
        };
        playBtnDes.elementNotify = ^id(VEMultiStatePlayButton *button, NSString *key, id obj) {
            if ([key isEqualToString:VEPlayEventStateChanged]) {
                [weak_self updatePlayButtonState:button];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
                BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
                button.hidden = screenIsLocking;
            }
            return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        playBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(groupContainer);
            }];
        };
        playBtnDes;
    });
}

- (void)updatePlayButtonState:(VEMultiStatePlayButton *)button {
    VEPlaybackState playbackState = [self.eventPoster currentPlaybackState];
    BOOL screenIsClear = [self.eventPoster screenIsClear];
    BOOL screenIsLocking = [self.eventPoster screenIsLocking];
    if (playbackState == VEPlaybackStateFinished) {
        button.playState = VEMultiStatePlayStateReplay;
        button.hidden = screenIsClear || screenIsLocking;
        return;
    } else if (playbackState == VEPlaybackStatePlaying) {
        button.playState = VEMultiStatePlayStatePause;
    } else if (playbackState == VEPlaybackStateUnknown || playbackState == VEPlaybackStateStopped) {
        button.playState = VEMultiStatePlayStateUnknown;
        return;
    } else {
        button.playState = VEMultiStatePlayStatePlay;
    }
    button.hidden = screenIsClear || screenIsLocking;
}

- (VEInterfaceElementDescriptionImp *)progressView {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *progressViewDes = [VEInterfaceElementDescriptionImp new];
        progressViewDes.elementID = VEProgressViewIdentifier;
        progressViewDes.type = VEInterfaceElementTypeProgressView;

        progressViewDes.elementAction = ^NSDictionary *(VEProgressView *progressView) {
            return @{VEPlayEventSeek: @(progressView.currentValue)};
        };

        progressViewDes.elementNotify = ^id(VEProgressView *progressView, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEPlayEventTimeIntervalChanged]) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                    progressView.totalValue = [weak_self.eventPoster duration];
                    progressView.currentValue = interval;
                    progressView.bufferValue = [weak_self.eventPoster playableDuration];
                };
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                progressView.hidden = screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                progressView.hidden = screenIsClear;
                progressView.userInteractionEnabled = !screenIsLocking;
            } else if ([key isEqualToString:VEUIEventSeeking]) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    BOOL isSeeking = [obj boolValue];
                    progressView.hidden = isSeeking ? NO : screenIsClear;
                };
            }
            return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventSeeking];
        };

        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            ((VEProgressView *)elementView).currentOrientation = UIInterfaceOrientationPortrait;
            UIView *fullscreenBtn = [weak_self viewOfElementIdentifier:VEInterFullScreenButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(groupContainer).offset(12.0);
                make.bottom.equalTo(groupContainer);
                make.height.equalTo(@48.0);
                if (fullscreenBtn) {
                    make.trailing.equalTo(fullscreenBtn.mas_leading).offset(-16.0);
                } else {
                    make.trailing.equalTo(groupContainer).offset(-12.0);
                }
            }];
        };

        progressViewDes;
    });
}

- (VEInterfaceElementDescriptionImp *)fullScreenButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *fullScreenBtnDes = [VEInterfaceElementDescriptionImp new];
        fullScreenBtnDes.elementID = VEInterFullScreenButtonIdentifier;
        fullScreenBtnDes.type = VEInterfaceElementTypeButton;
        fullScreenBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_portrait" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        fullScreenBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            VOLogD(VOToolKit, @"fullScreenBtnDes elementAction");
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
                    make.bottom.equalTo(groupContainer);
                    make.trailing.equalTo(groupContainer).offset(-12.0);
                    make.size.equalTo(@(CGSizeMake(28.0, 48.0)));
                }];
            } else {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            }
        };
        fullScreenBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)autoHideControllerGesture {
    @autoreleasepool {
        return ({
            VEInterfaceElementDescriptionImp *gestureDes = [VEInterfaceElementDescriptionImp new];
            gestureDes.type = VEInterfaceElementTypeGestureAutoHideController;
            gestureDes;
        });
    }
}

- (VEInterfaceElementDescriptionImp *)clearScreenGesture {
    return ({
        VEInterfaceElementDescriptionImp *clearScreenGestureDes = [VEInterfaceElementDescriptionImp new];
        clearScreenGestureDes.type = VEInterfaceElementTypeGestureSingleTap;
        clearScreenGestureDes.elementAction = ^NSString *(id sender) {
            return VEUIEventClearScreen;
        };
        clearScreenGestureDes;
    });
}

@end
