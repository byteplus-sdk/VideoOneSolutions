//
//  MiniDramaPlayButtonModule.m
//  MDPlayerKit
//

#import "MiniDramaPlayButtonModule.h"
#import "MDPlayerActionViewInterface.h"
#import "MDPlayerGestureServiceInterface.h"
#import "MDPlayerGestureHandlerProtocol.h"
#import "MDPlayerContext.h"
#import "MDPlayerContextKeyDefine.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIImage+Bundle.h>
#import "MDVideoPlayback.h"
#import "MDDramaFeedInfo.h"
#import "BTDMacros.h"


@interface MiniDramaPlayButtonModule() <MDPlayerGestureHandlerProtocol>
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, weak) id<MDVideoPlayback> playerInterface;
@property (nonatomic, weak) id<MDPlayerGestureServiceInterface> gestureService;
@property (nonatomic, weak) id<MDPlayerActionViewInterface> actionViewInterface;

@end

@implementation MiniDramaPlayButtonModule

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
    
    [self.gestureService addGestureHandler:self forType:MDGestureType_SingleTap];
    [self.gestureService addGestureHandler:self forType:MDGestureType_DoubleTap];
    
    @weakify(self);
    [self.context addKey:MDPlayerContextKeyPlayAction withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        if (object) {
            [self updatePlayButtonWithPlayState:YES];
        }
    }];
    
    [self.context addKey:MDPlayerContextKeyPauseAction withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self updatePlayButtonWithPlayState:NO];
    }];
    
    [self.context addKey:MDPlayerContextKeyPlaybackState withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        MDVideoPlaybackState playbackState = (MDVideoPlaybackState)[(NSNumber *)object integerValue];
        [self updatePlayButtonWithPlayState:(playbackState == MDVideoPlaybackStatePlaying)];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.actionViewInterface.playbackControlView);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    [self.gestureService removeGestureHandler:self];
    [self.context removeHandlersForObserver:self];
    if (self.playButton) {
        [self.playButton removeFromSuperview];
        self.playButton = nil;
    }
}

#pragma mark - Public Mehtod

- (void)updatePlayButtonWithPlayState:(BOOL)isPlaying {
    self.playButton.hidden = isPlaying;
    [[UIApplication sharedApplication] setIdleTimerDisabled:isPlaying];
}

#pragma mark - MDPlayerGestureHandlerProtocol

- (void)handleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(MDGestureType)gestureType {
    if (gestureType != MDGestureType_SingleTap) {
        [self.context post:@([gestureRecognizer locationInView:gestureRecognizer.view]) forKey:MDPlayerContextKeyPlayButtonDoubleTap];
        return;
    }
    MDVideoPlaybackState playbackState = (MDVideoPlaybackState)[self.context integerForHandlerKey:MDPlayerContextKeyPlaybackState];
    if (playbackState == MDVideoPlaybackStatePlaying) {
        [self.playerInterface pause];
    } else if (playbackState == MDVideoPlaybackStatePaused) {
        [self.playerInterface play];
    }
    [self.context post:@(self.playerInterface.playbackState) forKey:MDPlayerContextKeyPlayButtonSingleTap];
}

#pragma mark - Event Action

- (void)onClickPlayButton:(UIButton *)sender {
    MDVideoPlaybackState playbackState = (MDVideoPlaybackState)[self.context integerForHandlerKey:MDPlayerContextKeyPlaybackState];
    if (playbackState == MDVideoPlaybackStatePlaying) {
        [self.playerInterface pause];
    } else if (playbackState == MDVideoPlaybackStatePaused) {
        [self.playerInterface play];
    }
    [self.context post:@(self.playerInterface.playbackState) forKey:MDPlayerContextKeyPlayButtonSingleTap];
}

#pragma mark - Setter & Getter

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"video_play" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(onClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

@end
