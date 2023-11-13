// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAvatarView.h"

@interface LiveAvatarView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LiveAvatarView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setUrl:(NSString *)url {
    _url = url;
    self.imageView.image = [UIImage imageNamed:url bundleName:ToolKitBundleName subBundleName:AvatarBundleName];
}

#pragma mark - Getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor whiteColor];
    }
    return _imageView;
}

@end
