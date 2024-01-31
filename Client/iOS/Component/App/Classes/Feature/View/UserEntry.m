//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "UserEntry.h"
#import "Masonry.h"
#import "ToolKit.h"

@interface UserEntry ()

@property (nonatomic, strong) UIImageView *avatarIconView;

@end

@implementation UserEntry

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.avatarIconView];
        [self.avatarIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).priority(MASLayoutPriorityDefaultLow);
            make.center.equalTo(self);
            make.size.mas_lessThanOrEqualTo(30);
        }];
    }
    return self;
}

- (void)reloadData {
    self.avatarIconView.image = [UIImage imageNamed:[LocalUserComponent userModel].avatarName
                                         bundleName:ToolKitBundleName
                                      subBundleName:AvatarBundleName];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cornerRadius = (MIN(MIN(self.bounds.size.width, self.bounds.size.height), 30)) * 0.5;
    self.avatarIconView.layer.cornerRadius = cornerRadius;
}

- (UIImageView *)avatarIconView {
    if (!_avatarIconView) {
        _avatarIconView = [[UIImageView alloc] init];
        _avatarIconView.clipsToBounds = YES;
        _avatarIconView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarIconView.backgroundColor = [UIColor colorFromHexString:@"#D9D9D9"];
    }
    return _avatarIconView;
}

@end
