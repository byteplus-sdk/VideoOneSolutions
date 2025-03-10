// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaTrendingSubCell.h"

@interface MiniDramaTrendingSubCell ()

@property (nonatomic, strong) UIImageView *imageView_1;
@property (nonatomic, strong) BaseButton *markLabel_1;
@property (nonatomic, strong) UILabel *titleLabel_1;
@property (nonatomic, strong) BaseButton *descLabel_1;

@property (nonatomic, strong) UIImageView *imageView_2;
@property (nonatomic, strong) BaseButton *markLabel_2;
@property (nonatomic, strong) UILabel *titleLabel_2;
@property (nonatomic, strong) BaseButton *descLabel_2;

@property (nonatomic, strong) UIImageView *imageView_3;
@property (nonatomic, strong) BaseButton *markLabel_3;
@property (nonatomic, strong) UILabel *titleLabel_3;
@property (nonatomic, strong) BaseButton *descLabel_3;
@property (nonatomic, strong)NSMutableDictionary *dramaDict;

@end

@implementation MiniDramaTrendingSubCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

-(void)initViews {
    CGFloat imageWidth = 68;
    CGFloat imageHeight = 90;
    // item 1
    self.imageView_1 = [self imageView];
    [self addSubview:self.imageView_1];
    [self.imageView_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    self.markLabel_1 = [self markLabel];
    [self addSubview:self.markLabel_1];
    [self.markLabel_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView_1);
        make.top.equalTo(self.imageView_1).mas_offset(-1);
    }];
    self.descLabel_1 = [self descLabel];
    [self addSubview:self.descLabel_1];
    [self.descLabel_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView_1.mas_right).mas_offset(12);
        make.bottom.equalTo(self.imageView_1);
        make.right.equalTo(self);
    }];
    self.titleLabel_1 = [self titleLabel];
    [self addSubview:self.titleLabel_1];
    [self.titleLabel_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView_1.mas_right).mas_offset(12);
        make.right.equalTo(self);
        make.top.equalTo(self.imageView_1).mas_offset(2);
        make.width.mas_greaterThanOrEqualTo(90);
    }];

    // item 2
    self.imageView_2 = [self imageView];
    [self addSubview:self.imageView_2];
    [self.imageView_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.mas_equalTo(self.imageView_1.mas_bottom).mas_offset(12);
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    self.markLabel_2 = [self markLabel];
    [self addSubview:self.markLabel_2];
    [self.markLabel_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView_2);
        make.top.equalTo(self.imageView_2).mas_offset(-1);
    }];
    self.descLabel_2 = [self descLabel];
    [self addSubview:self.descLabel_2];
    [self.descLabel_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView_2.mas_right).mas_offset(12);
        make.bottom.equalTo(self.imageView_2);
        make.right.equalTo(self);
    }];
    self.titleLabel_2 = [self titleLabel];
    [self addSubview:self.titleLabel_2];
    [self.titleLabel_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView_2.mas_right).mas_offset(12);
        make.right.equalTo(self);
        make.top.equalTo(self.imageView_2).mas_offset(2);
        make.width.mas_greaterThanOrEqualTo(90);
    }];

    // item 3
    self.imageView_3 = [self imageView];
    [self addSubview:self.imageView_3];
    [self.imageView_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.mas_equalTo(self.imageView_2.mas_bottom).mas_offset(12);
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    self.markLabel_3 = [self markLabel];
    [self addSubview:self.markLabel_3];
    [self.markLabel_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView_3);
        make.top.equalTo(self.imageView_3).mas_offset(-1);
    }];
    self.descLabel_3 = [self descLabel];
    [self addSubview:self.descLabel_3];
    [self.descLabel_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView_3.mas_right).mas_offset(12);
        make.bottom.equalTo(self.imageView_3);
        make.right.equalTo(self);
    }];
    self.titleLabel_3 = [self titleLabel];
    [self addSubview:self.titleLabel_3];
    [self.titleLabel_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView_3.mas_right).mas_offset(12);
        make.right.equalTo(self);
        make.top.equalTo(self.imageView_3).mas_offset(2);
        make.width.mas_greaterThanOrEqualTo(90);
    }];

}

- (NSMutableDictionary *)dramaDict{
    if (!_dramaDict) {
        _dramaDict = [[NSMutableDictionary alloc] init];
    }
    return _dramaDict;
}

- (UIImageView *)imageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = 8;
    imageView.layer.masksToBounds = YES;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
    [imageView addGestureRecognizer:tap];
    return imageView;
}

-(BaseButton *)markLabel {
    BaseButton *button = [[BaseButton alloc] init];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    return button;
}

