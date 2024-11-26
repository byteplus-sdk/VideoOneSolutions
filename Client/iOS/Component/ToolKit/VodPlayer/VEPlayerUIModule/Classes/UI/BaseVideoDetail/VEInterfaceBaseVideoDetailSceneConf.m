//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceBaseVideoDetailSceneConf.h"
#import "Masonry.h"
#import "VEActionButton.h"
#import "VEDataPersistance.h"
#import "VEDisplayLabel.h"
#import "VEEventMessageBus.h"
#import "VEEventPoster+Private.h"
#import "VEInterfaceElementDescriptionImp.h"
#import "VEInterfaceProgressElement.h"
#import "VEInterfaceSlideButtonCell.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceSlideMenuPercentageCell.h"
#import "VEInterfaceSocialStackView.h"
#import "VEMaskView.h"
#import "VEMultiStatePlayButton.h"
#import "VEPlayerUIModule.h"
#import "VEProgressView.h"
#import "VEVerticalProgressSlider.h"
#import "BaseVideoModel.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/ReportComponent.h>

NSString *const VEBackButtonIdentifier = @"backButtonIdentifier";

NSString *const VEResolutionButtonIdentifier = @"resolutionButtonIdentifier";

NSString *const VEPlaySpeedButtonIdentifier = @"playSpeedButtonIdentifier";

NSString *const VEMoreButtonIdentifier = @"moreButtonIdentifier";

NSString *const VELockButtonIdentifier = @"lockButtonIdentifier";

NSString *const VETitleLabelIdentifier = @"titleLabelIdentifier";

NSString *const VELoopPlayButtonIdentifier = @"loopPlayButtonIdentifier";

NSString *const VEVolumeGestureIdentifier = @"volumeGestureIdentifier";

NSString *const VEBrightnessGestureIdentifier = @"brightnessGestureIdentifier";

NSString *const VEPlayGestureIdentifier = @"playGestureIdentifier";

NSString *const VEMenuButtonCellIdentifier = @"menuButtonCellIdentifier";

NSString *const VEMaskViewIdentifier = @"maskViewIdentifier";

NSString *const VESocialStackViewIdentifier = @"socialStackViewIdentifier";

NSString *const VELeftBrightnessSliderIdentifier = @"leftBrightnessSliderIdentifier";

NSString *const VERightVolumeSliderIdentifier = @"rightVolumeSliderIdentifier";

NSString *const VEPIPButtonIdentifier = @"pipButtonIdentifier";

@interface VEInterfaceBaseVideoDetailSceneConf ()

@property (nonatomic, strong) VEInterfaceSocialStackView *socialView;

@property (nonatomic, strong) VEVerticalProgressSlider *leftBrightnessSlider;

@property (nonatomic, strong) VEVerticalProgressSlider *rightVolumeSlider;

@end

@implementation VEInterfaceBaseVideoDetailSceneConf

@synthesize deactive;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventMessageBus = [[VEEventMessageBus alloc] init];
        self.eventPoster = [[VEEventPoster alloc] initWithEventMessageBus:self.eventMessageBus];
    }
    return self;
}

- (void)setVideoModel:(BaseVideoModel *)videoModel {
    _videoModel = videoModel;
    _socialView.videoModel = videoModel;
}

#pragma mark----- Tool

static inline CGSize squareSize(void) {
    if (normalScreenBehaivor()) {
        return CGSizeMake(24.0, 24.0);
    } else {
        return CGSizeMake(36.0, 36.0);
    }
}

