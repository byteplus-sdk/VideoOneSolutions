// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusRoomBottomView.h"
#import "UIView+Fillet.h"
#import "ChorusRTSManager.h"
#import "ChorusDataManager.h"

@interface ChorusRoomBottomView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ChorusRoomItemButton *inputButton;
@property (nonatomic, strong) NSMutableArray *buttonLists;
@property (nonatomic, strong) ChorusRoomItemButton *pickSongButton;
@property (nonatomic, strong) UILabel *songCountLabel;

@property (nonatomic, assign) CGFloat pickSongButtonWidth;

@end

@implementation ChorusRoomBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self);
            make.width.mas_equalTo(0);
        }];
        
        [self addSubview:self.inputButton];
        [self.inputButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
            make.left.top.equalTo(self);
            make.right.equalTo(self.contentView.mas_left).offset(-8);
        }];
        
        self.pickSongButtonWidth = 99;
        [self addSubview:self.pickSongButton];
        [self.pickSongButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(self.pickSongButtonWidth);
            make.top.right.equalTo(self);
        }];
        
        [self addSubviewAndConstraints];
    }
    return self;
}

- (void)inputButtonAction {
    if ([self.delegate respondsToSelector:@selector(chorusRoomBottomView:itemButton:didSelectStatus:)]) {
        [self.delegate chorusRoomBottomView:self itemButton:self.inputButton didSelectStatus:ChorusRoomBottomStatusInput];
    }
}

- (void)buttonAction:(ChorusRoomItemButton *)sender {
    if ([self.delegate respondsToSelector:@selector(chorusRoomBottomView:itemButton:didSelectStatus:)]) {
        [self.delegate chorusRoomBottomView:self itemButton:sender didSelectStatus:sender.tagNum];
    }
    
    if (sender.tagNum == ChorusRoomBottomStatusLocalMic) {
        BOOL isEnableMic = YES;
        if (sender.status == ButtonStatusActive) {
            sender.status = ButtonStatusNone;
            isEnableMic = YES;
        } else {
            sender.status = ButtonStatusActive;
            isEnableMic = NO;
        }
        [[ChorusRTCManager shareRtc] enableLocalAudio:isEnableMic];
    }
    
    if (sender.tagNum == ChorusRoomBottomStatusLocalCamera) {
        BOOL isEnableCamera = YES;
        if (sender.status == ButtonStatusActive) {
            sender.status = ButtonStatusNone;
            isEnableCamera = YES;
        } else {
            sender.status = ButtonStatusActive;
            isEnableCamera = NO;
        }
        
        [[ChorusRTCManager shareRtc] enableLocalVideo:isEnableCamera];
    }
}

- (void)addSubviewAndConstraints {
    NSInteger groupNum = 4;
    for (int i = 0; i < groupNum; i++) {
        ChorusRoomItemButton *button = [[ChorusRoomItemButton alloc] init];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonLists addObject:button];
        [self.contentView addSubview:button];
    }
}

#pragma mark - Publish Action

- (void)updateBottomLists {

    CGFloat itemWidth = 36;
    
    NSArray *status = [self getBottomLists];
    NSNumber *number = status.firstObject;
    if (number.integerValue == ChorusRoomBottomStatusInput) {
        self.inputButton.hidden = NO;
        NSMutableArray *mutableStatus = [status mutableCopy];
        [mutableStatus removeObjectAtIndex:0];
        status = [mutableStatus copy];
    } else {
        self.inputButton.hidden = YES;
    }
    
    NSMutableArray *lists = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.buttonLists.count; i++) {
        ChorusRoomItemButton *button = self.buttonLists[i];
        if (i < status.count) {
            NSNumber *number = status[i];
            ChorusRoomBottomStatus bottomStatus = number.integerValue;
            
            button.tagNum = bottomStatus;
            NSString *imageName = [self getImageWithStatus:bottomStatus];
            UIImage *image = [UIImage imageNamed:imageName bundleName:HomeBundleName];
            [button bingImage:image status:ButtonStatusNone];
            [button bingImage:[self getSelectImageWithStatus:bottomStatus] status:ButtonStatusActive];
            button.hidden = NO;
            button.status = ButtonStatusNone;
            [lists addObject:button];
            if (bottomStatus == ChorusRoomBottomStatusLocalMic &&
                ([ChorusDataManager shared].isLeadSinger ||
                 [ChorusDataManager shared].isSuccentor)) {
                button.enabled = NO;
                button.alpha = 0.5;
            } else {
                button.enabled = YES;
                button.alpha = 1.0;
            }
            
            if (bottomStatus == ChorusRoomBottomStatusLocalCamera) {
                if ([ChorusRTCManager shareRtc].isCameraOpen) {
                    button.status = ButtonStatusNone;
                } else {
                    button.status = ButtonStatusActive;
                }
            }
            
        } else {
            button.hidden = YES;
        }
    }
    
    if (lists.count > 1) {
        [lists mas_remakeConstraints:^(MASConstraintMaker *make) {
                
        }];
        [lists mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:itemWidth leadSpacing:0 tailSpacing:0];
        [lists mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(36);
        }];
    } else {
        ChorusRoomItemButton *button = lists.firstObject;
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(36);
            make.right.equalTo(self.contentView);
            make.width.mas_equalTo(itemWidth);
        }];
    }
    
    CGFloat counentWidth = (itemWidth * status.count) + ((status.count - 1) * 12);
    if (status.count < 1) {
        counentWidth = 0;
    }
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(counentWidth);
        make.right.equalTo(self).offset(self.pickSongButton.isHidden? 0:-self.pickSongButtonWidth - 8);
    }];
}

