//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FullScreenVideoGestureGuide.h"
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/UIColor+String.h>

@interface __FullScreenVideoGestureGuideItemView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLable;

@end

@implementation __FullScreenVideoGestureGuideItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.equalTo(self);
            make.size.mas_equalTo(100);
        }];

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.preferredMaxLayoutWidth = 164.0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.imageView.mas_bottom).offset(14.f);
        }];

        self.desLable = [[UILabel alloc] init];
        self.desLable.textColor = [UIColor colorFromHexString:@"#9DA3AF"];
        self.desLable.font = [UIFont systemFontOfSize:12.f];
        self.desLable.numberOfLines = 0;
        self.desLable.preferredMaxLayoutWidth = 164.0;
        self.desLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.desLable];
        [self.desLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(4.f);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}

@end

@interface __FullScreenVideoGestureGuideView : UIView

@end

@implementation __FullScreenVideoGestureGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];

        __FullScreenVideoGestureGuideItemView *middleGuide = [[__FullScreenVideoGestureGuideItemView alloc] init];
        middleGuide.imageView.image = [UIImage imageNamed:@"vod_full_screen_video_middle_guide"];
        middleGuide.titleLabel.text = LocalizedStringFromBundle(@"full_screen_video_middle_guide_title", @"VEVodApp");
        middleGuide.desLable.text = LocalizedStringFromBundle(@"full_screen_video_middle_guide_des", @"VEVodApp");
        [self addSubview:middleGuide];
        [middleGuide mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];

        __FullScreenVideoGestureGuideItemView *leftGuide = [[__FullScreenVideoGestureGuideItemView alloc] init];
        leftGuide.imageView.image = [UIImage imageNamed:@"vod_full_screen_video_left_guide"];
        leftGuide.titleLabel.text = LocalizedStringFromBundle(@"full_screen_video_left_guide_title", @"VEVodApp");
        leftGuide.desLable.text = LocalizedStringFromBundle(@"full_screen_video_left_guide_des", @"VEVodApp");
        [self addSubview:leftGuide];
        [leftGuide mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(middleGuide);
            make.trailing.equalTo(middleGuide.mas_leading).offset(-68);
        }];

        __FullScreenVideoGestureGuideItemView *rightGuide = [[__FullScreenVideoGestureGuideItemView alloc] init];
        rightGuide.imageView.image = [UIImage imageNamed:@"vod_full_screen_video_right_guide"];
        rightGuide.titleLabel.text = LocalizedStringFromBundle(@"full_screen_video_right_guide_title", @"VEVodApp");
        rightGuide.desLable.text = LocalizedStringFromBundle(@"full_screen_video_right_guide_des", @"VEVodApp");
        [self addSubview:rightGuide];
        [rightGuide mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(middleGuide);
            make.leading.equalTo(middleGuide.mas_trailing).offset(68);
        }];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3.0];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeFromSuperview];
}

@end

@implementation FullScreenVideoGestureGuide

+ (void)addGuideIfNeed:(UIView *)superView {
    if ([self getFullScreenVideoGestureGuideFlag]) {
        return;
    }
    [self setFullScreenVideoGestureGuideFlag:YES];
    __FullScreenVideoGestureGuideView *guideView = [[__FullScreenVideoGestureGuideView alloc] initWithFrame:superView.bounds];
    [superView addSubview:guideView];
    [guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
}

+ (BOOL)getFullScreenVideoGestureGuideFlag {
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"K_FullScreenVideoGestureGuideFlag"];
    return [number boolValue];
}

+ (void)setFullScreenVideoGestureGuideFlag:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setValue:@(flag) forKey:@"K_FullScreenVideoGestureGuideFlag"];
}

@end
