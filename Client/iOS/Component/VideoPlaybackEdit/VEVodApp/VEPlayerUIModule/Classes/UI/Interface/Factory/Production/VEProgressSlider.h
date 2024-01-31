// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@class VEEventMessageBus;
@protocol VEProgressSliderDelegate <NSObject>

- (void)progressManualChanged:(CGFloat)value touchEnd:(BOOL)end;

@end

@interface VEProgressSlider : UIView

@property (nonatomic, weak) id<VEProgressSliderDelegate> delegate;

@property (nonatomic, weak) VEEventMessageBus *eventMessageBus;

@property (nonatomic, assign) CGFloat progressValue;

@property (nonatomic, assign) CGFloat bufferValue;

- (void)setThumbImage:(UIImage *)image;

- (void)setProgressColor:(UIColor *)color;

- (void)setProgressBufferColor:(UIColor *)color;

- (void)setProgressBackgroundColor:(UIColor *)color;

@end
