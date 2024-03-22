//
//  KTVMusicView.h
//  veRTC_Demo
//
//  Created by on 2021/11/30.
//  
//

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

/// 音频播放路由改变
- (void)updateAudioRouteChanged;

@end

NS_ASSUME_NONNULL_END
