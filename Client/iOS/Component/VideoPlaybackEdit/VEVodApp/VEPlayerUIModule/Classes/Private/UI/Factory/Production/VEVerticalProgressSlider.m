//
//  VEVerticalProgressSlider.m
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/10/27.
//

#import "VEVerticalProgressSlider.h"
#import "Masonry.h"

@interface VEVerticalProgressSlider ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIView *dotView;

@property (nonatomic, assign) BOOL layouted;

@end

@implementation VEVerticalProgressSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutSublayers];
    }
    return self;
}

- (void)layoutSublayers {
    self.backgroundView = [UIView new];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.32];
    
    self.progressView = [UIView new];
    self.progressView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    
    self.dotView = [UIView new];
    self.dotView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.dotView.layer.cornerRadius = 5;
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.progressView];
    [self addSubview:self.dotView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.layouted) {
        self.layouted = YES;
        CGSize size = self.bounds.size;
        self.backgroundView.frame = CGRectMake(size.width/2.0-1, 0, 2, size.height);
        self.progressView.frame = CGRectMake(size.width/2.0-1, 0, 2, size.height);
        self.dotView.frame = CGRectMake(size.width/2.0-5, size.height, 10, 10);
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(1.0, MAX(0, progress));
    if (self.frame.size.width > 0) {
        CGSize size = self.bounds.size;
        CGFloat top = (1-progress)*size.height;
        self.progressView.frame = CGRectMake(size.width/2.0-1, top, 2, size.height-top);
        self.dotView.center = CGPointMake(self.dotView.center.x, top);
    }
}

- (void)elementViewAction {
    
}

- (void)elementViewEventNotify:(id)obj {
    
}

- (BOOL)isEnableZone:(CGPoint)point {
    return NO;
}


@end
