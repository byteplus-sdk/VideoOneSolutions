// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, VELTextSliderType) {
    VELTextSliderTypeAnimated,
    VELTextSliderTypeNormal,
};

@class VELUISlider;
@protocol VELUISliderDelegate <NSObject>

- (void)progressDidChange:(VELUISlider *)sender progress:(CGFloat)progress;
/// @param sender sender
- (void)progressEndChange:(VELUISlider *)sender progress:(CGFloat)progress;

@end


@interface VELUISlider : UIView
@property (nonatomic, weak) id<VELUISliderDelegate> delegate;
@property (nonatomic, assign) VELTextSliderType sliderType;
@property (nonatomic, strong) UIColor *activeLineColor;
@property (nonatomic, strong) UIColor *inactiveLineColor;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGFloat textSize;
@property (nonatomic) CGFloat textOffset;
@property (nonatomic) CGFloat paddingLeft;
@property (nonatomic) CGFloat paddingRight;
@property (nonatomic) CGFloat paddingBottom;
@property (nonatomic) NSInteger animationTime;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic) BOOL negativeable;

@property (nonatomic) BOOL enable;
@property (nonatomic, copy) NSString* (^progressFunc)(CGFloat progress);
- (void)resetToDefaultMinMaxValue;
@end
