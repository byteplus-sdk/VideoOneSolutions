// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSendGiftComponent.h"
#import "LiveGiftContentView.h"
#import "LiveGiftItemView.h"
#import "LiveGiftModel.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

@interface LiveSendGiftComponent () <LiveGiftItemViewDelegate>

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong) UIView *giftMaskView;

@property (nonatomic, strong) LiveGiftContentView *contentView;

@property (nonatomic, strong) NSString *roomID;

@end

@implementation LiveSendGiftComponent

- (instancetype)initWithView:(UIView *)superView {
    self = [super init];
    if (self) {
        _superView = superView;
    }
    return self;
}

#pragma mark - Public Action

- (void)showWithRoomID:(NSString *)roomID {
    self.roomID = roomID;
    [self.superView addSubview:self.giftMaskView];
    [self.giftMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superView);
    }];

    CGFloat contentViewHeight = 206 + [DeviceInforTool getVirtualHomeHeight];
    [self.superView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.superView);
        make.bottom.equalTo(self.superView).offset(contentViewHeight);
        make.height.mas_equalTo(contentViewHeight);
    }];
    [self.contentView.superview setNeedsLayout];
    [self.contentView.superview layoutIfNeeded];
    [UIView animateWithDuration:(0.25) animations:^{
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.superView).offset(0);
        }];
        [self.contentView.superview layoutIfNeeded];
    }];
    [self.contentView addSubviewAndConstraints:[self getGiftDataList]];
}

- (void)maskViewAction {
    if (self.giftMaskView.superview) {
        [self.giftMaskView removeFromSuperview];
        self.giftMaskView = nil;
    }
    if (self.contentView.superview) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
}

#pragma mark - Private Action

- (NSArray *)getGiftDataList {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    LiveGiftModel *model1 = [[LiveGiftModel alloc] init];
    model1.giftType = LiveGiftItemLike;
    model1.giftName = LocalizedStringFromBundle(@"gift_like", @"LiveRoomUI");
    model1.giftIcon = @"gift_like";
    [list addObject:model1];

    LiveGiftModel *model2 = [[LiveGiftModel alloc] init];
    model2.giftType = LiveGiftItemSugar;
    model2.giftName = LocalizedStringFromBundle(@"gift_sugar", @"LiveRoomUI");
    model2.giftIcon = @"gift_sugar";
    [list addObject:model2];

    LiveGiftModel *model3 = [[LiveGiftModel alloc] init];
    model3.giftType = LiveGiftItemDiamond;
    model3.giftName = LocalizedStringFromBundle(@"gift_diamond", @"LiveRoomUI");
    model3.giftIcon = @"gift_diamond";
    [list addObject:model3];

    LiveGiftModel *model4 = [[LiveGiftModel alloc] init];
    model4.giftType = LiveGiftItemFireworks;
    model4.giftName = LocalizedStringFromBundle(@"gift_fireworks", @"LiveRoomUI");
    model4.giftIcon = @"gift_fireworks";
    [list addObject:model4];

    return [list copy];
}

#pragma mark - LiveGiftItemViewDelegate

- (void)liveGiftItemClickHandler:(GiftType)giftType {
    if ([self.delegate respondsToSelector:@selector(liveGiftItemClickHandler:)]) {
        [self.delegate liveGiftItemClickHandler:giftType];
    }
}

#pragma mark - Getter

- (LiveGiftContentView *)contentView {
    if (!_contentView) {
        _contentView = [[LiveGiftContentView alloc] init];
        _contentView.backgroundColor = [UIColor colorWithRed:0.096 green:0.096 blue:0.096 alpha:1];
        _contentView.delegate = self;
    }
    return _contentView;
}

- (UIView *)giftMaskView {
    if (!_giftMaskView) {
        _giftMaskView = [[UIView alloc] init];
        _giftMaskView.backgroundColor = [UIColor clearColor];
        _giftMaskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewAction)];
        [_giftMaskView addGestureRecognizer:tap];
    }
    return _giftMaskView;
}
@end
