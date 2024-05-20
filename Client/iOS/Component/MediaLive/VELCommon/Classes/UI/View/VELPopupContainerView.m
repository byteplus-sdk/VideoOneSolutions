// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPopupContainerView.h"
#import "VELUIViewController.h"
#import "VELUILabel.h"
#import "UIView+VELAdd.h"
#import "UIViewController+VELAdd.h"
#import "VELCommonDefine.h"
@interface VELPopupContainerViewWindow : UIWindow
@end

@interface VELPopContainerViewController : VELUIViewController
@end

@interface VELPopContainerMaskControl : UIControl
@property(nonatomic, weak) VELPopupContainerView *popupContainerView;
@end

@interface VELPopupContainerView () {
    UIImageView                     *_imageView;
    VELUILabel                         *_textLabel;
    
    CALayer                         *_backgroundViewMaskLayer;
    CAShapeLayer                    *_copiedBackgroundLayer;
    CALayer                         *_copiedArrowImageLayer;
}

@property(nonatomic, strong) VELPopupContainerViewWindow *popupWindow;
@property(nonatomic, weak) UIWindow *previousKeyWindow;
@property(nonatomic, assign) BOOL hidesByUserTap;
@end

@implementation VELPopupContainerView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _backgroundLayer = [CAShapeLayer layer];
        [_backgroundLayer removeAllAnimations];
        [self.layer addSublayer:_backgroundLayer];
        
        _contentView = [[UIView alloc] init];
        self.contentView.clipsToBounds = YES;
        [self addSubview:self.contentView];
        
        self.automaticallyHidesWhenUserTap = YES;
        self.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        self.arrowSize = CGSizeMake(18, 9);
        self.maximumWidth = CGFLOAT_MAX;
        self.minimumWidth = 30;
        self.maximumHeight = CGFLOAT_MAX;
        self.minimumHeight = 60;
        self.preferLayoutDirection = VELPopupLayoutDirectionAbove;
        self.distanceBetweenSource = 5;
        self.safetyMarginsOfSuperview = UIEdgeInsetsMake(10, 10, 10, 10);
        self.backgroundColor = UIColor.whiteColor;
        self.maskViewBackgroundColor = UIColor.clearColor;
        self.highlightedBackgroundColor = nil;
        self.shadowColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
        self.borderColor = [UIColor lightGrayColor];
        self.borderWidth = (1 / UIScreen.mainScreen.scale);
        self.cornerRadius = 10;
    }
    return self;
}

- (void)dealloc {
    _sourceView.vel_frameDidChangeBlock = nil;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (VELUILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[VELUILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.textColor = UIColor.blackColor;
        _textLabel.numberOfLines = 0;
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}
- (nullable UIViewController *)visibleViewController {
    UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *visibleViewController = [rootViewController vel_visibleViewController];
    return visibleViewController;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self.contentView) {
        return self;
    }
    return result;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_backgroundView && !backgroundView) {
        [_backgroundView removeFromSuperview];
    }
    _backgroundView = backgroundView;
    if (backgroundView) {
        [self insertSubview:backgroundView atIndex:0];
        [self sendSubviewToBack:_arrowImageView];
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
        if (!_backgroundViewMaskLayer) {
            _copiedBackgroundLayer = [CAShapeLayer layer];
            [_copiedBackgroundLayer removeAllAnimations];
            _copiedBackgroundLayer.fillColor = UIColor.blackColor.CGColor;
            
            _copiedArrowImageLayer = [CALayer layer];
            [_copiedArrowImageLayer removeAllAnimations];
            
            _backgroundViewMaskLayer = [CALayer layer];
            [_backgroundViewMaskLayer removeAllAnimations];
            [_backgroundViewMaskLayer addSublayer:_copiedBackgroundLayer];
            [_backgroundViewMaskLayer addSublayer:_copiedArrowImageLayer];
        }
        backgroundView.layer.mask = _backgroundViewMaskLayer;
    }
    _arrowImageView.hidden = backgroundView || !self.arrowImage;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    _backgroundLayer.fillColor = _backgroundColor.CGColor;
    _arrowImageView.tintColor = backgroundColor;
}

