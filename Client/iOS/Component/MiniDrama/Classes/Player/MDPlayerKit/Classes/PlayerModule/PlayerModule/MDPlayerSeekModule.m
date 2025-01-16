//
//  MDPlayerSeekModule.m
//  MDPlayModule
//
//  Created by zyw on 2024/7/8.
//

#import "MDPlayerSeekModule.h"
#import "MDPlayerContextKeyDefine.h"
#import "MDPlayerActionViewInterface.h"
#import "MDPlayerGestureServiceInterface.h"
#import "MDPlayerGestureHandlerProtocol.h"
#import "MDPlayerContext.h"
#import <Masonry/Masonry.h>
#import "MDSliderControlView.h"
#import "MDPlayerSeekState.h"
#import "MDVideoPlayback.h"
#import "BTDMacros.h"


@interface MDPlayerSeekModule () <MDSliderControlViewDelegate>

@property (nonatomic, strong) MDSliderControlView *sliderControlView;

@property (nonatomic, weak) id<MDVideoPlayback> playerInterface;

@property (nonatomic, weak) id<MDPlayerGestureServiceInterface> gestureService;

@property (nonatomic, weak) id<MDPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, strong) NSTimer *timer;
@end

@implementation MDPlayerSeekModule

MDPlayerContextDILink(playerInterface, MDVideoPlayback, self.context);
MDPlayerContextDILink(gestureService, MDPlayerGestureServiceInterface, self.context);
MDPlayerContextDILink(actionViewInterface, MDPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    @weakify(self);
    [self.context addKey:MDPlayerContextKeyPlaybackState withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        if (self.playerInterface.playbackState == MDVideoPlaybackStatePlaying) {
            [self _startTimer];
        } else {
            [self _invalidateTimer];
        }
    }];
    [self.context addKey:MDPlayerContextKeySliderSeekBegin withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self _invalidateTimer];
    }];
    [self.context addKey:MDPlayerContextKeySliderCancel withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self _startTimer];
    }];
    [self.context addKey:MDPlayerContextKeySliderSeekEnd withObserver:self handler:^(MDPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self _startTimer];
        NSTimeInterval playbackTime = seekState.progress * seekState.duration;
        [self.playerInterface seekToTime:playbackTime complete:nil renderComplete:nil];
    }];
    [self.context addKey:MDPlayerContextKeySpeedTipViewShowed withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        BOOL showSpeedTipView = [object boolValue];
        self.sliderControlView.userInteractionEnabled = !showSpeedTipView;
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.sliderControlView];
    [self.sliderControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.actionViewInterface.playbackControlView);
        make.height.mas_equalTo(10);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.sliderControlView) {
        [self.sliderControlView removeFromSuperview];
        self.sliderControlView = nil;
    }
    [self _invalidateTimer];
}

#pragma mark - Timer

- (void)_startTimer {
    [self _invalidateTimer];
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:.1f target:self selector:@selector(_timerHandle) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)_invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)_timerHandle {
    if (self.playerInterface.duration) {
        self.sliderControlView.progressValue = self.playerInterface.currentPlaybackTime / self.playerInterface.duration;
    }
}

#pragma mark - MDSliderControlView Delegate

- (void)progressBeginSlideChange:(MDSliderControlView *)sliderControlView {
    MDPlayerSeekState *seekState = [[MDPlayerSeekState alloc] init];
    seekState.seekStage = MDPlayerSeekStageSliderBegin;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:MDPlayerContextKeySliderSeekBegin];
}

- (void)progressSliding:(MDSliderControlView *)sliderControlView value:(CGFloat)value {
    MDPlayerSeekState *seekState = [[MDPlayerSeekState alloc] init];
    seekState.seekStage = MDPlayerSeekStageSliderChanging;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:MDPlayerContextKeySliderChanging];
}

- (void)progressDidEndSlide:(MDSliderControlView *)sliderControlView value:(CGFloat)value {
    MDPlayerSeekState *seekState = [[MDPlayerSeekState alloc] init];
    seekState.seekStage = MDPlayerSeekStageSliderEnd;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:MDPlayerContextKeySliderSeekEnd];
}

- (void)progressSlideCancel:(MDSliderControlView *)sliderControlView {
    MDPlayerSeekState *seekState = [[MDPlayerSeekState alloc] init];
    seekState.seekStage = MDPlayerSeekStageSliderCancel;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:MDPlayerContextKeySliderCancel];
}

#pragma mark - Setter & Getter

- (MDSliderControlView *)sliderControlView {
    if (_sliderControlView == nil) {
        _sliderControlView = [[MDSliderControlView alloc] initWithContentMode:MDSliderControlViewContentModeBottom];
        _sliderControlView.progressBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        _sliderControlView.progressColor = [UIColor whiteColor];
        _sliderControlView.progressBufferColor = [UIColor clearColor];
        _sliderControlView.thumbHeight = 2;
        _sliderControlView.thumbOffset = 6;
        _sliderControlView.delegate = self;
        _sliderControlView.extendTouchSize = CGSizeMake(0, 10);
        _sliderControlView.tag = 11111;
    }
    return _sliderControlView;
}

@end
