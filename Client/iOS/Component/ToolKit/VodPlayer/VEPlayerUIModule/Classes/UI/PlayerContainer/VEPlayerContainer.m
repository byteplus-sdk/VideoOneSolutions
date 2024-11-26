//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEPlayerContainer.h"
#import <Masonry/Masonry.h>

@implementation VEPlayerContainer

- (UIView *)contentView {
    return self;
}

@end

@interface VEPlayerSecureContainer ()

@property (nonatomic, strong) UIView *secureContentView;

@property (nonatomic, strong) UITextField *textField;

@end

@implementation VEPlayerSecureContainer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textField = [[UITextField alloc] init];
        self.textField.secureTextEntry = YES;
        self.secureContentView = self.textField.subviews.firstObject;
        self.secureContentView.userInteractionEnabled = YES;
        [self addSubview:self.secureContentView];
        [self.secureContentView mas_makeConstraints:^(MASConstraintMaker *make) { // need remake
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (UIView *)contentView {
    return self.secureContentView;
}

@end
