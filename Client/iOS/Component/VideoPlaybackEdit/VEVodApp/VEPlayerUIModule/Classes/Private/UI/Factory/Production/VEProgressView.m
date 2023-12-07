// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "Masonry.h"
#import "UIView+VEElementDescripition.h"
#import "VEEventConst.h"
#import "VEInterfaceElementDescription.h"
#import "VEProgressSlider.h"
#import "VEProgressView+Private.h"

@interface VEProgressView () <VEProgressSliderDelegate>

@property (nonatomic, strong) UILabel *totalValueLabel; // protrait

@property (nonatomic, strong) UILabel *currentValueLabel; // protrait

@property (nonatomic, strong) UILabel *allValueLabel; // landscape

@property (nonatomic, assign) BOOL autoBackStartPoint;

@property (nonatomic, strong) VEProgressSlider *progressSlider;

@property (nonatomic, copy) void (^valueChanged)(CGFloat);

@end

@implementation VEProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    [self addSubview:self.totalValueLabel];
    [self addSubview:self.currentValueLabel];
    [self addSubview:self.allValueLabel];
    [self addSubview:self.progressSlider];
    self.currentOrientation = UIInterfaceOrientationPortrait;
}

- (void)layoutElements {
    if (self.currentOrientation == UIInterfaceOrientationLandscapeRight) {
        self.totalValueLabel.hidden = YES;
        self.currentValueLabel.hidden = YES;
        self.allValueLabel.hidden = NO;
        [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.centerY.equalTo(self);
            make.height.equalTo(@25.0);
        }];
        [self.allValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.progressSlider.mas_top);
            make.leading.equalTo(self.progressSlider.mas_leading).offset(12.0);
            make.trailing.equalTo(self);
        }];
    } else {
        self.totalValueLabel.hidden = NO;
        self.currentValueLabel.hidden = NO;
        self.allValueLabel.hidden = YES;
        [self.currentValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.centerY.equalTo(self);
            make.width.equalTo(@55.0);
            make.height.equalTo(@25.0);
        }];
        [self.totalValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self);
            make.centerY.equalTo(self);
            make.width.equalTo(@55.0);
            make.height.equalTo(@25.0);
        }];
        [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentValueLabel.mas_trailing);
            make.trailing.equalTo(self.totalValueLabel.mas_leading);
            make.centerY.equalTo(self);
            make.height.equalTo(@50.0);
        }];
    }
}

- (void)setEventMessageBus:(VEEventMessageBus *)eventMessageBus {
    _eventMessageBus = eventMessageBus;
    self.progressSlider.eventMessageBus = eventMessageBus;
    [eventMessageBus registEvent:VEPlayEventProgressValueIncrease withAction:@selector(sliderValueIncrease:) ofTarget:self];
}

- (void)setEventPoster:(VEEventPoster *)eventPoster {
    _eventPoster = eventPoster;
    [self setTotalValue:eventPoster.duration];
    [self setBufferValue:eventPoster.playableDuration];
    [self setCurrentValue:eventPoster.currentPlaybackTime];
}

#pragma mark----- Action

- (void)sliderValueIncrease:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *param = (NSDictionary *)value;
            NSNumber *began = [param objectForKey:@"touchBegan"];
            if ([began isKindOfClass:[NSNumber class]] && began.boolValue) {
                [self.eventMessageBus postEvent:VEUIEventSeeking withObject:@(YES) rightNow:YES];
                return;
            }
            NSNumber *progress = [param objectForKey:@"changeValue"];
            NSNumber *end = [param objectForKey:@"touchEnd"];
            if ([progress isKindOfClass:[NSNumber class]] && [end isKindOfClass:[NSNumber class]]) {
                CGFloat increaseValue = [progress floatValue];
                self.progressSlider.progressValue += increaseValue;
                [self progressManualChanged:self.progressSlider.progressValue touchEnd:end.boolValue];
                if (end.boolValue) {
                    [self.eventMessageBus postEvent:VEUIEventSeeking withObject:@(NO) rightNow:YES];
                }
            }
        }
    }
}

#pragma mark----- Setter

