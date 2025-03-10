// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import "MDDramaEpisodeInfoModel.h"


@protocol MiniDramaSelectionViewDelegate <NSObject>

- (void)onDramaSelectionCallback:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

@optional
- (void)onCloseHandleCallback;

- (void)onClickUnlockAllEpisode;

@end
