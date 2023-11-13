// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSimpleBlockSceneConf.h"
#import "VEPlayerUIModule.h"
#import "Masonry.h"
#import "VEActionButton.h"
#import "VEProgressView.h"
#import "VEDisplayLabel.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceSlideMenuPercentageCell.h"
#import "VEInterfaceSlideButtonCell.h"
#import "VEInterfaceElementDescriptionImp.h"
#import "VEEventMessageBus.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/ReportComponent.h>
#import "VEEventPoster+Private.h"
#import "VEVideoModel.h"
#import "VEDataPersistance.h"
#import "VEMaskView.h"

static NSString *playButtonIdentifier = @"playButtonIdentifier";

static NSString *progressViewIdentifier = @"progressViewIdentifier";

static NSString *fullScreenButtonIdentifier = @"fullScreenButtonIdentifier";

static NSString *backButtonIdentifier = @"backButtonIdentifier";

static NSString *resolutionButtonIdentifier = @"resolutionButtonIdentifier";

static NSString *playSpeedButtonIdentifier = @"playSpeedButtonIdentifier";

static NSString *moreButtonIdentifier = @"moreButtonIdentifier";

static NSString *lockButtonIdentifier = @"lockButtonIdentifier";

static NSString *titleLabelIdentifier = @"titleLabelIdentifier";

static NSString *loopPlayButtonIdentifier = @"loopPlayButtonIdentifier";

static NSString *volumeGestureIdentifier = @"volumeGestureIdentifier";

static NSString *brightnessGestureIdentifier = @"brightnessGestureIdentifier";

static NSString *progressGestureIdentifier = @"progressGestureIdentifier";

static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";

static NSString *playGestureIdentifier = @"playGestureIdentifier";

static NSString *reportIdentifier = @"reportIdentifier";

static NSString *maskViewIdentifier = @"maskViewIdentifier";

@interface VEInterfaceSimpleBlockSceneConf ()

@property (nonatomic, strong) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong) VEEventPoster *eventPoster;

@end

@implementation VEInterfaceSimpleBlockSceneConf

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventMessageBus = [[VEEventMessageBus alloc] init];
        self.eventPoster = [[VEEventPoster alloc] initWithEventMessageBus:self.eventMessageBus];
    }
    return self;
}

#pragma mark ----- Tool

static inline BOOL normalScreenBehaivor (void) {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
}

static inline CGSize squareSize (void) {
    if (normalScreenBehaivor()) {
        return CGSizeMake(24.0, 24.0);
    } else {
        return CGSizeMake(36.0, 36.0);
    }
}

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup {
    for (UIView *aView in viewGroup) {
        if ([aView.elementID isEqualToString:identifier]) {
            return aView;
        }
    }
    return nil;
}


#pragma mark ----- Element Statement

