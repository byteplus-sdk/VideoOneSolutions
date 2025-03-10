// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaHotVideoCard.h"
#import "MDDramaFeedInfo.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/NSString+Valid.h>
#import <SDWebImage/SDWebImage.h>
#import "BaseButton.h"

@interface MiniDramaHotVideoCard ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *hotFireImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *playTimesLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation MiniDramaHotVideoCard
- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo {
    self.titleLabel.text = dramaVideoInfo.dramaInfo.dramaTitle;
    self.playTimesLabel.text = [NSString stringForCount:dramaVideoInfo.dramaInfo.dramaPlayTimes];
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:dramaVideoInfo.dramaInfo.dramaCoverUrl] placeholderImage:[UIImage imageNamed:@"playcover_default" bundleName:@"VodPlayer"]];
    self.hotFireImageView.image = [UIImage imageNamed:@"mini_drama_hot_fire_white" bundleName:@"MiniDrama"];
}

- (void)configuratoinCustomView {
    [self addSubview:self.coverImageView];
    [self addSubview:self.closeButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.hotFireImageView];
    [self addSubview:self.playTimesLabel];
    [self addSubview:self.playButton];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.top.equalTo(self);
        make.right.equalTo(self);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12);
        make.right.equalTo(self).offset(-12);
        make.bottom.equalTo(self).offset(-12);
        make.height.mas_equalTo(36);
    }];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36, 48));
        make.top.greaterThanOrEqualTo(self).offset(16);
        make.bottom.equalTo(self.playButton.mas_top).offset(-5);
        make.left.equalTo(self.playButton);
    }];
    [self.hotFireImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.playButton.mas_top).offset(-11);
        make.left.equalTo(self.coverImageView.mas_right).offset(8);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    [self.playTimesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hotFireImageView.mas_right).offset(4);
        make.centerY.equalTo(self.hotFireImageView);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(18);
        make.bottom.equalTo(self.playTimesLabel.mas_top);
        make.left.equalTo(self.coverImageView.mas_right).offset(8);
        make.right.equalTo(self).offset(-30);
    }];
}

- (void)handleButtonClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickCardPlayButton)]) {
        [self.delegate onClickCardPlayButton];
    }
}

- (void)close {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickCloseCard)]) {
        [self.delegate onClickCloseCard];
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }
    return _titleLabel;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.layer.cornerRadius = 2;
        _coverImageView.layer.masksToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverImageView;
}

- (UIImageView *)hotFireImageView {
    if (!_hotFireImageView) {
        _hotFireImageView = [[UIImageView alloc] init];
        _hotFireImageView.image = [UIImage imageNamed:@"mini_drama_hot_fire_white" bundleName:@"MiniDrama"];
    }
    return _hotFireImageView;
}

- (UILabel *)playTimesLabel {
    if (!_playTimesLabel) {
        _playTimesLabel = [[UILabel alloc] init];
        _playTimesLabel.textColor = [UIColor whiteColor];
        _playTimesLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    }
    return _playTimesLabel;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        [_playButton setBackgroundColor:[UIColor colorFromRGBHexString:@"#FE2C55"]];
        _playButton.layer.cornerRadius = 8;
        _playButton.clipsToBounds = YES;
        [_playButton setTitle:LocalizedStringFromBundle(@"mini_drama_card_button_title", @"MiniDrama") forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(handleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        _closeButton.hidden = YES;
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:[UIImage imageNamed:@"white_close" bundleName:@"ToolKit"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

@end
