// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "UserHeadView.h"
#import "AvatarView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>
@interface UserHeadView ()

@property (nonatomic, strong) AvatarView *avatarView;

@property (nonatomic, strong) UIImageView *bgView;
@end

@implementation UserHeadView

- (instancetype)init {
    self = [super init];
    if (self) {
        //        self.bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_bg" bundleName:@"App"]];
        //        self.bgView.contentMode = UIViewContentModeScaleAspectFill;
        //        [self addSubview:self.bgView];
        //        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.edges.equalTo(self);
        //        }];

        [self addSubview:self.avatarView];
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).mas_offset(85);
            make.centerX.equalTo(self);
            make.bottom.mas_lessThanOrEqualTo(self).mas_offset(-20);
        }];
    }
    return self;
}

- (void)setNameString:(NSString *)nameString {
    _nameString = nameString.copy;

    self.avatarView.text = nameString;
}
- (void)setIconString:(NSString *)iconString {
    _iconString = iconString.copy;
    self.avatarView.iconUrl = iconString;
}

- (AvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[AvatarView alloc] init];
    }
    return _avatarView;
}

@end
