// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusMusicBottomView.h"
#import "ChorusDataManager.h"

@interface ChorusMusicBottomView ()

@property (nonatomic, strong) BaseButton *originalButton;
@property (nonatomic, strong) BaseButton *nextButton;
@property (nonatomic, strong) BaseButton *tuningButton;
@property (nonatomic, strong) BaseButton *songListButton;

@end

@implementation ChorusMusicBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [self addSubview:self.originalButton];
        [self addSubview:self.nextButton];
        [self addSubview:self.tuningButton];
        [self addSubview:self.songListButton];
        
        [list addObject:self.originalButton];
        [list addObject:self.nextButton];
        [list addObject:self.tuningButton];
        [list addObject:self.songListButton];
        
        CGFloat buttonWidth = 56;
        [list mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:buttonWidth leadSpacing:0 tailSpacing:0];
        [list mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(@0);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)update {
    if ([ChorusDataManager shared].isLeadSinger) {
        self.nextButton.alpha = 1;
        self.tuningButton.alpha = 1;
        self.originalButton.alpha = 1;
        self.songListButton.alpha = 1;
    } else if ([ChorusDataManager shared].isSuccentor) {
        self.originalButton.alpha = 0.2;
        self.nextButton.alpha = 0.2;
        self.tuningButton.alpha = 1;
        self.songListButton.alpha =  1;
    } else {
        // Role Audience
        self.nextButton.alpha = 0.2;
        self.tuningButton.alpha = 0.2;
        self.originalButton.alpha = 0.2;
        self.songListButton.alpha =  1;
    }
    
    self.originalButton.status = ButtonStatusNone;
}

#pragma mark - Private Action

- (void)buttonAction:(BaseButton *)sender {
    if (sender.alpha < 1) {
        
        return;
    }
    MusicTopState state = MusicTopStateNone;
    if (sender == self.originalButton) {
        state = MusicTopStateOriginal;
        sender.status = (sender.status == ButtonStatusNone) ? ButtonStatusActive : ButtonStatusNone;
    } else if (sender == self.tuningButton) {
        state = MusicTopStateTuning;
    } else if (sender == self.nextButton) {
        state = MusicTopStateNext;
    } else if (sender == self.songListButton) {
        state = MusicTopStateSongList;
    } else {
        // Error
    }
    
    BOOL isSelect = (sender.status == ButtonStatusActive) ? YES : NO;
    if (self.clickButtonBlock) {
        self.clickButtonBlock(state, isSelect, sender);
    }
}


#pragma mark - Getter


- (BaseButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [[BaseButton alloc] init];
        [_nextButton setImage:[UIImage imageNamed:@"music_next" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (BaseButton *)tuningButton {
    if (!_tuningButton) {
        _tuningButton = [[BaseButton alloc] init];
        [_tuningButton setImage:[UIImage imageNamed:@"music_tuning" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_tuningButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tuningButton;
}

- (BaseButton *)originalButton {
    if (!_originalButton) {
        _originalButton = [[BaseButton alloc] init];
        [_originalButton bingImage:[UIImage imageNamed:@"music_original" bundleName:HomeBundleName] status:ButtonStatusNone];
        [_originalButton bingImage:[UIImage imageNamed:@"music_original_s" bundleName:HomeBundleName] status:ButtonStatusActive];
        [_originalButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalButton;
}

- (BaseButton *)songListButton {
    if (!_songListButton) {
        _songListButton = [[BaseButton alloc] init];
        [_songListButton setImage:[UIImage imageNamed:@"music_list" bundleName:HomeBundleName] forState:UIControlStateNormal];
        [_songListButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _songListButton;
}


@end
