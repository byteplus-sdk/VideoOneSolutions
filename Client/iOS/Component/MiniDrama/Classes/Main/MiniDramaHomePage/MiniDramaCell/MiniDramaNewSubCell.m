// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaNewSubCell.h"

@interface MiniDramaNewSubCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BaseButton *markLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) BaseButton *playTimesLabel;

@end

@implementation MiniDramaNewSubCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

-(void)initViews {
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(133);
    }];

    [self addSubview:self.markLabel];
    [self.markLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView);
        make.top.equalTo(self.imageView).mas_offset(-1);
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(16);
    }];

    [self addSubview:self.playTimesLabel];
    [self.playTimesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.imageView).mas_offset(4);
        make.bottom.equalTo(self.imageView).mas_offset(-6);
        make.height.mas_offset(17);
    }];

    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.mas_equalTo(self.imageView.mas_bottom).mas_offset(8);
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

-(BaseButton *)markLabel {
    if (!_markLabel) {
        _markLabel = [[BaseButton alloc] init];
        _markLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_markLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_markLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _markLabel.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [_markLabel setBackgroundImage:[UIImage imageNamed:@"mini_drama_new_mark" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
        [_markLabel setTitle:@"New" forState:UIControlStateNormal];
    }
    return _markLabel;
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
        _playTimesLabel.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [_playTimesLabel setImage:[UIImage imageNamed:@"mini_drama_cell_play" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
        [_playTimesLabel setBackgroundColor:[UIColor clearColor]];
    }
    return _playTimesLabel;
}

- (void)setDramaInfoModel:(MDDramaInfoModel *)dramaInfoModel {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:dramaInfoModel.dramaCoverUrl]];
    self.titleLabel.text = dramaInfoModel.dramaTitle;
    self.markLabel.hidden = !dramaInfoModel.newReleased;
    [self.playTimesLabel setTitle:[self formatPlayTimesString:dramaInfoModel.dramaPlayTimes] forState:UIControlStateNormal];
}

@end
