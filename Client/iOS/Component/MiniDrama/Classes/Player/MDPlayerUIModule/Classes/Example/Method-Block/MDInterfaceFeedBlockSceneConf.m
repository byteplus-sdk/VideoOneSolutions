// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceFeedBlockSceneConf.h"
#import "MDPlayerUIModule.h"
#import "MDActionButton.h"
#import "MDProgressView.h"
#import "MDDisplayLabel.h"
#import "MDInterfaceSlideMenuCell.h"
#import "MDInterfaceElementDescriptionImp.h"
#import <Masonry/Masonry.h>

@implementation MDInterfaceFeedBlockSceneConf

static NSString *playButtonIdentifier = @"playButtonIdentifier";

static NSString *progressViewIdentifier = @"progressViewIdentifier";

static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";

#pragma mark ----- Element Statement

- (MDInterfaceElementDescriptionImp *)playButton {
    return ({
        MDInterfaceElementDescriptionImp *playBtnDes = [MDInterfaceElementDescriptionImp new];
        playBtnDes.elementID = playButtonIdentifier;
        playBtnDes.type = MDInterfaceElementTypeButton;
        playBtnDes.elementDisplay = ^(MDActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
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
            if ([key isEqualToString:MDPlayEventStateChanged]) {
                MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
                button.selected = playbackState != MDPlaybackStatePlaying;
            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            }
            return @[MDPlayEventStateChanged, MDUIEventScreenClearStateChanged];
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
    return ({
        MDInterfaceElementDescriptionImp *progressViewDes = [MDInterfaceElementDescriptionImp new];
        progressViewDes.elementID = progressViewIdentifier;
        progressViewDes.type = MDInterfaceElementTypeProgressView;
        progressViewDes.elementAction = ^NSDictionary* (MDProgressView *progressView) {
            return @{MDPlayEventSeek : @(progressView.currentValue)};
        };
        progressViewDes.elementNotify = ^id (MDProgressView *progressView, NSString *key, id obj) {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                progressView.totalValue = [[MDEventPoster currentPoster] duration];
                progressView.currentValue = interval;
                progressView.bufferValue = [[MDEventPoster currentPoster] playableDuration];
            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
                progressView.hidden = screenIsClear;
            }
            return @[MDPlayEventTimeIntervalChanged, MDUIEventScreenClearStateChanged];
        };
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            ((MDProgressView *)elementView).currentOrientation = UIInterfaceOrientationPortrait;
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(groupContainer).offset(10.0);
                make.bottom.equalTo(groupContainer).offset(5.0);
                make.trailing.equalTo(groupContainer).offset(-10.0);
                make.height.equalTo(@50.0);
            }];
        };
        progressViewDes;
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


#pragma mark ----- MDInterfaceElementProtocol

- (NSArray<id<MDInterfaceElementDescription>> *)customizedElements {
    return @[[self playButton], [self progressView], [self clearScreenGesture]];
}

@end
