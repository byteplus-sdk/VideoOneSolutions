// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VELUIButtonImagePosition) {
    VELUIButtonImagePositionTop,
    VELUIButtonImagePositionLeft,
    VELUIButtonImagePositionBottom,
    VELUIButtonImagePositionRight,
};

typedef NS_ENUM(NSInteger, VELUIButtonStatus) {
    VELUIButtonStatusNone,
    VELUIButtonStatusActive,
    VELUIButtonStatusIng,
    VELUIButtonStatusIllegal,
};

UIKIT_EXTERN const CGFloat VELUIButtonCornerRadiusAdjustsBounds;
@interface VELUIButton : UIButton
@property (nonatomic, assign) CGSize imageSize;

@property(nonatomic, assign) VELUIButtonImagePosition imagePosition;

@property(nonatomic, strong, nullable) UIColor *highlightedBackgroundColor;
@property(nonatomic, strong, nullable) UIColor *highlightedBorderColor;
@property(nonatomic, assign) BOOL adjustsButtonWhenHighlighted;
@property(nonatomic, assign) CGFloat spacingBetweenImageAndTitle;
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) VELUIButtonStatus status;

- (void)bingImage:(UIImage *)image status:(VELUIButtonStatus)status;
@end

NS_ASSUME_NONNULL_END
