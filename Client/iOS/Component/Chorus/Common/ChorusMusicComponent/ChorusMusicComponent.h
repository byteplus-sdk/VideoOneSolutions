// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>
#import "ChorusUserModel.h"
#import "ChorusSongModel.h"
@class ChorusMusicComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol ChorusMusicComponentDelegate <NSObject>

- (void)musicComponent:(ChorusMusicComponent *)musicComponent
     clickOpenSongList:(BOOL)isClick;

@end

@interface ChorusMusicComponent : NSObject

@property (nonatomic, weak) id<ChorusMusicComponentDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)view;
- (void)prepareMaterialsWithSongModel:(ChorusSongModel *)songModel;
- (void)prepareStartSingSong:(ChorusSongModel *_Nullable)songModel
         leadSingerUserModel:(ChorusUserModel *_Nullable)leadSingerUserModel;
- (void)reallyStartSingSong:(ChorusSongModel *)songModel;
- (void)stopSong;
- (void)showSongEndWithNextSongModel:(ChorusSongModel * _Nullable)nextSongModel;
- (void)updateCurrentSongTime:(NSString *)json;
- (void)sendSongTime:(NSInteger)songTime;
- (void)dismissTuningPanel;
- (void)updateNetworkQuality:(ChorusNetworkQualityStatus)status uid:(NSString *)uid;
- (void)updateFirstVideoFrameRenderedWithUid:(NSString *)uid;
- (void)updateUserAudioVolume:(NSDictionary<NSString *, NSNumber *> *)dict;
- (void)updateAudioRouteChanged;

@end

NS_ASSUME_NONNULL_END