-(UILabel *)titleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.numberOfLines = 4;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

-(BaseButton *)descLabel {
    BaseButton *button = [[BaseButton alloc] init];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [button setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHexString:@"#737A87"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [button setImage:[UIImage imageNamed:@"mini_drama_trending_fire_gray" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    return button;
}

-(void)hiddenItem:(NSInteger)index hidden:(BOOL)hidden fillData:(MDDramaInfoModel *)model fillIndex:(NSInteger)fillIndex{
    switch (index) {
        case 1:{
            self.imageView_1.hidden = hidden;
            self.markLabel_1.hidden = hidden;
            self.titleLabel_1.hidden = hidden;
            self.descLabel_1.hidden = hidden;
            if (!hidden) {
                [self.imageView_1 sd_setImageWithURL:[NSURL URLWithString:model.dramaCoverUrl]];
                [self.imageView_1 setTag:fillIndex];
                self.dramaDict[[NSString stringWithFormat:@"%ld", fillIndex]] = model;
                [self setMarkText:self.markLabel_1 fillIndex:fillIndex];
                self.titleLabel_1.text = model.dramaTitle;
                [self.descLabel_1 setTitle:[self formatPlayTimesString:model.dramaPlayTimes] forState:UIControlStateNormal];
            }
            break;
        }
        case 2:{
            self.imageView_2.hidden = hidden;
            self.markLabel_2.hidden = hidden;
            self.titleLabel_2.hidden = hidden;
            self.descLabel_2.hidden = hidden;
            if (!hidden) {
                [self.imageView_2 sd_setImageWithURL:[NSURL URLWithString:model.dramaCoverUrl]];
                [self.imageView_2 setTag:fillIndex];
                self.dramaDict[[NSString stringWithFormat:@"%ld", fillIndex]] = model;
                [self setMarkText:self.markLabel_2 fillIndex:fillIndex];
                self.titleLabel_2.text = model.dramaTitle;
                [self.descLabel_2 setTitle:[self formatPlayTimesString:model.dramaPlayTimes] forState:UIControlStateNormal];
            }
            break;
        }
        case 3:{
            self.imageView_3.hidden = hidden;
            self.markLabel_3.hidden = hidden;
            self.titleLabel_3.hidden = hidden;
            self.descLabel_3.hidden = hidden;
            if (!hidden) {
                [self.imageView_3 sd_setImageWithURL:[NSURL URLWithString:model.dramaCoverUrl]];
                [self.imageView_3 setTag:fillIndex];
                self.dramaDict[[NSString stringWithFormat:@"%ld", fillIndex]] = model;
                [self setMarkText:self.markLabel_3 fillIndex:fillIndex];
                self.titleLabel_3.text = model.dramaTitle;
                [self.descLabel_3 setTitle:[self formatPlayTimesString:model.dramaPlayTimes] forState:UIControlStateNormal];
            }
            break;
        }
        default:
            break;
    }
}

-(void)setMarkText:(BaseButton *)button fillIndex:(NSInteger)fillIndex {
    switch (fillIndex) {
        case 0:{
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, 32, 16);
            [button setBackgroundImage:[UIImage imageNamed:@"mini_drama_trending_top1" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
            [button setTitle:@"" forState:UIControlStateNormal];
            break;
        }
        case 1:{
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, 32, 16);
            [button setBackgroundImage:[UIImage imageNamed:@"mini_drama_trending_top2" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
            [button setTitle:@"" forState:UIControlStateNormal];
            break;
        }
        case 2:{
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, 32, 16);
            [button setBackgroundImage:[UIImage imageNamed:@"mini_drama_trending_top3" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
            [button setTitle:@"" forState:UIControlStateNormal];
            break;
        }
        default: {
            button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, 16, 16);
            [button setBackgroundImage:[UIImage imageNamed:@"mini_drama_trending_mark" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"%ld", fillIndex + 1] forState:UIControlStateNormal];
            break;
        }
    }
}

-(void)itemTapped:(UITapGestureRecognizer*)tap{
    [self.selectDelegate didMiniDramaSelectItem:self.dramaDict[[NSString stringWithFormat:@"%ld", tap.view.tag]]];
}

- (void)setMiniDramaData:(NSArray<MDDramaInfoModel *> *)datas startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex {
    [self.dramaDict removeAllObjects];
    [self hiddenItem:2 hidden:YES fillData:nil fillIndex:0];
    [self hiddenItem:3 hidden:YES fillData:nil fillIndex:0];
    int index = 1;
    for (int i = (int)startIndex; i <= endIndex; i++) {
        [self hiddenItem:index hidden:NO fillData:datas[i] fillIndex:i];
        index++;
    }
}

@end
