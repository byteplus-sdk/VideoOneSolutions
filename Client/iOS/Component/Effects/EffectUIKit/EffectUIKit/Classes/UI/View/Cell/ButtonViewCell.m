// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Masonry/Masonry.h>

#import "ButtonViewCell.h"
#import "ButtonView.h"

@interface ButtonViewCell ()

@property (nonatomic, strong) ButtonView *buttonView;

@end

@implementation ButtonViewCell

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.buttonView];
        [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    };
    return self;
}

#pragma mark - public
- (void)setSelectImg:(UIImage *)selectImg unselectImg:(UIImage *)unselectImg title:(NSString *)title expand:(BOOL)expand withPoint:(BOOL)withPoint {
    [self.buttonView setSelectImg:selectImg unselectImg:unselectImg title:title expand:expand withPoint:withPoint];
}

- (void)setSelectImg:(UIImage *)selectImg unselectImg:(UIImage *)unselectImg {
    [self.buttonView setSelectImg:selectImg unselectImg:unselectImg];
}

- (void)setPointOn:(BOOL)isOn {
    [self.buttonView setPointOn:isOn];
}

#pragma mark - setter

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.buttonView.selected = selected;
}

#pragma mark - getter

- (ButtonView *)buttonView {
    if (!_buttonView) {
        _buttonView = [ButtonView new];
        _buttonView.userInteractionEnabled = NO;
    }
    return _buttonView;
}

@end
