//
//  KTVMusicComponent.h
//  veRTC_Demo
//
//  Created by on 2021/11/30.
//  
//

#import <Foundation/Foundation.h>
#import "KTVUserModel.h"
#import "KTVSongModel.h"
@class KTVMusicComponent;

NS_ASSUME_NONNULL_BEGIN

@protocol MusicComponentDelegate <NSObject>

- (void)musicComponent:(KTVMusicComponent *)musicComponent clickPlayMusic:(BOOL)isClick;

- (void)musicComponent:(KTVMusicComponent *)musicComponent clickOpenSongList:(BOOL)isClick;

@end

@interface KTVMusicComponent : NSObject

- (instancetype)initWithSuperView:(UIView *)view
                           roomID:(NSString *)roomID;

/// Update the currently playing song
/// @param songModel songModel
- (void)startSingWithSongModel:(KTVSongModel * _Nullable)songModel;

- (void)stopSong;

/// Show song ending UI
/// @param nextSongModel next song
/// @param curSongModel current song
/// @param score Music score
- (void)showSongEndSongModel:(KTVSongModel * _Nullable)nextSongModel
                curSongModel:(KTVSongModel * _Nullable)curSongModel
                       score:(NSInteger)score;

/// Update current user role
/// @param loginUserModel User Info
- (void)updateUserModel:(KTVUserModel *)loginUserModel;

/// Update current song progress
- (void)updateCurrentSongTime:(NSDictionary *)infoDic;

- (void)sendSongTime:(NSInteger)songTime;

- (void)dismissTuningPanel;

@property (nonatomic, weak) id<MusicComponentDelegate> delegate;

/// 音频播放路由改变
- (void)updateAudioRouteChanged;

@end

NS_ASSUME_NONNULL_END
