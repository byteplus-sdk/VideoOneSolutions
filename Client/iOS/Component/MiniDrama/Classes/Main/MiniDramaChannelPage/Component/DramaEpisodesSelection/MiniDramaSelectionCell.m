// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaSelectionCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/UIColor+String.h>

@interface MiniDramaSelectionCell ()

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *playingImageView;
@property (nonatomic, strong) UIImageView *lockImageView;
@property (nonatomic, strong) UIView *tempImageView;

@end

@implementation MiniDramaSelectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.playingImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.lockImageView];

    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];

    [self.playingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.top.equalTo(self.contentView).with.offset(4);
        make.right.equalTo(self.contentView).with.offset(-4);
    }];
    
    [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(20, 13));
    }];
}

- (void)setDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    _dramaVideoInfo = dramaVideoInfo;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", @(dramaVideoInfo.order)];
    self.lockImageView.hidden = !dramaVideoInfo.vip;
}

- (void)setCurPlayDramaVideoInfo:(MDDramaEpisodeInfoModel *)curPlayDramaVideoInfo {
    if (self.dramaVideoInfo.order == curPlayDramaVideoInfo.order) {
        self.coverView.backgroundColor = [UIColor colorFromRGBHexString:@"#FF1764" andAlpha:0.2 *255];
        self.titleLabel.textColor = [UIColor colorFromHexString:@"#ED3596"];
        self.playingImageView.hidden = NO;
    } else {
        self.playingImageView.hidden = YES;
        self.coverView.backgroundColor = [UIColor colorFromRGBHexString:@"#989A9F" andAlpha:0.2 * 255];
        self.titleLabel.textColor = [UIColor colorFromRGBHexString:@"#CACBCE"];
    }
}

#pragma mark - lazy load

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.layer.cornerRadius = 8;
        _coverView.layer.masksToBounds = YES;
    }
    return _coverView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _titleLabel;
}

- (UIImageView *)playingImageView {
    if (_playingImageView == nil) {
        _playingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_playing" bundleName:@"MiniDrama"]];
    }
    return _playingImageView;
}

- (UIImageView *)lockImageView {
    if (_lockImageView == nil) {
        _lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"episode_lock" bundleName:@"MiniDrama"]];
    }
    return _lockImageView;
}

@end
