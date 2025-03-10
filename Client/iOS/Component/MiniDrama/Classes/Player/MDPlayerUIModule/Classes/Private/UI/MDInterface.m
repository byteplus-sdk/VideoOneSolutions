// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterface.h"
#import <Masonry/Masonry.h>
#import "MDEventConst.h"
#import "MDInterfaceBridge.h"
#import "MDInterfaceFactory.h"

NSString *const MDTaskPlayCoreTransfer = @"MDTaskPlayCoreTransfer";

NSString *const MDPlayEventPlay = @"MDPlayEventPlay";

NSString *const MDPlayEventPause = @"MDPlayEventPause";

NSString *const MDPlayEventSeek = @"MDPlayEventSeek";

NSString *const MDUIEventScreenOrientationChanged = @"MDUIEventScreenOrientationChanged";

extern NSString *const MDPlayProgressSliderGestureEnable;

@interface MDInterface ()

@end

@implementation MDInterface

- (instancetype)initWithPlayerCore:(id<MDPlayCoreAbilityProtocol>)core scene:(id<MDInterfaceElementDataSource>)scene {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self loadKit];
        [self registEvents];
        [self addObserver];
        [self initializeEventWithCore:core scene:scene];
    }
    return self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadKit {
    [MDInterfaceBridge bridge];
}

- (void)registEvents {
    [[MDEventMessageBus universalBus] registEvent:MDUIEventScreenRotation withAction:@selector(screenRotationAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventPageBack withAction:@selector(pageBackAction:) ofTarget:self];
	[[MDEventMessageBus universalBus] registEvent:MDUIEventStartPip withAction:@selector(startPipAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDPlayProgressSliderGestureEnable withAction:@selector(sliderAction:) ofTarget:self];
}

- (void)initializeEventWithCore:(id<MDPlayCoreAbilityProtocol>)core scene:(id<MDInterfaceElementDataSource>)scene {
    [self reloadCore:core];
    [self buildingScene:scene];
}

- (void)reloadCore:(id<MDPlayCoreAbilityProtocol>)core {
    if ([core conformsToProtocol:@protocol(MDPlayCoreAbilityProtocol)]) {
        [[MDEventMessageBus universalBus] postEvent:MDTaskPlayCoreTransfer withObject:core rightNow:YES];
    }
}

- (void)buildingScene:(id<MDInterfaceElementDataSource>)scene {
    UIView *interfaceContainer = [MDInterfaceFactory sceneOfMaterial:scene];
    [self addSubview:interfaceContainer];
    [interfaceContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];
}

- (void)screenRotationAction:(id)param {
    if ([self.delegate respondsToSelector:@selector(interfaceCallScreenRotation:)]) {
        [self.delegate interfaceCallScreenRotation:self];
    }
}

- (void)startPipAction:(id)param {
	if ([self.delegate respondsToSelector:@selector(interfaceCallStartPip:)]) {
		[self.delegate interfaceCallStartPip:self];
	}
}

- (void)pageBackAction:(id)param {
    if ([self.delegate respondsToSelector:@selector(interfaceCallPageBack:)]) {
        if (normalScreenBehaivor()) {
            [self destory];
        }
        [self.delegate interfaceCallPageBack:self];
    }
}

- (void)sliderAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        BOOL value = [paramDic.allValues.firstObject boolValue];
        if ([self.delegate respondsToSelector:@selector(interfaceShouldEnableSlide:)]) {
            [self.delegate interfaceShouldEnableSlide:value];
        }
    }
}

- (void)destory {
    @autoreleasepool {
        [MDEventMessageBus destroyUnit];
        [MDEventPoster destroyUnit];
        [MDInterfaceBridge destroyUnit];
        [self removeFromSuperview];
    }
}


#pragma mark ----- UIInterfaceOrientation

- (void)screenOrientationChanged:(NSNotification *)notification {
    [[MDEventMessageBus universalBus] postEvent:MDUIEventScreenOrientationChanged withObject:nil rightNow:YES];
}


#pragma mark ----- Tool

static inline BOOL normalScreenBehaivor () {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
}



@end
