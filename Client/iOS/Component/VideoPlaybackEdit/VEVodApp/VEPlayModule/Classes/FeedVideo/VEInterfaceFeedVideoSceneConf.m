// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceFeedVideoSceneConf.h"
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

@interface VEInterfaceFeedVideoSceneConf ()

@property (nonatomic, strong) NSArray<id<VEInterfaceElementDescription>> *customizedElements;

@end

@implementation VEInterfaceFeedVideoSceneConf

@synthesize deactive;

static NSString *maskViewIdentifier = @"maskViewIdentifier";

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventMessageBus = [[VEEventMessageBus alloc] init];
        self.eventPoster = [[VEEventPoster alloc] initWithEventMessageBus:self.eventMessageBus];
    }
    return self;
}

#pragma mark----- Element Statement

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

#pragma mark----- VEInterfaceElementProtocol

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    if (!_customizedElements) {
        _customizedElements = @[
            [self maskView],
            [self playButton],
            [self progressView],
            [self clearScreenGesture],
            [self fullScreenButton],
            [self autoHideControllerGesture],
        ];
    }
    return _customizedElements;
}

@end
