//
//  MiniDramaLancapeSceneConf.m
//  MiniDrama
//
//  Created by ByteDance on 2024/11/29.
//

#import "MiniDramaLandscapeSceneConf.h"
#import "MDPlayerUIModule.h"
#import <Masonry/Masonry.h>
#import "MDActionButton.h"
#import "MDProgressView.h"
#import "MDDisplayLabel.h"
#import "MDInterfaceSlideMenuCell.h"
#import "MDInterfaceElementDescriptionImp.h"
#import "MiniDramaSocialView.h"
#import "MDEventMessageBus.h"
#import "MDInterfaceSlideButtonCell.h"
#import "MDInterfaceSlideMenuPercentageCell.h"
#import "VEVerticalProgressSlider.h"
#import "MDInterfaceProgressElement.h"
#import <ToolKit/ReportComponent.h>
#import <ToolKit/ToolKit.h>

static NSString *playButtonIdentifier = @"playButtonIdentifier";

static NSString *progressViewIdentifier = @"progressViewIdentifier";

static NSString *fullScreenButtonIdentifier = @"fullScreenButtonIdentifier";

static NSString *backButtonIdentifier = @"backButtonIdentifier";

static NSString *resolutionButtonIdentifier = @"resolutionButtonIdentifier";

static NSString *playSpeedButtonIdentifier = @"playSpeedButtonIdentifier";

static NSString *episodeSelectionButtonIdentifier = @"episodeSelectionButtonIdentifier";

static NSString *const socialStackViewIdentifier = @"socialStackViewIdentifier";

static NSString *moreButtonIdentifier = @"moreButtonIdentifier";

static NSString *lockButtonIdentifier = @"lockButtonIdentifier";

static NSString *titleLabelIdentifier = @"titleLabelIdentifier";

static NSString *pipButtonIdentifier = @"pipButtonIdentifier";

static NSString *loopPlayButtonIdentifier = @"loopPlayButtonIdentifier";

static NSString *volumeGestureIdentifier = @"volumeGestureIdentifier";

static NSString *brightnessGestureIdentifier = @"brightnessGestureIdentifier";

static NSString *progressGestureIdentifier = @"progressGestureIdentifier";

static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";

static NSString *playGestureIdentifier = @"playGestureIdentifier";

static NSString *smartSubtitleButtonIdentify = @"smartSubtitleButtonIdentify";

static NSString *const MDMenuButtonCellIdentifier = @"menuButtonCellIdentifier";


@interface MiniDramaLandscapeSceneConf ()

@property (nonatomic, strong) MiniDramaSocialView *socialView;

@property (nonatomic, strong) MDActionButton *subtitlteButton;

@property (nonatomic, strong) VEVerticalProgressSlider *leftBrightnessSlider;

@property (nonatomic, strong) VEVerticalProgressSlider *rightVolumeSlider;

@property (nonatomic, weak) MDActionButton *playButtonView;

@end

@implementation MiniDramaLandscapeSceneConf


#pragma mark ----- Tool

static inline BOOL normalScreenBehaivor () {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
}

