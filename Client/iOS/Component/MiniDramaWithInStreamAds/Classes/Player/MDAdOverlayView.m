// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDAdOverlayView.h"
#import "MDSliderControlView.h"
#import <Masonry/Masonry.h>

static const CGFloat kMDAdProgressBarHeight = 2.0;
static const CGFloat kMDAdProgressBarInset = 6.0;
static const CGFloat kMDAdProgressBarThumbDiameter = 8.0;
static const CGFloat kMDAdBannerHeight = 24.0;
static const CGFloat kMDAdBannerHorizontalPadding = 14.0;
static const CGFloat kMDAdTimeHorizontalPadding = 8.0;
static const CGFloat kMDAdTimeVerticalPadding = 2.0;

/// Accent color used for the progress bar fill/thumb.
/// To recolor, change the hex value below. Examples:
///   blue: #1664FF (current), orange: #FF7D00, green: #00B42A, red: #F53F3F, purple: #6233FF
static UIColor *MDAdOverlayAccentColor(void) {
    return [UIColor colorWithRed:0x16 / 255.0 green:0x64 / 255.0 blue:0xFF / 255.0 alpha:1.0]; // #1664FF
}

@interface MDAdOverlayView ()
@property (nonatomic, strong) MDSliderControlView *progressBar;
@property (nonatomic, strong) UIView *timeBackground;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *bannerBackground;
@property (nonatomic, strong) UILabel *bannerLabel;
@end

@implementation MDAdOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // touches pass through to the underlying ad view.
        self.userInteractionEnabled = NO;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    // pill-shaped translucent background behind the "Advertising" banner.
    _bannerBackground = [[UIView alloc] init];
    _bannerBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _bannerBackground.layer.cornerRadius = kMDAdBannerHeight / 2.0;
    _bannerBackground.clipsToBounds = YES;
    [self addSubview:_bannerBackground];

    // "Advertising" banner: top-left.
    _bannerLabel = [[UILabel alloc] init];
    _bannerLabel.text = @"Advertising";
    _bannerLabel.textColor = [UIColor whiteColor];
    _bannerLabel.font = [UIFont systemFontOfSize:12.0];
    _bannerLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_bannerLabel];

    // progress bar (display-only), matching the regular player seek bar dimensions.
    _progressBar = [[MDSliderControlView alloc] initWithContentMode:MDSliderControlViewContentModeBottom];
    _progressBar.progressBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    _progressBar.progressColor = MDAdOverlayAccentColor();
    _progressBar.progressBufferColor = [UIColor clearColor];
    _progressBar.thumbHeight = kMDAdProgressBarHeight;
    _progressBar.thumbOffset = kMDAdProgressBarInset;
    UIImage *thumbDot = [self circleImageWithColor:MDAdOverlayAccentColor() diameter:kMDAdProgressBarThumbDiameter];
    _progressBar.thumbImage = thumbDot;
    _progressBar.thumbTouchImage = thumbDot;
    [self addSubview:_progressBar];

    // translucent pill behind the "mm:ss / mm:ss" time label so the white text stays
    // legible over bright ad content.
    _timeBackground = [[UIView alloc] init];
    _timeBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _timeBackground.layer.cornerRadius = 4.0;
    _timeBackground.clipsToBounds = YES;
    [self addSubview:_timeBackground];

    // progress time label ("mm:ss / mm:ss") above the progress bar, left-aligned.
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.text = @"00:00 / 00:00";
    [self addSubview:_timeLabel];

    // pill background: top-left.
    [_bannerBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        } else {
            make.top.equalTo(self).offset(28);
        }
        make.left.equalTo(self).offset(12);
        make.height.mas_equalTo(kMDAdBannerHeight);
    }];

    // label centered inside the pill.
    [_bannerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bannerBackground);
        make.left.equalTo(self.bannerBackground).offset(kMDAdBannerHorizontalPadding);
        make.right.equalTo(self.bannerBackground).offset(-kMDAdBannerHorizontalPadding);
    }];

    [_progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(kMDAdProgressBarThumbDiameter);
    }];

    // align the label's left with the progress bar's visible track start.
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressBar).offset(kMDAdProgressBarInset + kMDAdTimeHorizontalPadding);
        make.bottom.equalTo(self.progressBar.mas_top).offset(-6 - kMDAdTimeVerticalPadding);
    }];
    // pill wraps the time label with padding.
    [_timeBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressBar).offset(kMDAdProgressBarInset);
        make.top.equalTo(self.timeLabel).offset(-kMDAdTimeVerticalPadding);
        make.bottom.equalTo(self.timeLabel).offset(kMDAdTimeVerticalPadding);
        make.right.equalTo(self.timeLabel).offset(kMDAdTimeHorizontalPadding);
    }];
}

#pragma mark - Public

- (void)updateProgressWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (totalTime <= 0) {
        return;
    }
    self.progressBar.progressValue = currentTime / totalTime;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@",
                           [self formatTime:currentTime], [self formatTime:totalTime]];
}

- (void)reset {
    self.progressBar.progressValue = 0.0;
    self.timeLabel.text = @"00:00 / 00:00";
}

#pragma mark - Helpers

- (NSString *)formatTime:(NSTimeInterval)time {
    if (time < 0 || isnan(time)) {
        time = 0;
    }
    NSInteger total = (NSInteger)floor(time);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(total / 60), (long)(total % 60)];
}

- (UIImage *)circleImageWithColor:(UIColor *)color diameter:(CGFloat)diameter {
    CGSize size = CGSizeMake(diameter, diameter);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
        [color setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, diameter, diameter)] fill];
    }];
}

@end
