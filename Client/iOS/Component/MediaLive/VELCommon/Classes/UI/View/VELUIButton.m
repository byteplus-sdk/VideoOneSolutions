// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUIButton.h"
#import "VELCommonDefine.h"
const CGFloat VELUIButtonCornerRadiusAdjustsBounds = -1;

@interface VELUIButton ()
@property (nonatomic, strong) NSMutableDictionary *bingDic;
@property(nonatomic, strong) CALayer *highlightedBackgroundLayer;
@property(nonatomic, strong) UIColor *originBorderColor;
@end

@implementation VELUIButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        self.contentEdgeInsets = UIEdgeInsetsMake(CGFLOAT_MIN, 0, CGFLOAT_MIN, 0);
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    self.imagePosition = VELUIButtonImagePositionLeft;
    self.imageSize = CGSizeMake(-1, -1);
}

- (BOOL)__vel_imageSizeValid {
    return self.imageSize.width > 0 && self.imageSize.height > 0;
}
- (UIImageView *)_vel_imageView {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:NSSelectorFromString(@"_imageView")];
#pragma clang diagnostic pop
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (CGSizeEqualToSize(self.bounds.size, size) || size.width <= 0 || size.height <= 0) {
        size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    
    BOOL isImageViewShowing = !!self.currentImage;
    BOOL isTitleLabelShowing = !!self.currentTitle || self.currentAttributedTitle;
    CGSize imageTotalSize = CGSizeZero;
    CGSize titleTotalSize = CGSizeZero;
    CGFloat spacingBetweenImageAndTitle = VELCGFloatFlatted(isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0);
    UIEdgeInsets contentEdgeInsets = VELUIEdgeInsetsRemoveFloatMin(self.contentEdgeInsets);
    CGSize resultSize = CGSizeZero;
    CGSize contentLimitSize = CGSizeMake(size.width - VELUIEdgeInsetsGetHorizontalValue(contentEdgeInsets), size.height - VELUIEdgeInsetsGetVerticalValue(contentEdgeInsets));
    
    switch (self.imagePosition) {
        case VELUIButtonImagePositionTop:
        case VELUIButtonImagePositionBottom: {
            if (isImageViewShowing) {
                CGSize imageSize = CGSizeZero;
                if ([self __vel_imageSizeValid]) {
                    imageSize = self.imageSize;
                } else {
                    CGFloat imageLimitWidth = contentLimitSize.width - VELUIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
                    imageSize = self.imageView.image ? [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)] : self.currentImage.size;
                    imageSize.width = MIN(imageSize.width, imageLimitWidth);
                }
                imageTotalSize = CGSizeMake(imageSize.width + VELUIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
            }
            
            if (isTitleLabelShowing) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = MIN(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            }
            
            resultSize.width = VELUIEdgeInsetsGetHorizontalValue(contentEdgeInsets);
            resultSize.width += MAX(imageTotalSize.width, titleTotalSize.width);
            resultSize.height = VELUIEdgeInsetsGetVerticalValue(contentEdgeInsets) + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height;
        }
            break;
            
        case VELUIButtonImagePositionLeft:
        case VELUIButtonImagePositionRight: {
            if (isImageViewShowing) {
                CGSize imageSize = CGSizeZero;
                if ([self __vel_imageSizeValid]) {
                    imageSize = self.imageSize;
                } else {
                    CGFloat imageLimitHeight = contentLimitSize.height - VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                    imageSize = self.imageView.image ? [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)] : self.currentImage.size;
                    imageSize.height = MIN(imageSize.height, imageLimitHeight);
                }
                imageTotalSize = CGSizeMake(imageSize.width + VELUIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
            }
            
            if (isTitleLabelShowing) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - imageTotalSize.width - spacingBetweenImageAndTitle, contentLimitSize.height - VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = MIN(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            }
            
            resultSize.width = VELUIEdgeInsetsGetHorizontalValue(contentEdgeInsets) + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
            resultSize.height = VELUIEdgeInsetsGetVerticalValue(contentEdgeInsets);
            resultSize.height += MAX(imageTotalSize.height, titleTotalSize.height);
        }
            break;
    }
    return resultSize;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    if (self.cornerRadius == VELUIButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
    }
    
    BOOL isImageViewShowing = !!self.currentImage;
    BOOL isTitleLabelShowing = !!self.currentTitle || !!self.currentAttributedTitle;
    CGSize imageLimitSize = CGSizeZero;
    CGSize titleLimitSize = CGSizeZero;
    CGSize imageTotalSize = CGSizeZero;
    CGSize titleTotalSize = CGSizeZero;
    CGFloat spacingBetweenImageAndTitle = VELCGFloatFlatted(isImageViewShowing && isTitleLabelShowing ? self.spacingBetweenImageAndTitle : 0);
    CGRect imageFrame = CGRectZero;
    CGRect titleFrame = CGRectZero;
    UIEdgeInsets contentEdgeInsets = VELUIEdgeInsetsRemoveFloatMin(self.contentEdgeInsets);
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - VELUIEdgeInsetsGetHorizontalValue(contentEdgeInsets), CGRectGetHeight(self.bounds) - VELUIEdgeInsetsGetVerticalValue(contentEdgeInsets));
    
    if (isImageViewShowing) {
        CGSize imageSize = CGSizeZero;
        imageLimitSize = CGSizeMake(contentSize.width - VELUIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
        if ([self __vel_imageSizeValid]) {
            imageSize = self.imageSize;
            imageSize.width = MIN(imageLimitSize.width, imageSize.width);
            imageSize.height = MIN(imageLimitSize.height, imageSize.height);
        } else {
            imageSize = self._vel_imageView.image ? [self._vel_imageView sizeThatFits:imageLimitSize] : self.currentImage.size;
            imageSize.width = MIN(imageLimitSize.width, imageSize.width);
            imageSize.height = MIN(imageLimitSize.height, imageSize.height);
        }
        imageFrame = VELCGRectMakeWithSize(imageSize);
        imageTotalSize = CGSizeMake(imageSize.width + VELUIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
    }
    void (^makesureBoundsPositive)(UIView *) = ^void(UIView *view) {
        CGRect bounds = view.bounds;
        if (CGRectGetMinX(bounds) < 0 || CGRectGetMinY(bounds) < 0) {
            bounds = VELCGRectMakeWithSize(bounds.size);
            view.bounds = bounds;
        }
    };
    if (isImageViewShowing) {
        makesureBoundsPositive(self._vel_imageView);
    }
    if (isTitleLabelShowing) {
        makesureBoundsPositive(self.titleLabel);
    }
    
    if (self.imagePosition == VELUIButtonImagePositionTop || self.imagePosition == VELUIButtonImagePositionBottom) {
        
        if (isTitleLabelShowing) {
            titleLimitSize = CGSizeMake(contentSize.width - VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.width = MIN(titleLimitSize.width, titleSize.width);
            titleSize.height = MIN(titleLimitSize.height, titleSize.height);
            titleFrame = VELCGRectMakeWithSize(titleSize);
            titleTotalSize = CGSizeMake(titleSize.width + VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        }
        
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
                break;
            case UIControlContentHorizontalAlignmentCenter:
                imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left + VELCGFloatGetCenter(imageLimitSize.width, CGRectGetWidth(imageFrame))) : imageFrame;
                titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left + VELCGFloatGetCenter(titleLimitSize.width, CGRectGetWidth(titleFrame))) : titleFrame;
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                break;
            case UIControlContentHorizontalAlignmentFill:
                if (isImageViewShowing) {
                    imageFrame = VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                    imageFrame = VELCGRectSetWidth(imageFrame, imageLimitSize.width);
                }
                if (isTitleLabelShowing) {
                    titleFrame = VELCGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                    titleFrame = VELCGRectSetWidth(titleFrame, titleLimitSize.width);
                }
                break;
            default:
                break;
        }
        
        if (self.imagePosition == VELUIButtonImagePositionTop) {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                    titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height;
                    CGFloat minY = VELCGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top;
                    imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, minY + self.imageEdgeInsets.top) : imageFrame;
                    titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, minY + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                    imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - titleTotalSize.height - spacingBetweenImageAndTitle - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                    break;
                case UIControlContentVerticalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                        titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + self.titleEdgeInsets.top) : titleFrame;
                        titleFrame = isTitleLabelShowing ? VELCGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame)) : titleFrame;
                        
                    } else if (isImageViewShowing) {
                        imageFrame = VELCGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
                        imageFrame = VELCGRectSetHeight(imageFrame, contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
                    } else {
                        titleFrame = VELCGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                        titleFrame = VELCGRectSetHeight(titleFrame, contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                    }
                }
                    break;
            }
        } else {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
                    imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageAndTitle + self.imageEdgeInsets.top) : imageFrame;
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageAndTitle;
                    CGFloat minY = VELCGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top;
                    titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, minY + self.titleEdgeInsets.top) : titleFrame;
                    imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, minY + titleTotalSize.height + spacingBetweenImageAndTitle + self.imageEdgeInsets.top) : imageFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                    titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                    break;
                case UIControlContentVerticalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        imageFrame = VELCGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                        titleFrame = VELCGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                        titleFrame = VELCGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                        
                    } else if (isImageViewShowing) {
                        imageFrame = VELCGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
                        imageFrame = VELCGRectSetHeight(imageFrame, contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
                    } else {
                        titleFrame = VELCGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                        titleFrame = VELCGRectSetHeight(titleFrame, contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                    }
                }
                    break;
            }
        }
        
        if (isImageViewShowing) {
            imageFrame = VELCGRectFlatted(imageFrame);
            self._vel_imageView.frame = imageFrame;
        }
        if (isTitleLabelShowing) {
            titleFrame = VELCGRectFlatted(titleFrame);
            self.titleLabel.frame = titleFrame;
        }
        
    } else if (self.imagePosition == VELUIButtonImagePositionLeft || self.imagePosition == VELUIButtonImagePositionRight) {
        
        if (isTitleLabelShowing) {
            titleLimitSize = CGSizeMake(contentSize.width - VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - imageTotalSize.width - spacingBetweenImageAndTitle, contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.width = MIN(titleLimitSize.width, titleSize.width);
            titleSize.height = MIN(titleLimitSize.height, titleSize.height);
            titleFrame = VELCGRectMakeWithSize(titleSize);
            titleTotalSize = CGSizeMake(titleSize.width + VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        }
        
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop:
                imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
                
                break;
            case UIControlContentVerticalAlignmentCenter:
                imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, contentEdgeInsets.top + VELCGFloatGetCenter(contentSize.height, CGRectGetHeight(imageFrame)) + self.imageEdgeInsets.top) : imageFrame;
                titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, contentEdgeInsets.top + VELCGFloatGetCenter(contentSize.height, CGRectGetHeight(titleFrame)) + self.titleEdgeInsets.top) : titleFrame;
                break;
            case UIControlContentVerticalAlignmentBottom:
                imageFrame = isImageViewShowing ? VELCGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                titleFrame = isTitleLabelShowing ? VELCGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                break;
            case UIControlContentVerticalAlignmentFill:
                if (isImageViewShowing) {
                    imageFrame = VELCGRectSetY(imageFrame, contentEdgeInsets.top + self.imageEdgeInsets.top);
                    imageFrame = VELCGRectSetHeight(imageFrame, contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
                }
                if (isTitleLabelShowing) {
                    titleFrame = VELCGRectSetY(titleFrame, contentEdgeInsets.top + self.titleEdgeInsets.top);
                    titleFrame = VELCGRectSetHeight(titleFrame, contentSize.height - VELUIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                }
                break;
        }
        
        if (self.imagePosition == VELUIButtonImagePositionLeft) {
            switch (self.contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentLeft:
                    imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                    titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
                    break;
                case UIControlContentHorizontalAlignmentCenter: {
                    CGFloat contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
                    CGFloat minX = contentEdgeInsets.left + VELCGFloatGetCenter(contentSize.width, contentWidth);
                    imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, minX + self.imageEdgeInsets.left) : imageFrame;
                    titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, minX + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight: {
                    if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width) {
                        imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                        titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left) : titleFrame;
                    } else {
                        titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                        imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - titleTotalSize.width - spacingBetweenImageAndTitle - imageTotalSize.width + self.imageEdgeInsets.left) : imageFrame;
                    }
                }
                    break;
                case UIControlContentHorizontalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        imageFrame = VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                        titleFrame = VELCGRectSetX(titleFrame, contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left);
                        titleFrame = VELCGRectSetWidth(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
                    } else if (isImageViewShowing) {
                        imageFrame = VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                        imageFrame = VELCGRectSetWidth(imageFrame, contentSize.width - VELUIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets));
                    } else {
                        titleFrame = VELCGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                        titleFrame = VELCGRectSetWidth(titleFrame, contentSize.width - VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets));
                    }
                }
                    break;
                default:
                    break;
            }
        } else {
            switch (self.contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentLeft: {
                    if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width > contentSize.width) {
                        imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                        titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleTotalSize.width + self.titleEdgeInsets.left) : titleFrame;
                    } else {
                        titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
                        imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left) : imageFrame;
                    }
                }
                    break;
                case UIControlContentHorizontalAlignmentCenter: {
                    CGFloat contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width;
                    CGFloat minX = contentEdgeInsets.left + VELCGFloatGetCenter(contentSize.width, contentWidth);
                    titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, minX + self.titleEdgeInsets.left) : titleFrame;
                    imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, minX + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left) : imageFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight:
                    imageFrame = isImageViewShowing ? VELCGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                    titleFrame = isTitleLabelShowing ? VELCGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                    break;
                case UIControlContentHorizontalAlignmentFill: {
                    if (isImageViewShowing && isTitleLabelShowing) {
                        imageFrame = VELCGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame));
                        titleFrame = VELCGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                        titleFrame = VELCGRectSetWidth(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
                        
                    } else if (isImageViewShowing) {
                        imageFrame = VELCGRectSetX(imageFrame, contentEdgeInsets.left + self.imageEdgeInsets.left);
                        imageFrame = VELCGRectSetWidth(imageFrame, contentSize.width - VELUIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets));
                    } else {
                        titleFrame = VELCGRectSetX(titleFrame, contentEdgeInsets.left + self.titleEdgeInsets.left);
                        titleFrame = VELCGRectSetWidth(titleFrame, contentSize.width - VELUIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets));
                    }
                }
                    break;
                default:
                    break;
            }
        }
        
        if (isImageViewShowing) {
            imageFrame = VELCGRectFlatted(imageFrame);
            self._vel_imageView.frame = imageFrame;
        }
        if (isTitleLabelShowing) {
            titleFrame = VELCGRectFlatted(titleFrame);
            self.titleLabel.frame = titleFrame;
        }
    }
}

- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
    _spacingBetweenImageAndTitle = spacingBetweenImageAndTitle;
    
    [self setNeedsLayout];
}

- (void)setImagePosition:(VELUIButtonImagePosition)imagePosition {
    _imagePosition = imagePosition;
    
    [self setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    if (cornerRadius != VELUIButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = cornerRadius;
    }
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted && !self.originBorderColor) {
        self.originBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];
    }
    
    if (self.highlightedBackgroundColor || self.highlightedBorderColor) {
        [self adjustsButtonHighlighted];
    }
    if (!self.enabled) {
        return;
    }
    if (self.adjustsButtonWhenHighlighted) {
        if (highlighted) {
            self.alpha = 0.3;
        } else {
            self.alpha = 1;
        }
    }
}

- (void)adjustsButtonHighlighted {
    if (self.highlightedBackgroundColor) {
        if (!self.highlightedBackgroundLayer) {
            self.highlightedBackgroundLayer = [CALayer layer];
            [self.highlightedBackgroundLayer removeAllAnimations];
            [self.layer insertSublayer:self.highlightedBackgroundLayer atIndex:0];
        }
        self.highlightedBackgroundLayer.frame = self.bounds;
        self.highlightedBackgroundLayer.cornerRadius = self.layer.cornerRadius;
        if (@available(iOS 11.0, *)) {
            self.highlightedBackgroundLayer.maskedCorners = self.layer.maskedCorners;
        }
        self.highlightedBackgroundLayer.backgroundColor = self.highlighted ? self.highlightedBackgroundColor.CGColor : UIColor.clearColor.CGColor;
    }
    
    if (self.highlightedBorderColor) {
        self.layer.borderColor = self.highlighted ? self.highlightedBorderColor.CGColor : self.originBorderColor.CGColor;
    }
}

- (void)setStatus:(VELUIButtonStatus)status {
    _status = status;
    NSString *key = [NSString stringWithFormat:@"status_%ld", (long)status];
    UIImage *image = self.bingDic[key];
    if (image && [image isKindOfClass:[UIImage class]]) {
        [self setImage:image forState:UIControlStateNormal];
    }
}

- (void)bingImage:(UIImage *)image status:(VELUIButtonStatus)status {
    if (image) {
        NSString *key = [NSString stringWithFormat:@"status_%ld", (long)status];
        [self.bingDic setValue:image forKey:key];
        if (status == VELUIButtonStatusNone) {
            [self setImage:image forState:UIControlStateNormal];
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

#pragma mark - getter

- (NSMutableDictionary *)bingDic {
    if (!_bingDic) {
        _bingDic = [[NSMutableDictionary alloc] init];
    }
    return _bingDic;
}

@end
