// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TextSliderType) {
    TextSliderTypeAnimated,
    TextSliderTypeNormal,
};

@class EffectUISlider;
@protocol EffectUIKitUISliderDelegate <NSObject>

- (void)progressDidChange:(EffectUISlider *)sender progress:(CGFloat)progress;

- (void)progressEndChange:(EffectUISlider *)sender progress:(CGFloat)progress;

@end


@interface EffectUISlider : UIView

@property (nonatomic, weak) id<EffectUIKitUISliderDelegate> delegate;

@property (nonatomic, assign) TextSliderType sliderType;

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

@property (nonatomic, copy) NSString* (^progressFunc)(CGFloat progress);

- (void)resetToDefaultMinMaxValue;
@end
