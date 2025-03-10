// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "TextSwitchView.h"
#import <Masonry/Masonry.h>

@interface TextSwitchView () <TextSwitchItemViewDelegate>

@property (nonatomic, strong) NSMutableArray<TextSwitchItemView *> *itemViews;

@end

@implementation TextSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _itemViews = [NSMutableArray array];
    }
    return self;
}

- (void)setItems:(NSArray<TextSwitchItem *> *)items {
    _items = items;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemViews removeAllObjects];
    
    UIView *last = nil;
    for (TextSwitchItem *item in items) {
        TextSwitchItemView *v = [self itemView:item];
        [self.itemViews addObject:v];
        [self addSubview:v];
        
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(last == nil ? self : last.mas_trailing).offset(last == nil ? 0 : 16);
            make.bottom.equalTo(self);
            make.width.mas_equalTo(item.minTextWidth + 8);
        }];
        last = v;
    }
    
//    UIView *last = nil;
//    for (UIView *v in self.itemViews) {
//        [v mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.equalTo(last == nil ? self : last.mas_trailing).offset(last == nil ? 0 : 16);
//            make.bottom.equalTo(self);
//            make.width.mas_equalTo(
//        }];
//    }
//    [self.itemViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
//                                withFixedSpacing:(10)
//                                     leadSpacing:0
//                                     tailSpacing:0];
//    [self.itemViews mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self);
//    }];
    
    self.selectItem = self.items[0];
}

- (void)setSelectItem:(TextSwitchItem *)selectItem {
    if (selectItem == nil) {
        return;
    }
    if (self.selectItem != nil) {
        NSInteger oldSelect = [self.items indexOfObject:self.selectItem];
        if (oldSelect == NSNotFound) {
            [self.itemViews makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
        } else {
            self.itemViews[oldSelect].selected = NO;
        }
    }
    _selectItem = selectItem;
    
    NSInteger idx = [self.items indexOfObject:selectItem];
    self.itemViews[idx].selected = YES;
}

#pragma mark - TextSwitchItemViewDelegate
- (void)textSwitchItemView:(TextSwitchItemView *)view didSelect:(TextSwitchItem *)item {
    self.selectItem = item;
    [self.delegate textSwitchItemView:view didSelect:item];
}

#pragma mark - getter
- (TextSwitchItemView *)itemView:(TextSwitchItem *)item {
    TextSwitchItemView *v = [[TextSwitchItemView alloc] init];
    v.item = item;
    v.delegate = self;
    return v;
}

@end
