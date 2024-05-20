// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "KTVSongModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicTopView : UIView

@property (nonatomic, assign) NSTimeInterval time;

- (void)updateWithSongModel:(KTVSongModel *)songModel
             loginUserModel:(KTVUserModel *)loginUserModel;

@end

NS_ASSUME_NONNULL_END
