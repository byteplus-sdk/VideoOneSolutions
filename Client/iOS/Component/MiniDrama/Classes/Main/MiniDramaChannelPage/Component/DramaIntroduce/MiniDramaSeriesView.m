// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaSeriesView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/UIColor+String.h>
#import "MDDramaFeedInfo.h"

@interface MiniDramaSeriesView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MiniDramaSeriesView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dramaButtonHandle)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo {
    self.titleLabel.text = dramaVideoInfo.dramaInfo.dramaTitle;
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor colorFromRGBHexString:@"#282828" andAlpha:0.35 * 255];
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
    
    [self addSubview:self.iconImageView];
    [self addSubview:self.label];
    [self addSubview:self.lineView];
    [self addSubview:self.titleLabel];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(4);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.top.equalTo(self).offset(4);
        make.bottom.equalTo(self).offset(-4);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(4);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImageView);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(1);
        make.left.equalTo(self.label.mas_right).offset(4);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImageView);
        make.left.equalTo(self.lineView.mas_right).with.offset(4);
        make.right.equalTo(self).offset(-6);
    }];
}

#pragma mark - private
- (void)dramaButtonHandle {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickSeriesViewCallback)]) {
        [self.delegate onClickSeriesViewCallback];
    }
}

#pragma mark - lazy load

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drama_play_icon" bundleName:@"MiniDrama"]];
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    return _iconImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor  = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.36 * 255];
    }
    return _lineView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.text = @"Short drama";
        _label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _label;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}
@end
