// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELUILabel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VELPopupLayoutDirection) {
    VELPopupLayoutDirectionAbove,
    VELPopupLayoutDirectionBelow,
    VELPopupLayoutDirectionLeft,
    VELPopupLayoutDirectionRight
};

@interface VELPopupContainerView : UIControl {
    CAShapeLayer    *_backgroundLayer;
    UIImageView     *_arrowImageView;
    CGFloat         _arrowMinX;
    CGFloat         _arrowMinY;
}

@property(nonatomic, assign) BOOL automaticallyHidesWhenUserTap;
@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, strong, readonly, nullable) UIImageView *imageView;
@property(nonatomic, strong, readonly, nullable) VELUILabel *textLabel;
@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets imageEdgeInsets;
@property(nonatomic, assign) UIEdgeInsets textEdgeInsets;
@property(nonatomic, assign) CGSize arrowSize;
@property(nonatomic, strong, nullable) UIImage *arrowImage;
@property(nonatomic, assign) CGFloat maximumWidth;
@property(nonatomic, assign) CGFloat minimumWidth;
@property(nonatomic, assign) CGFloat maximumHeight;
@property(nonatomic, assign) CGFloat minimumHeight;
@property(nonatomic, assign) VELPopupLayoutDirection preferLayoutDirection;
@property(nonatomic, assign, readonly) VELPopupLayoutDirection currentLayoutDirection;
@property(nonatomic, assign) CGFloat distanceBetweenSource;
@property(nonatomic, assign) UIEdgeInsets safetyMarginsOfSuperview;
@property(nonatomic, strong, nullable) UIView *backgroundView;
@property(nonatomic, strong, nullable) UIColor *backgroundColor;
@property(nonatomic, strong, nullable) UIColor *highlightedBackgroundColor;
@property(nonatomic, strong, nullable) UIColor *maskViewBackgroundColor;
@property(nonatomic, strong, nullable) UIColor *shadowColor;
@property(nonatomic, strong, nullable) UIColor *borderColor;
@property(nonatomic, assign) CGFloat borderWidth;
@property(nonatomic, assign) CGFloat cornerRadius;
@property(nonatomic, weak, nullable) __kindof UIView *sourceView;
@property(nonatomic, assign) CGRect sourceRect;
@property(nonatomic, copy, nullable) void (^willShowBlock)(BOOL animated);
@property(nonatomic, copy, nullable) void (^willHideBlock)(BOOL hidesByUserTap, BOOL animated);
@property(nonatomic, copy, nullable) void (^didHideBlock)(BOOL hidesByUserTap);
- (void)updateLayout;
- (void)showWithAnimated:(BOOL)animated;
- (void)showWithAnimated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
- (void)hideWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^ __nullable)(BOOL finished))completion;
- (BOOL)isShowing;
- (CGSize)sizeThatFitsInContentView:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