#pragma mark----- Element Statement
- (VEInterfaceElementDescriptionImp *)progressView {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *progressViewDes = [super progressView];
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            VEProgressView *progressView = (VEProgressView *)elementView;
            if (normalScreenBehaivor()) {
                UIView *fullscreenBtn = [weak_self viewOfElementIdentifier:VEInterFullScreenButtonIdentifier inGroup:elementGroup];
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(groupContainer).offset(12.0);
                    make.centerY.equalTo(fullscreenBtn);
                    make.trailing.equalTo(fullscreenBtn.mas_leading).offset(-16.0);
                    make.height.equalTo(@48.0);
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
            [groupContainer addSubview:weak_self.leftBrightnessSlider];
            [weak_self.leftBrightnessSlider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(groupContainer);
                make.leading.equalTo(groupContainer).offset(51);
                make.size.equalTo(@(CGSizeMake(5, 160)));
            }];
            [groupContainer addSubview:weak_self.rightVolumeSlider];
            [weak_self.rightVolumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(groupContainer);
                make.trailing.equalTo(groupContainer).offset(-51);
                make.size.equalTo(@(CGSizeMake(5, 160)));
            }];
        };
        progressViewDes;
    });
}

- (VEVerticalProgressSlider *)leftBrightnessSlider {
    if (!_leftBrightnessSlider) {
        _leftBrightnessSlider = [VEVerticalProgressSlider new];
        _leftBrightnessSlider.hidden = YES;
        _leftBrightnessSlider.userInteractionEnabled = NO;
    }
    return _leftBrightnessSlider;
}

- (VEVerticalProgressSlider *)rightVolumeSlider {
    if (!_rightVolumeSlider) {
        _rightVolumeSlider = [VEVerticalProgressSlider new];
        _rightVolumeSlider.hidden = YES;
        _rightVolumeSlider.userInteractionEnabled = NO;
    }
    return _rightVolumeSlider;
}

