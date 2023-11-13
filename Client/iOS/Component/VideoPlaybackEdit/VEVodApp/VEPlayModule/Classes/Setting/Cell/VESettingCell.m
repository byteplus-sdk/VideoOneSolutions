// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VESettingCell.h"
#import "Masonry.h"
#import "UIColor+String.h"

@interface VESettingCell ()



@end

@implementation VESettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorFromHexString:@"#F7F8FA"];
        self.bgView = [UIView new];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(12);
            make.right.equalTo(self).offset(-12);
            make.top.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)setCornerStyle:(SettingCellCornerStyle)cornerStyle {
    _cornerStyle = cornerStyle;
    self.bgView.layer.cornerRadius = 8;
    if (@available(iOS 11.0, *)) {
        switch (cornerStyle) {
            case SettingCellCornerStyleUp:
                self.bgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
                break;
            case SettingCellCornerStyleBottom:
                self.bgView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                break;
            case SettingCellCornerStyleFull:
                self.bgView.layer.cornerRadius = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                break;
            default:
                self.bgView.layer.cornerRadius = 0;
                break;
        }
    }
    
    
    
}

@end
