// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "LightUpSelectableView.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"
@implementation LightUpSelectableConfig
@synthesize imageSize = _imageSize;

+ (instancetype)initWithUnselectImage:(NSString *)unselectImage imageSize:(CGSize)imageSize {
    LightUpSelectableConfig *config = [self new];
//    config.selectedImageName = selectImage;
    config.unselectedImageName = unselectImage;
    config.imageSize = imageSize;
    return config;
}

- (LightUpSelectableView *)generateView {
    LightUpSelectableView *v = [[LightUpSelectableView alloc] init];
//    v.selectedImageName = self.selectedImageName;
    v.unselectedImageName = self.unselectedImageName;
    return v;
}

@end

@interface LightUpSelectableView ()

@property (nonatomic, strong) UIImageView *iv;

@end

@implementation LightUpSelectableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iv];
        
        [self.iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.bottom.equalTo(self);
            make.leading.top.equalTo(self);
        }];
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    [super setIsSelected:isSelected];

    self.iv.alpha = isSelected ? 1 : 0.5;
}

//- (void)setSelectedImageName:(NSString *)selectedImageName {
//    _selectedImageName = selectedImageName;
//    
//    if (self.isSelected) {
//        self.iv.image = [EffectCommon imageNamed:selectedImageName];
//    }
//}

- (void)setUnselectedImageName:(NSString *)unselectedImageName {
    _unselectedImageName = unselectedImageName;
    
    if (!self.isSelected) {
        self.iv.image = [EffectCommon imageNamed:[NSString stringWithFormat:@"%@", unselectedImageName]];
    }
}

#pragma mark - getter
- (UIImageView *)iv {
    if (!_iv) {
        _iv = [UIImageView new];
        _iv.contentMode = UIViewContentModeScaleAspectFill;
        _iv.clipsToBounds = YES;
    }
    return _iv;
}

@end
