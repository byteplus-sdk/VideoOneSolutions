// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

@interface UIView (VELLayout)

/// self.frame.origin.y
@property (nonatomic, assign) CGFloat vel_top;

/// self.frame.origin.y + self.frame.size.height
@property (nonatomic, assign) CGFloat vel_bottom;

/// self.frame.origin.x
@property (nonatomic, assign) CGFloat vel_left;

/// self.frame.origin.x + self.frame.size.width
@property (nonatomic, assign) CGFloat vel_right;

/// self.frame.size.width
@property (nonatomic, assign) CGFloat vel_width;

/// self.frame.size.height
@property (nonatomic, assign) CGFloat vel_height;

/// self.center.x
@property (nonatomic, assign) CGFloat vel_centerX;

/// self.center.y
@property (nonatomic, assign) CGFloat vel_centerY;

/// self.frame.size
@property (nonatomic, assign) CGSize vel_size;

/// self.frame.origin
@property (nonatomic, assign) CGPoint vel_origin;
/// - Parameters:
- (void)vel_roundRect:(UIRectCorner)corners withSize:(CGSize)size;
- (CGRect)vel_convertRect:(CGRect)rect toView:(nullable UIView *)view;
- (CGRect)vel_convertRect:(CGRect)rect fromView:(nullable UIView *)view;
- (BOOL)vel_visible;
- (void)vel_removeAllSubviews;


/**
 Takes a screenshot of the underlying `CALayer` of the receiver and returns a `UIImage` object representation.
 
 @return An image representing the receiver
 */
- (UIImage *)imageRepresentation;

@property (assign,nonatomic) CGFloat frameX;
@property (assign,nonatomic) CGFloat frameY;
@property (assign,nonatomic) CGFloat frameW;
@property (assign,nonatomic) CGFloat frameH;
/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat centerY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

- (void)removeAllSubviews;
@end

@interface UIView (VELLayoutBlock)
@property(nullable, nonatomic, copy) CGRect (^vel_frameWillChangeBlock)(__kindof UIView *view, CGRect followingFrame);
@property(nullable, nonatomic, copy) void (^vel_frameDidChangeBlock)(__kindof UIView *view, CGRect precedingFrame);
@property(nullable, nonatomic, copy) void (^vel_layoutSubviewsBlock)(__kindof UIView *view);
@property(nullable, nonatomic, copy) CGSize (^vel_sizeThatFitsBlock)(__kindof UIView *view, CGSize size, CGSize superResult);
@property(nullable, nonatomic, copy) __kindof UIView * (^vel_hitTestBlock)(CGPoint point, UIEvent *event, __kindof UIView *originalView);
@end
