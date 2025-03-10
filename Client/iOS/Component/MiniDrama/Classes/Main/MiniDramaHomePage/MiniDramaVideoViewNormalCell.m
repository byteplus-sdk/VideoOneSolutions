// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaVideoViewNormalCell.h"

@interface MiniDramaVideoViewNormalCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) BaseButton *playTimesLabel;

@end

@implementation MiniDramaVideoViewNormalCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(40);
    }];

    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.mas_equalTo(self.titleLabel.mas_top).mas_offset(-10);
    }];

    [self addSubview:self.playTimesLabel];
    [self.playTimesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.imageView).mas_offset(6);
        make.bottom.equalTo(self.imageView).mas_offset(-8);
        make.height.mas_offset(18);
    }];

}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 8;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

-(BaseButton *)playTimesLabel {
    if (!_playTimesLabel) {
        _playTimesLabel = [[BaseButton alloc] init];
        _playTimesLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _playTimesLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_playTimesLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playTimesLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _playTimesLabel.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [_playTimesLabel setImage:[UIImage imageNamed:@"mini_drama_cell_play" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
        [_playTimesLabel setBackgroundColor:[UIColor clearColor]];
    }
    return _playTimesLabel;
}

- (void)setDramaInfoModel:(MDDramaInfoModel *)dramaInfoModel {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:dramaInfoModel.dramaCoverUrl]];
    self.titleLabel.text = dramaInfoModel.dramaTitle;
    [self.playTimesLabel setTitle:[self formatPlayTimesString:dramaInfoModel.dramaPlayTimes] forState:UIControlStateNormal];
}

@end