- (void)setMaskViewBackgroundColor:(UIColor *)maskViewBackgroundColor {
    _maskViewBackgroundColor = maskViewBackgroundColor;
    if (self.popupWindow) {
        self.popupWindow.rootViewController.view.backgroundColor = maskViewBackgroundColor;
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    _backgroundLayer.shadowColor = shadowColor.CGColor;
    if (shadowColor) {
        _backgroundLayer.shadowOffset = CGSizeMake(0, 2);
        _backgroundLayer.shadowOpacity = 1;
        _backgroundLayer.shadowRadius = 10;
    } else {
        _backgroundLayer.shadowOpacity = 0;
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    _backgroundLayer.strokeColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    _backgroundLayer.lineWidth = _borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (self.highlightedBackgroundColor) {
        UIColor *color = highlighted ? self.highlightedBackgroundColor : self.backgroundColor;
        _backgroundLayer.fillColor = color.CGColor;
        _arrowImageView.tintColor = color;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize contentLimitSize = [self contentSizeInSize:size];
    CGSize contentSize = CGSizeZero;
    contentSize = [self sizeThatFitsInContentView:contentLimitSize];
    CGSize resultSize = [self sizeWithContentSize:contentSize sizeThatFits:size];
    return resultSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL isUsingArrowImage = !!self.arrowImage;
    CGAffineTransform arrowImageTransform = CGAffineTransformIdentity;
    CGPoint arrowImagePosition = CGPointZero;
    
    CGSize arrowSize = self.arrowSizeAuto;
    CGRect roundedRect = CGRectMake(self.borderWidth / 2.0 + (self.currentLayoutDirection == VELPopupLayoutDirectionRight ? arrowSize.width : 0),
                                    self.borderWidth / 2.0 + (self.currentLayoutDirection == VELPopupLayoutDirectionBelow ? arrowSize.height : 0),
                                    CGRectGetWidth(self.bounds) - self.borderWidth - self.arrowSpacingInHorizontal,
                                    CGRectGetHeight(self.bounds) - self.borderWidth - self.arrowSpacingInVertical);
    CGFloat cornerRadius = self.cornerRadius;
    
    CGPoint leftTopArcCenter = CGPointMake(CGRectGetMinX(roundedRect) + cornerRadius, CGRectGetMinY(roundedRect) + cornerRadius);
    CGPoint leftBottomArcCenter = CGPointMake(leftTopArcCenter.x, CGRectGetMaxY(roundedRect) - cornerRadius);
    CGPoint rightTopArcCenter = CGPointMake(CGRectGetMaxX(roundedRect) - cornerRadius, leftTopArcCenter.y);
    CGPoint rightBottomArcCenter = CGPointMake(rightTopArcCenter.x, leftBottomArcCenter.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftTopArcCenter.x, CGRectGetMinY(roundedRect))];
    [path addArcWithCenter:leftTopArcCenter radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    
    if (self.currentLayoutDirection == VELPopupLayoutDirectionRight) {
        if (isUsingArrowImage) {
            arrowImageTransform = CGAffineTransformMakeRotation((M_PI * (0.5)));
            arrowImagePosition = CGPointMake(arrowSize.width / 2, _arrowMinY + arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), _arrowMinY)];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect) - arrowSize.width, _arrowMinY + arrowSize.height / 2)];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), _arrowMinY + arrowSize.height)];
        }
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), leftBottomArcCenter.y)];
    [path addArcWithCenter:leftBottomArcCenter radius:cornerRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
    
    if (self.currentLayoutDirection == VELPopupLayoutDirectionAbove) {
        if (isUsingArrowImage) {
            arrowImagePosition = CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetHeight(self.bounds) - arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(_arrowMinX, CGRectGetMaxY(roundedRect))];
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetMaxY(roundedRect) + arrowSize.height)];
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width, CGRectGetMaxY(roundedRect))];
        }
    }
    
    [path addLineToPoint:CGPointMake(rightBottomArcCenter.x, CGRectGetMaxY(roundedRect))];
    [path addArcWithCenter:rightBottomArcCenter radius:cornerRadius startAngle:M_PI * 0.5 endAngle:0.0 clockwise:NO];
    
    if (self.currentLayoutDirection == VELPopupLayoutDirectionLeft) {
        if (isUsingArrowImage) {
            arrowImageTransform = CGAffineTransformMakeRotation((M_PI * (-0.5)));
            arrowImagePosition = CGPointMake(CGRectGetWidth(self.bounds) - arrowSize.width / 2, _arrowMinY + arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), _arrowMinY + arrowSize.height)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect) + arrowSize.width, _arrowMinY + arrowSize.height / 2)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), _arrowMinY)];
        }
    }
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), rightTopArcCenter.y)];
    [path addArcWithCenter:rightTopArcCenter radius:cornerRadius startAngle:0.0 endAngle:M_PI * 1.5 clockwise:NO];
    
    if (self.currentLayoutDirection == VELPopupLayoutDirectionBelow) {
        if (isUsingArrowImage) {
            arrowImageTransform = CGAffineTransformMakeRotation(-M_PI);
            arrowImagePosition = CGPointMake(_arrowMinX + arrowSize.width / 2, arrowSize.height / 2);
        } else {
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width, CGRectGetMinY(roundedRect))];
            [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetMinY(roundedRect) - arrowSize.height)];
            [path addLineToPoint:CGPointMake(_arrowMinX, CGRectGetMinY(roundedRect))];
        }
    }
    [path closePath];
    
    _backgroundLayer.path = path.CGPath;
    _backgroundLayer.shadowPath = path.CGPath;
    _backgroundLayer.frame = self.bounds;
    
    if (isUsingArrowImage) {
        _arrowImageView.transform = arrowImageTransform;
        _arrowImageView.center = arrowImagePosition;
    }
    
    if (self.backgroundView) {
        self.backgroundView.frame = self.bounds;
        _backgroundViewMaskLayer.frame = self.bounds;
        
        _copiedBackgroundLayer.path = _backgroundLayer.path;
        _copiedBackgroundLayer.frame = _backgroundLayer.frame;
        
        _copiedArrowImageLayer.bounds = _arrowImageView.bounds;
        _copiedArrowImageLayer.affineTransform = arrowImageTransform;
        _copiedArrowImageLayer.position = arrowImagePosition;
        _copiedArrowImageLayer.contents = (id)_arrowImageView.image.CGImage;
        _copiedArrowImageLayer.contentsScale = _arrowImageView.image.scale;
    }
    
    [self layoutDefaultSubviews];
}

