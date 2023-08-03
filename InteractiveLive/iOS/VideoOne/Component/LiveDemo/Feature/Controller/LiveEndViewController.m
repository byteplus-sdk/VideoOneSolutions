// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveEndViewController.h"
#import "LiveEndView.h"
#import "LiveRTCManager.h"

@interface LiveEndViewController ()

@property (nonatomic, strong) LiveEndView *contentView;

@property (nonatomic, strong) LiveEndLiveModel *model;

@end

@implementation LiveEndViewController

- (instancetype)initWithModel:(LiveEndLiveModel *)endLiveModel {
    self = [super init];
    if(self) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        self.contentView.model = endLiveModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubviewAndConstraints];
}

- (void)addSubviewAndConstraints {
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.contentView setupLocalRenderView];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)setBackBlock:(void (^)(void))backBlock {
    _backBlock = backBlock;
    self.contentView.backToHomeBlock = backBlock;
}

#pragma mark - Getter

- (LiveEndView *)contentView {
    if(!_contentView) {
        _contentView = [[LiveEndView alloc] init];
    }
    return _contentView;
}

- (LiveEndLiveModel *)model {
    if(!_model) {
        _model = [[LiveEndLiveModel alloc] init];
    }
    return _model;
}

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[LiveRTCManager shareRtc] switchVideoCapture:NO];
    [[LiveRTCManager shareRtc] switchAudioCapture:NO];
}

@end