- (VEInterfaceElementDescriptionImp *)backButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *backBtnDes = [VEInterfaceElementDescriptionImp new];
        backBtnDes.elementID = VEBackButtonIdentifier;
        backBtnDes.type = VEInterfaceElementTypeButton;
        backBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_page_back" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        backBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventPageBack;
        };
        backBtnDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
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
        resolutionBtnDes.elementID = VEResolutionButtonIdentifier;
        resolutionBtnDes.type = VEInterfaceElementTypeButton;
        resolutionBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_resolution" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setTitle:LocalizedStringFromBundle(@"resolution_default", @"VodPlayer") forState:UIControlStateNormal];
            NSString *currentResolutionTitle = [weak_self.eventPoster currentResolutionForDisplay];
            if (currentResolutionTitle && [currentResolutionTitle length] > 0) {
                [button setTitle:currentResolutionTitle forState:UIControlStateNormal];
            }
        };
        resolutionBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventShowResolutionMenu;
        };
        resolutionBtnDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
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
        playSpeedBtnDes.elementID = VEPlaySpeedButtonIdentifier;
        playSpeedBtnDes.type = VEInterfaceElementTypeButton;
        playSpeedBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_speed" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setTitle:@"1.0x" forState:UIControlStateNormal];
            NSString *currentSpeedTitle = [weak_self.eventPoster currentPlaySpeedForDisplay];
            if (currentSpeedTitle && [currentSpeedTitle length] > 0) {
                [button setTitle:currentSpeedTitle forState:UIControlStateNormal];
            }
        };
        playSpeedBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventShowPlaySpeedMenu;
        };
        playSpeedBtnDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
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
            return @[VEPlayEventPlaySpeedChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
            ;
        };
        playSpeedBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *resolutionBtn = [weak_self viewOfElementIdentifier:VEResolutionButtonIdentifier inGroup:elementGroup];
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
        moreButtonDes.elementID = VEMoreButtonIdentifier;
        moreButtonDes.type = VEInterfaceElementTypeButton;
        moreButtonDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_more" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        moreButtonDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventShowMoreMenu;
        };
        moreButtonDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];

            if ([key isEqualToString:VEUIEventScreenOrientationChanged]) {
                // state: rotate back to portrait.
                if (screenIsClear) {
                    button.hidden = YES;
                } else {
                    button.hidden = normalScreenBehaivor();
                }
            } else if (normalScreenBehaivor()) {
                button.hidden = YES;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenOrientationChanged];
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
        lockButtonDes.elementID = VELockButtonIdentifier;
        lockButtonDes.type = VEInterfaceElementTypeButton;
        lockButtonDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_unlock" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"long_video_lock" bundleName:@"VodPlayer"] forState:UIControlStateSelected];
        };
        lockButtonDes.elementAction = ^NSDictionary *(VEActionButton *button) {
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            return @{VEUIEventLockScreen: @(!screenIsLocking)};
        };
        lockButtonDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenOrientationChanged]) {
                // state: rotate back to portrait.
                if (screenIsClear) {
                    button.hidden = YES;
                } else {
                    button.hidden = normalScreenBehaivor();
                }
            } else if (normalScreenBehaivor()) {
                button.hidden = YES;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.selected = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenOrientationChanged];
        };
        lockButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *moreButton = [weak_self viewOfElementIdentifier:VEMoreButtonIdentifier inGroup:elementGroup];
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
        titleLabelDes.elementID = VETitleLabelIdentifier;
        titleLabelDes.type = VEInterfaceElementTypeLabel;
        titleLabelDes.elementDisplay = ^(VEDisplayLabel *label) {
            label.text = [weak_self.eventPoster title];
        };
        titleLabelDes.elementNotify = ^id(VEDisplayLabel *label, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];

            if ([key isEqualToString:VEUIEventScreenOrientationChanged]) {
                // state: rotate back to portrait.
                if (screenIsClear) {
                    label.hidden = YES;
                } else {
                    label.hidden = normalScreenBehaivor();
                }
            } else if (normalScreenBehaivor()) {
                label.hidden = YES;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                label.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                label.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenOrientationChanged];
        };
        titleLabelDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *backBtn = [weak_self viewOfElementIdentifier:VEBackButtonIdentifier inGroup:elementGroup];
            UIView *moreBtn = [weak_self viewOfElementIdentifier:VEMoreButtonIdentifier inGroup:elementGroup];
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
        loopPlayButtonDes.elementID = VELoopPlayButtonIdentifier;
        loopPlayButtonDes.type = VEInterfaceElementTypeMenuNormalCell;
        loopPlayButtonDes.elementDisplay = ^(VEInterfaceSlideMenuCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"cyclic_mode", @"VodPlayer");
            [cell.leftButton setTitle:LocalizedStringFromBundle(@"loop_mode_on", @"VodPlayer") forState:UIControlStateNormal];
            [cell.rightButton setTitle:LocalizedStringFromBundle(@"loop_mode_off", @"VodPlayer") forState:UIControlStateNormal];
            [cell highlightLeftButton:weak_self.eventPoster.loopPlayOpen];
        };
        loopPlayButtonDes.elementAction = ^NSString *(VEInterfaceSlideMenuCell *cell) {
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
        volumeGestureDes.elementID = VEVolumeGestureIdentifier;
        volumeGestureDes.type = VEInterfaceElementTypeMenuPercentageCell;
        volumeGestureDes.elementAction = ^NSString *(id sender) {
            return VEUIEventVolumeIncrease;
        };
        volumeGestureDes.elementDisplay = ^(VEInterfaceSlideMenuPercentageCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"voice", @"VodPlayer");
            cell.iconImgView.image = [UIImage imageNamed:@"vod_videosettting_volume" bundleName:@"VodPlayer"];
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
        brightnessGestureDes.elementID = VEBrightnessGestureIdentifier;
        brightnessGestureDes.type = VEInterfaceElementTypeMenuPercentageCell;
        brightnessGestureDes.elementAction = ^NSString *(id sender) {
            return VEUIEventBrightnessIncrease;
        };
        brightnessGestureDes.elementDisplay = ^(VEInterfaceSlideMenuPercentageCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"brightness", @"VodPlayer");
            cell.iconImgView.image = [UIImage imageNamed:@"vod_videosettting_brightness" bundleName:@"VodPlayer"];
            cell.percentage = [weak_self.eventPoster currentBrightness];
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
        brightnessGestureDes.elementID = VEBrightnessGestureIdentifier;
        brightnessGestureDes.type = VEInterfaceElementTypeGestureLeftVerticalPan;
        brightnessGestureDes.elementAction = ^NSString *(id sender) {
            return VEUIEventBrightnessIncrease;
        };
        brightnessGestureDes.elementNotify = ^id(UIView *view, NSString *key, NSDictionary *param) {
            if (normalScreenBehaivor()) {
                return view;
            }
            NSNumber *began = [param objectForKey:@"touchBegan"];
            if (began.boolValue) {
                weak_self.leftBrightnessSlider.hidden = NO;
                return view;
            }
            NSNumber *value = param[@"changeValue"];
            if (value) {
                [weak_self.eventMessageBus postEvent:VEUIEventBrightnessIncrease withObject:value rightNow:YES];
                weak_self.leftBrightnessSlider.progress = [weak_self.eventPoster currentBrightness];
            }
            NSNumber *end = [param objectForKey:@"touchEnd"];
            if (end.boolValue) {
                weak_self.leftBrightnessSlider.hidden = YES;
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
        volumeDes.elementID = VEVolumeGestureIdentifier;
        volumeDes.type = VEInterfaceElementTypeGestureRightVerticalPan;
        volumeDes.elementAction = ^NSString *(id sender) {
            return VEUIEventVolumeIncrease;
        };
        volumeDes.elementNotify = ^id(UIView *view, NSString *key, NSDictionary *param) {
            if (normalScreenBehaivor()) {
                return view;
            }
            NSNumber *began = [param objectForKey:@"touchBegan"];
            if (began.boolValue) {
                weak_self.rightVolumeSlider.hidden = NO;
                return view;
            }
            NSNumber *value = param[@"changeValue"];
            if (value) {
                [weak_self.eventMessageBus postEvent:VEUIEventVolumeIncrease withObject:value rightNow:YES];
                weak_self.rightVolumeSlider.progress = [weak_self.eventPoster currentVolume];
            }
            NSNumber *end = [param objectForKey:@"touchEnd"];
            if (end.boolValue) {
                weak_self.rightVolumeSlider.hidden = YES;
            }
            return view;
        };
        volumeDes;
    });
}

