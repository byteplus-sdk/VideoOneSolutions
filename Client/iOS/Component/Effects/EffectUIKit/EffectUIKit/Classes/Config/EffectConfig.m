// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectConfig.h"
#import "BaseBarView.h"

NSString *const EFFECT_CONFIG_KEY = @"EFFECT_CONFIG_KEY";

@implementation EffectUIKitBeautyConfigItem

- (instancetype)initWithTitle:(NSString *)title type:(EffectUIKitType)type {
    if (self = [super init]) {
        self.title = title;
        self.effecType = type;
    }
    return self;
}

@end

@implementation EffectConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _showBoard = YES;
        _showResetButton = YES;
        _showCompareButton = YES;
        _effectType = EffectUIKitTypeLite;
        _topBarMode = BaseBarAll;
    }
    return self;
}

- (BOOL)isAutoTest {
    return _composerNodes != nil;
}

#pragma mark getter
+ (EffectConfig * (^)(void))newInstance {
    return ^id() {
        return [[EffectConfig alloc] init];
    };
}

- (EffectConfig * (^)(EffectUIKitType))effectTypeW {
    return ^id(EffectUIKitType effectType) {
        self.effectType = effectType;
        return self;
    };
}

- (EffectConfig * (^)(NSInteger))topBarModeW {
    return ^id(NSInteger mode) {
        self.topBarMode = mode;
        return self;
    };
}

- (EffectConfig *(^)(id))titleW {
    return ^id(NSString *config) {
        self.title = config;
        return self;
    };
}

- (EffectConfig * (^)(BOOL, BOOL))showResetAndCompareW {
    return ^id(BOOL showReset, BOOL showCompare) {
        self.showResetButton = showReset;
        self.showCompareButton = showCompare;
        return self;
    };
}

@end