static inline CGSize squareSize () {
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

- (void)setVideoCount:(NSInteger)videoCount {
    _videoCount = videoCount;
}

#pragma mark ----- Element Statement

- (MDInterfaceElementDescriptionImp *)playButton {
    __weak __typeof(self)weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *playBtnDes = [MDInterfaceElementDescriptionImp new];
        playBtnDes.elementID = playButtonIdentifier;
        playBtnDes.type = MDInterfaceElementTypeButton;
        playBtnDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_pause" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"video_play" bundleName:@"VodPlayer"] forState:UIControlStateSelected];
            weak_self.playButtonView = button;
        };
        playBtnDes.elementAction = ^NSString *(MDActionButton *button) {
            MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
            if (playbackState == MDPlaybackStatePlaying) {
                return MDPlayEventPause;
            } else {
                return MDPlayEventPlay;
            }
        };
        playBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDPlayEventStateChanged]) {
                MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
                button.selected = playbackState != MDPlaybackStatePlaying;
            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDPlayEventStateChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
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

- (MDInterfaceElementDescriptionImp *)progressView {
    __weak typeof(self) weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *progressViewDes = [MDInterfaceElementDescriptionImp new];
        progressViewDes.elementID = progressViewIdentifier;
        progressViewDes.type = MDInterfaceElementTypeProgressView;
        progressViewDes.elementAction = ^NSDictionary* (MDProgressView *progressView) {
            return @{MDPlayEventSeek : @(progressView.currentValue)};
        };
        progressViewDes.elementNotify = ^id (MDProgressView *progressView, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDPlayEventTimeIntervalChanged]) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                    progressView.totalValue = [[MDEventPoster currentPoster] duration];
                    progressView.currentValue = interval;
                    progressView.bufferValue = [[MDEventPoster currentPoster] playableDuration];
                };
            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                progressView.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                progressView.hidden = screenIsLocking;
            }
            return @[MDPlayEventTimeIntervalChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
        };
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            MDProgressView *progressView = (MDProgressView *)elementView;
            if (normalScreenBehaivor()) {
                UIView *fullscreenBtn = [self viewOfElementIdentifier:fullScreenButtonIdentifier inGroup:elementGroup];
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

- (MDInterfaceElementDescriptionImp *)fullScreenButton {
    return ({
        MDInterfaceElementDescriptionImp *fullScreenBtnDes = [MDInterfaceElementDescriptionImp new];
        fullScreenBtnDes.elementID = fullScreenButtonIdentifier;
        fullScreenBtnDes.type = MDInterfaceElementTypeButton;
        fullScreenBtnDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_portrait" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        fullScreenBtnDes.elementAction = ^NSString *(MDActionButton *button) {
            return MDUIEventScreenRotation;
        };
        fullScreenBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
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

- (MDInterfaceElementDescriptionImp *)backButton {
    return ({
        MDInterfaceElementDescriptionImp *backBtnDes = [MDInterfaceElementDescriptionImp new];
        backBtnDes.elementID = backButtonIdentifier;
        backBtnDes.type = MDInterfaceElementTypeButton;
        backBtnDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_page_back" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        backBtnDes.elementAction = ^NSString *(MDActionButton *button) {
            return MDUIEventPageBack;
        };
        backBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
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

- (MDInterfaceElementDescriptionImp *)episodesButton {
    __weak __typeof(self)weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *episodesButton = [MDInterfaceElementDescriptionImp new];
        episodesButton.elementID = episodeSelectionButtonIdentifier;
        episodesButton.type = MDInterfaceElementTypeButton;
        episodesButton.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"episodes_button" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%ld", weak_self.videoCount] forState:UIControlStateNormal];
            button.tag = 10001;
        };
        episodesButton.elementAction = ^id(id) {
            return MDUIEventShowEpisodesView;
        };
        episodesButton.elementNotify = ^id(MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDPlayEventEpisodesChanged]) {
                NSLog(@"MDPlayEventEpisodesChanged");
            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDPlayEventEpisodesChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
        };
        episodesButton.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(groupContainer).offset(-9.0);
                    make.trailing.equalTo(groupContainer.mas_trailing).offset(-50.0);
                    make.size.equalTo(@(CGSizeMake(80.0, 50.0)));
                }];
            }
        };
        episodesButton;
    });
}

