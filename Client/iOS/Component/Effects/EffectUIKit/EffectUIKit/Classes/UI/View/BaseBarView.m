// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BaseBarView.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"

@interface BaseBarView ()

@property (nonatomic, strong) UIButton *btnOpen;
@property (nonatomic, strong) UIButton *btnImagePicker;
@property (nonatomic, strong) UIButton *btnSetting;
@property (nonatomic, strong) UIButton *btnSwitchCamera;
@property (nonatomic, strong) UIButton *btnReset;
@property (nonatomic, strong) UILabel *ptvFrameTime;
@property (nonatomic, strong) UILabel *ptvFrameCount;

@end

@implementation BaseBarView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat TOP_BUTTON_WIDTH = (32);
        CGFloat RECORD_BUTTON_WIDTH = (56.f);
        
        [self addSubview:self.btnBack];
        [self addSubview:self.btnImagePicker];
        [self addSubview:self.btnSetting];
        [self addSubview:self.btnSwitchCamera];
        [self addSubview:self.btnOpen];
        [self addSubview:self.btnReset];
        [self addSubview:self.btnRecord];
        [self addSubview:self.btnPlay];
        [self addSubview:self.btnVideoPicker];
        
        NSArray<UIView *> *barArray = [NSArray arrayWithObjects:self.btnBack, self.btnImagePicker, self.btnSetting, self.btnSwitchCamera, nil];
        [barArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                           withFixedItemLength:TOP_BUTTON_WIDTH
                                   leadSpacing:30
                                   tailSpacing:30];
        [barArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.topMargin.mas_equalTo(10);
            make.height.mas_equalTo(TOP_BUTTON_WIDTH);
        }];
        
        [self.btnRecord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.height.mas_equalTo(RECORD_BUTTON_WIDTH);
            make.bottom.equalTo(self).offset(-RECORD_BUTTON_WIDTH);
        }];
        
        [self.btnOpen mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(TOP_BUTTON_WIDTH);
            make.centerY.equalTo(self.btnRecord);
            make.leading.equalTo(self).offset(50);
        }];
        
        [self.btnReset mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(TOP_BUTTON_WIDTH);
            make.centerY.equalTo(self.btnRecord);
            make.right.equalTo(self).offset(-50);
        }];
        
        [self.btnPlay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.width.mas_equalTo(RECORD_BUTTON_WIDTH);
        }];
        [self.btnPlay.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.btnPlay);
        }];
        
        [self.btnVideoPicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.width.mas_equalTo((64));
        }];
    }
    return self;
}

#pragma mark - public
- (void)showBoard {
    self.btnOpen.hidden = NO;
    if (self.showReset) {
        self.btnReset.hidden = NO;
    }
    self.btnRecord.hidden = NO;
}

- (void)hideBoard {
    self.btnOpen.hidden = YES;
    self.btnReset.hidden = YES;
    self.btnRecord.hidden = YES;
}

- (void)showBar:(NSInteger)mode {
    self.btnBack.hidden = (mode & BaseBarBack) == 0;
    self.btnSetting.hidden = (mode & BaseBarSetting) == 0;
    self.btnImagePicker.hidden = (mode & BaseBarImagePicker) == 0;
    self.btnSwitchCamera.hidden = (mode & BaseBarSwitch) == 0;
}

- (void)showProfile:(BOOL)show {
    if (show) {
        [self addSubview:self.ptvFrameTime];
        [self addSubview:self.ptvFrameCount];
        [self addSubview:self.lInputResolution];
        [self.ptvFrameCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(250, 20));
            make.top.equalTo(self).offset(100);
            make.leading.equalTo(self).offset(20);
        }];
        [self.ptvFrameTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.trailing.equalTo(self.ptvFrameCount);
            make.top.mas_equalTo(self.ptvFrameCount.mas_bottom);
        }];
        [self.lInputResolution mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.trailing.equalTo(self.ptvFrameCount);
            make.top.mas_equalTo(self.ptvFrameTime.mas_bottom);
        }];
    } else {
        [self.ptvFrameTime removeFromSuperview];
        [self.ptvFrameCount removeFromSuperview];
        [self.lInputResolution removeFromSuperview];
    }
}

- (void)showPhotoNightSceneProfile:(BOOL) show {
    if (show) {
        [self addSubview:self.ptvFrameTime];
        [self addSubview:self.lInputResolution];
        [self.ptvFrameTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(250, 20));
            make.top.equalTo(self).offset(100);
            make.leading.equalTo(self).offset(20);
        }];
        [self.lInputResolution mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.trailing.equalTo(self.ptvFrameTime);
            make.top.mas_equalTo(self.ptvFrameTime.mas_bottom);
        }];
    } else {
        [self.ptvFrameTime removeFromSuperview];
        [self.lInputResolution removeFromSuperview];
    }
}

- (void)updateProfile:(int)frameCount frameTime:(double)frameTime resolution:(CGSize)resolution {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:1];
    shadow.shadowBlurRadius = 2.f;
    shadow.shadowOffset = CGSizeMake(0, 0);
    self.ptvFrameCount.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"frame_count", nil) stringByAppendingFormat:@" %d", frameCount] attributes:@{NSShadowAttributeName:shadow}];
    self.ptvFrameTime.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"frame_time", nil) stringByAppendingFormat:@" %.1f ms", frameTime * 1000] attributes:@{NSShadowAttributeName:shadow}];
    self.lInputResolution.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"input_resolution", nil) stringByAppendingFormat:@" %0.f*%.0f", resolution.height, resolution.width] attributes:@{NSShadowAttributeName:shadow}];
}