- (void)layoutDefaultSubviews {
    self.contentView.frame = CGRectMake(
                                        self.borderWidth + self.contentEdgeInsets.left + (self.currentLayoutDirection == VELPopupLayoutDirectionRight ? self.arrowSizeAuto.width : 0),
                                        self.borderWidth + self.contentEdgeInsets.top + (self.currentLayoutDirection == VELPopupLayoutDirectionBelow ? self.arrowSizeAuto.height : 0),
                                        CGRectGetWidth(self.bounds) - self.borderWidth * 2 - VELUIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) - self.arrowSpacingInHorizontal,
                                        CGRectGetHeight(self.bounds) - self.borderWidth * 2 - VELUIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) - self.arrowSpacingInVertical);
    CGFloat contentViewCornerRadius = fabs(MIN(CGRectGetMinX(self.contentView.frame) - self.cornerRadius, 0));
    self.contentView.layer.cornerRadius = contentViewCornerRadius;
    
    BOOL isImageViewShowing = [self isSubviewShowing:_imageView];
    BOOL isTextLabelShowing = [self isSubviewShowing:_textLabel];
    if (isImageViewShowing) {
        [_imageView sizeToFit];
        _imageView.frame = VELCGRectSetX(_imageView.frame, self.imageEdgeInsets.left);
        if (self.contentMode == UIViewContentModeTop) {
            _imageView.frame = VELCGRectSetY(_imageView.frame, self.imageEdgeInsets.top);
        } else if (self.contentMode == UIViewContentModeBottom) {
            _imageView.frame = VELCGRectSetY(_imageView.frame, CGRectGetHeight(self.contentView.bounds) - self.imageEdgeInsets.bottom - CGRectGetHeight(_imageView.frame));
        } else {
            _imageView.frame = VELCGRectSetY(_imageView.frame, self.imageEdgeInsets.top + VELCGFloatGetCenter(CGRectGetHeight(self.contentView.bounds), CGRectGetHeight(_imageView.frame)));
        }
    }
    if (isTextLabelShowing) {
        CGFloat textLabelMinX = (isImageViewShowing ? ceil(CGRectGetMaxX(_imageView.frame) + self.imageEdgeInsets.right) : 0) + self.textEdgeInsets.left;
        CGSize textLabelLimitSize = CGSizeMake(ceil(CGRectGetWidth(self.contentView.bounds) - textLabelMinX), ceil(CGRectGetHeight(self.contentView.bounds) - self.textEdgeInsets.top - self.textEdgeInsets.bottom));
        CGSize textLabelSize = [_textLabel sizeThatFits:textLabelLimitSize];
        _textLabel.frame = CGRectMake(textLabelMinX, 0, textLabelLimitSize.width, ceil(textLabelSize.height));
        if (self.contentMode == UIViewContentModeTop) {
            _textLabel.frame = VELCGRectSetY(_textLabel.frame, self.textEdgeInsets.top);
        } else if (self.contentMode == UIViewContentModeBottom) {
            _textLabel.frame = VELCGRectSetY(_textLabel.frame, CGRectGetHeight(self.contentView.bounds) - self.textEdgeInsets.bottom - CGRectGetHeight(_textLabel.frame));
        } else {
            _textLabel.frame = VELCGRectSetY(_textLabel.frame, self.textEdgeInsets.top + VELCGFloatGetCenter(CGRectGetHeight(self.contentView.bounds), CGRectGetHeight(_textLabel.frame)));
        }
    }
}

