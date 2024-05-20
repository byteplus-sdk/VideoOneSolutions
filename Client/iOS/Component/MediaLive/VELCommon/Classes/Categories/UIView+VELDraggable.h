// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VELDraggingMode) {
    VELDraggingModeDisabled,
    VELDraggingModeNormal,
    VELDraggingModeRevert,
    VELDraggingModePullOver,
    VELDraggingModeAdsorb,
};

@protocol VELDraggingDelegate <NSObject>

@optional
- (void)draggingDidBegan:(UIView *)view;
- (void)draggingDidChanged:(UIView *)view;
- (void)draggingDidEnded:(UIView *)view;

@end

@interface UIView (VELDraggable) <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <VELDraggingDelegate> vel_delegate;

@property (nonatomic, assign) VELDraggingMode vel_draggingMode;

@property(nonatomic, assign) BOOL vel_draggingInBounds;

@property (nonatomic, assign) UIEdgeInsets vel_edgeInsets;

- (void)vel_adsorbingAnimated:(BOOL)animated;

- (void)vel_pullOverAnimated:(BOOL)animated;

- (void)vel_revertAnimated:(BOOL)animated;

@end
