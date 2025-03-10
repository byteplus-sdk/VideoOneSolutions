// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceSlideMenuPercentageCell.h"
#import "Masonry.h"
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceElementDescription.h"
#import <ToolKit/UIColor+String.h>

@interface MDInterfaceSlideMenuPercentageCell ()

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIView *progressBGView;

@end

@implementation MDInterfaceSlideMenuPercentageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.progressBGView];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.iconImgView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView);
    }];

    [self.progressBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView.mas_right);
        make.height.equalTo(@(40.0));
        make.bottom.equalTo(self.mas_bottom).offset(-8);
    }];
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressBGView.mas_left).offset(8);
        make.centerY.equalTo(self.progressBGView.mas_centerY);
        make.size.equalTo(@(CGSizeMake(32, 32)));
    }];
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:gesture];
}

- (void)updateCellWidth {
    if (self.progressBGView.frame.size.width > 0 && self.percentage > 0) {
        CGRect rect = self.progressBGView.frame;
        rect.size.width = rect.size.width * self.percentage;
        self.progressView.frame = rect;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateCellWidth];
}

- (void)onPan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat p = [recognizer locationInView:self].x;
            p = p - self.progressBGView.frame.origin.x;
            p = MIN(MAX(0, p), self.progressBGView.frame.size.width);
            CGRect rect = self.progressBGView.frame;
            rect.size.width = p;
            self.progressView.frame = rect;
            if (self.elementDescription.elementNotify) {
                CGFloat percent = p / self.progressBGView.frame.size.width;
                self.elementDescription.elementNotify(self, @"progress", [NSValue valueWithCGPoint:CGPointMake(percent, 1)]);
            }
        } break;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}

#pragma mark----- Lazy Load

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [UIImageView new];
    }
    return _iconImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor whiteColor];
        _progressView.layer.masksToBounds = YES;
        _progressView.layer.cornerRadius = 2;
    }
    return _progressView;
}

- (UIView *)progressBGView {
    if (!_progressBGView) {
        _progressBGView = [[UIView alloc] init];
        _progressBGView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.24 * 255];
        _progressBGView.layer.masksToBounds = YES;
        _progressBGView.layer.cornerRadius = 2;
    }
    return _progressBGView;
}

@end
