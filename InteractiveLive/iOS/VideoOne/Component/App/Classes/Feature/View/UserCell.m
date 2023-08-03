// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "UserCell.h"
#import "LocalizatorBundle.h"
#import "Masonry.h"
#import "ToolKit.h"

@interface UserCell ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desTitleLabel;
@property (nonatomic, strong) UIImageView *moreImageView;
@property (nonatomic, strong) UIView *bgView;
@end

@implementation UserCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)setModel:(MenuCellModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    if ([model.title isEqualToString:LocalizedStringFromBundle(@"user_name", @"App")]) {
        self.desTitleLabel.text = [LocalUserComponent userModel].name;
    } else {
        self.desTitleLabel.text = model.desTitle;
    }
    
    CGFloat desRight = 0;
    if (model.isMore) {
        desRight = -40;
        self.moreImageView.hidden = NO;
    } else {
        desRight = -16;
        self.moreImageView.hidden = YES;
    }

    [self.desTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(desRight);
    }];
}

#pragma mark - Private Action

- (void)createUIComponent {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 32, 60)];
    contentView.backgroundColor = [UIColor whiteColor];
    self.bgView = contentView;
    [self addCornerMask];
    [self.contentView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).mas_offset(16);
        make.right.equalTo(self.contentView.mas_right).mas_offset(-16);
    }];
    
    [contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(16);
        make.centerY.equalTo(contentView);
    }];
    
    [contentView addSubview:self.desTitleLabel];
    [self.desTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.titleLabel);
        make.width.mas_lessThanOrEqualTo(150);
    }];
    
    [contentView addSubview:self.moreImageView];
    [self.moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.titleLabel);
    }];
    
    [contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16.f);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(contentView);
        make.right.equalTo(contentView);
    }];
}

- (void)setCorner:(UIRectCorner)corner {
    _corner = corner;
    [self addCornerMask];
}

- (void)addCornerMask {
    if (self.corner < 1) {
        self.bgView.layer.mask = nil;
        return;
    }
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bgView.bounds byRoundingCorners:self.corner cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bgView.bounds;
    maskLayer.path = bezierPath.CGPath;
    self.bgView.layer.mask = maskLayer;
}

#pragma mark - Private Action

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addCornerMask];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#020814"];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)desTitleLabel {
    if (!_desTitleLabel) {
        _desTitleLabel = [[UILabel alloc] init];
        _desTitleLabel.textColor = [UIColor colorFromHexString:@"#80838A"];
        _desTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _desTitleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor clearColor];
    }
    return _lineView;
}

- (UIImageView *)moreImageView {
    if (!_moreImageView) {
        _moreImageView = [[UIImageView alloc] init];
        _moreImageView.image = [UIImage imageNamed:@"menu_list_more" bundleName:@"App"];
    }
    return _moreImageView;
}

@end
