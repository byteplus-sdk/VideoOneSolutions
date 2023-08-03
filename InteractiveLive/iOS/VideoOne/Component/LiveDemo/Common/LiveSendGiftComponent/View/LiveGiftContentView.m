// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveGiftContentView.h"

@interface LiveGiftContentView () <LiveGiftItemSendButtonDelegate>

@property (nonatomic, strong) UIView * giftTableView;

@property (nonatomic, assign) float rate;

@property (nonatomic, strong) NSArray<LiveGiftItemView *>* giftItemViewList;

@end

@implementation LiveGiftContentView

- (instancetype)init {
    self = [super init];
    if(self) {
        _rate = 1;
        if(SCREEN_WIDTH < 375) {
            _rate = SCREEN_WIDTH / 375;
        }
        [self addSubview:self.giftTableView];
        [self.giftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(342 * self.rate);
            make.height.mas_equalTo(100);
            make.centerX.equalTo(self);
            make.top.mas_equalTo(self).offset(17);
        }];
    }
    return  self;
}
   
- (void)addSubviewAndConstraints:(NSArray<LiveGiftModel *>* )giftDataList {
    int length = (int)giftDataList.count;
    __weak __typeof(self) wself = self;
    NSMutableArray  *mutableArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < length; i++) {
        LiveGiftItemView *giftItem = [[LiveGiftItemView alloc] initWithBlock:^(GiftType giftType) {
            [wself updateSelectedGiftItem:giftType];
        }];
        giftItem.model = giftDataList[i];
        giftItem.delegate = self;
        [mutableArray addObject:giftItem];
        [self.giftTableView addSubview:giftItem];
        [giftItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(75 * self.rate, 94));
            make.left.mas_equalTo(self.giftTableView).offset(i * 89 * self.rate);
        }];
    }
    self.giftItemViewList = [mutableArray copy];
    [self.giftItemViewList[0] beSelected:YES];
}

- (void)updateSelectedGiftItem:(GiftType)giftType {
    if(self.currentGiftType == giftType) {
        return;
    }
    self.currentGiftType = giftType;
    for(LiveGiftItemView* item in self.giftItemViewList) {
        if(item.model.giftType != giftType) {
            [item beSelected:NO];
        } else {
            [item beSelected:YES];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *path = [UIBezierPath
                          bezierPathWithRoundedRect:self.bounds
                          byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                          cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

#pragma mark - LiveGiftItemSendButtonDelegate

- (void)liveGiftItemSendButtonHandler:(GiftType)giftType {
    if([self.delegate respondsToSelector:@selector(liveGiftItemClickHandler:)]) {
        [self.delegate liveGiftItemClickHandler:giftType];
    }
}

#pragma mark - Getter

- (UIView *)giftTableView {
    if(!_giftTableView) {
        _giftTableView = [[UIView alloc] init];
        _giftTableView.userInteractionEnabled = YES;
        _giftTableView.backgroundColor = [UIColor clearColor];
    }
    return  _giftTableView;
}

- (NSArray<LiveGiftItemView *> *)giftItemViewList {
    if(!_giftItemViewList) {
        _giftItemViewList = [[NSArray alloc] init];
    }
    return _giftItemViewList;
}
@end
