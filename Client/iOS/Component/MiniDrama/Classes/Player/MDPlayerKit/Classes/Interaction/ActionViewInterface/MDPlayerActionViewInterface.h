//
//  MDPlayerActionViewInterface.h
//  MDPlayerKit
//


#import <UIKit/UIKit.h>
#import "MDPlayerActionView.h"
#import "MDPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

/** ---------------------------------------  */
/**  播放器视图层级                             **/
/**  -playerContainerView                    **/
/**  --EnginePlayerView                       **/
/**  --ActionView                                  **/
/**  ---ControlView                               **/
/** ---------------------------------------  */

@protocol MDPlayerActionViewInterface <NSObject>

/// 播放器的父容器视图，如果当前组件超出播放器视图范围，可以用播放器的父视图进行布局
@property (nonatomic, weak, nullable) UIView *playerContainerView;

/// 播放器交互视图
@property (nonatomic, strong, readonly) MDPlayerActionView *actionView;

/// 在playback control 的下面，比如弹幕
@property (nonatomic, strong, readonly) MDPlayerControlView *underlayControlView;

/// 播放控制层：所有能控制播放器的都叫做 control： part 中控制功能的控件会加到这个 view 上, 他控制着整体控件的消失和出现
@property (nonatomic, strong, readonly) MDPlayerControlView * playbackControlView;

/// 锁屏时的控制层
@property (nonatomic, strong, readonly) MDPlayerControlView * playbackLockControlView;

/// 在 playback control的上面，比如各种的提示。loading 等 ,不会随着control隐藏而隐藏
@property (nonatomic, strong, readonly) MDPlayerControlView * overlayControlView;

@end

NS_ASSUME_NONNULL_END
