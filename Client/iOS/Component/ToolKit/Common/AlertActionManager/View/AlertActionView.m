// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AlertActionView.h"
#import "Masonry.h"

@interface AlertActionView ()

@property (nonatomic, strong) UIView *userView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *verticalLineView;

@property (nonatomic, copy) NSArray *alertActionList;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *describe;

@end

@implementation AlertActionView

- (instancetype)initWithTitle:(NSString *)title
                     describe:(NSString *)describe
              alertActionList:(NSArray *)alertActionList
               alertUserModel:(AlertUserModel *)alertUserModel {
    self = [super init];
    if (self) {
        self.alertActionList = alertActionList;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;

        [self addSubview:self.userView];
        [self.userView addSubview:self.avatarImageView];
        [self.userView addSubview:self.userNameLabel];
        [self addSubview:self.messageLabel];
        [self addSubview:self.describeLabel];
        [self addSubview:self.lineView];

        [self.userView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.mas_equalTo(28);
            make.top.mas_equalTo(24);
        }];

        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(28, 28));
            make.top.left.equalTo(self.userView);
        }];

        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.userView);
            make.centerY.equalTo(self.avatarImageView);
            make.left.equalTo(self.avatarImageView.mas_right).mas_equalTo(8);
            make.width.mas_lessThanOrEqualTo(120);
        }];

        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            NSInteger topOffset = alertUserModel ? 64 : 24;
            make.top.equalTo(self).offset(topOffset);
        }];

        [self.describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.equalTo(self.messageLabel.mas_bottom).offset(12);
        }];

        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.describeLabel.mas_bottom).offset(20);
            make.height.mas_equalTo(1);
        }];
        // Update data
        self.messageLabel.text = title;
        self.describeLabel.text = describe;
        if (alertUserModel) {
            self.avatarImageView.image = alertUserModel.avatarImage;
            self.userNameLabel.text = alertUserModel.userName;
        }
        NSMutableArray *buttonList = [[NSMutableArray alloc] init];
        for (int i = 0; i < alertActionList.count; i++) {
            AlertActionModel *actionModel = alertActionList[i];
            UIButton *button = [[UIButton alloc] init];
            button.tag = 3000 + i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:actionModel.title forState:UIControlStateNormal];
            switch (i) {
                case 0:
                    [button setTitleColor:actionModel.textColor ?: [UIColor colorWithRed:0.25 green:0.27 blue:0.31 alpha:1.0] forState:UIControlStateNormal];
                    button.titleLabel.font = actionModel.font ?: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
                    break;
                case 1:
                    [button setTitleColor:actionModel.textColor ?: [UIColor colorWithRed:0.09 green:0.09 blue:0.14 alpha:1.0] forState:UIControlStateNormal];
                    button.titleLabel.font = actionModel.font ?: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
                    break;
                default:
                    break;
            }
            [self addSubview:button];
            [buttonList addObject:button];
        }

        UIButton *lastButton = nil;
        if (buttonList.count > 1) {
            [buttonList mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
            [buttonList mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.lineView.mas_bottom);
                make.bottom.equalTo(self);
                make.height.mas_equalTo(48);
            }];
            lastButton = buttonList.lastObject;
        } else if (buttonList.count == 1) {
            UIButton *button = buttonList[0];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.lineView.mas_bottom);
                make.width.bottom.equalTo(self);
                make.height.mas_equalTo(48);
            }];
        } else {
            // error
        }

        [self addSubview:self.verticalLineView];
        if (lastButton) {
            self.verticalLineView.hidden = NO;
            [self.verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.top.equalTo(lastButton);
                make.width.mas_equalTo(1);
            }];
        } else {
            self.verticalLineView.hidden = YES;
        }
    }
    return self;
}

#pragma mark - Private Action

- (void)buttonAction:(UIButton *)sender {
    AlertActionModel *model = self.alertActionList[sender.tag - 3000];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:model.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){

    }];
    if (self.clickButtonBlock) {
        self.clickButtonBlock();
    }
    if (model.alertModelClickBlock) {
        model.alertModelClickBlock(alertAction);
    }
}

#pragma mark - Getter

- (UIView *)userView {
    if (!_userView) {
        _userView = [[UIView alloc] init];
        _userView.backgroundColor = [UIColor clearColor];
    }
    return _userView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 14;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textColor = [UIColor colorWithRed:0.01 green:0.03 blue:0.08 alpha:1.0];
        _userNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _userNameLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _messageLabel.textColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.14 alpha:1.0];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

- (UILabel *)describeLabel {
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc] init];
        _describeLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _describeLabel.textColor = [UIColor colorWithRed:0.25 green:0.27 blue:0.31 alpha:1.0];
        _describeLabel.numberOfLines = 0;
        _describeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _describeLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:22 / 255 green:23 / 255 blue:35 / 255 alpha:0.12];
    }
    return _lineView;
}

- (UIView *)verticalLineView {
    if (!_verticalLineView) {
        _verticalLineView = [[UIView alloc] init];
        _verticalLineView.backgroundColor = [UIColor colorWithRed:22 / 255 green:23 / 255 blue:35 / 255 alpha:0.12];
    }
    return _verticalLineView;
}

@end
