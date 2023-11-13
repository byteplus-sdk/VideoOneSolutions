// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEMaskView.h"
#import "UIView+VEElementDescripition.h"

@interface VEMaskView () 

@property (nonatomic, strong) CALayer *fullMask;
@property (nonatomic, strong) CAGradientLayer *topMask;
@property (nonatomic, strong) CAGradientLayer *bottomMask;

@end

@implementation VEMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha: 0.12];
        
        _topHeight = 48.0;
        _bottomHeight = 50.0;
        
        _topMask = [[CAGradientLayer alloc] init];
        _topMask.startPoint = CGPointMake(0.5, 0);
        _topMask.endPoint = CGPointMake(0.5, 1.0);
        [self.layer addSublayer:_topMask];
        
        _bottomMask = [[CAGradientLayer alloc] init];
        _bottomMask.startPoint = CGPointMake(0.5, 0);
        _bottomMask.endPoint = CGPointMake(0.5, 1.0);
        _bottomMask.colors = @[
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.0].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.02].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.05].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.11].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.18].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.27].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.36].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.46].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:0 alpha: 0.55].CGColor,
        ];
        [self.layer addSublayer:_bottomMask];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGSize size = self.bounds.size;
    _topMask.frame = CGRectMake(0, 0, size.width, _topHeight);
    _bottomMask.frame = CGRectMake(0, size.height - _bottomHeight, size.width, _bottomHeight);
    [CATransaction commit];
}

- (void)setTopHeight:(CGFloat)topHeight {
    _topHeight = topHeight;
    [self setNeedsLayout];
}

- (void)setBottomHeight:(CGFloat)bottomHeight {
    _bottomHeight = bottomHeight;
    [self setNeedsLayout];
}

- (void)elementViewAction {
    
}

- (void)elementViewEventNotify:(id)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)obj;
        if (self.elementDescription.elementNotify) {
            self.elementDescription.elementNotify(self, [[paramDic allKeys] firstObject], [[paramDic allValues] firstObject]);
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    return NO;
}

@end
