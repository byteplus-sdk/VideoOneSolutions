// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveDuringPKUserView.h"

@interface LiveDuringPKUserView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *leftAvatarImageView;
@property (nonatomic, strong) UILabel *leftNameLabel;
@property (nonatomic, strong) UIImageView *rightAvatarImageView;
@property (nonatomic, strong) UILabel *rightNameLabel;

@end

@implementation LiveDuringPKUserView

- (instancetype)initWithUserList:(NSArray<LiveUserModel *> *)userList {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imageView];
        [self addSubview:self.leftAvatarImageView];
        [self addSubview:self.leftNameLabel];
        [self addSubview:self.rightAvatarImageView];
        [self addSubview:self.rightNameLabel];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.leftAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(48, 48));
            make.left.mas_equalTo(16);
            make.centerY.equalTo(self);
        }];
        
        [self.leftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftAvatarImageView.mas_right).offset(6);
            make.centerY.equalTo(self);
            make.width.mas_lessThanOrEqualTo(70);
        }];
        
        [self.rightAvatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(48, 48));
            make.right.mas_equalTo(-16);
            make.centerY.equalTo(self);
        }];
        
        [self.rightNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.rightAvatarImageView.mas_left).offset(-6);
            make.centerY.equalTo(self);
            make.width.mas_lessThanOrEqualTo(70);
        }];
        
        LiveUserModel *leftUserModel = [self getUserModelWithType:YES
                                                         userList:userList];
        LiveUserModel *rightUserModel = [self getUserModelWithType:NO
                                                         userList:userList];
        self.leftNameLabel.text = leftUserModel.name;
        self.leftAvatarImageView.image = [UIImage imageNamed:leftUserModel.avatarName bundleName:HomeBundleName subBundleName:AvatarBundleName];
        
        self.rightNameLabel.text = rightUserModel.name;
        self.rightAvatarImageView.image = [UIImage imageNamed:rightUserModel.avatarName bundleName:HomeBundleName subBundleName:AvatarBundleName];
    }
    return self;
}

#pragma mark - Private Action

- (LiveUserModel *)getUserModelWithType:(BOOL)isLeft
                               userList:(NSArray<LiveUserModel *> *)userList {
    LiveUserModel *localUserModel = nil;
    for (LiveUserModel *userModel in userList) {
        if ([userModel.uid isEqualToString:[LocalUserComponent userModel].uid]) {
            localUserModel = userModel;
            break;
        }
    }
    if (isLeft) {
        return localUserModel;
    } else {
        NSMutableArray *mutableList = [[NSMutableArray alloc] initWithArray:userList];
        [mutableList removeObject:localUserModel];
        return mutableList.lastObject;
    }
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"pk_during" bundleName:HomeBundleName];
    }
    return _imageView;
}

- (UIImageView *)leftAvatarImageView {
    if (!_leftAvatarImageView) {
        _leftAvatarImageView = [[UIImageView alloc] init];
        _leftAvatarImageView.layer.cornerRadius = 24;
        _leftAvatarImageView.layer.masksToBounds = YES;
        _leftAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _leftAvatarImageView.layer.borderWidth = 2;
    }
    return _leftAvatarImageView;
}

- (UILabel *)leftNameLabel {
    if (!_leftNameLabel) {
        _leftNameLabel = [[UILabel alloc] init];
        _leftNameLabel.textColor = [UIColor whiteColor];
        _leftNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _leftNameLabel;
}

- (UIImageView *)rightAvatarImageView {
    if (!_rightAvatarImageView) {
        _rightAvatarImageView = [[UIImageView alloc] init];
        _rightAvatarImageView.layer.cornerRadius = 24;
        _rightAvatarImageView.layer.masksToBounds = YES;
        _rightAvatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _rightAvatarImageView.layer.borderWidth = 2;
    }
    return _rightAvatarImageView;
}

- (UILabel *)rightNameLabel {
    if (!_rightNameLabel) {
        _rightNameLabel = [[UILabel alloc] init];
        _rightNameLabel.textColor = [UIColor whiteColor];
        _rightNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    }
    return _rightNameLabel;
}

@end
