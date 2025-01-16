// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsContentView.h"
#import "LiveAddGuestsApplicationListsView.h"
#import "LiveAddGuestsOnlineListsView.h"
#import "LiveAddGuestsTopView.h"

@interface LiveAddGuestsContentView () <LiveAddGuestsTopViewDelegate, LiveAddGuestsApplicationListsViewDelegate, LiveAddGuestsOnlineListsViewDelegate>

@property (nonatomic, strong) UIView *guestMaskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) LiveAddGuestsTopView *topView;
@property (nonatomic, strong) LiveAddGuestsOnlineListsView *listsView;
@property (nonatomic, strong) LiveAddGuestsApplicationListsView *applicationListView;

@end

@implementation LiveAddGuestsContentView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubviewConstraints];

        __weak __typeof(self) wself = self;
        self.listsView.clickApplicationBlock = ^{
            [wself.topView simulateClick:1];
        };
        self.listsView.clickCloseConnectBlock = ^{
            if ([wself.delegate respondsToSelector:@selector(liveAddGuests:clickCloseConnect:)]) {
                [wself.delegate liveAddGuests:wself clickCloseConnect:YES];
            }
        };

        // test
    }
    return self;
}

#pragma mark - Publish Action

- (void)updateCoHostStartTime:(NSDate *)time {
    [self.listsView updateStartTime:time];
}

- (void)setOnlineDataLists:(NSArray<LiveUserModel *> *)onlineDataLists {
    _onlineDataLists = onlineDataLists;
    if (onlineDataLists.count >= 6) {
        self.applicationListView.isApplyDisable = YES;
    } else {
        self.applicationListView.isApplyDisable = NO;
    }
    self.listsView.dataLists = onlineDataLists;
}

- (void)setApplicationDataLists:(NSArray<LiveUserModel *> *)applies {
    NSArray<LiveUserModel *> * sorted = [applies sortedArrayUsingComparator:^(LiveUserModel * o1, LiveUserModel * o2){
        return [o1.applyLinkTime compare:o2.applyLinkTime];
    }];

    self.applicationListView.dataLists = sorted;
    self.topView.isUnread = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationReadApplyMessage object:nil];
}

- (void)switchApplicationList {
    [self.topView simulateClick:1];
}

- (BOOL)IsDisplayApplyList {
    if (self.applicationListView.superview &&
        self.applicationListView.hidden == NO) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setIsUnread:(BOOL)isUnread {
    _isUnread = isUnread;
    self.topView.isUnread = isUnread;
}

- (void)updateGuestsMic:(BOOL)mic uid:(NSString *)uid {
    [self.listsView updateGuestsMic:mic uid:uid];
}

- (void)updateGuestsCamera:(BOOL)camera uid:(NSString *)uid {
    [self.listsView updateGuestsCamera:camera uid:uid];
}

#pragma mark - LiveAddGuestsApplicationListsViewDelegate
- (void)applicationListsView:(LiveAddGuestsApplicationListsView *)applicationListsView clickAgreeButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(liveAddGuests:clickAgree:)]) {
        [self.delegate liveAddGuests:self clickAgree:model];
    }
}

- (void)applicationListsView:(LiveAddGuestsApplicationListsView *)applicationListsView clickRejectButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(liveAddGuests:clickReject:)]) {
        [self.delegate liveAddGuests:self clickReject:model];
    }
}

#pragma mark - LiveAddGuestsOnlineListsViewDelegate

- (void)onlineListsView:(LiveAddGuestsOnlineListsView *)onlineListsView
        clickKickButton:(nonnull LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(liveAddGuests:clickKick:)]) {
        [self.delegate liveAddGuests:self clickKick:model];
    }
}

- (void)onlineListsView:(LiveAddGuestsOnlineListsView *)onlineListsView
         clickMicButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(liveAddGuests:clickMic:)]) {
        [self.delegate liveAddGuests:self clickMic:model];
    }
}

- (void)onlineListsView:(LiveAddGuestsOnlineListsView *)onlineListsView
      clickCameraButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(liveAddGuests:clickCamera:)]) {
        [self.delegate liveAddGuests:self clickCamera:model];
    }
}

#pragma mark - LiveAddGuestsTopViewDelegate

- (void)LiveAddGuestsTopView:(LiveAddGuestsTopView *)LiveAddGuestsTopView clickSwitchItem:(NSInteger)index {
    self.listsView.hidden = (index == 0) ? NO : YES;
    self.applicationListView.hidden = (index == 1) ? NO : YES;
    if (self.requestRefreshBlcok) {
        self.requestRefreshBlcok();
    }
}

#pragma mark - Private Action

- (void)maskViewAction {
    if (self.clickMaskBlcok) {
        self.clickMaskBlcok();
    }
}

- (void)closeConnectButtonAction {
}

- (void)addSubviewConstraints {
    [self addSubview:self.guestMaskView];
    [self.guestMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-361);
    }];

    [self.contentView addSubview:self.topImageView];
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(143);
    }];

    [self.contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.height.mas_equalTo(44);
    }];

    [self.contentView addSubview:self.listsView];
    [self.listsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.top.equalTo(self.topView.mas_bottom);
    }];

    [self.contentView addSubview:self.applicationListView];
    [self.applicationListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.listsView);
    }];
}

#pragma mark - Getter

- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] init];
        _topImageView.image = [UIImage imageNamed:@"ch-host_top" bundleName:HomeBundleName];
    }
    return _topImageView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorFromHexString:@"#161823"];

        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, 361 + [DeviceInforTool getVirtualHomeHeight]);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.frame = rect;
        layer.path = path.CGPath;
        _contentView.layer.mask = layer;
    }
    return _contentView;
}

- (LiveAddGuestsTopView *)topView {
    if (!_topView) {
        _topView = [[LiveAddGuestsTopView alloc] init];
        _topView.delegate = self;
    }
    return _topView;
}

- (LiveAddGuestsOnlineListsView *)listsView {
    if (!_listsView) {
        _listsView = [[LiveAddGuestsOnlineListsView alloc] init];
        _listsView.delegate = self;
        _listsView.backgroundColor = [UIColor clearColor];
        _listsView.hidden = NO;
    }
    return _listsView;
}

- (LiveAddGuestsApplicationListsView *)applicationListView {
    if (!_applicationListView) {
        _applicationListView = [[LiveAddGuestsApplicationListsView alloc] init];
        _applicationListView.delegate = self;
        _applicationListView.backgroundColor = [UIColor clearColor];
        _applicationListView.hidden = YES;
    }
    return _applicationListView;
}

- (UIView *)guestMaskView {
    if (!_guestMaskView) {
        _guestMaskView = [[UIView alloc] init];
        _guestMaskView.backgroundColor = [UIColor clearColor];
        _guestMaskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewAction)];
        [_guestMaskView addGestureRecognizer:tap];
    }
    return _guestMaskView;
}

@end
