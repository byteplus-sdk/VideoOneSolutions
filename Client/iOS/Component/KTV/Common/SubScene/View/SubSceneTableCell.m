// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "SubSceneTableCell.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/UIImage+Bundle.h>

@interface SubSceneTableCell ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desFirstLabel;
@property (nonatomic, strong) UILabel *desSecondLabel;

@end

@implementation SubSceneTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(16);
        make.right.equalTo(self.contentView).mas_offset(-16);
        make.top.equalTo(self.contentView).mas_offset(0);
        make.bottom.equalTo(self.contentView).mas_offset(-24);
    }];

    [self.maskView addSubview:self.backgroundImageView];
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.maskView);
    }];
    
    [self.maskView addSubview:self.desSecondLabel];
    [self.desSecondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@44);
        make.bottom.equalTo(@-16);
        make.right.lessThanOrEqualTo(self.backgroundImageView.mas_right);
    }];
    
    [self.maskView addSubview:self.desFirstLabel];
    [self.desFirstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@44);
        make.bottom.equalTo(@-36);
        make.right.lessThanOrEqualTo(self.backgroundImageView.mas_right);
    }];

    [self.maskView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@24);
        make.bottom.equalTo(@-60);
        make.right.lessThanOrEqualTo(self.backgroundImageView.mas_right);
    }];
    
    [self addIconImage:self.desFirstLabel];
    [self addIconImage:self.desSecondLabel];
}

- (void)setModel:(BaseSceneEntrance *)model {
    _model = model;
    self.backgroundImageView.image = [UIImage imageNamed:model.iconName bundleName:model.bundleName];
    self.titleLabel.text = model.title;
    if (model.desList.count >= 1) {
        self.desFirstLabel.text = model.desList.firstObject;
    }
    
    if (model.desList.count >= 2) {
        self.desSecondLabel.text = model.desList.lastObject;
    }
}

#pragma mark - Private Action

- (void)addIconImage:(UILabel *)label {
    label.clipsToBounds = NO;
    UIImageView *image = [[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"sub_scene_icon" bundleName:HomeBundleName];
    
    [label addSubview:image];
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@14);
        make.right.equalTo(label.mas_left).offset(-6);
        make.centerY.equalTo(label);
    }];
}

#pragma mark - Getter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
    }
    return _maskView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backgroundImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UILabel *)desFirstLabel {
    if (!_desFirstLabel) {
        _desFirstLabel = [[UILabel alloc] init];
        _desFirstLabel.textColor = [UIColor whiteColor];
        _desFirstLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _desFirstLabel.numberOfLines = 1;
    }
    return _desFirstLabel;
}

- (UILabel *)desSecondLabel {
    if (!_desSecondLabel) {
        _desSecondLabel = [[UILabel alloc] init];
        _desSecondLabel.textColor = [UIColor whiteColor];
        _desSecondLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _desSecondLabel.numberOfLines = 1;
    }
    return _desSecondLabel;
}

@end