- (void)setSourceView:(__kindof UIView *)sourceView {
    _sourceView = sourceView;
    __weak __typeof(self)weakSelf = self;
    sourceView.vel_frameDidChangeBlock = ^(__kindof UIView * _Nonnull view, CGRect precedingFrame) {
        if (!view.window || !weakSelf.superview) return;
        UIView *convertToView = weakSelf.popupWindow ? UIApplication.sharedApplication.delegate.window : weakSelf.superview;
        CGRect rect = [view vel_convertRect:view.bounds toView:convertToView];
        weakSelf.sourceRect = rect;
    };
    sourceView.vel_frameDidChangeBlock(sourceView, sourceView.frame);
}

- (void)setSourceRect:(CGRect)sourceRect {
    _sourceRect = sourceRect;
    if (self.isShowing) {
        [self layoutWithTargetRect:sourceRect];
    }
}

- (void)updateLayout {
    if (self.sourceView) {
        self.sourceView = self.sourceView;
    } else {
        self.sourceRect = self.sourceRect;
    }
}

- (void)layoutWithTargetRect:(CGRect)targetRect {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    }
    
    _currentLayoutDirection = self.preferLayoutDirection;
    targetRect = self.popupWindow ? [self.popupWindow convertRect:targetRect toView:superview] : targetRect;
    CGRect containerRect = superview.bounds;
    
    CGSize (^sizeToFitBlock)(void) = ^CGSize(void) {
        CGSize result = CGSizeZero;
        if (self.isVerticalLayoutDirection) {
            result.width = CGRectGetWidth(containerRect) - VELUIEdgeInsetsGetHorizontalValue(self.safetyMarginsAvoidSafeAreaInsets);
        } else if (self.currentLayoutDirection == VELPopupLayoutDirectionLeft) {
            result.width = CGRectGetMinX(targetRect) - self.distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.left;
        } else if (self.currentLayoutDirection == VELPopupLayoutDirectionRight) {
            result.width = CGRectGetWidth(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right - self.distanceBetweenSource - CGRectGetMaxX(targetRect);
        }
        if (self.isHorizontalLayoutDirection) {
            result.height = CGRectGetHeight(containerRect) - VELUIEdgeInsetsGetVerticalValue(self.safetyMarginsAvoidSafeAreaInsets);
        } else if (self.currentLayoutDirection == VELPopupLayoutDirectionAbove) {
            result.height = CGRectGetMinY(targetRect) - self.distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.top;
        } else if (self.currentLayoutDirection == VELPopupLayoutDirectionBelow) {
            result.height = CGRectGetHeight(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom - self.distanceBetweenSource - CGRectGetMaxY(targetRect);
        }
        result = CGSizeMake(MIN(self.maximumWidth, result.width), MIN(self.maximumHeight, result.height));
        return result;
    };
    
    
    CGSize tipSize = [self sizeThatFits:sizeToFitBlock()];
    CGFloat preferredTipWidth = tipSize.width;
    CGFloat preferredTipHeight = tipSize.height;
    CGFloat tipMinX = 0;
    CGFloat tipMinY = 0;
    
    if (self.isVerticalLayoutDirection) {
        CGFloat a = CGRectGetMidX(targetRect) - tipSize.width / 2;
        tipMinX = MAX(CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left, a);
        
        CGFloat tipMaxX = tipMinX + tipSize.width;
        if (tipMaxX + self.safetyMarginsAvoidSafeAreaInsets.right > CGRectGetMaxX(containerRect)) {
            CGFloat distanceCanMoveToLeft = tipMaxX - (CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right);
            if (tipMinX - distanceCanMoveToLeft >= CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left) {
                tipMinX -= distanceCanMoveToLeft;
            } else {
                tipMinX = CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left;
                tipMaxX = CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right;
                tipSize.width = MIN(tipSize.width, tipMaxX - tipMinX);
            }
        }
        BOOL tipWidthChanged = tipSize.width != preferredTipWidth;
        if (tipWidthChanged) {
            tipSize = [self sizeThatFits:tipSize];
        }
        
        BOOL canShowAtAbove = [self canTipShowAtSpecifiedLayoutDirect:VELPopupLayoutDirectionAbove targetRect:targetRect tipSize:tipSize];
        BOOL canShowAtBelow = [self canTipShowAtSpecifiedLayoutDirect:VELPopupLayoutDirectionBelow targetRect:targetRect tipSize:tipSize];
        
        if (!canShowAtAbove && !canShowAtBelow) {
            CGFloat maximumHeightAbove = CGRectGetMinY(targetRect) - CGRectGetMinY(containerRect) - self.distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.top;
            CGFloat maximumHeightBelow = CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom - self.distanceBetweenSource - CGRectGetMaxY(targetRect);
            self.maximumHeight = MAX(self.minimumHeight, MAX(maximumHeightAbove, maximumHeightBelow));
            tipSize.height = self.maximumHeight;
            _currentLayoutDirection = maximumHeightAbove > maximumHeightBelow ? VELPopupLayoutDirectionAbove : VELPopupLayoutDirectionBelow;
            
        } else if (_currentLayoutDirection == VELPopupLayoutDirectionAbove && !canShowAtAbove) {
            _currentLayoutDirection = VELPopupLayoutDirectionBelow;
            tipSize.height = [self sizeThatFits:CGSizeMake(tipSize.width, sizeToFitBlock().height)].height;
        } else if (_currentLayoutDirection == VELPopupLayoutDirectionBelow && !canShowAtBelow) {
            _currentLayoutDirection = VELPopupLayoutDirectionAbove;
            tipSize.height = [self sizeThatFits:CGSizeMake(tipSize.width, sizeToFitBlock().height)].height;
        }
        
        tipMinY = [self tipOriginWithTargetRect:targetRect tipSize:tipSize preferLayoutDirection:_currentLayoutDirection].y;
        
        if (_currentLayoutDirection == VELPopupLayoutDirectionAbove) {
            CGFloat tipMinYIfAlignSafetyMarginTop = CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top;
            tipMinY = MAX(tipMinY, tipMinYIfAlignSafetyMarginTop);
        } else if (_currentLayoutDirection == VELPopupLayoutDirectionBelow) {
            CGFloat tipMinYIfAlignSafetyMarginBottom = CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom - tipSize.height;
            tipMinY = MIN(tipMinY, tipMinYIfAlignSafetyMarginBottom);
        }
        
        self.frame = VELCGRectFlatMake(tipMinX, tipMinY, tipSize.width, tipSize.height);
        
        CGPoint targetRectCenter = VELCGPointGetCenterWithRect(targetRect);
        CGFloat selfMidX = targetRectCenter.x - CGRectGetMinX(self.frame);
        _arrowMinX = selfMidX - self.arrowSizeAuto.width / 2;
    } else {
        CGFloat a = CGRectGetMidY(targetRect) - tipSize.height / 2;
        tipMinY = MAX(CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top, a);
        
        CGFloat tipMaxY = tipMinY + tipSize.height;
        if (tipMaxY + self.safetyMarginsAvoidSafeAreaInsets.bottom > CGRectGetMaxY(containerRect)) {
            CGFloat distanceCanMoveToTop = tipMaxY - (CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom);
            if (tipMinY - distanceCanMoveToTop >= CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top) {
                tipMinY -= distanceCanMoveToTop;
            } else {
                tipMinY = CGRectGetMinY(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.top;
                tipMaxY = CGRectGetMaxY(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.bottom;
                tipSize.height = MIN(tipSize.height, tipMaxY - tipMinY);
            }
        }
        
        BOOL tipHeightChanged = tipSize.height != preferredTipHeight;
        if (tipHeightChanged) {
            tipSize = [self sizeThatFits:tipSize];
        }
        
        BOOL canShowAtLeft = [self canTipShowAtSpecifiedLayoutDirect:VELPopupLayoutDirectionLeft targetRect:targetRect tipSize:tipSize];
        BOOL canShowAtRight = [self canTipShowAtSpecifiedLayoutDirect:VELPopupLayoutDirectionRight targetRect:targetRect tipSize:tipSize];
        
        if (!canShowAtLeft && !canShowAtRight) {
            CGFloat maximumWidthLeft = CGRectGetMinX(targetRect) - CGRectGetMinX(containerRect) - self.distanceBetweenSource - self.safetyMarginsAvoidSafeAreaInsets.left;
            CGFloat maximumWidthRight = CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right - self.distanceBetweenSource - CGRectGetMaxX(targetRect);
            self.maximumWidth = MAX(self.minimumWidth, MAX(maximumWidthLeft, maximumWidthRight));
            tipSize.width = self.maximumWidth;
            _currentLayoutDirection = maximumWidthLeft > maximumWidthRight ? VELPopupLayoutDirectionLeft : VELPopupLayoutDirectionRight;
            
            
        } else if (_currentLayoutDirection == VELPopupLayoutDirectionLeft && !canShowAtLeft) {
            _currentLayoutDirection = VELPopupLayoutDirectionRight;
            tipSize.width = [self sizeThatFits:CGSizeMake(sizeToFitBlock().width, tipSize.height)].width;
        } else if (_currentLayoutDirection == VELPopupLayoutDirectionRight && !canShowAtRight) {
            _currentLayoutDirection = VELPopupLayoutDirectionLeft;
            tipSize.width = [self sizeThatFits:CGSizeMake(sizeToFitBlock().width, tipSize.height)].width;
        }
        
        tipMinX = [self tipOriginWithTargetRect:targetRect tipSize:tipSize preferLayoutDirection:_currentLayoutDirection].x;
        
        if (_currentLayoutDirection == VELPopupLayoutDirectionLeft) {
            CGFloat tipMinXIfAlignSafetyMarginLeft = CGRectGetMinX(containerRect) + self.safetyMarginsAvoidSafeAreaInsets.left;
            tipMinX = MAX(tipMinX, tipMinXIfAlignSafetyMarginLeft);
        } else if (_currentLayoutDirection == VELPopupLayoutDirectionRight) {
            CGFloat tipMinXIfAlignSafetyMarginRight = CGRectGetMaxX(containerRect) - self.safetyMarginsAvoidSafeAreaInsets.right - tipSize.width;
            tipMinX = MIN(tipMinX, tipMinXIfAlignSafetyMarginRight);
        }
        
        self.frame = VELCGRectFlatMake(tipMinX, tipMinY, tipSize.width, tipSize.height);
        
        CGPoint targetRectCenter = VELCGPointGetCenterWithRect(targetRect);
        CGFloat selfMidY = targetRectCenter.y - CGRectGetMinY(self.frame);
        _arrowMinY = selfMidY - self.arrowSizeAuto.height / 2;
    }
    
    [self setNeedsLayout];
}

- (CGPoint)tipOriginWithTargetRect:(CGRect)itemRect tipSize:(CGSize)tipSize preferLayoutDirection:(VELPopupLayoutDirection)direction {
    CGPoint tipOrigin = CGPointZero;
    switch (direction) {
        case VELPopupLayoutDirectionAbove:
            tipOrigin.y = CGRectGetMinY(itemRect) - tipSize.height - self.distanceBetweenSource;
            break;
        case VELPopupLayoutDirectionBelow:
            tipOrigin.y = CGRectGetMaxY(itemRect) + self.distanceBetweenSource;
            break;
        case VELPopupLayoutDirectionLeft:
            tipOrigin.x = CGRectGetMinX(itemRect) - tipSize.width - self.distanceBetweenSource;
            break;
        case VELPopupLayoutDirectionRight:
            tipOrigin.x = CGRectGetMaxX(itemRect) + self.distanceBetweenSource;
            break;
        default:
            break;
    }
    return tipOrigin;
}

- (BOOL)canTipShowAtSpecifiedLayoutDirect:(VELPopupLayoutDirection)direction targetRect:(CGRect)itemRect tipSize:(CGSize)tipSize {
    BOOL canShow = NO;
    if (self.isVerticalLayoutDirection) {
        CGFloat tipMinY = [self tipOriginWithTargetRect:itemRect tipSize:tipSize preferLayoutDirection:direction].y;
        if (direction == VELPopupLayoutDirectionAbove) {
            canShow = tipMinY >= self.safetyMarginsAvoidSafeAreaInsets.top;
        } else if (direction == VELPopupLayoutDirectionBelow) {
            canShow = tipMinY + tipSize.height + self.safetyMarginsAvoidSafeAreaInsets.bottom <= CGRectGetHeight(self.superview.bounds);
        }
    } else {
        CGFloat tipMinX = [self tipOriginWithTargetRect:itemRect tipSize:tipSize preferLayoutDirection:direction].x;
        if (direction == VELPopupLayoutDirectionLeft) {
            canShow = tipMinX >= self.safetyMarginsAvoidSafeAreaInsets.left;
        } else if (direction == VELPopupLayoutDirectionRight) {
            canShow = tipMinX + tipSize.width + self.safetyMarginsAvoidSafeAreaInsets.right <= CGRectGetWidth(self.superview.bounds);
        }
    }
    
    return canShow;
}

- (void)showWithAnimated:(BOOL)animated {
    [self showWithAnimated:animated completion:nil];
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    BOOL isShowingByWindowMode = NO;
    if (!self.superview) {
        [self initPopupContainerViewWindowIfNeeded];
        
        VELUIViewController *viewController = (VELUIViewController *)self.popupWindow.rootViewController;
        viewController.supportedOrientationMask = [self visibleViewController].supportedInterfaceOrientations;
        
        self.previousKeyWindow = UIApplication.sharedApplication.keyWindow;
        [self.popupWindow makeKeyAndVisible];
        
        isShowingByWindowMode = YES;
    } else {
        self.hidden = NO;
    }
    
    [self updateLayout];
    
    if (self.willShowBlock) {
        self.willShowBlock(animated);
    }
    
    if (animated) {
        if (isShowingByWindowMode) {
            self.popupWindow.alpha = 0;
        } else {
            self.alpha = 0;
        }
        self.layer.transform = CATransform3DMakeScale(0.98, 0.98, 1);
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:12 options:UIViewAnimationOptionCurveLinear animations:^{
            self.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            if (isShowingByWindowMode) {
                self.popupWindow.alpha = 1;
            } else {
                self.alpha = 1;
            }
        } completion:nil];
    } else {
        if (isShowingByWindowMode) {
            self.popupWindow.alpha = 1;
        } else {
            self.alpha = 1;
        }
        if (completion) {
            completion(YES);
        }
    }
}

- (void)hideWithAnimated:(BOOL)animated {
    [self hideWithAnimated:animated completion:nil];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (self.willHideBlock) {
        self.willHideBlock(self.hidesByUserTap, animated);
    }
    
    BOOL isShowingByWindowMode = !!self.popupWindow;
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            if (isShowingByWindowMode) {
                self.popupWindow.alpha = 0;
            } else {
                self.alpha = 0;
            }
        } completion:^(BOOL finished) {
            [self hideCompletionWithWindowMode:isShowingByWindowMode completion:completion];
        }];
    } else {
        [self hideCompletionWithWindowMode:isShowingByWindowMode completion:completion];
    }
}

