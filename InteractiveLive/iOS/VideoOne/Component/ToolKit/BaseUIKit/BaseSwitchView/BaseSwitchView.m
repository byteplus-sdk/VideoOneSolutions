// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseSwitchView.h"

static NSInteger const ImageSpacing = 3;
static NSInteger const ImageHeight = 26;
static NSInteger const ImageWidth = 39;

@interface BaseSwitchView ()

@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerLeft;
@property (nonatomic, strong) UISwipeGestureRecognizer *recognizerRight;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, assign) BOOL isOn;

@end

@implementation BaseSwitchView

- (instancetype)initWithOn:(BOOL)isOn {
    self = [super init];
    if (self) {
        self.isOn = isOn;
        [self addGestureRecognizer:self.recognizerLeft];
        [self addGestureRecognizer:self.recognizerRight];
        [self addGestureRecognizer:self.tapRecognizer];
        [self addSubview:self.iconImageView];
        [self addSubview:self.leftLabel];
        [self addSubview:self.rightLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.iconImageView.frame = CGRectMake(ImageSpacing, ImageSpacing, ImageWidth, ImageHeight);
    
    self.leftLabel.frame = CGRectMake(ImageSpacing, ImageSpacing, ImageWidth, ImageHeight);
    
    CGFloat right = self.frame.size.width - ImageWidth - ImageSpacing;
    self.rightLabel.frame = CGRectMake(right, ImageSpacing, ImageWidth, ImageHeight);
    if (self.isOn) {
        [self switchDirectionWithRight:NO];
    } else {
        [self switchDirectionWithLeft:NO];
    }
}

#pragma mark - Setter

- (void)setState:(BaseSwitchViewState)state {
    _state = state;
    
    if (self.didChangeBlock) {
        self.didChangeBlock(state);
    }
}

- (void)setSelectColor:(UIColor *)selectColor {
    _selectColor = selectColor;
    
    if (self.state == BaseSwitchViewStateLeft) {
        self.leftLabel.textColor = selectColor;
    } else {
        self.rightLabel.textColor = selectColor;
    }
}

- (void)setDefaultColor:(UIColor *)defaultColor {
    _defaultColor = defaultColor;
    
    if (self.state == BaseSwitchViewStateLeft) {
        self.rightLabel.textColor = defaultColor;
    } else {
        self.leftLabel.textColor = defaultColor;
    }
}

#pragma mark - Private Action

- (void)willSwitchDirection:(BaseSwitchViewState)state {
    if (state == BaseSwitchViewStateLeft) {
        self.leftLabel.textColor = self.selectColor;
        self.rightLabel.textColor = self.defaultColor;
    } else {
        self.rightLabel.textColor = self.selectColor;
        self.leftLabel.textColor = self.defaultColor;
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.state == BaseSwitchViewStateRight) {
            return;
        }
        [self switchDirectionWithRight:YES];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.state == BaseSwitchViewStateLeft) {
            return;
        }
        [self switchDirectionWithLeft:YES];
    }
}

- (void)tapRecognizerAction {
    if (self.state == BaseSwitchViewStateRight) {
        [self switchDirectionWithLeft:YES];
    } else if (self.state == BaseSwitchViewStateLeft) {
        [self switchDirectionWithRight:YES];
    }
}

- (void)switchDirectionWithLeft:(BOOL)isAnimation {
    [self willSwitchDirection:BaseSwitchViewStateLeft];
    [self.iconImageView.layer removeAllAnimations];
    if (isAnimation) {
        [UIView animateWithDuration:0.15 animations:^{
            self.iconImageView.frame = CGRectMake(ImageSpacing, ImageSpacing, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
                self.state = BaseSwitchViewStateLeft;
            }
        }];
    } else {
        self.iconImageView.frame = CGRectMake(ImageSpacing, ImageSpacing, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        self.state = BaseSwitchViewStateLeft;
    }
    
}

- (void)switchDirectionWithRight:(BOOL)isAnimation {
    [self willSwitchDirection:BaseSwitchViewStateRight];
    [self.iconImageView.layer removeAllAnimations];
    if (isAnimation) {
        [UIView animateWithDuration:0.15 animations:^{
            self.iconImageView.frame = CGRectMake(self.frame.size.width - ImageSpacing - self.iconImageView.frame.size.width, ImageSpacing, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
                self.state = BaseSwitchViewStateRight;
            }
        }];
    } else {
        self.iconImageView.frame = CGRectMake(self.frame.size.width - ImageSpacing - self.iconImageView.frame.size.width, ImageSpacing, self.iconImageView.frame.size.width, self.iconImageView.frame.size.height);
        self.state = BaseSwitchViewStateRight;
    }
    
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor whiteColor];
        _iconImageView.layer.cornerRadius = ImageHeight / 2;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}

- (UISwipeGestureRecognizer *)recognizerRight {
    if (_recognizerRight == nil) {
        _recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [_recognizerRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    }
    return _recognizerRight;
}

- (UISwipeGestureRecognizer *)recognizerLeft {
    if (_recognizerLeft == nil) {
        _recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [_recognizerLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    }
    return _recognizerLeft;
}

- (UITapGestureRecognizer *)tapRecognizer {
    if (_tapRecognizer == nil) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerAction)];
    }
    return _tapRecognizer;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.text = @"15";
        _leftLabel.textAlignment = NSTextAlignmentCenter;
        _leftLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.text = @"20";
        _rightLabel.textAlignment = NSTextAlignmentCenter;
        _rightLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _rightLabel;
}

@end
