// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "KTVUserModel.h"
#import "KTVSongModel.h"
@class KTVMusicView;

NS_ASSUME_NONNULL_BEGIN

@protocol KTVMusicViewdelegate <NSObject>

- (void)musicViewdelegate:(KTVMusicView *)musicViewdelegate topViewClickCut:(BOOL)isResult;

- (void)musicViewdelegate:(KTVMusicView *)musicViewdelegate topViewClickSongList:(BOOL)isOpen;

@end

@interface KTVMusicView : UIView

@property (nonatomic, assign) NSTimeInterval time;

@property (nonatomic, weak) id<KTVMusicViewdelegate> musicDelegate;

- (void)updateTopWithSongModel:(KTVSongModel *)songModel
                loginUserModel:(KTVUserModel *)loginUserModel;

- (void)dismissTuningPanel;

- (void)resetTuningView:(BOOL)isStartMusic;

- (void)loadLrcByPath:(KTVDownloadSongModel *)downloadSongModel;

- (void)resetLrc;
- (void)updateAudioRouteChanged;

@end

NS_ASSUME_NONNULL_END
