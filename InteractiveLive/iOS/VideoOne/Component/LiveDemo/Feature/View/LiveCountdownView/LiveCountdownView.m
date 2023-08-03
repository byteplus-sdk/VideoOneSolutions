// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveCountdownView.h"
#import "GCDTimer.h"

@interface LiveCountdownView ()

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) GCDTimer *timer;

@property (nonatomic, assign) NSInteger number;

@property (nonatomic, copy) void (^countdownCompleteBlock)(void);

@end

@implementation LiveCountdownView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidden = YES;
        [self addSubview:self.numberLabel];
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.center.equalTo(self);
        }];
        self.number = 3;
    }
    return self;
}

- (void)start:(void (^)(void))block {
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    }];
    self.countdownCompleteBlock = block;
    __weak __typeof(self) wself = self;
    [self.timer start:1 block:^(BOOL result) {
        [wself timerMethod];
    }];
}

- (void)timerMethod {
    self.numberLabel.text = @(self.number).stringValue;
    if (self.number == 0) {
        [self.timer suspend];
        if (self.countdownCompleteBlock) {
            self.countdownCompleteBlock();
        }
//        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"start_live_title")];
    }
    self.number--;
}

#pragma mark - Getter

- (GCDTimer *)timer {
    if (!_timer) {
        _timer = [[GCDTimer alloc] init];
    }
    return _timer;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:48 weight:UIFontWeightBold];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.layer.cornerRadius = 50;
        _numberLabel.layer.masksToBounds = YES;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.backgroundColor = [UIColor colorFromRGBHexString:@"#000000"
                                                             andAlpha:0.5 * 255];
    }
    return _numberLabel;
}

@end
