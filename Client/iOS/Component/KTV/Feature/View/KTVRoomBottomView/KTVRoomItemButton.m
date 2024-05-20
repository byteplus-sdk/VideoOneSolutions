// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVRoomItemButton.h"

@interface KTVRoomItemButton ()

@property (nonatomic, strong) UIImageView *redImageView;

@end

@implementation KTVRoomItemButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        _isRed = NO;
        
        [self addSubview:self.redImageView];
        [self.redImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(10, 10));
            make.top.equalTo(self);
            make.right.equalTo(self).offset(-1);
        }];
    }
    return self;
}


#pragma mark - Publish Action

- (void)setIsRed:(BOOL)isRed {
    _isRed = isRed;
    
    self.redImageView.hidden = !isRed;
}

#pragma mark - Getter


- (UIImageView *)redImageView {
    if (!_redImageView) {
        _redImageView = [[UIImageView alloc] init];
        _redImageView.image = [UIImage imageNamed:@"KTV_bottom_red" bundleName:HomeBundleName];
        _redImageView.hidden = YES;
    }
    return _redImageView;
}


@end
