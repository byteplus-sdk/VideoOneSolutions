//
//  MiniDramaPlayerSpeedModule.m
//  MDPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import "MiniDramaPlayerSpeedModule.h"
#import "MDPlayerContextKeyDefine.h"
#import "MDPlayerActionViewInterface.h"
#import "MDPlayerGestureServiceInterface.h"
#import "MDPlayerGestureHandlerProtocol.h"
#import "MiniDramaSpeedTipView.h"
#import <Masonry/Masonry.h>
#import "MDVideoPlayback.h"

@interface MiniDramaPlayerSpeedModule () <MDPlayerGestureHandlerProtocol>

@property (nonatomic, strong) MiniDramaSpeedTipView *speedTipView;
@property (nonatomic, weak) id<MDVideoPlayback> playerInterface;
@property (nonatomic, weak) id<MDPlayerGestureServiceInterface> gestureService;
@property (nonatomic, weak) id<MDPlayerActionViewInterface> actionViewInterface;

@end

@implementation MiniDramaPlayerSpeedModule

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
    
    [self.gestureService addGestureHandler:self forType:MDGestureType_LongPress];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playerContainerView addSubview:self.speedTipView];
    [self.speedTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.actionViewInterface.playerContainerView);
        make.bottom.equalTo(self.actionViewInterface.playerContainerView).with.offset(-33);
        make.size.mas_equalTo(CGSizeMake(MiniDramaSpeedTipViewViewWidth, MiniDramaSpeedTipViewViewHeight));
    }];
    self.speedTipView.alpha = 0;
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.speedTipView) {
        [self.speedTipView removeFromSuperview];
        self.speedTipView = nil;
    }
}

#pragma mark - MDPlayerGestureHandlerProtocol

- (void)handleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(MDGestureType)gestureType {
    if (gestureType == MDGestureType_LongPress) {
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (state == UIGestureRecognizerStateBegan) {
            self.playerInterface.playbackRate = 2.0f;
            [self.speedTipView showSpeedView:[NSString stringWithFormat:@"%.0fx倍速中", self.playerInterface.playbackRate]];
            [self.context post:@(YES) forKey:MDPlayerContextKeySpeedTipViewShowed];
        } else if (state == UIGestureRecognizerStateEnded ||
                   state == UIGestureRecognizerStateCancelled ||
                   state == UIGestureRecognizerStateFailed) {
            self.playerInterface.playbackRate = 1.0f;
            [self.speedTipView hiddenSpeedView];
            [self.context post:@(NO) forKey:MDPlayerContextKeySpeedTipViewShowed];
        }
    }
}

#pragma mark - Getter

- (MiniDramaSpeedTipView *)speedTipView {
    if (_speedTipView == nil) {
        _speedTipView = [[MiniDramaSpeedTipView alloc] init];
    }
    return _speedTipView;
}

@end
