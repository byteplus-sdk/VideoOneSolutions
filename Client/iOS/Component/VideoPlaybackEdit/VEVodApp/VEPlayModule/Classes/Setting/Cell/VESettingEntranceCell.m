//
//  VESettingEntranceCell.m
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/11/2.
//

#import "VESettingEntranceCell.h"
#import "VESettingModel.h"
#import "UIColor+String.h"
#import "Masonry.h"
#import "Localizator.h"

const NSString *VESettingEntranceCellCellReuseID = @"VESettingEntranceCellCellReuseID";

@interface VESettingEntranceCell ()


@property (strong, nonatomic) UILabel *titleLabel;


@end

@implementation VESettingEntranceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor colorFromHexString:@"#020814"];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(28);
            make.centerY.equalTo(self);
        }];
        UIImageView *close = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_back"]];
        close.transform = CGAffineTransformRotate(close.transform, M_PI);
        [self.contentView addSubview:close];
        [close mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(self);
            make.size.equalTo(@(CGSizeMake(15, 15)));
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onButtonClick)];
        [self.contentView addGestureRecognizer:tap];
    }
    return self;
}


- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText];
}

- (void)onButtonClick {
    if (self.settingModel.allAreaAction) {
        self.settingModel.allAreaAction();
    }
}


@end
