// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSimpleMethodSceneConf.h"
#import "VEEventMessageBus.h"
#import "VEEventPoster.h"
#import "VEInterfacePlayElement.h"
#import "VEInterfaceProgressElement.h"

@interface VEInterfaceSimpleMethodSceneConf ()

@property (nonatomic, strong) VEEventMessageBus *eventMessageBus;

@property (nonatomic, strong) VEEventPoster *eventPoster;

@end

@implementation VEInterfaceSimpleMethodSceneConf

@synthesize deActive;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventMessageBus = [[VEEventMessageBus alloc] init];
        self.eventPoster = [[VEEventPoster alloc] initWithEventMessageBus:self.eventMessageBus];
    }
    return self;
}

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    return @[
        [VEInterfacePlayElement playButtonWithEventPoster:self.eventPoster],
        [VEInterfacePlayElement playGestureWithEventPoster:self.eventPoster],
        [VEInterfacePlayElement likeGesture],
        [VEInterfaceProgressElement progressViewWithEventPoster:self.eventPoster],
    ];
}

@end