- (VEInterfaceElementDescriptionImp *)playButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *playBtnDes = [VEInterfaceElementDescriptionImp new];
        playBtnDes.elementID = playButtonIdentifier;
        playBtnDes.type = VEInterfaceElementTypeButton;
        playBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
        };
        playBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
            if (playbackState == VEPlaybackStatePlaying) {
                return VEPlayEventPause;
            } else {
                return VEPlayEventPlay;
            }
        };
        playBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEPlayEventStateChanged]) {
                VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
                button.selected = playbackState != VEPlaybackStatePlaying;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        playBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(groupContainer);
                make.size.equalTo(@(CGSizeMake(50.0, 50.0)));
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
        
        progressViewDes.elementAction = ^NSDictionary* (VEProgressView *progressView) {
            return @{VEPlayEventSeek : @(progressView.currentValue)};
        };
        
        
        progressViewDes.elementNotify = ^id (VEProgressView *progressView, NSString *key, id obj) {
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
                progressView.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                progressView.hidden = screenIsLocking;
            }
            return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            VEProgressView *progressView = (VEProgressView *)elementView;
            if (normalScreenBehaivor()) {
                UIView *fullscreenBtn = [weak_self viewOfElementIdentifier:fullScreenButtonIdentifier inGroup:elementGroup];
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(groupContainer).offset(12.0);
                    make.centerY.equalTo(fullscreenBtn);
                    make.trailing.equalTo(fullscreenBtn.mas_leading).offset(-5.0);
                    make.height.equalTo(@50.0);
                }];
                progressView.currentOrientation = UIInterfaceOrientationPortrait;
            } else {
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(groupContainer).offset(45.0);
                    make.trailing.equalTo(groupContainer).offset(-45.0);
                    make.bottom.equalTo(groupContainer).offset(-50.0);
                    make.height.equalTo(@40.0);
                }];
                progressView.currentOrientation = UIInterfaceOrientationLandscapeRight;
            }
        };
        progressViewDes;
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
        fullScreenBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
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
                    make.bottom.equalTo(groupContainer).offset(-10.0);
                    make.trailing.equalTo(groupContainer).offset(-3.0);
                    make.size.equalTo(@(CGSizeMake(44.0, 44.0)));
                }];
            } else {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            }
        };
        fullScreenBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)backButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *backBtnDes = [VEInterfaceElementDescriptionImp new];
        backBtnDes.elementID = backButtonIdentifier;
        backBtnDes.type = VEInterfaceElementTypeButton;
        backBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_page_back"] forState:UIControlStateNormal];
        };
        backBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            if (normalScreenBehaivor()) {
                return VEUIEventPageBack;
            } else {
                return VEUIEventScreenRotation;
            }
        };
        backBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        backBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            CGFloat leading = normalScreenBehaivor() ? 12.0 : 48.0;
            CGFloat top = normalScreenBehaivor() ? 10.0 : 16.0;
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(groupContainer).offset(top);
                make.leading.equalTo(groupContainer).offset(leading);
                make.size.equalTo(@(squareSize()));
            }];
        };
        backBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)resolutionButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *resolutionBtnDes = [VEInterfaceElementDescriptionImp new];
        resolutionBtnDes.elementID = resolutionButtonIdentifier;
        resolutionBtnDes.type = VEInterfaceElementTypeButton;
        resolutionBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_resolution"] forState:UIControlStateNormal];
            [button setTitle:LocalizedStringFromBundle(@"resolution_default", @"VEVodApp") forState:UIControlStateNormal];
        };
        resolutionBtnDes.elementAction = ^NSString* (VEActionButton *button) {
            return VEUIEventShowResolutionMenu;
        };
        resolutionBtnDes.elementNotify = ^id (VEActionButton *button,  NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEPlayEventResolutionChanged]) {
                NSString *currentResolutionTitle = [weak_self.eventPoster currentResolutionForDisplay];
                [button setTitle:currentResolutionTitle forState:UIControlStateNormal];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEPlayEventResolutionChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        resolutionBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(groupContainer).offset(-9.0);
                    make.trailing.equalTo(groupContainer.mas_trailing).offset(-50.0);
                    make.height.equalTo(@(50.0));
                }];
            }
        };
        resolutionBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)playSpeedButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *playSpeedBtnDes = [VEInterfaceElementDescriptionImp new];
        playSpeedBtnDes.elementID = playSpeedButtonIdentifier;
        playSpeedBtnDes.type = VEInterfaceElementTypeButton;
        playSpeedBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_speed"] forState:UIControlStateNormal];
            [button setTitle:@"1.0x" forState:UIControlStateNormal];
        };
        playSpeedBtnDes.elementAction = ^NSString* (VEActionButton *button) {
            return VEUIEventShowPlaySpeedMenu;
        };
        playSpeedBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEPlayEventPlaySpeedChanged]) {
                NSString *currentSpeedTitle = [weak_self.eventPoster currentPlaySpeedForDisplay];
                [button setTitle:currentSpeedTitle forState:UIControlStateNormal];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEPlayEventPlaySpeedChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];;
        };
        playSpeedBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *resolutionBtn = [weak_self viewOfElementIdentifier:resolutionButtonIdentifier inGroup:elementGroup];
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(resolutionBtn);
                    make.trailing.equalTo(resolutionBtn.mas_leading).offset(-10.0);
                    make.size.equalTo(@(CGSizeMake(80.0, 50.0)));
                }];
            }
        };
        playSpeedBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)moreButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *moreButtonDes = [VEInterfaceElementDescriptionImp new];
        moreButtonDes.elementID = moreButtonIdentifier;
        moreButtonDes.type = VEInterfaceElementTypeButton;
        moreButtonDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_more"] forState:UIControlStateNormal];
        };
        moreButtonDes.elementAction = ^NSString* (VEActionButton *button) {
            return VEUIEventShowMoreMenu;
        };
        moreButtonDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            
            if ([key isEqualToString:VEUIEventScreenRotation]) {
                //state: rotate back to portrait.
                if (screenIsClear) {
                    button.hidden = YES;
                } else {
                    button.hidden = !button.hidden;
                }
            } else if (normalScreenBehaivor()) {
                button.hidden = YES;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenRotation];
        };
        moreButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            CGFloat trailing = normalScreenBehaivor() ? 14.0 : 54.0;
            CGFloat top = normalScreenBehaivor() ? 10.0 : 16.0;
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(groupContainer).offset(top);
                make.trailing.equalTo(groupContainer).offset(-trailing);
                make.size.equalTo(@(squareSize()));
            }];
        };
        moreButtonDes;
    });
}

