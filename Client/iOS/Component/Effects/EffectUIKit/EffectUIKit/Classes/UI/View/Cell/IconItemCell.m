// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "IconItemCell.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"
static CGFloat const ModernFilterCellContentPadding = 2.f;

@interface IconItemCell ()

@property (nonatomic, strong) UIImageView *ivBorder;
@property (nonatomic, strong) UIImageView *iv;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, strong) DownloadView *dv;

@end

@implementation IconItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.borderLayer];
        [self addSubview:self.iv];
        [self addSubview:self.dv];
        
        [self.iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.bottom.equalTo(self).offset(-2 * ModernFilterCellContentPadding);
            make.leading.top.equalTo(self).offset(2 * ModernFilterCellContentPadding);
        }];
        
        [self.dv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12, 12));
            make.trailing.bottom.equalTo(self).with.offset(-2 * ModernFilterCellContentPadding - 2);
        }];
        
        _useCellSelectedState = NO;
    }
    return self;
}

- (void)setUseCellSelectedState:(BOOL)useCellSelectedState {
    _useCellSelectedState = useCellSelectedState;
    if (useCellSelectedState) {
        [self setIsSelected:self.selected];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (_useCellSelectedState) {
        [self setIsSelected:selected];
    }
}

- (void)setIsSelected:(BOOL)selected {
    self.borderLayer.hidden = !selected;
    [self setNeedsDisplay];
}

- (void)updateWithIcon:(NSString *)iconName {
    if ([iconName containsString:@"http://"] || [iconName containsString:@"https://"]) {
        NSAssert(NO, @"need network image sdk, do it by yourself");
    } else {
        self.iv.image = [EffectCommon imageNamed:iconName];
    }
}

- (void)setDownloadState:(DownloadViewState)state {
    _dv.hidden = NO;
    self.dv.state = state;
}

- (void)setDownloadProgress:(CGFloat)progress {
    self.dv.downloadProgress = progress;
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

- (DownloadView *)dv {
    if (_dv) {
        return _dv;
    }
    
    _dv = [DownloadView new];
    _dv.downloadImage = [EffectCommon imageNamed:@"ic_to_download"];
    _dv.hidden = YES;
    return _dv;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.frame = self.contentView.bounds;
        _borderLayer.contents = (id)[[EffectCommon imageNamed:@"ic_select_border"] CGImage];
        _borderLayer.hidden = YES;
    }
    return _borderLayer;
}

@end
