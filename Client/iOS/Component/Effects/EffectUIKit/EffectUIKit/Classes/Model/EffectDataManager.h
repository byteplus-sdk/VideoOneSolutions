// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "EffectItem.h"
#import "ComposerNodeModel.h"
#import "TextSwitchItemView.h"

typedef NS_ENUM(NSInteger, EffectUIKitType) {
    EffectUIKitTypeLite,
    EffectUIKitTypeLiteNotAsia,
    EffectUIKitTypeStandard,
    EffectUIKitTypeStandardNotAsia,
};
NS_ASSUME_NONNULL_BEGIN

@interface EffectDataManager : NSObject


@property (nonatomic, readonly) EffectUIKitType effectType;


@property (nonatomic, strong, class, readonly, nullable) NSArray<TextSwitchItem *> *styleMakeupSwitchItems;


@property (nonatomic, assign) BOOL defaultEffectOn;


@property (nonatomic, assign) BOOL cacheable;


@property(nonatomic, strong) NSArray<EffectUIKitCategoryModel *> *effectCategoryModelArray;

- (instancetype)initWithType:(EffectUIKitType)type;

- (nullable NSMutableArray<NSNumber *> *)defaultIntensity:(EffectUIKitNode)ID;


- (nullable NSMutableArray<NSNumber *> *)defaultIntensityMax:(EffectUIKitNode)ID;


- (nullable NSMutableArray<NSNumber *> *)defaultIntensityMin:(EffectUIKitNode)ID;


- (NSArray<EffectItem *> *)buttonItemArrayWithDefaultIntensity;


- (NSDictionary *)hairDyeFullColor:(NSString *)key ItemColor:(EffectColorItem *)color;


- (NSInteger)hairDyeFullIndex:(NSString *)key;


+ (nullable NSArray <NSNumber *>*)conflictTypesFor:(EffectUIKitNode)nodeType;


- (void)resetLastDefaultValueFor:(EffectItem *)item;
@end
NS_ASSUME_NONNULL_END
