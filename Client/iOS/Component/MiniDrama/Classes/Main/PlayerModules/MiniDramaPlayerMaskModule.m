// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaPlayerMaskModule.h"
#import "MDPlayerContext.h"
#import "MDPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>

@interface MiniDramaPlayerMaskModule ()

@property (nonatomic, strong) UIImageView *playerTopMaskView;
@property (nonatomic, strong) UIImageView *playerBottomMaskView;

@property (nonatomic, weak) id<MDPlayerActionViewInterface> actionViewInterface;

@end

@implementation MiniDramaPlayerMaskModule

MDPlayerContextDILink(actionViewInterface, MDPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.underlayControlView addSubview:self.playerTopMaskView];
    [self.actionViewInterface.underlayControlView addSubview:self.playerBottomMaskView];
    
    [self.playerTopMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.actionViewInterface.underlayControlView);
        make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.width * 280 /375);
    }];
    
    [self.playerBottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.actionViewInterface.underlayControlView);
        make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.width * 280 /375);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.playerTopMaskView) {
        [self.playerTopMaskView removeFromSuperview];
        self.playerTopMaskView = nil;
    }
    if (self.playerBottomMaskView) {
        [self.playerBottomMaskView removeFromSuperview];
        self.playerBottomMaskView = nil;
    }
}

#pragma mark - Setter & Getter

- (UIImageView *)playerTopMaskView {
    if (_playerTopMaskView == nil) {
        _playerTopMaskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_feed_cover"]];
        _playerTopMaskView.transform = CGAffineTransformMakeRotation(M_PI);
        _playerBottomMaskView.contentMode = UIViewContentModeScaleAspectFill;
        _playerBottomMaskView.clipsToBounds = YES;
    }
    return _playerTopMaskView;
}

- (UIImageView *)playerBottomMaskView {
    if (_playerBottomMaskView == nil) {
        _playerBottomMaskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_feed_cover"]];
        _playerBottomMaskView.contentMode = UIViewContentModeScaleAspectFill;
        _playerBottomMaskView.clipsToBounds = YES;
    }
    return _playerBottomMaskView;
}
@end