- (void)hideCompletionWithWindowMode:(BOOL)windowMode completion:(void (^)(BOOL))completion {
    if (windowMode) {
        if (UIApplication.sharedApplication.keyWindow == self.popupWindow) {
            [self.previousKeyWindow makeKeyWindow];
        }
        [self removeFromSuperview];
        self.popupWindow.rootViewController = nil;
        
        self.popupWindow.hidden = YES;
        self.popupWindow = nil;
    } else {
        self.hidden = YES;
    }
    if (completion) {
        completion(YES);
    }
    if (self.didHideBlock) {
        self.didHideBlock(self.hidesByUserTap);
    }
    self.hidesByUserTap = NO;
}

- (BOOL)isShowing {
    BOOL isShowingIfAddedToView = self.superview && !self.hidden && !self.popupWindow;
    BOOL isShowingIfInWindow = self.superview && self.popupWindow && !self.popupWindow.hidden;
    return isShowingIfAddedToView || isShowingIfInWindow;
}

- (BOOL)isSubviewShowing:(UIView *)subview {
    return subview && !subview.hidden && subview.superview;
}

- (void)initPopupContainerViewWindowIfNeeded {
    if (!self.popupWindow) {
        self.popupWindow = [[VELPopupContainerViewWindow alloc] init];
        self.popupWindow.backgroundColor = UIColor.clearColor;
        self.popupWindow.windowLevel = UIWindowLevelAlert - 4.0;
        VELPopContainerViewController *viewController = [[VELPopContainerViewController alloc] init];
        if (@available(iOS 11.0, *)) {
            
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            viewController.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
        }
        viewController.showNavigationBar = NO;
        ((VELPopContainerMaskControl *)viewController.view).popupContainerView = self;
        if (self.automaticallyHidesWhenUserTap) {
            viewController.view.backgroundColor = self.maskViewBackgroundColor;
        } else {
            viewController.view.backgroundColor = [UIColor clearColor];
        }
        viewController.supportedOrientationMask = [self visibleViewController].supportedInterfaceOrientations;
        self.popupWindow.rootViewController = viewController;
        [self.popupWindow.rootViewController.view addSubview:self];
    }
}

