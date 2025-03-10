// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "RectangleSelectableView.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"
static CGFloat const RectangleSelectableViewPadding = 2.f;

@implementation RectangleSelectableConfig

@synthesize imageSize = _imageSize;

+ (instancetype)initWithImageName:(NSString *)imageName imageSize:(CGSize)imageSize {
    RectangleSelectableConfig *config = [[self alloc] init];
    config.imageName = imageName;
    config.imageSize = imageSize;
    return config;
}

- (RectangleSelectableView *)generateView {
    RectangleSelectableView *v = [[RectangleSelectableView alloc] init];
    if ([self.imageName containsString:@"http://"] || [self.imageName containsString:@"https://"]) {
        NSAssert(NO, @"need network sdk, do it by yourself");
    } else {
        v.iv.image = [EffectCommon imageNamed:self.imageName];
    }
    return v;
}

@end

@interface RectangleSelectableView ()

@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end

@implementation RectangleSelectableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.borderLayer];
        [self addSubview:self.iv];
        
        [self.iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.bottom.equalTo(self).offset(-1.5 * RectangleSelectableViewPadding);
            make.leading.top.equalTo(self).offset(1.5 * RectangleSelectableViewPadding);
            make.width.height.mas_equalTo(60);
        }];
        self.iv.layer.masksToBounds = YES;
        self.iv.layer.cornerRadius = 2;
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected {
    [super setIsSelected:isSelected];
    
    self.borderLayer.hidden = !isSelected;
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.borderLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
}

#pragma mark getter
- (UIImageView *)iv {
    if (!_iv) {
        _iv = [UIImageView new];
        _iv.contentMode = UIViewContentModeScaleAspectFill;
        _iv.clipsToBounds = YES;
    }
    return _iv;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.frame = self.bounds;
        _borderLayer.contents = (id)[[EffectCommon imageNamed:@"ic_select_border"] CGImage];
        _borderLayer.hidden = YES;
    }
    return _borderLayer;
}

@end