- (void)updateProfile:(double)frameTime resolution:(CGSize)resolution {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithWhite:0 alpha:1];
    shadow.shadowBlurRadius = 2.f;
    shadow.shadowOffset = CGSizeMake(0, 0);
    self.ptvFrameTime.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"frame_time", nil) stringByAppendingFormat:@" %.1f ms", frameTime * 1000] attributes:@{NSShadowAttributeName:shadow}];
    self.lInputResolution.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(@"input_resolution", nil) stringByAppendingFormat:@" %0.f*%.0f", resolution.height, resolution.width] attributes:@{NSShadowAttributeName:shadow}];
}

- (void)baseViewDidTap:(UIView *)sender {
    if (sender == self.btnRecord) {
        [self.delegate baseView:self didTapRecord:sender];
    } else if (sender == self.btnOpen) {
        [self.delegate baseView:self didTapOpen:sender];
    } else if (sender == self.btnReset) {
        [self.delegate baseView:self didTapReset:sender];
    } else if (sender == self.btnBack) {
        [self.delegate baseView:self didTapBack:sender];
    } else if (sender == self.btnImagePicker) {
        [self.delegate baseView:self didTapImagePicker:sender];
    } else if (sender == self.btnSetting) {
        [self.delegate baseView:self didTapSetting:sender];
    } else if (sender == self.btnSwitchCamera) {
        [self.delegate baseView:self didTapSwitchCamera:sender];
    } else if (sender == self.btnPlay) {
        [self.delegate baseView:self didTapPlay:sender];
    } else if (sender == self.btnVideoPicker) {
        [self.delegate baseView:self didTapVideoPicker:sender];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    UIView *v = [self hitTest:point withEvent:event];
    
    if (v == self) {
        [self.delegate baseViewDidTouch:self];
    }
}

#pragma mark - getter
- (UIButton *)btnRecord {
    if (_btnRecord == nil) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[EffectCommon imageNamed:@"ic_record"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnRecord = btn;
    }
    return _btnRecord;
}

- (UIButton *)btnOpen {
    if (_btnOpen == nil) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[EffectCommon imageNamed:@"ic_arrow_up"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnOpen = btn;
    }
    return _btnOpen;
}

- (UIButton *)btnBack {
    if (_btnBack == nil) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[EffectCommon imageNamed:@"ic_arrow_left"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnBack = btn;
    }
    return _btnBack;
}

- (UIButton *)btnImagePicker {
    if (_btnImagePicker == nil) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[EffectCommon imageNamed:@"ic_image_picker"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnImagePicker = btn;
    }
    return _btnImagePicker;
}

- (UIButton *)btnSetting {
    if (_btnSetting == nil) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[EffectCommon imageNamed:@"ic_setting"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnSetting = btn;
    }
    return _btnSetting;
}

- (UIButton *)btnSwitchCamera {
    if (_btnSwitchCamera == nil) {
        UIButton *btn = [[UIButton alloc] init];
        UIImage *img = [EffectCommon imageNamed:@"ic_switch_camera"];
        [btn setImage:img forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnSwitchCamera = btn;
    }
    return _btnSwitchCamera;
}

- (UIButton *)btnPlay {
    if (_btnPlay == nil) {
        _btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        _btnPlay.contentMode = UIViewContentModeScaleAspectFit;
        [_btnPlay setImage:[EffectCommon imageNamed:@"ic_video_play"] forState:UIControlStateNormal];
        [_btnPlay addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnPlay.hidden = YES;
    }
    return _btnPlay;
}
- (UIButton *)btnReset {
    if (_btnReset == nil) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[EffectCommon imageNamed:@"ic_reset"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnReset = btn;
    }
    return _btnReset;
}
- (UIButton *)btnVideoPicker {
    if (_btnVideoPicker == nil) {
        _btnVideoPicker = [[UIButton alloc] init];
        [_btnVideoPicker setImage:[EffectCommon imageNamed:@"ic_video_picker"] forState:UIControlStateNormal];
        [_btnVideoPicker addTarget:self action:@selector(baseViewDidTap:) forControlEvents:UIControlEventTouchUpInside];
        _btnVideoPicker.hidden = YES;
    }
    return _btnVideoPicker;
}
- (UILabel *)ptvFrameTime {
    if (_ptvFrameTime == nil) {
        _ptvFrameTime = [[UILabel alloc] init];
        _ptvFrameTime.text = NSLocalizedString(@"frame_time", nil);
        _ptvFrameTime.font = [UIFont systemFontOfSize:12];
        _ptvFrameTime.textColor = [UIColor whiteColor];
        _ptvFrameTime.backgroundColor = [UIColor clearColor];
    }
    return _ptvFrameTime;
}

- (UILabel *)ptvFrameCount {
    if (_ptvFrameCount == nil) {
        _ptvFrameCount = [[UILabel alloc] init];
        _ptvFrameCount.text = NSLocalizedString(@"frame_count", nil);
        _ptvFrameCount.font = [UIFont systemFontOfSize:12];
        _ptvFrameCount.textColor = [UIColor whiteColor];
        _ptvFrameCount.backgroundColor = [UIColor clearColor];
    }
    return _ptvFrameCount;
}

- (UILabel *)lInputResolution {
    if (_lInputResolution == nil) {
        _lInputResolution = [[UILabel alloc] init];
        _lInputResolution.text = NSLocalizedString(@"input_resolution", nil);
        _lInputResolution.font = [UIFont systemFontOfSize:12];
        _lInputResolution.textColor = [UIColor whiteColor];
        _lInputResolution.backgroundColor = [UIColor clearColor];
    }
    return _lInputResolution;
}
@end
