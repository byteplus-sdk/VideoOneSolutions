// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "ButtonItem.h"
#import "ComposerNodeModel.h"
#import "SelectableCell.h"
#import "EffectColorItem.h"
NS_ASSUME_NONNULL_BEGIN
@interface EffectItem : ButtonItem

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model showIntensityBar:(BOOL)showIntensityBar;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model tipTitle:(NSString *)tipTitle;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model tipTitle:(NSString *)tipTitle colorset:(NSArray *)colorset;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model tipTitle:(NSString *)tipTitle colorset:(NSArray *)colorset type:(EffectUIKitTpye)type;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model tipTitle:(NSString *)tipTitle showIntensityBar:(BOOL)showIntensityBar;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model tipTitle:(NSString *)tipTitle showIntensityBar:(BOOL)showIntensityBar type:(EffectUIKitTpye)type;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(nullable ComposerNodeModel *)model enableNegative:(BOOL)enableNegative;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(nullable NSArray<EffectItem *> *)children;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(nullable NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(nullable NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect colorset:(nullable NSArray *)colorset;

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(nullable NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect showIntensityBar:(BOOL)showIntensityBar;

+ (instancetype)initWithId:(EffectUIKitNode)ID image:(NSString *)image title:(NSString *)title resourcePath:(NSString *)resourcePath tip:(NSString *)tip;

+ (instancetype)initWithId:(EffectUIKitNode)ID;

+ (instancetype)initWithId:(EffectUIKitNode)ID children:(nullable NSArray<EffectItem *> *)children;

+ (instancetype)initWithId:(EffectUIKitNode)ID children:(nullable NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect;

- (void)updateState;

- (void)reset;

- (void)resetToDefault;

/// ID
@property (nonatomic, assign) EffectUIKitNode ID;

/// ID or parent.ID , not Close
@property (nonatomic, assign) EffectUIKitNode validID;

@property (nonatomic, strong, readonly, nullable) NSArray<NSNumber *> *validIntensity;

@property (nonatomic, strong, nullable) NSMutableArray <NSNumber *> *validIntensityMax;

@property (nonatomic, strong, nullable) NSMutableArray <NSNumber *> *validIntensityMin;

@property (nonatomic, assign) NSUInteger intensityIndex;

/// self.lastIntensityArray[self.intensityIndex] || self.intensityArray[self.intensityIndex]
@property (nonatomic, assign, readwrite) CGFloat intensity;

@property (nonatomic, strong, nullable) NSMutableArray <NSNumber *> *intensityMaxArray;

@property (nonatomic, strong, nullable) NSMutableArray <NSNumber *> *intensityMinArray;

@property (nonatomic, strong, nullable) NSMutableArray <NSNumber *> *intensityArray;

@property (nonatomic, strong, nullable) NSMutableArray <NSNumber *> *lastIntensityArray;

@property (nonatomic, weak, readonly, nullable) EffectItem *availableItem;

#pragma mark Only for leaf item, maybe
@property (nonatomic, strong, readonly, nullable) ComposerNodeModel *model;

@property (nonatomic, assign) BOOL showIntensityBar;

@property (nonatomic, assign) BOOL enableNegative;

@property (nonatomic, assign) EffectUIKitTpye type;

@property (nonatomic, weak, nullable) EffectItem *parent;

@property (nonatomic, strong, nullable) NSArray<EffectItem *> *children;

@property (nonatomic, weak, readonly, nullable) NSArray<EffectItem *> *allChildren;

@property (nonatomic, strong, nullable) NSArray <EffectColorItem *> *colorset;

@property (nonatomic, weak, nullable) EffectColorItem *selectedColor;

@property (nonatomic, strong, nullable) EffectItem *selectChild;

@property (nonatomic, assign) BOOL enableMultiSelect;

@property (nonatomic, assign) BOOL reuseChildrenIntensity;

@property (nonatomic, weak, nullable) SelectableCell *cell;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) BOOL localSave;

@property (nonatomic, copy, nullable) NSString *resourcePath;

@property (nonatomic, readonly) BOOL hasIntensity;

@property(nonatomic, copy) void (^progressBlock)(CGFloat progress);

@property(nonatomic, copy) void (^completionBlock)(BOOL success, NSError *error);

- (void)updateProgress:(CGFloat)progress complete:(BOOL)complete;
@end



@interface EffectUIKitCategoryModel : NSObject

@property (nonatomic, readonly) EffectUIKitNode type;

@property (nonatomic, readonly, copy) NSString *title;

@property (nonatomic, strong, readonly) EffectItem *item;

+ (instancetype)categoryWithType:(EffectUIKitNode)type title:(NSString *)title item:(EffectItem *)item;

@end
NS_ASSUME_NONNULL_END