- (MDInterfaceElementDescriptionImp *)resolutionButton {
    __weak __typeof(self) weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *resolutionBtnDes = [MDInterfaceElementDescriptionImp new];
        resolutionBtnDes.elementID = resolutionButtonIdentifier;
        resolutionBtnDes.type = MDInterfaceElementTypeButton;
        resolutionBtnDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_resolution" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setTitle:LocalizedStringFromBundle(@"resolution_default", @"VodPlayer") forState:UIControlStateNormal];
        };
        resolutionBtnDes.elementAction = ^NSString* (MDActionButton *button) {
            return MDUIEventShowResolutionMenu;
        };
        resolutionBtnDes.elementNotify = ^id (MDActionButton *button,  NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDPlayEventResolutionChanged]) {
                NSString *currentResolutionTitle = [[MDEventPoster currentPoster] currentResolutionForDisplay];
                [button setTitle:currentResolutionTitle forState:UIControlStateNormal];
            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDPlayEventResolutionChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
        };
        resolutionBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *episodeButton = [self viewOfElementIdentifier:episodeSelectionButtonIdentifier inGroup:elementGroup];
                if (episodeButton != nil) {
                    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerY.equalTo(episodeButton);
                        make.trailing.equalTo(episodeButton.mas_leading).offset(-10.0);
                        make.size.equalTo(@(CGSizeMake(100.0, 50.0)));
                    }];
                } else {
                    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.bottom.equalTo(groupContainer).offset(-9.0);
                        make.trailing.equalTo(groupContainer.mas_trailing).offset(-50.0);
                        make.size.equalTo(@(CGSizeMake(100.0, 50.0)));
                    }];
                }
            }
        };
        resolutionBtnDes;
    });
}

- (MDInterfaceElementDescriptionImp *)playSpeedButton {
    return ({
        MDInterfaceElementDescriptionImp *playSpeedBtnDes = [MDInterfaceElementDescriptionImp new];
        playSpeedBtnDes.elementID = playSpeedButtonIdentifier;
        playSpeedBtnDes.type = MDInterfaceElementTypeButton;
        playSpeedBtnDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_speed" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setTitle:@"1.0x" forState:UIControlStateNormal];
        };
        playSpeedBtnDes.elementAction = ^NSString* (MDActionButton *button) {
            return MDUIEventShowPlaySpeedMenu;
        };
        playSpeedBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDPlayEventPlaySpeedChanged]) {
                NSString *currentSpeedTitle = [[MDEventPoster currentPoster] currentPlaySpeedForDisplay];
                [button setTitle:currentSpeedTitle forState:UIControlStateNormal];
            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDPlayEventPlaySpeedChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
        };
        playSpeedBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *resolutionBtn = [self viewOfElementIdentifier:resolutionButtonIdentifier inGroup:elementGroup];
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

- (MDInterfaceElementDescriptionImp *)moreButton {
    return ({
        MDInterfaceElementDescriptionImp *moreButtonDes = [MDInterfaceElementDescriptionImp new];
        moreButtonDes.elementID = moreButtonIdentifier;
        moreButtonDes.type = MDInterfaceElementTypeButton;
        moreButtonDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_more" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        };
        moreButtonDes.elementAction = ^NSString* (MDActionButton *button) {
            return MDUIEventShowMoreMenu;
        };
        moreButtonDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
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

- (MDInterfaceElementDescriptionImp *)subTitleButtonView {
    __weak typeof(self) weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *subTitleButtonDes = [MDInterfaceElementDescriptionImp new];
        subTitleButtonDes.elementID = smartSubtitleButtonIdentify;
        subTitleButtonDes.type = MDInterfaceElementTypeButton;
        subTitleButtonDes.elementDisplay = ^(MDActionButton *button) {
            _subtitlteButton = button;
            [button setImage:[UIImage imageNamed:@"subTitleOff" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            NSString *title = LocalizedStringFromBundle(@"subtitle_default", @"VodPlayer");
            [button setTitle:title forState:UIControlStateNormal];
        };
        subTitleButtonDes.elementAction = ^NSString *(MDActionButton *button) {
            return MDPlayEventShowSubtitleMenu;
        };
        subTitleButtonDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
        };
        subTitleButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *playSpeedBtn = [weak_self viewOfElementIdentifier:playSpeedButtonIdentifier inGroup:elementGroup];
                [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(playSpeedBtn);
                    make.trailing.equalTo(playSpeedBtn.mas_leading).offset(-10);
                    make.size.mas_greaterThanOrEqualTo(CGSizeMake(100.0, 50.0));
                }];
            }
        };
        subTitleButtonDes;
    });
}

