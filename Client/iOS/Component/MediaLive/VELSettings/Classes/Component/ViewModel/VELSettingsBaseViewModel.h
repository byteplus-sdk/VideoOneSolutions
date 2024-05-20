// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VELSettingsBaseViewModel;
@protocol VELSettingsUIViewProtocol <NSObject>
@property (nonatomic, strong) __kindof VELSettingsBaseViewModel *model;
@property (nonatomic, assign) BOOL enable;
@end

FOUNDATION_EXPORT const NSString *VELExtraInfoKeyClass;
FOUNDATION_EXPORT const CGFloat VELEqualToSuper;
FOUNDATION_EXPORT const CGFloat VELAutomaticDimension;

@interface VELSettingsBaseViewModel : NSObject
@property (nonatomic, assign) BOOL showVisualEffect;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL useCellSelect;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL showDisableMask;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *containerBackgroundColor;
@property (nonatomic, strong) UIColor *containerSelectBackgroundColor;
@property (nonatomic, assign) BOOL hasBorder;
@property (nonatomic, strong, nullable) UIColor *borderColor;
@property (nonatomic, strong, nullable) UIColor *selectedBorderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) BOOL hasShadow;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, assign) CGSize size;
/// CGSizeMake(self.size.width - VELUIEdgeInsetsGetHorizontalValue(self.insets) - VELUIEdgeInsetsGetHorizontalValue(self.margin),
/// self.size.height - VELUIEdgeInsetsGetVerticalValue(self.insets) - VELUIEdgeInsetsGetHorizontalValue(self.margin));
@property (nonatomic, assign, readonly) CGSize containerSize;
@property (nonatomic, strong, readonly) NSMutableDictionary *extraInfo;
@property(nonatomic, weak, readonly) UIView <VELSettingsUIViewProtocol> *settingView;
@property (nonatomic, copy) void (^selectedBlock)(__kindof VELSettingsBaseViewModel *model, NSInteger index);
@property (nonatomic, copy, readonly) NSString *identifier;
- (Class <VELSettingsUIViewProtocol>)collectionCellClass;
+ (Class <VELSettingsUIViewProtocol>)collectionCellClass;
- (Class <VELSettingsUIViewProtocol>)tableViewCellClass;
+ (Class <VELSettingsUIViewProtocol>)tableViewCellClass;
- (void)syncSettings:(__kindof VELSettingsBaseViewModel *)model;
- (UIView <VELSettingsUIViewProtocol> *)createSettingsViewFor:(nullable NSString *)identifier;
- (void)updateUI;
- (void)clearDefault;
@end

NS_ASSUME_NONNULL_END