- (VEInterfaceElementDescriptionImp *)playGesture {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *playGestureDes = [VEInterfaceElementDescriptionImp new];
        playGestureDes.elementID = VEPlayGestureIdentifier;
        playGestureDes.type = VEInterfaceElementTypeGestureDoubleTap;
        playGestureDes.elementAction = ^NSString *(id sender) {
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

- (VEInterfaceElementDescriptionImp *)menuButtonCell {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *reportDes = [VEInterfaceElementDescriptionImp new];
        reportDes.elementID = VEMenuButtonCellIdentifier;
        reportDes.type = VEInterfaceElementTypeMenuButtonCell;
        reportDes.elementDisplay = ^(__kindof VEInterfaceSlideButtonCell *cell) {
            NSMutableArray *buttons = [NSMutableArray array];
            if (!weak_self.skipPIPMode) {
                // PIP
                VEInterfaceSlideButton *pipButton = [[VEInterfaceSlideButton alloc] init];
                pipButton.elementID = @"pip";
                [pipButton bingImage:[UIImage imageNamed:@"vod_pip_icon" bundleName:@"VodPlayer"] status:ButtonStatusNone];
                [pipButton bingImage:[UIImage imageNamed:@"vod_pip_icon_s" bundleName:@"VodPlayer"] status:ButtonStatusActive];
                [pipButton setTitle:LocalizedStringFromBundle(@"vod_pip", @"VodPlayer") forState:UIControlStateNormal];
                pipButton.status = [weak_self.eventPoster pipStatus] == PIPManagerStatusStartSuccess ? ButtonStatusActive : ButtonStatusNone;
                [buttons addObject:pipButton];
            }
            VEInterfaceSlideButton *reportButton = [[VEInterfaceSlideButton alloc] init];
            reportButton.elementID = @"report";
            [reportButton bingImage:[UIImage imageNamed:@"vod_video_report" bundleName:@"VodPlayer"] status:ButtonStatusNone];
            [reportButton setTitle:LocalizedStringFromBundle(@"vod_report", @"VodPlayer") forState:UIControlStateNormal];
            [buttons addObject:reportButton];

            cell.buttons = buttons;
        };
        reportDes.elementNotify = ^id(__kindof VEInterfaceSlideButton *button, NSString *key, id obj) {
            if ([key isEqualToString:@"report"]) {
                [ReportComponent report:weak_self.videoModel.videoId cancelHandler:nil completion:nil];
            } else if ([key isEqualToString:@"pip"]) {
                if (button.status == ButtonStatusActive) {
                    [weak_self.eventPoster disablePIP];
                    button.status = ButtonStatusNone;
                } else {
                    __weak typeof(button) weak_button = button;
                    [weak_self.eventPoster enablePIP:^(PIPManagerStatus status) {
                        if (status == PIPManagerStatusStartSuccess) {
                            weak_button.status = ButtonStatusActive;
                        }
                    }];
                }
            }
            return nil;
        };
        reportDes.elementAction = ^NSString *(id sender) {
            return nil;
        };
        reportDes;
    });
}

