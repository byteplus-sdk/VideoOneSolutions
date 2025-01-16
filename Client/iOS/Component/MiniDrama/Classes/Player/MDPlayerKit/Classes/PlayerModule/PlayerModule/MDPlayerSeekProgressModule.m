//
//  MDPlayerSeekProgressModule.m
//  MDPlayModule
//
//  Created by zyw on 2024/7/8.
//

#import "MDPlayerSeekProgressModule.h"
#import "MDPlayerContextKeyDefine.h"
#import "MDPlayerActionViewInterface.h"
#import "MDPlayerGestureServiceInterface.h"
#import "MDPlayerSeekProgressView.h"
#import <Masonry/Masonry.h>
#import "MDPlayerSeekState.h"
#import "MDVideoPlayback.h"
#import "BTDMacros.h"


@interface MDPlayerSeekProgressModule ()

@property (nonatomic, strong) MDPlayerSeekProgressView *seekProgressTipView;

@property (nonatomic, weak) id<MDVideoPlayback> playerInterface;

@property (nonatomic, weak) id<MDPlayerActionViewInterface> actionViewInterface;

@end

@implementation MDPlayerSeekProgressModule

MDPlayerContextDILink(playerInterface, MDVideoPlayback, self.context);
MDPlayerContextDILink(actionViewInterface, MDPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    @weakify(self);
    [self.context addKey:MDPlayerContextKeySliderSeekBegin withObserver:self handler:^(MDPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:YES];
        [self __updateSeekProgress:seekState];
    }];
    [self.context addKey:MDPlayerContextKeySliderChanging withObserver:self handler:^(MDPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:YES];
        [self __updateSeekProgress:seekState];
    }];
    [self.context addKey:MDPlayerContextKeySliderCancel withObserver:self handler:^(MDPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:NO];
        [self __updateSeekProgress:seekState];
    }];
    [self.context addKey:MDPlayerContextKeySliderSeekEnd withObserver:self handler:^(MDPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:NO];
        [self __updateSeekProgress:seekState];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.overlayControlView addSubview:self.seekProgressTipView];
    
    [self.seekProgressTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.actionViewInterface.overlayControlView);
        make.bottom.equalTo(self.actionViewInterface.overlayControlView).with.offset(-130);
        make.left.right.equalTo(self.actionViewInterface.overlayControlView);
        make.height.mas_equalTo(30);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.seekProgressTipView) {
        [self.seekProgressTipView removeFromSuperview];
        self.seekProgressTipView = nil;
    }
}

#pragma mark - Private

- (void)__updateSeekProgress:(MDPlayerSeekState *)state {
    NSInteger playbackTime = state.progress * state.duration;
    [self.seekProgressTipView updateProgress:playbackTime duration:state.duration];
}

#pragma mark - Getter && Setter

- (MDPlayerSeekProgressView *)seekProgressTipView {
    if (_seekProgressTipView == nil) {
        _seekProgressTipView = [[MDPlayerSeekProgressView alloc] init];
    }
    return _seekProgressTipView;
}

@end
