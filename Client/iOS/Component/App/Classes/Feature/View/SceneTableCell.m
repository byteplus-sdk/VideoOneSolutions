// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "SceneTableCell.h"
#import "Localizator.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/UIImage+Bundle.h>

@interface SceneGradientButton : UIButton

@end

@implementation SceneGradientButton

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *startColor = [UIColor colorFromHexString:@"#2F69FF"];
        UIColor *middleColor = [UIColor colorFromHexString:@"#6147FF"];
        UIColor *endColor = [UIColor colorFromHexString:@"#C446FF"];
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.colors = @[(id)startColor.CGColor, (id)middleColor.CGColor, (id)endColor.CGColor];
        gradientLayer.locations = @[@0, @0.47, @1];
        gradientLayer.startPoint = CGPointMake(0.25, 0.5);
        gradientLayer.endPoint = CGPointMake(0.75, 0.5);
    }
    return self;
}

@end

@interface SceneTableCell ()
@property (nonatomic, strong) UIImageView *tipIconV;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIImageView *iconV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) SceneGradientButton *actionBtn;
@end

@implementation SceneTableCell
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

    UIView *shadowView = [[UIView alloc] init];
    shadowView.backgroundColor = [UIColor colorFromHexString:@"#F6FAFD"];
    [self.contentView addSubview:shadowView];
    shadowView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.04].CGColor;
    shadowView.layer.shadowRadius = 16;
    shadowView.layer.shadowOpacity = 1;
    shadowView.layer.cornerRadius = 12;
    shadowView.layer.shadowOffset = CGSizeMake(0, 4);

    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 12;
    contentView.clipsToBounds = YES;
    [self.contentView addSubview:contentView];
    [@[shadowView, contentView] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).mas_offset(16);
        make.right.equalTo(self.contentView).mas_offset(-16);
        make.top.equalTo(self.contentView).mas_offset(8);
        make.bottom.equalTo(self.contentView).mas_offset(-8);
    }];

    self.iconV = [[UIImageView alloc] init];
    self.iconV.contentMode = UIViewContentModeScaleAspectFill;
    self.iconV.clipsToBounds = YES;
    self.iconV.layer.cornerRadius = 8;
    [contentView addSubview:self.iconV];
    [self.iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
        make.height.mas_equalTo(135);
        make.width.equalTo(self.iconV.mas_height);
    }];

    self.tipIconV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_icon_bg" bundleName:@"App"]];
    [contentView addSubview:self.tipIconV];
    [self.tipIconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(43, 20));
    }];

    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.text = LocalizedStringFromBundle(@"home_icon_new_tip", @"App");
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.font = [UIFont fontWithName:@"Roboto" size:10] ?: [UIFont systemFontOfSize:10 weight:700];
    [self.tipIconV addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.tipIconV);
    }];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor colorFromHexString:@"#1D2129"];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    [contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconV.mas_right).mas_offset(12);
        make.top.equalTo(self.iconV);
        make.right.mas_lessThanOrEqualTo(contentView).mas_offset(-12);
    }];

    self.desLabel = [[UILabel alloc] init];
    self.desLabel.textColor = [UIColor colorFromHexString:@"#4E5969"];
    self.desLabel.font = [UIFont systemFontOfSize:12];
    self.desLabel.numberOfLines = 0;
    [contentView addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(4);
        make.right.mas_lessThanOrEqualTo(contentView).mas_offset(-12);
    }];

    self.actionBtn = [[SceneGradientButton alloc] init];
    self.actionBtn.layer.cornerRadius = 8;
    self.actionBtn.clipsToBounds = YES;
    [contentView addSubview:self.actionBtn];
    [self.actionBtn addTarget:self action:@selector(actionBtnDidClick:) forControlEvents:(UIControlEventTouchUpInside)];
    self.actionBtn.titleLabel.font = [UIFont fontWithName:@"Roboto" size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.actionBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.actionBtn setTitle:LocalizedStringFromBundle(@"home_cell_try", @"App") forState:(UIControlStateNormal)];
    [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconV.mas_right).mas_offset(12);
        make.right.equalTo(contentView).mas_offset(-12);
        make.bottom.equalTo(contentView).mas_offset(-16);
        make.height.mas_equalTo(36).priorityHigh();
        make.top.mas_greaterThanOrEqualTo(self.desLabel.mas_bottom).mas_offset(12);
    }];
}

- (void)setModel:(BaseSceneEntrance *)model {
    _model = model;
    self.tipIconV.hidden = !model.isNew;
    if (model.iconNames != nil && model.iconNames.count > 0) {
        NSMutableArray<UIImage *> *images = [NSMutableArray arrayWithCapacity:model.iconNames.count];
        [model.iconNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            UIImage *img = [UIImage imageNamed:obj bundleName:@"App"];
            if (img != nil) {
                [images addObject:img];
            }
        }];
        self.iconV.animationImages = images;
        self.iconV.animationDuration = images.count * 1.25;
        [self.iconV startAnimating];
    } else {
        self.iconV.image = [UIImage imageNamed:model.iconName bundleName:@"App"];
    }
    self.nameLabel.text = model.title;
    self.desLabel.text = model.des;
}

- (void)actionBtnDidClick:(UIButton *)btn {
    if (self.goAction) {
        self.goAction(self, self.model);
    }
}

@end