- (VEInterfaceElementDescriptionImp *)maskView {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *maskVewDes = [VEInterfaceElementDescriptionImp new];
        maskVewDes.elementID = VEMaskViewIdentifier;
        maskVewDes.type = VEInterfaceElementTypeMaskView;
        maskVewDes.elementWillLayout = ^(VEMaskView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.topHeight = 48.0;
                elementView.bottomHeight = 50.0;
            } else {
                elementView.topHeight = 120.0;
                elementView.bottomHeight = 160.0;
            }
            elementView.topMask.colors = @[
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.495].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.475].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.45].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.41].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.37].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.325].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.275].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.225].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.18].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.11].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.02].CGColor,
                (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0].CGColor,
            ];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(groupContainer);
            }];
        };
        maskVewDes.elementNotify = ^id(VEMaskView *elementView, NSString *key, id obj) {
            if ([key isEqual:VEUIEventScreenClearStateChanged]) {
                BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
                BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
                elementView.topMask.hidden = screenIsLocking ?: screenIsClear;
                elementView.fullMask.hidden = screenIsClear;
                elementView.bottomMask.hidden = screenIsClear;
            } else if ([key isEqual:VEUIEventScreenLockStateChanged]) {
                BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
                elementView.topMask.hidden = screenIsLocking;
            } else if ([key isEqual:VEUIEventScreenOrientationChanged]) {
                if (normalScreenBehaivor()) {
                    elementView.topHeight = 48.0;
                    elementView.bottomHeight = 50.0;
                } else {
                    elementView.topHeight = 120.0;
                    elementView.bottomHeight = 160.0;
                }
            } else if ([key isEqualToString:VEUIEventSeeking]) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
                    BOOL isSeeking = [obj boolValue];
                    elementView.bottomMask.hidden = isSeeking ? NO : screenIsClear;
                };
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenOrientationChanged, VEUIEventSeeking];
        };
        maskVewDes;
    });
}

- (VEInterfaceElementDescriptionImp *)socialStackView {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *viewDes = [VEInterfaceElementDescriptionImp new];
        viewDes.elementID = VESocialStackViewIdentifier;
        viewDes.type = VEInterfaceElementTypeCustomView;
        viewDes.customView = weak_self.socialView;
        viewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            elementView.hidden = normalScreenBehaivor();
            [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.offset(52);
                make.bottom.offset(-16);
            }];
        };
        viewDes.elementNotify = ^id(UIView *elementView, NSString *key, id obj) {
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenOrientationChanged];
        };
        viewDes;
    });
}

