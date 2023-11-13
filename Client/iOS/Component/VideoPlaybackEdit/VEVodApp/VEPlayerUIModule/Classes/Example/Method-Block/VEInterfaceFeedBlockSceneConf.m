// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceFeedBlockSceneConf.h"
#import "VEPlayerUIModule.h"
#import "VEActionButton.h"
#import "VEProgressView.h"
#import "VEDisplayLabel.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceElementDescriptionImp.h"
#import "Masonry.h"
#import "VEEventMessageBus.h"

@interface VEInterfaceFeedBlockSceneConf ()

@property (nonatomic, strong) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong) VEEventPoster *eventPoster;

@end

@implementation VEInterfaceFeedBlockSceneConf

static NSString *playButtonIdentifier = @"playButtonIdentifier";

static NSString *progressViewIdentifier = @"progressViewIdentifier";

static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";

static NSString *maskViewIdentifier = @"maskViewIdentifier";

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventMessageBus = [[VEEventMessageBus alloc] init];
        self.eventPoster = [[VEEventPoster alloc] initWithEventMessageBus:self.eventMessageBus];
    }
    return self;
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
            if ([key isEqualToString:VEPlayEventStateChanged]) {
                VEPlaybackState playbackState = [weak_self.eventPoster currentPlaybackState];
                button.selected = playbackState != VEPlaybackStatePlaying;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            }
            return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged];
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
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                progressView.totalValue = [weak_self.eventPoster duration];
                progressView.currentValue = interval;
                progressView.bufferValue = [weak_self.eventPoster playableDuration];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                progressView.hidden = screenIsClear;
            }
            return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged];
        };
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            ((VEProgressView *)elementView).currentOrientation = UIInterfaceOrientationPortrait;
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
        maskVewDes.elementNotify = ^id (UIView *elementView, NSString *key, id obj) {
            BOOL screenIsClear = [weak_self.eventPoster screenIsClear];
            elementView.hidden = screenIsClear;
            return VEUIEventScreenClearStateChanged;
        };
        maskVewDes;
    });
}

#pragma mark ----- VEInterfaceElementProtocol

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    return @[[self maskView], [self playButton], [self progressView], [self clearScreenGesture]];
}

@end
