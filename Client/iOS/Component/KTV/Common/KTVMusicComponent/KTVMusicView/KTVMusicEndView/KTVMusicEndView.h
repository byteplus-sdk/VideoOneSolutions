// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "KTVSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicEndView : UIView

- (void)showWithModel:(KTVSongModel *)songModel
                block:(void (^)(BOOL result))block;

@property (nonatomic, copy) void (^clickPlayMusicBlock)(void);

@end

NS_ASSUME_NONNULL_END