- (void)setIsHiddenText:(BOOL)isHiddenText {
    _isHiddenText = isHiddenText;

    if (isHiddenText) {
        self.totalValueLabel.hidden = YES;
        self.currentValueLabel.hidden = YES;
        [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    } else {
        [self layoutElements];
    }
}

- (void)setCurrentOrientation:(UIInterfaceOrientation)currentOrientation {
    if (_currentOrientation != currentOrientation) {
        _currentOrientation = currentOrientation;
        [self layoutElements];
        self.currentValue = (self.progressSlider.progressValue * self.totalValue);
        self.bufferValue = (self.progressSlider.bufferValue * self.totalValue);
    }
}

- (void)setCurrentValue:(NSTimeInterval)currentValue {
    if (self.totalValue == 0) {
        self.currentValueLabel.text = [self intervalForDisplay:0];
        return;
    }
    if (self.autoBackStartPoint && currentValue >= self.totalValue) {
        currentValue = 0.0;
    }
    currentValue = MAX(0.0, MIN(currentValue, self.totalValue));
    _currentValue = currentValue;
    NSString *currentValueForDisplay = [self intervalForDisplay:currentValue];
    NSString *totalValueForDisplay = [self intervalForDisplay:self.totalValue];
    self.currentValueLabel.text = [NSString stringWithFormat:@"%@", currentValueForDisplay];
    NSString *allValue = [NSString stringWithFormat:@"%@ / %@", currentValueForDisplay, totalValueForDisplay];
    NSMutableAttributedString *attributedAllValue = [[NSMutableAttributedString alloc] initWithString:allValue];
    [attributedAllValue addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithWhite:1.0 alpha:0.64]
                               range:NSMakeRange(currentValueForDisplay.length, attributedAllValue.length - currentValueForDisplay.length)];
    self.allValueLabel.attributedText = attributedAllValue;
    CGFloat rate = currentValue / self.totalValue;
    self.progressSlider.progressValue = rate;
}

- (void)setBufferValue:(NSTimeInterval)bufferValue {
    if (self.totalValue > 0) {
        bufferValue = MAX(0.0, MIN(bufferValue, self.totalValue));
        _bufferValue = bufferValue;
        CGFloat rate = bufferValue / self.totalValue;
        self.progressSlider.bufferValue = rate;
    }
}

- (void)setTotalValue:(NSTimeInterval)totalValue {
    _totalValue = totalValue;
    self.totalValueLabel.text = [NSString stringWithFormat:@"%@", [self intervalForDisplay:totalValue]];
}

#pragma mark----- Lazy Load

- (UILabel *)totalValueLabel {
    if (!_totalValueLabel) {
        _totalValueLabel = [UILabel new];
        _totalValueLabel.textAlignment = NSTextAlignmentLeft;
        _totalValueLabel.font = [UIFont boldSystemFontOfSize:11.0];
        _totalValueLabel.textColor = [UIColor whiteColor];
        _totalValueLabel.text = @"00:00";
    }
    return _totalValueLabel;
}

- (UILabel *)currentValueLabel {
    if (!_currentValueLabel) {
        _currentValueLabel = [UILabel new];
        _currentValueLabel.textAlignment = NSTextAlignmentRight;
        _currentValueLabel.font = [UIFont boldSystemFontOfSize:11.0];
        _currentValueLabel.textColor = [UIColor whiteColor];
        _currentValueLabel.text = @"00:00";
    }
    return _currentValueLabel;
}

- (UILabel *)allValueLabel {
    if (!_allValueLabel) {
        _allValueLabel = [UILabel new];
        _allValueLabel.textAlignment = NSTextAlignmentLeft;
        _allValueLabel.font = [UIFont boldSystemFontOfSize:11.0];
        _allValueLabel.textColor = [UIColor whiteColor];
    }
    return _allValueLabel;
}

- (VEProgressSlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[VEProgressSlider alloc] init];
        _progressSlider.delegate = self;
        _progressSlider.progressValue = 0.0;
        [_progressSlider setProgressColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        [_progressSlider setProgressBufferColor:[UIColor colorWithWhite:1.0 alpha:0.32]];
        [_progressSlider setProgressBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.16]];
    }
    return _progressSlider;
}

- (void)progressManualChanged:(CGFloat)value touchEnd:(BOOL)end {
    NSString *currentValueForDisplay = [self intervalForDisplay:(self.progressSlider.progressValue * self.totalValue)];
    NSString *totalValueForDisplay = [self intervalForDisplay:self.totalValue];
    self.currentValueLabel.text = [NSString stringWithFormat:@"%@", currentValueForDisplay];
    self.allValueLabel.text = [NSString stringWithFormat:@"%@ / %@", currentValueForDisplay, totalValueForDisplay];
    if (end && self.valueChanged) {
        self.valueChanged(value);
    }
}

#pragma mark----- Tool

- (NSString *)intervalForDisplay:(NSTimeInterval)interval {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale systemLocale];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    if (interval > 3601) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

#pragma mark----- VEInterfaceFactoryProduction

- (void)elementViewAction {
    __weak typeof(self) weak_self = self;
    self.valueChanged = ^(CGFloat sliderValue) {
        NSTimeInterval destination = [weak_self.eventPoster duration] * sliderValue * 1.000;
        [weak_self.eventMessageBus postEvent:VEPlayEventSeek withObject:@(destination) rightNow:YES];
    };
}

- (void)elementViewEventNotify:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        if (self.elementDescription.elementNotify) {
            self.elementDescription.elementNotify(self, [[paramDic allKeys] firstObject], [[paramDic allValues] firstObject]);
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    if (CGRectContainsPoint(self.frame, point)) {
        return YES;
    }
    return NO;
}

@end
