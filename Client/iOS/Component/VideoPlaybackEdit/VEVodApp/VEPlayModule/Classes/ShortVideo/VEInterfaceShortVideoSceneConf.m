// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceShortVideoSceneConf.h"
#import "VEEventMessageBus.h"
#import "VEEventPoster.h"
#import "VEInterfacePlayElement.h"
#import "VEInterfaceProgressElement.h"

@interface VEInterfaceShortVideoSceneConf ()

@property (nonatomic, strong) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong) VEEventPoster *eventPoster;

@property (nonatomic, strong) NSArray<id<VEInterfaceElementDescription>> *customizedElements;

@end

@implementation VEInterfaceShortVideoSceneConf

@synthesize deactive;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventMessageBus = [[VEEventMessageBus alloc] init];
        self.eventPoster = [[VEEventPoster alloc] initWithEventMessageBus:self.eventMessageBus];
    }
    return self;
}

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    if (!_customizedElements) {
        _customizedElements = @[
            [VEInterfacePlayElement playButtonWithEventPoster:self.eventPoster],
            [VEInterfacePlayElement playGestureWithEventPoster:self.eventPoster],
            [VEInterfacePlayElement likeGesture],
            [VEInterfaceProgressElement progressViewWithEventPoster:self.eventPoster],
        ];
    }
    return _customizedElements;
}

@end
