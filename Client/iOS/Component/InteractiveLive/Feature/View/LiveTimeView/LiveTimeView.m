// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveTimeView.h"

@interface LiveTimeView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) GCDTimer *timer;
@property (nonatomic, assign) NSInteger second;

@end

@implementation LiveTimeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.2 * 255];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.second = 0;

        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.left.equalTo(self);
            make.width.mas_equalTo(44);
        }];

        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right);
            make.top.height.right.equalTo(self);
            make.width.mas_equalTo(44);
        }];

        __weak __typeof(self) wself = self;
        [self.timer start:1 block:^(BOOL result) {
            [wself timerMethod];
        }];
        [self.timer suspend];
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateLiveTime:(NSDate *)time {
    if (!time) {
        time = [NSDate date];
    }
    NSInteger createTime = [time timeIntervalSince1970];
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
    NSInteger second = nowTime - createTime;
    self.second = second;
    [self.timer resume];
}

#pragma mark - Private Action

- (void)timerMethod {
    self.second++;
    self.timeLabel.text = [NSString stringWithFormat:@"%.02ld:%.02ld", (long)self.second / 60, (long)self.second % 60];
    if (self.second >= 60 * LIVE_TIME_RESTRICTION) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLiveTimeEnd object:nil];
    }
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setImage:[UIImage imageNamed:@"time_live" bundleName:HomeBundleName]];
    }
    return _imageView;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _timeLabel.text = @"00:00";
    }
    return _timeLabel;
}

- (GCDTimer *)timer {
    if (!_timer) {
        _timer = [[GCDTimer alloc] init];
    }
    return _timer;
}

@end
