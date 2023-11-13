// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BaseIMCell.h"
#import "Masonry.h"
#import "UIColor+String.h"

@interface BaseIMCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *roomNameLabel;

@end

@implementation BaseIMCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self createUIComponent];
    }
    return self;
}

- (void)setModel:(BaseIMModel *)model {
    _model = model;

    [self setLineSpace:5
                  name:model.userName
               message:model.message
               inLabel:self.roomNameLabel
                 image:model.iconImage];

    if (model.backgroundColor) {
        self.bgView.backgroundColor = model.backgroundColor;
    } else {
        // Default color
        self.bgView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.24 * 255];
    }
}

- (void)contentViewClickAction {
    if (self.model.clickBlock) {
        self.model.clickBlock(self.model);
    }
}

#pragma mark - Private Action

- (void)createUIComponent {
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(4);
        make.bottom.left.equalTo(self.contentView);
        make.width.lessThanOrEqualTo(self.contentView);
    }];

    [self.bgView addSubview:self.roomNameLabel];
    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(8.5);
        make.top.equalTo(self.bgView).offset(5);
        make.right.equalTo(self.bgView).offset(-8.5);
        make.bottom.equalTo(self.bgView).offset(-5);
    }];

    self.bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewClickAction)];
    [self.bgView addGestureRecognizer:tap];
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

    if (image) {
        name = [NSString stringWithFormat:@" %@：", name];
    } else {
        name = [name stringByAppendingString:@"："];
    }
    NSString *cellMessage = [NSString stringWithFormat:@"%@%@", name, message];
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

    if (image) {
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        attch.image = image;
        attch.bounds = CGRectMake(0, label.font.descender + 1.5, 26, 14);
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attch];
        [attributedString insertAttributedString:imageString atIndex:0];
    }

    label.attributedText = attributedString;
}

#pragma mark - Getter

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.textColor = [UIColor whiteColor];
        _roomNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _roomNameLabel.numberOfLines = 0;
    }
    return _roomNameLabel;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.24 * 255];
        _bgView.layer.cornerRadius = 14;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

@end
