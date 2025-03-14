// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDLPlayerLoadingView.h"
#import "MDActivityIndicator.h"
#import "NSTimer+BTDAdditions.h"
#import "UIView+BTDAdditions.h"
#import <Masonry/Masonry.h>
#import "MDPlayerUtility.h"

static const CGFloat kFullScreenTipLoadingViewH = 32;
static const CGFloat kInLineTipLoadingViewH = 28;
static const CGFloat kLabelFont = 11.0;
static const CGFloat kLabelTopOffset = 8.0;
static const NSTimeInterval kRefreshNetSpeedTimeInterval = 1;

@interface MDLPlayerLoadingView ()
@property (nonatomic, strong) MDActivityIndicator *loadingView;
@property (nonatomic, strong) UILabel *loadingTip;
@property (nonatomic, strong) NSTimer *refreshNetSpeedTimer;

@property (nonatomic, assign) CGFloat offsetCenterY;
@end

@implementation MDLPlayerLoadingView
@synthesize isFullScreen;
@synthesize refreshNetSpeedTipTimeInternal;
@synthesize dataSource;

#pragma mark - lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidden = YES;
        [self _buildViewHierarchy];
        _showNetSpeedTip = NO;
        isFullScreen = NO;
        refreshNetSpeedTipTimeInternal = kRefreshNetSpeedTimeInterval;
        self.layer.cornerRadius = 4;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)didMoveToSuperview{
    if (self.superview) {
        [self _buildConstraints];
    }
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
    [self stopRefreshNetSpeedTimer];
}

- (void)dealloc{
    [self stopRefreshNetSpeedTimer];
}

#pragma mark public methods

- (void)startLoading {
    [self.loadingView startAnimating];
    self.hidden = NO;
    if (self.showNetSpeedTip) {
        [self showLoadingNetWorkSpeed:YES];
    }
}

- (void)stopLoading {
    [self.loadingView stopAnimating];
    self.hidden = YES;
    [self showLoadingNetWorkSpeed:NO];
}

- (BOOL)isLoading {
    return self.loadingView.isAnimating;
}

#pragma mark -
#pragma mark UI

- (void)_buildViewHierarchy {
    [self addSubview:self.loadingView];
    [self addSubview:self.loadingTip];
}

- (void)_buildConstraints {
    CGFloat labelHight = self.loadingTip.btd_height;
    CGFloat offset = self.showNetSpeedTip ? kLabelTopOffset : 4.0;
    CGFloat viewW = isFullScreen ? kFullScreenTipLoadingViewH : kInLineTipLoadingViewH;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.superview);
        make.centerY.mas_equalTo(self.superview).offset(self.offsetCenterY);
        make.width.mas_equalTo(viewW + 60);
        make.height.mas_equalTo(viewW + offset + labelHight + 40);
    }];
    
    [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(viewW);
        make.height.mas_equalTo(viewW);
    }];
}

- (void)layoutOffsetCenterY:(CGFloat)y {
    self.offsetCenterY = y;
    if (self.superview) {
        [self _buildConstraints];
    }
}
- (void)showLoadingNetWorkSpeed:(BOOL)show{
    self.loadingView.hidden = !show;
    if (show) {
        [self configLoadingNetworkSpeed];
        [self startRefreshNetSpeedTimer];
    }else{
        [self stopRefreshNetSpeedTimer];
    }
}
- (void)configLoadingNetworkSpeed {
    if ([self.dataSource respondsToSelector:@selector(netWorkSpeedInfo)]) {
        [self setLoadingText:self.dataSource.netWorkSpeedInfo];
    }
}

#pragma mark refreshNetSpeedTimer

- (void)startRefreshNetSpeedTimer{
    [self stopRefreshNetSpeedTimer];
    [self ttv_addObserver];
    self.refreshNetSpeedTimer = [NSTimer btd_scheduledTimerWithTimeInterval:self.refreshNetSpeedTipTimeInternal weakTarget:self selector:@selector(configLoadingNetworkSpeed) userInfo:nil repeats:YES];
}

- (void)stopRefreshNetSpeedTimer{
    [self.refreshNetSpeedTimer invalidate];
    self.refreshNetSpeedTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark private methods
- (void)ttv_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)ttv_enterBackground {
    [self.refreshNetSpeedTimer btd_pause];
}

- (void)ttv_enterForeground {
    [self.refreshNetSpeedTimer btd_resume];
}

#pragma mark getters  && setters
- (MDActivityIndicator *)loadingView {
    if (!_loadingView) {
        CGFloat viewW = isFullScreen ? kFullScreenTipLoadingViewH : kInLineTipLoadingViewH;
        _loadingView = [[MDActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, viewW, viewW)];
        _loadingView.lineWidth = 4;
        _loadingView.hidesWhenStopped = YES;
        _loadingView.tintColor = [UIColor whiteColor];
    }
    return _loadingView;
}

- (UILabel *)loadingTip
{
    if (!_loadingTip) {
        _loadingTip = [[UILabel alloc] init];
        _loadingTip.textColor = [UIColor whiteColor];
        _loadingTip.font = [UIFont systemFontOfSize:kLabelFont];
        _loadingTip.layer.shadowOpacity = 1.f;
        _loadingTip.layer.shadowOffset = CGSizeZero;
        _loadingTip.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.38f].CGColor;
        _loadingTip.layer.shadowRadius = 2.f;
        _loadingTip.hidden = YES;
        [_loadingTip sizeToFit];
    }
    return _loadingTip;
}

- (void)setIsFullScreen:(BOOL)fullScreen{
    if (isFullScreen != fullScreen) {
        isFullScreen = fullScreen;
        if (self.superview && !self.hidden) {
            [self _buildConstraints];
            [self setNeedsLayout];
        }
    }
}

- (void)setRefreshNetSpeedTipTimeInternal:(NSTimeInterval)netSpeedTipTimeInternal{
    if (netSpeedTipTimeInternal < 0 ||  netSpeedTipTimeInternal == refreshNetSpeedTipTimeInternal) {
        return;
    }
    refreshNetSpeedTipTimeInternal = netSpeedTipTimeInternal;
}

#pragma mark - public

- (void)setLoadingText:(NSString *)text {
    self.loadingTip.hidden = YES;
    UILabel *label = self.loadingTip;
    CGFloat offset = self.showNetSpeedTip ? kLabelTopOffset : 4.0;
    label.hidden = NO;
    label.text = text;
    [label sizeToFit];
    [self.loadingTip mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadingView.mas_bottom).offset(offset);
        make.centerX.equalTo(self.loadingView);
        make.width.mas_equalTo(label.btd_width);
        make.height.mas_equalTo(label.btd_height);
    }];
    [self setNeedsLayout];
}

@end


