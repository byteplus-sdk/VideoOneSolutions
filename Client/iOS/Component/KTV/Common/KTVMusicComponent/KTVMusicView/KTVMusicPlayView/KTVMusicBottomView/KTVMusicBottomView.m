//
//  KTVMusicBottomView.m
//  AFNetworking
//
//  Created by bytedance on 2024/1/15.
//

#import "KTVMusicBottomView.h"

@interface KTVMusicBottomView ()

@property (nonatomic, strong) BaseButton *nextButton;
@property (nonatomic, strong) BaseButton *pauseButton;
@property (nonatomic, strong) BaseButton *tuningButton;
@property (nonatomic, strong) BaseButton *originalButton;
@property (nonatomic, strong) BaseButton *songListButton;

@property (nonatomic, strong) KTVSongModel *songModel;

@end

@implementation KTVMusicBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [self addSubview:self.nextButton];
        [self addSubview:self.pauseButton];
        [self addSubview:self.tuningButton];
        [self addSubview:self.originalButton];
        [self addSubview:self.songListButton];
        
        [list addObject:self.originalButton];
        [list addObject:self.pauseButton];
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

- (void)updateWithSongModel:(KTVSongModel *)songModel
             loginUserModel:(KTVUserModel *)loginUserModel {
    self.songModel = songModel;
    
    if ([self isSingerWithSongModel:songModel
                     loginUserModel:loginUserModel]) {
        // Role Singer
        self.nextButton.alpha = 1;
        self.pauseButton.alpha = 1;
        self.tuningButton.alpha = 1;
        self.originalButton.alpha = 1;
        self.songListButton.alpha = 1;
    } else {
        if (loginUserModel.userRole == KTVUserRoleHost) {
            // Role Host
            self.nextButton.alpha = 1;
            self.pauseButton.alpha = 0.2;
            self.tuningButton.alpha = 0.2;
            self.originalButton.alpha = 0.2;
            self.songListButton.alpha = 1;
        } else {
            // Role Audience
            self.nextButton.alpha = 0.2;
            self.pauseButton.alpha = 0.2;
            self.tuningButton.alpha = 0.2;
            self.originalButton.alpha = 0.2;
            self.songListButton.alpha = (loginUserModel.status == KTVUserStatusActive) ? 1 : 0.2;
        }
    }
    
    self.originalButton.status = ButtonStatusNone;
    self.pauseButton.status = ButtonStatusNone;
}

#pragma mark - Private Action

- (BOOL)isSingerWithSongModel:(KTVSongModel *)songModel
               loginUserModel:(KTVUserModel *)loginUserModel {
    BOOL isCompetence = (loginUserModel.status == KTVUserStatusActive || loginUserModel.userRole == KTVUserRoleHost);
    if (isCompetence &&
        [songModel.pickedUserID isEqualToString:loginUserModel.uid]) {
        return YES;
    } else {
        return NO;
    }
}

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
    } else if (sender == self.pauseButton) {
        state = MusicTopStatePause;
        sender.status = (sender.status == ButtonStatusNone) ? ButtonStatusActive : ButtonStatusNone;
    } else if (sender == self.nextButton) {
        state = MusicTopStateNext;
    } else if (sender == self.songListButton) {
        state = MusicTopStateSongList;
    } else {
        //error
    }
    
    BOOL isSelect = (sender.status == ButtonStatusActive) ? YES : NO;
    if (self.clickButtonBlock) {
        self.clickButtonBlock(state, isSelect);
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

- (BaseButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [[BaseButton alloc] init];
        [_pauseButton bingImage:[UIImage imageNamed:@"music_pauser" bundleName:HomeBundleName] status:ButtonStatusNone];
        [_pauseButton bingImage:[UIImage imageNamed:@"music_pauser_s" bundleName:HomeBundleName] status:ButtonStatusActive];
        [_pauseButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
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