- (VEInterfaceElementDescriptionImp *)lockButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *lockButtonDes = [VEInterfaceElementDescriptionImp new];
        lockButtonDes.elementID = lockButtonIdentifier;
        lockButtonDes.type = VEInterfaceElementTypeButton;
        lockButtonDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_unlock"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"long_video_lock"] forState:UIControlStateSelected];
        };
        lockButtonDes.elementAction = ^NSString* (VEActionButton *button) {
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            [weak_self.eventPoster setScreenIsLocking:!screenIsLocking];
            return VEUIEventLockScreen;
        };
        lockButtonDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenRotation]) {
                //state: rotate back to portrait.
                if (screenIsClear) {
                    button.hidden = YES;
                } else {
                    button.hidden = !button.hidden;
                }
            } else if (normalScreenBehaivor()) {
                button.hidden = YES;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.selected = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenRotation];
        };
        lockButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *moreButton = [weak_self viewOfElementIdentifier:moreButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(moreButton).offset(-20);
                make.centerY.equalTo(groupContainer);
                make.size.equalTo(@(squareSize()));
            }];
        };
        lockButtonDes;
    });
}

- (VEInterfaceElementDescriptionImp *)titleLabel {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *titleLabelDes = [VEInterfaceElementDescriptionImp new];
        titleLabelDes.elementID = titleLabelIdentifier;
        titleLabelDes.type = VEInterfaceElementTypeLabel;
        titleLabelDes.elementDisplay = ^(VEDisplayLabel *label) {
            label.text = [weak_self.eventPoster title];
        };
        titleLabelDes.elementNotify = ^id (VEDisplayLabel *label, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            
            if ([key isEqualToString:VEUIEventScreenRotation]) {
                //state: rotate back to portrait.
                if (screenIsClear) {
                    label.hidden = YES;
                } else {
                    label.hidden = !label.hidden;
                }
            } else if (normalScreenBehaivor()) {
                label.hidden = YES;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                label.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                label.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenRotation];;
        };
        titleLabelDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *backBtn = [weak_self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
            UIView *moreBtn = [weak_self viewOfElementIdentifier:moreButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(backBtn.mas_trailing).offset(8.0);
                make.centerY.equalTo(backBtn);
                make.trailing.equalTo(moreBtn.mas_leading).offset(8.0);
                make.height.equalTo(@50.0);
            }];
        };
        titleLabelDes;
    });
}

- (VEInterfaceElementDescriptionImp *)loopPlayButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *loopPlayButtonDes = [VEInterfaceElementDescriptionImp new];
        loopPlayButtonDes.elementID = loopPlayButtonIdentifier;
        loopPlayButtonDes.type = VEInterfaceElementTypeMenuNormalCell;
        loopPlayButtonDes.elementDisplay = ^(VEInterfaceSlideMenuCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"cyclic_mode", @"VEVodApp");
            [cell.leftButton setTitle:LocalizedStringFromBundle(@"loop_mode_on", @"VEVodApp") forState:UIControlStateNormal];
            [cell.rightButton setTitle:LocalizedStringFromBundle(@"loop_mode_off", @"VEVodApp") forState:UIControlStateNormal];
            BOOL loop = [VEDataPersistance boolValueFor:VEDataCacheKeyPlayLoop defaultValue:YES];
            [cell highlightLeftButton:loop];
        };
        loopPlayButtonDes.elementAction = ^NSString* (VEInterfaceSlideMenuCell *cell) {
            return VEPlayEventChangeLoopPlayMode;
        };
        loopPlayButtonDes.elementNotify = ^id(UIButton *btn, NSString *key, NSNumber *value) {
            if (value) {
                [VEDataPersistance setBoolValue:value.boolValue forKey:VEDataCacheKeyPlayLoop];
                [weak_self.eventMessageBus postEvent:VEPlayEventChangeLoopPlayMode withObject:value rightNow:YES];
            }
            return btn;
        };
        loopPlayButtonDes;
    });
}

