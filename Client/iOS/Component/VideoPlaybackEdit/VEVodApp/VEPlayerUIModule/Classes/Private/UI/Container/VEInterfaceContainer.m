// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceContainer.h"
#import "Masonry.h"
#import "VEEventConst.h"
#import "VEInterfaceFloater.h"
#import "VEInterfaceProtocol.h"
#import "VEInterfaceSensor.h"
#import "VEInterfaceVisual.h"

@interface VEInterfaceContainer ()

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@property (nonatomic, strong) VEInterfaceSensor *sensorView;

@property (nonatomic, strong) VEInterfaceVisual *visualView;

@property (nonatomic, strong) VEInterfaceFloater *floaterView;

@end

@implementation VEInterfaceContainer

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeSublayers:scene];
        [self registEvents];
    }
    return self;
}

- (void)registEvents {
    [self.scene.eventMessageBus registEvent:VEUIEventLockScreen withAction:@selector(lockScreenAction:) ofTarget:self];
    [self.scene.eventMessageBus registEvent:VEUIEventClearScreen withAction:@selector(clearScreenAction:) ofTarget:self];
    [self.scene.eventMessageBus registEvent:VEUIEventScreenClearStateChanged withAction:@selector(performClearScreenLater:) ofTarget:self];
    [self.scene.eventMessageBus registEvent:VEPlayEventStateChanged withAction:@selector(performClearScreenLater:) ofTarget:self];
    [self.scene.eventMessageBus registEvent:VEUIEventResetAutoHideController withAction:@selector(performClearScreenLater:) ofTarget:self];
}

- (void)initializeSublayers:(id<VEInterfaceElementDataSource>)scene {
    self.scene = scene;
    if (!self.sensorView) {
        self.sensorView = [[VEInterfaceSensor alloc] initWithScene:scene];
    }
    [self addSubview:self.sensorView];
    if (!self.visualView) {
        self.visualView = [[VEInterfaceVisual alloc] initWithScene:scene];
    }
    [self addSubview:self.visualView];
    if (!self.floaterView) {
        self.floaterView = [[VEInterfaceFloater alloc] initWithScene:scene];
    }
    [self addSubview:self.floaterView];
    [self layoutSubModules];
}

- (void)layoutSubModules {
    [self.visualView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];

    [self.sensorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];

    [self.floaterView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];
}

- (void)lockScreenAction:(id)param {
    [self.scene.eventMessageBus postEvent:VEUIEventScreenLockStateChanged withObject:nil rightNow:YES];
}

- (void)clearScreenAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            [self.scene.eventPoster setScreenIsClear:[value boolValue]];
        }
        [self.scene.eventMessageBus postEvent:VEUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    }
}

- (void)performClearScreenLater:(id)param {
    [self.sensorView performClearScreenLater];
}

@end