- (void)updateBottomStatus:(ChorusRoomBottomStatus)status isActive:(BOOL)isActive {
    ChorusRoomItemButton *currentButton = nil;
    for (int i = 0; i < self.buttonLists.count; i++) {
        ChorusRoomItemButton *button = self.buttonLists[i];
        if (button.tagNum == status) {
            currentButton = button;
            break;
        }
    }
    if (currentButton) {
        currentButton.status = isActive ? ButtonStatusActive : ButtonStatusNone;
    }
}

- (void)updatePickedSongCount:(NSInteger)count {
    self.songCountLabel.hidden = (count == 0);
    if (count < 10) {
        _songCountLabel.font = [UIFont systemFontOfSize:12];
        _songCountLabel.text = @(count).stringValue;
    } else if (count < 100) {
        _songCountLabel.font = [UIFont systemFontOfSize:10];
        _songCountLabel.text = @(count).stringValue;
    } else {
        _songCountLabel.font = [UIFont systemFontOfSize:8];
        _songCountLabel.text = @"99+";
    }
}

#pragma mark - Private Action

- (NSArray *)getBottomLists {
    NSArray *bottomLists = nil;
    
    if ([ChorusDataManager shared].isLeadSinger || [ChorusDataManager shared].isSuccentor) {
        bottomLists = @[
            @(ChorusRoomBottomStatusInput),
            @(ChorusRoomBottomStatusLocalMic),
            @(ChorusRoomBottomStatusLocalCamera),
        ];
    } else if ([ChorusDataManager shared].isHost) {
        bottomLists = @[
            @(ChorusRoomBottomStatusInput),
            @(ChorusRoomBottomStatusLocalMic)
        ];
    } else {
        bottomLists = @[
            @(ChorusRoomBottomStatusInput)
        ];
    }
    return bottomLists;
}

- (NSString *)getImageWithStatus:(ChorusRoomBottomStatus)status {
    NSString *name = @"";
    switch (status) {
        case ChorusRoomBottomStatusLocalMic:
            name = @"Chorus_bottom_mic";
            break;
        case ChorusRoomBottomStatusLocalCamera:
            name = @"chorus_local_camera_on";
            break;
        default:
            break;
    }
    return name;
}

- (UIImage *)getSelectImageWithStatus:(ChorusRoomBottomStatus)status {
    NSString *name = @"";
    switch (status) {
        case ChorusRoomBottomStatusLocalMic:
            name = @"Chorus_localmic_s";
            break;
        case ChorusRoomBottomStatusLocalCamera:
            name = @"chorus_local_camera_off";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:name bundleName:HomeBundleName];
}

- (void)pickSongButtonClick {
    if ([self.delegate respondsToSelector:@selector(chorusRoomBottomView:itemButton:didSelectStatus:)]) {
        [self.delegate chorusRoomBottomView:self itemButton:self.pickSongButton didSelectStatus:ChorusRoomBottomStatusPickSong];
    }
}

#pragma mark - getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (NSMutableArray *)buttonLists {
    if (!_buttonLists) {
        _buttonLists = [[NSMutableArray alloc] init];
    }
    return _buttonLists;
}

- (ChorusRoomItemButton *)inputButton {
    if (!_inputButton) {
        _inputButton = [[ChorusRoomItemButton alloc] init];
        [_inputButton setBackgroundImage:[UIImage imageNamed:@"room_bottom_input" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_inputButton addTarget:self action:@selector(inputButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _inputButton.hidden = YES;
        
        UILabel *desLabel = [[UILabel alloc] init];
        desLabel.text = LocalizedString(@"label_input_placeholder");
        desLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.5 * 255];
        desLabel.font = [UIFont systemFontOfSize:14];
        [_inputButton addSubview:desLabel];
        [desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_inputButton);
            make.left.equalTo(_inputButton).offset(16);
        }];
    }
    return _inputButton;
}

- (ChorusRoomItemButton *)pickSongButton {
    if (!_pickSongButton) {
        _pickSongButton = [[ChorusRoomItemButton alloc] init];
        [_pickSongButton addTarget:self action:@selector(pickSongButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_pickSongButton setBackgroundImage:[UIImage imageNamed:@"room_request_bg" bundleName:HomeBundleName] forState:UIControlStateNormal];
        
        UIImageView *iconImageView = [[UIImageView alloc] init];
        iconImageView.image = [UIImage imageNamed:@"room_request_icon" bundleName:HomeBundleName];
        [_pickSongButton addSubview:iconImageView];
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 14));
            make.centerY.equalTo(_pickSongButton);
            make.left.equalTo(_pickSongButton).offset(12);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = LocalizedString(@"button_music_list_request_song");
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [_pickSongButton addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_pickSongButton);
            make.left.equalTo(iconImageView.mas_right).offset(4);
            make.right.equalTo(@-15);
        }];
        
        [_pickSongButton addSubview:self.songCountLabel];
        [self.songCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_pickSongButton);
            make.centerY.equalTo(_pickSongButton.mas_top);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    return _pickSongButton;
}

- (UILabel *)songCountLabel {
    if (!_songCountLabel) {
        _songCountLabel = [[UILabel alloc] init];
        _songCountLabel.layer.cornerRadius = 10;
        _songCountLabel.layer.masksToBounds = YES;
        _songCountLabel.layer.borderWidth = 2;
        _songCountLabel.layer.borderColor = UIColor.whiteColor.CGColor;
        _songCountLabel.textAlignment = NSTextAlignmentCenter;
        _songCountLabel.font = [UIFont systemFontOfSize:12];
        _songCountLabel.textColor = UIColor.whiteColor;
        _songCountLabel.backgroundColor = [UIColor colorFromHexString:@"#EE77C6"];
        _songCountLabel.hidden = YES;
    }
    return _songCountLabel;
}

@end