- (VEInterfaceSocialStackView *)socialView {
    if (!_socialView) {
        _socialView = [VEInterfaceSocialStackView new];
        _socialView.axis = UILayoutConstraintAxisHorizontal;
        _socialView.videoModel = self.videoModel;
        _socialView.eventMessageBus = self.eventMessageBus;
        _socialView.eventPoster = self.eventPoster;
    }
    return _socialView;
}

- (VEInterfaceElementDescriptionImp *)pipButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *pipButtonDes = [VEInterfaceElementDescriptionImp new];
        pipButtonDes.elementID = VEPIPButtonIdentifier;
        pipButtonDes.type = VEInterfaceElementTypeButton;
        void (^changeButtonState)(VEActionButton *button) = ^(VEActionButton *button) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            BOOL forceHidden = !normalScreenBehaivor() || screenIsClear || screenIsLocking;
            if (![weak_self.eventPoster isEnabledPIP]) {
                button.hidden = forceHidden;
                button.selected = NO;
            } else if ([weak_self.eventPoster pipStatus] == PIPManagerStatusNone) {
                button.hidden = YES;
                button.selected = NO;
            } else if ([weak_self.eventPoster pipStatus] == PIPManagerStatusStartSuccess) {
                button.hidden = forceHidden;
                button.selected = YES;
            } else if ([weak_self.eventPoster pipStatus] == PIPManagerStatusParameterFailed) {
                button.selected = NO;
            } else {
                button.hidden = forceHidden;
                button.selected = NO;
            }
        };
        pipButtonDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"vod_pip_icon" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"vod_pip_icon_s" bundleName:@"VodPlayer"] forState:UIControlStateSelected];
            button.hidden = YES;
            changeButtonState(button);
        };
        pipButtonDes.elementAction = ^NSString *(VEActionButton *button) {
            if (button.isSelected) {
                [weak_self.eventPoster disablePIP];
            } else {
                [weak_self.eventPoster enablePIP:nil];
            }
            return nil;
        };
        pipButtonDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            if (key) {
                changeButtonState(button);
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged, VEUIEventScreenOrientationChanged, VEPlayEventPiPStatusChanged];
        };
        pipButtonDes.elementWillLayout = ^(VEActionButton *button, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(24, 24));
                make.top.equalTo(@10);
                make.right.equalTo(@-12);
            }];
        };
        pipButtonDes;
    });
}

#pragma mark----- VEInterfaceElementProtocol

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    if (!_customizedElements) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:@[
            [self maskView],
            [self playButton],
            [self progressView],
            [self fullScreenButton],
            [self backButton],
            [self socialStackView],
            [self resolutionButton],
            [self playSpeedButton],
            [self moreButton],
            [self lockButton],
            [self titleLabel],
            [self volumeGesture],
            [self brightnessGesture],
            [self playGesture],
            [self clearScreenGesture],
            [self brightnessVerticalGesture],
            [self volumeVerticalGesture],
            [VEInterfaceProgressElement progressGesture],
            [self autoHideControllerGesture],
        ]];
        if (!self.skipPIPMode) {
            [array addObject:[self pipButton]];
        }
        if (!self.skipPlayMode) {
            [array addObject:[self loopPlayButton]];
        }
        [array addObject:[self menuButtonCell]];
        NSArray *extra = [self extraElements];
        if (extra) {
            [array addObjectsFromArray:extra];
        }
        _customizedElements = array.copy;
    }
    return _customizedElements;
}

- (NSArray *)extraElements {
    return nil;
}

#pragma mark - Getter
- (BOOL)skipPIPMode {
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 14.0) {
        return _skipPIPMode;
    } else {
        return YES;
    }
}

@end
