// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEMultiStatePlayButton.h"
#import "Localizator.h"
#import "Masonry.h"
#import "UIColor+String.h"
#import <ToolKit/ToolKit.h>

@interface VEMultiStatePlayButton ()

@property (nonatomic, strong) UIImageView *bigIcon;

@property (nonatomic, strong) UIImageView *replayIcon;
@property (nonatomic, strong) UILabel *replayLabel;

@end

@implementation VEMultiStatePlayButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bigIcon = [[UIImageView alloc] init];
        [self addSubview:self.bigIcon];
        [self.bigIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(@(CGSizeMake(50, 50)));
        }];

        self.replayIcon = [[UIImageView alloc] init];
        self.replayIcon.image = [UIImage imageNamed:@"vod_rotate" bundleName:@"VodPlayer"];
        [self addSubview:self.replayIcon];

        UILabel *label = [UILabel new];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = LocalizedStringFromBundle(@"vod_replay", @"VodPlayer");
        [self addSubview:label];
        self.replayLabel = label;

        [self.replayIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(18);
            make.centerY.equalTo(self);
            make.size.equalTo(@(CGSizeMake(16, 16)));
            make.top.equalTo(self).offset(10);
            make.bottom.equalTo(self).offset(-10);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.replayIcon.mas_right).offset(6);
            make.right.equalTo(self).offset(-18);
            make.centerY.equalTo(self);
        }];
        //        self.backgroundColor = [UIColor colorFromRGBHexString:@"#292929" andAlpha:0.34*255];
        self.layer.borderColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.2 * 255].CGColor;
        self.layer.cornerRadius = 5;
        self.replayIcon.hidden = YES;
        self.replayLabel.hidden = YES;
    }
    return self;
}

- (void)setPlayState:(VEMultiStatePlayState)playState {
    _playState = playState;
    switch (playState) {
        case VEMultiStatePlayStateUnknown: {
            self.hidden = YES;
            return;
        }
        case VEMultiStatePlayStatePlay:
        case VEMultiStatePlayStatePause: {
            self.bigIcon.image = [UIImage imageNamed:playState == VEMultiStatePlayStatePlay ? @"video_play" : @"video_pause" bundleName:@"VodPlayer"];
        } break;
        default:
            break;
    }
    self.bigIcon.hidden = playState == VEMultiStatePlayStateReplay;
    self.replayIcon.hidden = playState != VEMultiStatePlayStateReplay;
    self.replayLabel.hidden = playState != VEMultiStatePlayStateReplay;
    self.layer.borderWidth = playState == VEMultiStatePlayStateReplay ? 1.0 : 0;
    self.backgroundColor = playState == VEMultiStatePlayStateReplay ? [UIColor colorFromRGBHexString:@"#292929" andAlpha:0.34 * 255] : [UIColor clearColor];
}

- (void)setHidden:(BOOL)hidden {
    if (_playState == VEMultiStatePlayStateUnknown) {
        [super setHidden:YES];
        return;
    }
    [super setHidden:hidden];
}

@end
