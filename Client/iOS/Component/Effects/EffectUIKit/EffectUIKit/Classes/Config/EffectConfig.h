// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef EffectConfig_h
#define EffectConfig_h

#import <Foundation/Foundation.h>
#import "EffectDataManager.h"

FOUNDATION_EXTERN NSString *const EFFECT_CONFIG_KEY;


@interface EffectUIKitBeautyConfigItem : NSObject

- (instancetype)initWithTitle:(NSString *)title type:(EffectUIKitType)type;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) EffectUIKitType effecType;

@end


@interface EffectConfig : NSObject

+ (EffectConfig * (^)(void))newInstance;
- (EffectConfig * (^)(BOOL, BOOL))showResetAndCompareW;
- (EffectConfig * (^)(EffectUIKitType))effectTypeW;
- (EffectConfig * (^)(id))titleW;
- (EffectConfig * (^)(NSInteger))topBarModeW;


@property (nonatomic) BOOL showBoard;

@property (nonatomic, strong) NSString *title;

@property (nonatomic) BOOL showResetButton;

@property (nonatomic) BOOL showCompareButton;

@property (nonatomic, assign) NSInteger topBarMode;

@property (nonatomic, assign) EffectUIKitType effectType;

@property (nonatomic, assign, readonly) BOOL isAutoTest;

@property (nonatomic, strong) NSArray<ComposerNodeModel *> *composerNodes;

@property (nonatomic, strong) NSString *filterName;

@property (nonatomic, assign) CGFloat filterIntensity;

@end

#endif /* EffectConfig_h */
