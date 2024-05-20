// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MusicTopState) {
    MusicTopStateNone = 0,
    MusicTopStateOriginal,
    MusicTopStateTuning,
    MusicTopStatePause,
    MusicTopStateNext,
    MusicTopStateSongList,
};

@interface KTVMusicBottomView : UIView

@property (nonatomic, copy) void (^clickButtonBlock) (MusicTopState state,
                                                      BOOL isSelect);

- (void)updateWithSongModel:(KTVSongModel *)songModel
             loginUserModel:(KTVUserModel *)loginUserModel;

@end

NS_ASSUME_NONNULL_END
