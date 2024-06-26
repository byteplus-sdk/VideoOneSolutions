// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MusicTopState) {
    MusicTopStateNone = 0,
    MusicTopStateOriginal,
    MusicTopStateNext,
    MusicTopStateTuning,
    MusicTopStateSongList,
};

@interface ChorusMusicBottomView : UIView

@property (nonatomic, copy) void (^clickButtonBlock)(MusicTopState state,
                                                     BOOL isSelect,
                                                     BaseButton *button);

- (void)update;

@end

NS_ASSUME_NONNULL_END