- (CGSize)contentSizeInSize:(CGSize)size {
    CGSize contentSize = CGSizeMake(size.width - VELUIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) - self.borderWidth * 2 - self.arrowSpacingInHorizontal, size.height - VELUIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) - self.borderWidth * 2 - self.arrowSpacingInVertical);
    return contentSize;
}

- (CGSize)sizeWithContentSize:(CGSize)contentSize sizeThatFits:(CGSize)sizeThatFits {
    CGFloat resultWidth = contentSize.width + VELUIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + self.borderWidth * 2 + self.arrowSpacingInHorizontal;
    resultWidth = MAX(MIN(resultWidth, self.maximumWidth), self.minimumWidth);
    resultWidth = ceil(resultWidth);
    
    CGFloat resultHeight = contentSize.height + VELUIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) + self.borderWidth * 2 + self.arrowSpacingInVertical;
    resultHeight = MAX(MIN(resultHeight, self.maximumHeight), self.minimumHeight);
    resultHeight = ceil(resultHeight);
    
    return CGSizeMake(resultWidth, resultHeight);
}

- (BOOL)isHorizontalLayoutDirection {
    return self.preferLayoutDirection == VELPopupLayoutDirectionLeft || self.preferLayoutDirection == VELPopupLayoutDirectionRight;
}

