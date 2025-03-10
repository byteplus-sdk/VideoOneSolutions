// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceContainer.h"
#import "MDInterfaceProtocol.h"
#import "MDInterfaceVisual.h"
#import "MDInterfaceSensor.h"
#import "MDInterfaceFloater.h"
#import "MDEventConst.h"
#import <Masonry/Masonry.h>

@interface MDInterfaceContainer ()

@property (nonatomic, strong) MDInterfaceSensor *sensorView;

@property (nonatomic, strong) MDInterfaceVisual *visualView;

@property (nonatomic, strong) MDInterfaceFloater *floaterView;

@end

@implementation MDInterfaceContainer

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeSublayers:scene];
        [self registEvents];
    }
    return self;
}

- (void)registEvents {
    [[MDEventMessageBus universalBus] registEvent:MDUIEventLockScreen withAction:@selector(lockScreenAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventClearScreen withAction:@selector(clearScreenAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventScreenClearStateChanged withAction:@selector(performClearScreenLater:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayEventStateChanged withAction:@selector(performClearScreenLater:) ofTarget:self];
    
}

- (void)performClearScreenLater:(id)param {
    [self.sensorView performClearScreenLater];
}

- (void)initializeSublayers:(id<MDInterfaceElementDataSource>)scene {
    if (!self.sensorView) {
        self.sensorView = [[MDInterfaceSensor alloc] initWithScene:scene];
    }
    [self addSubview:self.sensorView];
    if (!self.visualView) {
        self.visualView = [[MDInterfaceVisual alloc] initWithScene:scene];
    }
    [self addSubview:self.visualView];
    if (!self.floaterView) {
        self.floaterView = [[MDInterfaceFloater alloc] initWithScene:scene];
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
    BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
    [[MDEventPoster currentPoster] setScreenIsLocking:!screenIsLocking];
    [[MDEventMessageBus universalBus] postEvent:MDUIEventScreenLockStateChanged withObject:nil rightNow:YES];
}

- (void)clearScreenAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            [[MDEventPoster currentPoster] setScreenIsClear:[value boolValue]];
        } else {
            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
            [[MDEventPoster currentPoster] setScreenIsClear:!screenIsClear];
        }
        [[MDEventMessageBus universalBus] postEvent:MDUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    }
}

@end