- (VEInterfaceElementDescriptionImp *)volumeGesture {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *volumeGestureDes = [VEInterfaceElementDescriptionImp new];
        volumeGestureDes.elementID = volumeGestureIdentifier;
        volumeGestureDes.type = VEInterfaceElementTypeMenuPercentageCell;
        volumeGestureDes.elementAction = ^NSString* (id sender) {
            return VEUIEventVolumeIncrease;
        };
        volumeGestureDes.elementDisplay = ^(VEInterfaceSlideMenuPercentageCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"voice", @"VEVodApp");
            cell.iconImgView.image = [UIImage imageNamed:@"vod_videosettting_volume"];
            cell.percentage = [weak_self.eventPoster currentVolume];
        };
        volumeGestureDes.elementNotify = ^id(UIView *view, NSString *key, NSValue *value) {
            if (value) {
                [weak_self.eventMessageBus postEvent:VEUIEventVolumeIncrease withObject:value rightNow:YES];
            }
            return view;
        };
        volumeGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)brightnessGesture {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *brightnessGestureDes = [VEInterfaceElementDescriptionImp new];
        brightnessGestureDes.elementID = brightnessGestureIdentifier;
        brightnessGestureDes.type = VEInterfaceElementTypeMenuPercentageCell;
        brightnessGestureDes.elementAction = ^NSString* (id sender) {
            return VEUIEventBrightnessIncrease;
        };
        brightnessGestureDes.elementDisplay = ^(VEInterfaceSlideMenuPercentageCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"brightness", @"VEVodApp");
            cell.iconImgView.image = [UIImage imageNamed:@"vod_videosettting_brightness"];
            cell.percentage = [weak_self.eventPoster currentBrightness];;
        };
        brightnessGestureDes.elementNotify = ^id(UIView *view, NSString *key, NSValue *value) {
            if (value) {
                [weak_self.eventMessageBus postEvent:VEUIEventBrightnessIncrease withObject:value rightNow:YES];
            }
            return view;
        };
        brightnessGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)brightnessVerticalGesture {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *brightnessGestureDes = [VEInterfaceElementDescriptionImp new];
        brightnessGestureDes.elementID = brightnessGestureIdentifier;
        brightnessGestureDes.type = VEInterfaceElementTypeGestureLeftVerticalPan;
        brightnessGestureDes.elementAction = ^NSString* (id sender) {
            return VEUIEventBrightnessIncrease;
        };
        brightnessGestureDes.elementNotify = ^id(UIView *view, NSString *key, NSNumber *value) {
            if (value) {
                [weak_self.eventMessageBus postEvent:VEUIEventBrightnessIncrease withObject:value rightNow:YES];
            }
            return view;
        };
        brightnessGestureDes;
    });
}


- (VEInterfaceElementDescriptionImp *)volumeVerticalGesture {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *volumeDes = [VEInterfaceElementDescriptionImp new];
        volumeDes.elementID = brightnessGestureIdentifier;
        volumeDes.type = VEInterfaceElementTypeGestureRightVerticalPan;
        volumeDes.elementAction = ^NSString* (id sender) {
            return VEUIEventVolumeIncrease;
        };
        volumeDes.elementNotify = ^id(UIView *view, NSString *key, NSNumber *value) {
            if (value) {
                [weak_self.eventMessageBus postEvent:VEUIEventVolumeIncrease withObject:value rightNow:YES];
            }
            return view;
        };
        volumeDes;
    });
}