- (BOOL)isVerticalLayoutDirection {
    return self.preferLayoutDirection == VELPopupLayoutDirectionAbove || self.preferLayoutDirection == VELPopupLayoutDirectionBelow;
}

- (void)setArrowImage:(UIImage *)arrowImage {
    _arrowImage = arrowImage;
    if (arrowImage) {
        _arrowSize = arrowImage.size;
        
        if (!_arrowImageView) {
            _arrowImageView = UIImageView.new;
            _arrowImageView.tintColor = self.backgroundColor;
            [self addSubview:_arrowImageView];
        }
        _arrowImageView.hidden = !!self.backgroundView;
        _arrowImageView.image = arrowImage;
        _arrowImageView.bounds = VELCGRectMakeWithSize(arrowImage.size);
    } else {
        _arrowImageView.hidden = YES;
        _arrowImageView.image = nil;
    }
}

- (void)setArrowSize:(CGSize)arrowSize {
    if (!self.arrowImage) {
        _arrowSize = arrowSize;
    }
}
- (CGSize)arrowSizeAuto {
    return self.isHorizontalLayoutDirection ? CGSizeMake(self.arrowSize.height, self.arrowSize.width) : self.arrowSize;
}

- (CGFloat)arrowSpacingInHorizontal {
    return self.isHorizontalLayoutDirection ? self.arrowSizeAuto.width : 0;
}

