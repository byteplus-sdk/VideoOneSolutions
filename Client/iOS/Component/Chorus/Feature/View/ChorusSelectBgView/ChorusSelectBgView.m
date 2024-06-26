// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusSelectBgView.h"
#import "ChorusSelectBgItemView.h"

@interface ChorusSelectBgView ()

@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation ChorusSelectBgView

- (instancetype)init {
    self = [super init];
    if (self) {
        for (int i = 0; i < 3; i++) {
            ChorusSelectBgItemView *itemView = [[ChorusSelectBgItemView alloc] initWithIndex:i];
            [itemView addTarget:self action:@selector(itemViewAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:itemView];
            [self.list addObject:itemView];
        }
        [self.list mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:27.5 leadSpacing:0 tailSpacing:0];
        [self.list mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
        }];
        
        ChorusSelectBgItemView *itemView = self.list.firstObject;
        itemView.isSelected = YES;
    }
    return self;
}

- (NSString *)getDefaults {
    ChorusSelectBgItemView *itemView = self.list.firstObject;
    return [itemView getBackgroundImageName];
}

- (void)itemViewAction:(ChorusSelectBgItemView *)itemView {
    for (ChorusSelectBgItemView *item in self.list) {
        item.isSelected = NO;
    }
    itemView.isSelected = YES;
    if (self.clickBlock) {
        self.clickBlock([itemView getBackgroundImageName],
                        [itemView getBackgroundSmallImageName]);
    }
}

#pragma mark - Getter

- (NSMutableArray *)list {
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

@end
