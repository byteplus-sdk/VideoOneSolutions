//
//  KTVMusicTuningView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicTuningView : UIView

- (void)reset:(BOOL)isStartMusic;

/// 音频播放路由改变
- (void)updateAudioRouteChanged;

@end

NS_ASSUME_NONNULL_END
