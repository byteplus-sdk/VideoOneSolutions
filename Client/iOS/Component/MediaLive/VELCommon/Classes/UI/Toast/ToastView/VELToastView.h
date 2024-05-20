// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELToastContentView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VELToastPosition) {
    VELToastPositionTop,
    VELToastPositionCenter,
    VELToastPositionBottom
};

@interface VELToastView : UIView
@property (nonatomic, assign) BOOL enableMaskControl;
@property (nonatomic, assign, getter=isLoadingView) BOOL loadingView;
@property(nonatomic, copy) void (^_Nullable didHideBlock)(VELToastView *toastView);
@property(nonatomic, copy) void (^_Nullable willHideBlock)(VELToastView *toastView);
- (nonnull instancetype)initWithContainer:(nonnull UIView *)container;
- (void)showWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;
@property(nonatomic, assign) VELToastPosition position;
@property(nonatomic, strong, readonly) VELToastContentView *contentView;
+ (BOOL)hideAllToastInView:(UIView * _Nullable)view animated:(BOOL)animated;
+ (void)hideAllLoadingInView:(UIView * _Nullable)view animated:(BOOL)animated;
+ (BOOL)hideAllToastInView:(UIView * _Nullable)view filter:(BOOL (^)(VELToastView *view))filter animated:(BOOL)animated;
+ (nullable NSArray <VELToastView *> *)allToastInView:(UIView *)view;
@end


NS_ASSUME_NONNULL_END