- (MDInterfaceElementDescriptionImp *)socialStackView {
    __weak typeof(self) weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *socialStack = [MDInterfaceElementDescriptionImp new];
        socialStack.elementID = socialStackViewIdentifier;
        socialStack.type = MDInterfaceElementTypeCustomView;
        socialStack.customView = weak_self.socialView;
        socialStack.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            elementView.hidden = normalScreenBehaivor();
            [elementView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(groupContainer).offset(52);
                make.bottom.equalTo(groupContainer).offset(-16);
            }];
        };
        socialStack.elementNotify = ^id(UIView *elementView, NSString *key, id obj) {
            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged, MDUIEventScreenOrientationChanged];
        };
        socialStack;
    });
}

- (MDInterfaceElementDescriptionImp *)lockButton {
    return ({
        MDInterfaceElementDescriptionImp *lockButtonDes = [MDInterfaceElementDescriptionImp new];
        lockButtonDes.elementID = lockButtonIdentifier;
        lockButtonDes.type = MDInterfaceElementTypeButton;
        lockButtonDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_unlock" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"long_video_lock" bundleName:@"VodPlayer"] forState:UIControlStateSelected];
        };
        lockButtonDes.elementAction = ^NSString* (MDActionButton *button) {
            return MDUIEventLockScreen;
        };
        lockButtonDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                button.selected = screenIsLocking;
            }
            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
        };
        lockButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *backBtn = [self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(groupContainer).offset(-72);
                make.centerY.equalTo(groupContainer);
                make.size.equalTo(@(squareSize()));
            }];
        };
        lockButtonDes;
    });
}

- (MDInterfaceElementDescriptionImp *)titleLabel {
    return ({
        MDInterfaceElementDescriptionImp *titleLabelDes = [MDInterfaceElementDescriptionImp new];
        titleLabelDes.elementID = titleLabelIdentifier;
        titleLabelDes.type = MDInterfaceElementTypeLabel;
        titleLabelDes.elementDisplay = ^(MDDisplayLabel *label) {
            label.text = [[MDEventPoster currentPoster] title];
        };
        titleLabelDes.elementNotify = ^id (MDDisplayLabel *label, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                label.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
                label.hidden = screenIsLocking;
            }
            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
        };
        titleLabelDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *backBtn = [self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
            UIView *moreBtn = [self viewOfElementIdentifier:moreButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(backBtn.mas_trailing).offset(8.0);
                make.centerY.equalTo(backBtn);
                make.trailing.equalTo(groupContainer).offset(8.0);
                make.height.equalTo(@50.0);
            }];
        };
        titleLabelDes;
    });
}

- (MDInterfaceElementDescriptionImp *)loopPlayButton {
    return ({
        MDInterfaceElementDescriptionImp *loopPlayButtonDes = [MDInterfaceElementDescriptionImp new];
        loopPlayButtonDes.elementID = loopPlayButtonIdentifier;
        loopPlayButtonDes.type = MDInterfaceElementTypeMenuNormalCell;
        loopPlayButtonDes.elementDisplay = ^(MDInterfaceSlideMenuCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"cyclic_mode", @"VodPlayer");
            [cell.leftButton setTitle:LocalizedStringFromBundle(@"loop_mode_on", @"VodPlayer") forState:UIControlStateNormal];
            [cell.rightButton setTitle:LocalizedStringFromBundle(@"loop_mode_off", @"VodPlayer") forState:UIControlStateNormal];
            [cell highlightLeftButton:[MDEventPoster currentPoster].loopPlayOpen];
        };
        loopPlayButtonDes.elementAction = ^NSString* (MDInterfaceSlideMenuCell *cell) {
            return MDPlayEventChangeLoopPlayMode;
        };
        loopPlayButtonDes.elementNotify = ^id(UIButton *btn, NSString *key, NSNumber *value) {
            if (value) {
                [[MDEventMessageBus universalBus] postEvent:MDPlayEventChangeLoopPlayMode withObject:value rightNow:YES];
            }
            return btn;
        };
        loopPlayButtonDes;
    });
}