- (CGFloat)arrowSpacingInVertical {
    return self.isVerticalLayoutDirection ? self.arrowSizeAuto.height : 0;
}

- (UIEdgeInsets)safetyMarginsAvoidSafeAreaInsets {
    UIEdgeInsets result = self.safetyMarginsOfSuperview;
    if (@available(iOS 11.0, *)) {
        if (self.isHorizontalLayoutDirection) {
            result.left += self.superview.safeAreaInsets.left;
            result.right += self.superview.safeAreaInsets.right;
        } else {
            result.top += self.superview.safeAreaInsets.top;
            result.bottom += self.superview.safeAreaInsets.bottom;
        }
    }
    return result;
}


- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    if (![self isSubviewShowing:_imageView] && ![self isSubviewShowing:_textLabel]) {
        CGSize selfSize = [self contentSizeInSize:self.bounds.size];
        return selfSize;
    }
    
    CGSize resultSize = CGSizeZero;
    
    BOOL isImageViewShowing = [self isSubviewShowing:_imageView];
    if (isImageViewShowing) {
        CGSize imageViewSize = [_imageView sizeThatFits:size];
        resultSize.width += ceil(imageViewSize.width) + self.imageEdgeInsets.left;
        resultSize.height += ceil(imageViewSize.height) + self.imageEdgeInsets.top;
    }
    
    BOOL isTextLabelShowing = [self isSubviewShowing:_textLabel];
    if (isTextLabelShowing) {
        CGSize textLabelLimitSize = CGSizeMake(size.width - resultSize.width - self.imageEdgeInsets.right, size.height);
        CGSize textLabelSize = [_textLabel sizeThatFits:textLabelLimitSize];
        resultSize.width += (isImageViewShowing ? self.imageEdgeInsets.right : 0) + ceil(textLabelSize.width) + self.textEdgeInsets.left;
        resultSize.height = MAX(resultSize.height, ceil(textLabelSize.height) + self.textEdgeInsets.top);
    }
    return resultSize;
}

@end


@implementation VELPopContainerViewController

- (void)loadView {
    VELPopContainerMaskControl *maskControl = [[VELPopContainerMaskControl alloc] init];
    self.view = maskControl;
}

@end

@implementation VELPopContainerMaskControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(handleMaskEvent:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        if (!self.popupContainerView.automaticallyHidesWhenUserTap) {
            return nil;
        }
    }
    return result;
}

- (void)handleMaskEvent:(id)sender {
    if (self.popupContainerView.automaticallyHidesWhenUserTap) {
        self.popupContainerView.hidesByUserTap = YES;
        [self.popupContainerView hideWithAnimated:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.popupContainerView updateLayout];
}

@end

@implementation VELPopupContainerViewWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        return nil;
    }
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rootViewController.view.frame = self.bounds;
}
@end
