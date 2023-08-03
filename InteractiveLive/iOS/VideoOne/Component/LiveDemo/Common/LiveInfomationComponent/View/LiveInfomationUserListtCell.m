// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInfomationUserListtCell.h"
#import "LiveAvatarView.h"

@interface LiveInfomationUserListtCell ()

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation LiveInfomationUserListtCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)setModel:(LiveInfomationModel *)model {
    _model = model;
    self.messageLabel.text = model.title;
    self.valueLabel.text = model.value;
    self.lineView.hidden = !model.isSegmentation;
}

- (void)createUIComponent {
    [self.contentView addSubview:self.valueLabel];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(16);
        make.centerY.equalTo(self.contentView);
        make.right.mas_lessThanOrEqualTo(self.valueLabel.mas_left).offset(-3);
    }];
    
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.top.equalTo(self);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Getter

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = [UIColor colorFromHexString:@"#CCCED0"];
        _valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _valueLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor colorFromHexString:@"#FFFFFF"];
        _messageLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _messageLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.15 * 255];
        _lineView.hidden = YES;
    }
    return _lineView;
}

@end