- (VEInterfaceElementDescriptionImp *)progressGesture {
    return ({
        VEInterfaceElementDescriptionImp *progressGestureDes = [VEInterfaceElementDescriptionImp new];
        progressGestureDes.elementID = progressGestureIdentifier;
        progressGestureDes.type = VEInterfaceElementTypeGestureHorizontalPan;
        progressGestureDes.elementAction = ^NSString* (id sender) {
            return VEPlayEventProgressValueIncrease;
        };
        progressGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)playGesture {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *playGestureDes = [VEInterfaceElementDescriptionImp new];
        playGestureDes.elementID = playGestureIdentifier;
        playGestureDes.type = VEInterfaceElementTypeGestureDoubleTap;
        playGestureDes.elementAction = ^NSString* (id sender) {
            if ([weak_self.eventPoster screenIsLocking] || [weak_self.eventPoster screenIsClear]) {
                return nil;
            }
            VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
            if (playbackState == VEPlaybackStatePlaying) {
                return VEPlayEventPause;
            } else {
                return VEPlayEventPlay;
            }
        };
        playGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)clearScreenGesture {
    return ({
        VEInterfaceElementDescriptionImp *clearScreenGestureDes = [VEInterfaceElementDescriptionImp new];
        clearScreenGestureDes.elementID = clearScreenGestureIdentifier;
        clearScreenGestureDes.type = VEInterfaceElementTypeGestureSingleTap;
        clearScreenGestureDes.elementAction = ^NSString* (id sender) {
            return VEUIEventClearScreen;
        };
        clearScreenGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)report {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *reportDes = [VEInterfaceElementDescriptionImp new];
        reportDes.elementID = reportIdentifier;
        reportDes.type = VEInterfaceElementTypeButtonCell;
        reportDes.elementAction = ^NSString* (id sender) {
            return VEUIEventScreenRotation;
        };
        reportDes.elementDisplay = ^(__kindof VEInterfaceSlideButtonCell *cell) {
            [cell.button setImage:[UIImage imageNamed:@"vod_video_report"] forState:UIControlStateNormal];
            cell.titleLabel.text = LocalizedStringFromBundle(@"vod_report", @"VEVodApp");
        };
        reportDes.elementNotify = ^id(UIButton *btn, NSString *key, id obj) {
            [ReportComponent report:weak_self.videoModel.videoId cancelHandler:nil completion:nil];
            return nil;
        };
        reportDes;
    });
}

- (VEInterfaceElementDescriptionImp *)maskView {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *maskVewDes = [VEInterfaceElementDescriptionImp new];
        maskVewDes.elementID = maskViewIdentifier;
        maskVewDes.type = VEInterfaceElementTypeMaskView;
        maskVewDes.elementWillLayout = ^(VEMaskView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            elementView.topMask.colors = @[
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.5].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.495].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.475].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.45].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.41].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.37].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.325].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.275].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.225].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.18].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.11].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.05].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.02].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.0].CGColor,
            ];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(groupContainer);
            }];
        };
        maskVewDes.elementNotify = ^id (VEMaskView *elementView, NSString *key, id obj) {
            if ([key isEqual:VEUIEventScreenClearStateChanged]) {
                BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
                elementView.hidden = screenIsClear;
            } else if ([key isEqual:VEUIEventScreenLockStateChanged])  {
                BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
                elementView.topMask.hidden = screenIsLocking;
                elementView.bottomMask.hidden = screenIsLocking;
            } else if ([key isEqual:VEUIEventScreenRotation])  {
                if (normalScreenBehaivor()) {
                    elementView.topHeight = 48.0;
                    elementView.bottomHeight = 50.0;
                } else {
                    elementView.topHeight = 120.0;
                    elementView.bottomHeight = 160.0;
                }
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenRotation];
        };
        maskVewDes;
    });
}

#pragma mark ----- VEInterfaceElementProtocol

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    return @[[self maskView],
             [self playButton],
             [self progressView],
             [self fullScreenButton],
             [self backButton],
             [self resolutionButton],
             [self playSpeedButton],
             [self moreButton],
             [self lockButton],
             [self titleLabel],
             [self volumeGesture],
             [self brightnessGesture],
             [self loopPlayButton],
             [self progressGesture],
             [self playGesture],
             [self clearScreenGesture],
             [self report],
             [self brightnessVerticalGesture],
             [self volumeVerticalGesture]
    ];
}


@end
