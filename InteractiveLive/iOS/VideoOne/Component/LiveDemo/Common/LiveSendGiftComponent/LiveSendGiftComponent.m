// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSendGiftComponent.h"
#import "LiveGiftContentView.h"
#import "LiveGiftModel.h"
#import "LiveGiftItemView.h"


@interface LiveSendGiftComponent () <LiveGiftItemViewDelegate>

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) LiveGiftContentView * contentView;


@end

@implementation LiveSendGiftComponent

- (instancetype)initWithView:(UIView *)superView {
    self  = [super init];
    if(self) {
        _superView = superView;
    }
    return self;
}

#pragma mark - Public Action

- (void)show {
    [self.superView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    if(self.maskView.superview) { 
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
    if(self.contentView.superview) {
        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
}

#pragma mark - Private Action

- (NSArray *)getGiftDataList {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    LiveGiftModel *model1 = [[LiveGiftModel alloc] init];
    model1.giftType = LiveGiftItemLike;
    model1.giftName = @"Like";
    model1.giftIcon = @"gift_like";
    [list addObject:model1];
    
    LiveGiftModel *model2 = [[LiveGiftModel alloc] init];
    model2.giftType = LiveGiftItemSugar;
    model2.giftName = @"Sugar";
    model2.giftIcon = @"gift_sugar";
    [list addObject:model2];
    
    LiveGiftModel *model3 = [[LiveGiftModel alloc] init];
    model3.giftType = LiveGiftItemDiamond;
    model3.giftName = @"Diamond";
    model3.giftIcon = @"gift_diamond";
    [list addObject:model3];
    
    LiveGiftModel *model4 = [[LiveGiftModel alloc] init];
    model4.giftType = LiveGiftItemFireworks;
    model4.giftName = @"Fireworks";
    model4.giftIcon = @"gift_fireworks";
    [list addObject:model4];
    
    return [list copy];
}


#pragma mark - LiveGiftItemViewDelegate

-(void) liveGiftItemClickHandler:(GiftType)giftType {
//    [self maskViewAction];
    LiveMessageModel *messageModel = [[LiveMessageModel alloc] init];
    messageModel.type = LiveMessageModelStateGift;
    messageModel.content = @"send gift";
    messageModel.count = 1;
    messageModel.giftType = giftType;
    messageModel.user_id = [LocalUserComponent userModel].uid;
    messageModel.user_name = [LocalUserComponent userModel].name;
    [LiveRTSManager sendIMMessage:messageModel
                            block:^(RTSACKModel * _Nonnull model) {
        if(!model.result) {
            NSLog(@"send gift failed!!!");
        }
    }];
}

#pragma mark - Getter

- (LiveGiftContentView *)contentView {
    if(!_contentView) {
        _contentView = [[LiveGiftContentView alloc] init];
        _contentView.backgroundColor = [UIColor colorWithRed:0.096 green:0.096 blue:0.096 alpha:1];
        _contentView.delegate = self;
    }
    return _contentView;
}

- (UIView *)maskView {
    if(!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}
@end
