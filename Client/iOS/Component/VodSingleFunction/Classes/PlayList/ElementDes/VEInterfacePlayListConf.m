// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfacePlayListConf.h"
#import "NSObject+ToElementDescription.h"
#import "PlayListFloatView.h"
#import "VEActionButton.h"
#import "VEEventConst.h"
#import "VEInterface.h"
#import "VEInterfaceBaseVideoDetailSceneConf.h"
#import "VEInterfaceElementDescriptionImp.h"
#import "VEMultiStatePlayButton.h"
#import <ToolKit/ToolKit.h>

#import "Masonry.h"

static NSString *playListButtonIdentify = @"playListButtonIdentify";
static NSString *previousButtonIdentify = @"previousButtonIdentify";
static NSString *nextButtonIdentify = @"nextButtonIdentify";
NSString *const VEUIEventShowPlayListMenu = @"VEUIEventShowPlayListMenu";
NSString *const VEUIEventPlayPreviousVideo = @"VEUIEventPlayPreviousVideo";
NSString *const VEUIEventPlayNextVideo = @"VEUIEventPlayNextVideo";

@interface VEInterfacePlayListConf ()
@property (nonatomic, weak) VEActionButton *button;
@property (nonatomic, weak) VEActionButton *preButton;
@property (nonatomic, weak) VEActionButton *nextButton;

@end

@implementation VEInterfacePlayListConf

- (VEInterfaceElementDescriptionImp *)playListButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *playButtonDes = [VEInterfaceElementDescriptionImp new];
        playButtonDes.elementID = playListButtonIdentify;
        playButtonDes.type = VEInterfaceElementTypeButton;
        playButtonDes.elementDisplay = ^(__kindof UIView *button) {
            weak_self.button = button;
            [button setImage:[UIImage imageNamed:@"playlist" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%ld", weak_self.manager.playList.count] forState:UIControlStateNormal];
        };
        playButtonDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventShowPlayListMenu;
        };
        playButtonDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            BOOL screenIsLocking = [weak_self.eventPoster screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        playButtonDes.elementWillLayout = ^(__kindof UIView *elementView, NSSet<UIView *> *elementGroup, __kindof UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(groupContainer).offset(-9.0);
                    make.trailing.equalTo(groupContainer.mas_trailing).offset(-44.0);
                    make.height.mas_equalTo(50.0);
                }];
            }
        };
        playButtonDes;
    });
}

- (VEInterfaceElementDescriptionImp *)resolutionButton {
    VEInterfaceElementDescriptionImp *resolutionBtnDes = [super resolutionButton];
    __weak typeof(self) weak_self = self;
    return ({
        resolutionBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *playListBtn = [weak_self viewOfElementIdentifier:playListButtonIdentify inGroup:elementGroup];
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(playListBtn);
                    make.trailing.equalTo(playListBtn.mas_leading).offset(-32.0);
                    make.height.equalTo(@(50.0));
                }];
            }
        };
        resolutionBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)previousVideoButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *preBtnDes = [VEInterfaceElementDescriptionImp new];
        preBtnDes.elementID = previousButtonIdentify;
        preBtnDes.type = VEInterfaceElementTypeButton;
        preBtnDes.elementDisplay = ^(__kindof UIView *button) {
            weak_self.preButton = button;
            [button setImage:[UIImage imageNamed:@"previous_video" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        preBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventPlayPreviousVideo;
        };
        preBtnDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            button.hidden = [weak_self preButtonHidden];
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        preBtnDes.elementWillLayout = ^(__kindof UIView *elementView, NSSet<UIView *> *elementGroup, __kindof UIView *groupContainer) {
            if (weak_self.manager.currentPlayViewIndex == 0) {
                elementView.hidden = YES;
            }
            UIView *playBtn = [weak_self viewOfElementIdentifier:VEInterPlayButtonIdentifier inGroup:elementGroup];
            [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(playBtn);
                make.trailing.mas_equalTo(playBtn.mas_leading).offset(-48);
                make.height.mas_equalTo(64);
            }];
        };
        preBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)nextVideoButton {
    __weak typeof(self) weak_self = self;
    return ({
        VEInterfaceElementDescriptionImp *nextBtnDes = [VEInterfaceElementDescriptionImp new];
        nextBtnDes.elementID = previousButtonIdentify;
        nextBtnDes.type = VEInterfaceElementTypeButton;
        nextBtnDes.elementDisplay = ^(__kindof UIView *button) {
            weak_self.nextButton = button;
            [button setImage:[UIImage imageNamed:@"next_video" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        nextBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventPlayNextVideo;
        };
        nextBtnDes.elementNotify = ^id(VEActionButton *button, NSString *key, id obj) {
            button.hidden = [weak_self nextButtonHidden];
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        nextBtnDes.elementWillLayout = ^(__kindof UIView *elementView, NSSet<UIView *> *elementGroup, __kindof UIView *groupContainer) {
            UIView *playBtn = [weak_self viewOfElementIdentifier:VEInterPlayButtonIdentifier inGroup:elementGroup];
            [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(playBtn);
                make.leading.mas_equalTo(playBtn.mas_trailing).offset(48);
                make.height.mas_equalTo(64);
            }];
        };
        nextBtnDes;
    });
}

- (void)updatePlayButtonState:(VEMultiStatePlayButton *)button {
    VEPlaybackState playbackState = [self.eventPoster currentPlaybackState];
    BOOL screenIsClear = [self.eventPoster screenIsClear];
    BOOL screenIsLocking = [self.eventPoster screenIsLocking];
    if (playbackState == VEPlaybackStateFinished) {
//        button.playState = VEMultiStatePlayStateReplay;
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

- (BOOL)preButtonHidden {
    BOOL screenIsClear = [self.eventPoster screenIsClear];
    BOOL screenIsLocking = [self.eventPoster screenIsLocking];
    if (self.manager.currentPlayViewIndex == 0) {
        return YES;
    } else {
        return screenIsLocking || screenIsClear;
    }
}

- (BOOL)nextButtonHidden {
    BOOL screenIsClear = [self.eventPoster screenIsClear];
    BOOL screenIsLocking = [self.eventPoster screenIsLocking];
    if (self.manager.currentPlayViewIndex == self.manager.playList.count - 1) {
        return YES;
    } else {
        return screenIsLocking || screenIsClear;
    }
}

- (void)refresh {
    self.preButton.hidden = [self preButtonHidden];
    self.nextButton.hidden = [self nextButtonHidden];
}

#pragma mark - Setter
- (void)setManager:(PlayListManager *)manager {
    _manager = manager;
    _manager.eventPoster = self.eventPoster;
    manager.eventMessageBus = self.eventMessageBus;
}

#pragma mark - VEInterfaceElementProtocol

- (NSArray *)extraElements {
    return @[[self playListButton],
             [self previousVideoButton],
             [self nextVideoButton]];
}

@end
