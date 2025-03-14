// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerSeekProgressView.h"
#import <Masonry/Masonry.h>

@interface MDPlayerSeekProgressView ()

@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *sepLabel;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, assign) NSInteger duration;

@end

@implementation MDPlayerSeekProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
        self.alpha = 0;
    }
    return self;
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.currentLabel];
    [self addSubview:self.sepLabel];
    [self addSubview:self.durationLabel];
    
    [self.sepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(5);
    }];
    
    [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.sepLabel.mas_left).with.offset(-16);
        make.top.bottom.equalTo(self);
    }];
    
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.sepLabel.mas_left).with.offset(16);
        make.top.bottom.equalTo(self);
    }];
}

#pragma mark - Public

- (void)showView:(BOOL)show {
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = show ? 1 : 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)updateProgress:(NSInteger)playbackTime duration:(NSInteger)duration; {
    self.currentLabel.text = [self formatPlayTime:playbackTime];
    if (self.duration != duration) {
        self.durationLabel.text = [self formatPlayTime:duration];
        self.duration = duration;
    }
}

#pragma mark - private

- (NSString *)formatPlayTime:(NSTimeInterval)playSeconds {
    NSInteger hour = playSeconds / 3600;
    NSInteger minute = (playSeconds - hour * 3600) / 60;
    NSInteger seconds = playSeconds - hour * 3600 - minute * 60;
    
    NSString *timeText = @"00:00";
    if (hour > 0) {
        timeText = [NSString stringWithFormat:@"%.02zd:%.02zd:%.02zd", hour, minute, seconds];
    } else {
        timeText = [NSString stringWithFormat:@"%.02zd:%.02zd",minute, seconds];
    }
    
    return timeText;
}

#pragma mark - lazy load

- (UILabel *)currentLabel {
    if (_currentLabel == nil) {
        _currentLabel = [[UILabel alloc] init];
        _currentLabel.textColor = [UIColor whiteColor];
        _currentLabel.font = [UIFont systemFontOfSize:24];
    }
    return _currentLabel;
}

- (UILabel *)sepLabel {
    if (_sepLabel == nil) {
        _sepLabel = [[UILabel alloc] init];
        _sepLabel.text = @"/";
        _sepLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _sepLabel.font = [UIFont systemFontOfSize:14];
    }
    return _sepLabel;
}

- (UILabel *)durationLabel {
    if (_durationLabel == nil) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _durationLabel.font = [UIFont systemFontOfSize:24];
    }
    return _durationLabel;
}

@end
