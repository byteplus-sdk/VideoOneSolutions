// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveJoinIMView.h"

@interface LiveJoinIMView ()

@property (nonatomic, strong) UIImageView *joinImageView;
@property (nonatomic, strong) UILabel *roomNameLabel;

@end

@implementation LiveJoinIMView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)addIM:(BaseIMModel *)model {
    [self setLineSpace:5
                  name:model.userName
               message:model.message
               inLabel:self.roomNameLabel
                 image:model.iconImage];
}

#pragma mark - Private Action

- (void)createUIComponent {
    [self addSubview:self.joinImageView];
    [self.joinImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(28, 28));
        make.left.centerY.equalTo(self);
    }];

    [self addSubview:self.roomNameLabel];
    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.joinImageView.mas_right).offset(6);
        make.right.centerY.equalTo(self);
    }];
}

#pragma mark - Private Action

- (void)setLineSpace:(CGFloat)lineSpace
                name:(NSString *)name
             message:(NSString *)message
             inLabel:(UILabel *)label
               image:(UIImage *)image {
    if (!message || !label) {
        return;
    }

    self.joinImageView.image = image;
    NSString *cellMessage = [NSString stringWithFormat:@"%@ %@", name, message];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cellMessage];

    if (label) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = lineSpace;
        paragraphStyle.lineBreakMode = label.lineBreakMode;
        paragraphStyle.alignment = label.textAlignment;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [cellMessage length])];
    }

    if (NOEmptyStr(name) && NOEmptyStr(message)) {
        UIColor *nameColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.75 * 255];
        UIColor *textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:1.0 * 255];
        NSRange nameRange = [cellMessage rangeOfString:name];
        NSRange textRange = [cellMessage rangeOfString:message];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:nameColor
                                 range:nameRange];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:textColor
                                 range:textRange];
    }

    label.attributedText = attributedString;
}

#pragma mark - Getter

- (UIImageView *)joinImageView {
    if (!_joinImageView) {
        _joinImageView = [[UIImageView alloc] init];
    }
    return _joinImageView;
}

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.textColor = [UIColor whiteColor];
        _roomNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _roomNameLabel.numberOfLines = 1;
    }
    return _roomNameLabel;
}

@end