- (MDInterfaceElementDescriptionImp *)volumeGesture {
    return ({
        MDInterfaceElementDescriptionImp *volumeGestureDes = [MDInterfaceElementDescriptionImp new];
        volumeGestureDes.elementID = volumeGestureIdentifier;
        volumeGestureDes.type = MDInterfaceElementTypeMenuPercentageCell;
        volumeGestureDes.elementAction = ^NSString *(id sender) {
            return MDUIEventVolumeIncrease;
        };
        volumeGestureDes.elementDisplay = ^(MDInterfaceSlideMenuPercentageCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"voice", @"VodPlayer");
            cell.iconImgView.image = [UIImage imageNamed:@"vod_videosettting_volume" bundleName:@"VodPlayer"];
            cell.percentage =  [[MDEventPoster currentPoster] currentVolume];
        };
        volumeGestureDes.elementNotify = ^id(UIView *view, NSString *key, NSValue *value) {
            VOLogI(VOMiniDrama, @"volume: %@", value);
            if (value) {
                [[MDEventMessageBus universalBus] postEvent:MDUIEventVolumeIncrease withObject:value rightNow:YES];
            }
            return view;
        };
        volumeGestureDes;
    });
}

- (MDInterfaceElementDescriptionImp *)volumeVerticalGesture {
    __weak typeof(self) weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *volumeGestureDes = [MDInterfaceElementDescriptionImp new];
        volumeGestureDes.elementID = volumeGestureIdentifier;
        volumeGestureDes.type = MDInterfaceElementTypeGestureRightVerticalPan;
        volumeGestureDes.elementAction = ^NSString* (id sender) {
            return MDUIEventVolumeIncrease;
        };
        volumeGestureDes.elementNotify = ^id(UIView *view, NSString *key, NSDictionary *param) {
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
                [[MDEventMessageBus universalBus] postEvent:MDUIEventVolumeIncrease withObject:value rightNow:YES];
                weak_self.rightVolumeSlider.progress = [[MDEventPoster currentPoster] currentVolume];
            }
            NSNumber *end = [param objectForKey:@"touchEnd"];
            if (end.boolValue) {
                weak_self.rightVolumeSlider.hidden = YES;
            }
            return view;
        };
        volumeGestureDes;
    });
}

- (MDInterfaceElementDescriptionImp *)brightnessGesture {
    return ({
        MDInterfaceElementDescriptionImp *brightnessGestureDes = [MDInterfaceElementDescriptionImp new];
        brightnessGestureDes.elementID = brightnessGestureIdentifier;
        brightnessGestureDes.type = MDInterfaceElementTypeMenuPercentageCell;
        brightnessGestureDes.elementAction = ^NSString *(id sender) {
            return MDUIEventBrightnessIncrease;
        };
        brightnessGestureDes.elementDisplay = ^(MDInterfaceSlideMenuPercentageCell *cell) {
            cell.titleLabel.text = LocalizedStringFromBundle(@"brightness", @"VodPlayer");
            cell.iconImgView.image = [UIImage imageNamed:@"vod_videosettting_brightness" bundleName:@"VodPlayer"];
            cell.percentage =  [[MDEventPoster currentPoster] currentBrightness];
        };
        brightnessGestureDes.elementNotify = ^id(UIView *view, NSString *key, NSValue *value) {
            if (value) {
                [[MDEventMessageBus universalBus] postEvent:MDUIEventBrightnessIncrease withObject:value rightNow:YES];
            }
            return view;
        };
        brightnessGestureDes;
    });
}

