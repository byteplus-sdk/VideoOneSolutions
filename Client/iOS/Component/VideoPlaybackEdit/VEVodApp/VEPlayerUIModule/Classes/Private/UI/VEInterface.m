// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterface.h"
#import "Masonry.h"
#import "VEEventConst.h"
#import "VEInterfaceFactory.h"
#import "VEInterfaceProtocol.h"

NSString *const VETaskPlayCoreTransfer = @"VETaskPlayCoreTransfer";

NSString *const VEPlayEventPlay = @"VEPlayEventPlay";

NSString *const VEPlayEventPause = @"VEPlayEventPause";

NSString *const VEPlayEventSeek = @"VEPlayEventSeek";

NSString *const VEPlayEventSeeking = @"VEPlayEventSeeking";

NSString *const VEUIEventScreenOrientationChanged = @"VEUIEventScreenOrientationChanged";

extern NSString *const VEPlayProgressSliderGestureEnable;

@interface VEInterface ()

@property (nonatomic, strong) id<VEInterfaceElementDataSource> scene;

@end

@implementation VEInterface

- (instancetype)initWithPlayerCore:(id<VEPlayCoreAbilityProtocol>)core scene:(id<VEInterfaceElementDataSource>)scene {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.scene = scene;
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

- (void)registEvents {
    [self.eventMessageBus registEvent:VEUIEventScreenRotation withAction:@selector(screenRotationAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEUIEventPageBack withAction:@selector(pageBackAction:) ofTarget:self];
    [self.eventMessageBus registEvent:VEPlayProgressSliderGestureEnable withAction:@selector(sliderAction:) ofTarget:self];
}

- (void)initializeEventWithCore:(id<VEPlayCoreAbilityProtocol>)core scene:(id<VEInterfaceElementDataSource>)scene {
    [self reloadCore:core];
    [self buildingScene:scene];
}

- (VEEventMessageBus *)eventMessageBus {
    return self.scene.eventMessageBus;
}

- (VEEventPoster *)eventPoster {
    return self.scene.eventPoster;
}

- (void)reloadCore:(id<VEPlayCoreAbilityProtocol>)core {
    if ([core conformsToProtocol:@protocol(VEPlayCoreAbilityProtocol)]) {
        [self.eventMessageBus postEvent:VETaskPlayCoreTransfer withObject:core rightNow:YES]; // Ensure that the core is not released during playback.
    }
}

- (void)buildingScene:(id<VEInterfaceElementDataSource>)scene {
    UIView *interfaceContainer = [VEInterfaceFactory sceneOfMaterial:scene];
    [self addSubview:interfaceContainer];
    [interfaceContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];
}

- (void)screenRotationAction:(id)param {
    // rotate the screen
    if ([self.delegate respondsToSelector:@selector(interfaceCallScreenRotation:)]) {
        [self.delegate interfaceCallScreenRotation:self];
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
    [self.eventMessageBus destroyUnit];
    [self removeFromSuperview];
}

#pragma mark----- UIInterfaceOrientation

- (void)screenOrientationChanged:(NSNotification *)notification {
    [self.eventMessageBus postEvent:VEUIEventScreenOrientationChanged withObject:nil rightNow:YES];
}

#pragma mark----- Tool

static inline BOOL normalScreenBehaivor(void) {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
}

@end
