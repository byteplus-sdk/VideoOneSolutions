// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELNetworkQualityView.h"
#import "VELCommonDefine.h"
#import <Masonry/Masonry.h>
@interface VELNetworkQualityView ()
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation VELNetworkQualityView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.level = 3;
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


- (void)setLevel:(NSInteger)level {
    _level = level;
    switch (level) {
        case 1:
            self.imageView.image = VELUIImageMake(@"medialive_net_bad");
            break;
        case 2:
            self.imageView.image = VELUIImageMake(@"medialive_net_poor");
            break;
        case 3:
            self.imageView.image = VELUIImageMake(@"medialive_net_good");
            break;
        default:
            self.imageView.image = VELUIImageMake(@"medialive_net_unknown");
            break;
    }
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}
@end
