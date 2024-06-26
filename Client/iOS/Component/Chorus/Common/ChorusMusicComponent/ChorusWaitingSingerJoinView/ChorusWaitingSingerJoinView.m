// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusWaitingSingerJoinView.h"
#import "ChorusDataManager.h"
#import "ChorusSongNameLabel.h"

@interface ChorusWaitingSingerJoinView ()

@property (nonatomic, strong) ChorusSongNameLabel *songNameLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, assign) ChorusSingingType actionType;

@end

@implementation ChorusWaitingSingerJoinView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.songNameLabel];
        [self addSubview:self.actionButton];
        [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.centerX.equalTo(self);
            make.height.mas_equalTo(20);
        }];
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.songNameLabel.mas_bottom).offset(12);
            make.bottom.equalTo(self);
            make.centerX.equalTo(self);
            make.size.mas_offset(CGSizeMake(240, 44));
        }];
    }
    return self;
}

- (void)updateUI {
    self.songNameLabel.text = [NSString stringWithFormat:@"《%@》", [ChorusDataManager shared].currentSongModel.musicName];
    if ([ChorusDataManager shared].isLeadSinger) {
        [self.actionButton setTitle:LocalizedString(@"button_solo_name") forState:UIControlStateNormal];
        self.actionType = ChorusSingingTypeSolo;
    } else {
        [self.actionButton setTitle:LocalizedString(@"button_chorus_name") forState:UIControlStateNormal];
        self.actionType = ChorusSingingTypeChorus;
    }
}

- (void)actionButtonClick {
    if (self.startSingingTypeBlock) {
        self.startSingingTypeBlock(self.actionType);
    }
}

#pragma mark - Getter

- (ChorusSongNameLabel *)songNameLabel {
    if (!_songNameLabel) {
        _songNameLabel = [[ChorusSongNameLabel alloc] init];
    }
    return _songNameLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.layer.cornerRadius = 22;
        _actionButton.layer.borderWidth = 0.5;
        _actionButton.layer.borderColor = [[UIColor colorFromHexString:@"#FFFFFF"] colorWithAlphaComponent:0.4].CGColor;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_actionButton setImage:[UIImage imageNamed:@"chorus_waiting_icon" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(actionButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

@end
