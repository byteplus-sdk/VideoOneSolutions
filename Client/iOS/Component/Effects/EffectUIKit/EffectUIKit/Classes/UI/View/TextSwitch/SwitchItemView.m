// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SwitchItemView.h"
#import <Masonry/Masonry.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation SwitchItemConfig

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items selectIndex:(NSInteger)index {
    self = [super init];
    if (self) {
        _title = title;
        _items = items;
        _selectIndex = index;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title items:(NSArray *)items selectIndex:(NSInteger)index key:(NSString *)key {
    self = [[SwitchItemConfig alloc] initWithTitle:title items:items selectIndex:index];
    if (self) {
        self.key = key;
    }
    return self;
}

@end
@interface SwitchItemView ()

@property (nonatomic, strong) UILabel *lTitle;
@property (nonatomic, strong) NSArray<UIButton *> *vItems;
@property (nonatomic, strong) UIButton *selectView;
@property (nonatomic, strong) UIView *vBg;

@end

@implementation SwitchItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.lTitle];
        
        [self.lTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leadingMargin.mas_equalTo(16);
        }];
    }
    return self;
}

- (void)setConfig:(SwitchItemConfig *)config {
    _config = config;
    self.lTitle.text = NSLocalizedString(config.title, nil);
    [self setItems:config.items];
    [self setSelectIndex:config.selectIndex withImpact:NO];
}

- (void)setItems:(NSArray<NSString *> *)items {
    if (self.vItems != nil) {
        [self.vItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.vItems = nil;
    }
    
    [self addSubview:self.vBg];
    self.vItems = [self vItems:items];
    for (UIView *v in self.vItems) {
        [self addSubview:v];
    }
    
    UIView *last = nil;
    for (NSInteger i = self.vItems.count-1; i >= 0; i--) {
        UIView *v = self.vItems[i];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            if (last == nil) {
                make.trailing.equalTo(self).offset(-20);
            } else {
                make.trailing.equalTo(last.mas_leading).offset(-16);
            }
        }];
        last = v;
    }
    
    [self.vBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(25);
        make.centerY.equalTo(self.vItems[0]);
        make.leading.equalTo(self.vItems[0]).offset(-5);
        make.trailing.equalTo(self.vItems[0]).offset(5);
    }];
}

- (void)setSelectIndex:(NSInteger)selectIndex withImpact:(BOOL)impact {
    self.config.selectIndex = selectIndex;
    UIButton *v = self.vItems[selectIndex];
    
    [UIView animateWithDuration:0.2 animations:^{
        if (self.selectView != nil) {
            self.selectView.backgroundColor = nil;
            [self.selectView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [v setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.vBg mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(25);
            make.centerY.equalTo(v);
            make.leading.equalTo(v).offset(-5);
            make.trailing.equalTo(v).offset(5);
        }];
        
        [self.vBg.superview layoutIfNeeded];
    }];
    
    self.selectView = v;
    
    if (impact) {
        if (@available(iOS 10.0, *)) {
            UIImpactFeedbackGenerator *light = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            [light impactOccurred];
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)switchItemDidTap:(UIButton *)sender {
    NSInteger index = [self.vItems indexOfObject:sender];
    [self setSelectIndex:index withImpact:YES];
    [self.delegate switchItemView:self didSelect:index];
}

#pragma mark - getter
- (UILabel *)lTitle {
    if (_lTitle) {
        return _lTitle;
    }
    
    _lTitle = [UILabel new];
    _lTitle.textColor = [UIColor whiteColor];
    _lTitle.font = [UIFont systemFontOfSize:13];
    return _lTitle;
}

- (NSArray<UIButton *> *)vItems:(NSArray<NSString *> *)items {
    NSMutableArray<UIView *> *views = [NSMutableArray array];
    
    for (NSString *s in items) {
        UIButton *btn = [UIButton new];
        [btn setTitle:NSLocalizedString(s, nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn addTarget:self action:@selector(switchItemDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [views addObject:btn];
    }
    
    return [views copy];
}

- (UIView *)vBg {
    if (_vBg) {
        return _vBg;
    }
    
    _vBg = [UIView new];
    _vBg.layer.cornerRadius = 12.5;
    _vBg.backgroundColor = [UIColor whiteColor];
    return _vBg;
}

@end