- (MDInterfaceElementDescriptionImp *)brightnessVerticalGesture {
    __weak typeof(self) weak_self = self;
    return ({
        MDInterfaceElementDescriptionImp *brightnessGestureDes = [MDInterfaceElementDescriptionImp new];
        brightnessGestureDes.elementID = brightnessGestureIdentifier;
        brightnessGestureDes.type = MDInterfaceElementTypeGestureLeftVerticalPan;
        brightnessGestureDes.elementAction = ^NSString* (id sender) {
            return MDUIEventBrightnessIncrease;
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
                [[MDEventMessageBus universalBus] postEvent:MDUIEventBrightnessIncrease withObject:value rightNow:YES];
                weak_self.leftBrightnessSlider.progress = [[MDEventPoster currentPoster] currentBrightness];
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

- (MDInterfaceElementDescriptionImp *)playGesture {
    return ({
        MDInterfaceElementDescriptionImp *playGestureDes = [MDInterfaceElementDescriptionImp new];
        playGestureDes.elementID = playGestureIdentifier;
        playGestureDes.type = MDInterfaceElementTypeGestureDoubleTap;
        playGestureDes.elementAction = ^NSString* (id sender) {
            if ([[MDEventPoster currentPoster] screenIsLocking] || [[MDEventPoster currentPoster] screenIsClear]) {
                return nil;
            }
            MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
            if (playbackState == MDPlaybackStatePlaying) {
                return MDPlayEventPause;
            } else {
                return MDPlayEventPlay;
            }
        };
        playGestureDes;
    });
}

- (MDInterfaceElementDescriptionImp *)clearScreenGesture {
    return ({
        MDInterfaceElementDescriptionImp *clearScreenGestureDes = [MDInterfaceElementDescriptionImp new];
        clearScreenGestureDes.elementID = clearScreenGestureIdentifier;
        clearScreenGestureDes.type = MDInterfaceElementTypeGestureSingleTap;
        clearScreenGestureDes.elementAction = ^NSString* (id sender) {
            return MDUIEventClearScreen;
        };
        clearScreenGestureDes;
    });
}

- (MDInterfaceElementDescriptionImp *)autoHideControllerGesture {
    @autoreleasepool {
        return ({
            MDInterfaceElementDescriptionImp *gestureDes = [MDInterfaceElementDescriptionImp new];
            gestureDes.type = MDInterfaceElementTypeGestureAutoHideController;
            gestureDes;
        });
    }
}

- (MDInterfaceElementDescriptionImp *)menuButtonCell {
    __weak __typeof(self)weak_self = self;
    return ({
       MDInterfaceElementDescriptionImp *menuButtonDes = [MDInterfaceElementDescriptionImp new];
        menuButtonDes.elementID = MDMenuButtonCellIdentifier;
        menuButtonDes.type = MDInterfaceElementTypeMenuButtonCell;
        menuButtonDes.elementDisplay = ^(__kindof MDInterfaceSlideButtonCell * cell) {
           NSMutableArray *buttons = [NSMutableArray array];
            // PIP
            MDInterfaceSlideButton *pipButton = [[MDInterfaceSlideButton alloc] init];
            pipButton.elementID = @"pip";
            [pipButton bingImage:[UIImage imageNamed:@"vod_pip_icon" bundleName:@"VodPlayer"] status:ButtonStatusNone];
            [pipButton bingImage:[UIImage imageNamed:@"vod_pip_icon_s" bundleName:@"VodPlayer"] status:ButtonStatusActive];
            [pipButton setTitle:LocalizedStringFromBundle(@"vod_pip", @"VodPlayer") forState:UIControlStateNormal];
            pipButton.status = [[MDEventPoster currentPoster] isPipOpen] ? ButtonStatusActive : ButtonStatusNone;
            [buttons addObject:pipButton];
            MDInterfaceSlideButton *reportButton = [[MDInterfaceSlideButton alloc] init];
            reportButton.elementID = @"report";
            [reportButton bingImage:[UIImage imageNamed:@"vod_video_report" bundleName:@"VodPlayer"] status:ButtonStatusNone];
            [reportButton setTitle:LocalizedStringFromBundle(@"vod_report", @"VodPlayer") forState:UIControlStateNormal];
            [buttons addObject:reportButton];

            cell.buttons = buttons;
        };
        menuButtonDes.elementAction = ^NSString *(id sender) {
            return nil;
        };
        menuButtonDes.elementNotify = ^id(__kindof MDInterfaceSlideButton *button, NSString *key, id obj) {
            if ([key isEqualToString:@"report"]) {
                [ReportComponent report:weak_self.videoModel.videoId cancelHandler:nil completion:nil];
            } else if ([key isEqualToString:@"pip"]) {
                if (button.status == ButtonStatusActive) {
                    [[MDEventPoster currentPoster] disablePIP];
                    button.status = ButtonStatusNone;
                } else {
                    __weak typeof(button) weak_button = button;
                    [[MDEventPoster currentPoster] enablePIP:^(BOOL isOpenPip) {
                        if (isOpenPip) {
                            weak_button.status = ButtonStatusActive;
                        }
                    }];
                }
            }
            return nil;
        };
        menuButtonDes;
    });
}

#pragma mark ----- MDInterfaceElementProtocol

- (NSArray<id<MDInterfaceElementDescription>> *)customizedElements {
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[self playButton]];
    [elements addObject:[self progressView]];
    [elements addObject:[self fullScreenButton]];
    [elements addObject:[self backButton]];
    [elements addObject:[self resolutionButton]];
    [elements addObject:[self playSpeedButton]];
    [elements addObject:[self episodesButton]];
    [elements addObject:[self lockButton]];
    [elements addObject:[self titleLabel]];
    [elements addObject:[self moreButton]];

    [elements addObject:[self volumeGesture]];
    [elements addObject:[self brightnessGesture]];
    [elements addObject:[self loopPlayButton]];
    [elements addObject:[self menuButtonCell]];
    [elements addObject:[self volumeVerticalGesture]];
    [elements addObject:[self brightnessVerticalGesture]];
    [elements addObject:[self playGesture]];
    [elements addObject:[self autoHideControllerGesture]];
    [elements addObject:[self clearScreenGesture]];
    [elements addObject:[self subTitleButtonView]];
    [elements addObject:[self socialStackView]];
    return [elements copy];
}

- (void)refreshSubtitleButton:(DramaSubtitleModel *)model {
    if (!model) {
        [self resetState];
        return;
    }
    if (model.subtitleId != 0) {
        [self.subtitlteButton setImage:[UIImage imageNamed:@"subTitle" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
    }
    [self.subtitlteButton setTitle:model.languageName forState:UIControlStateNormal];
}

- (void)resetState {
    __weak __typeof__(self) weak_self = self;
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [weak_self.subtitlteButton setImage:[UIImage imageNamed:@"subTitle" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        NSString *title = LocalizedStringFromBundle(@"subtitle_default", @"VodPlayer");
        [weak_self.subtitlteButton setTitle:title forState:UIControlStateNormal];
    });
}

- (void)updatePlayButton:(BOOL)isPlaying {
    if (self.playButtonView) {
        self.playButtonView.selected = !isPlaying;
    }
}

#pragma mark - Getter

- (MiniDramaSocialView *)socialView {
    if (!_socialView) {
        _socialView = [[MiniDramaSocialView alloc] init];
        _socialView.axis = UILayoutConstraintAxisHorizontal;
        _socialView.videoModel = self.videoModel;
    }
    return _socialView;
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


@end
