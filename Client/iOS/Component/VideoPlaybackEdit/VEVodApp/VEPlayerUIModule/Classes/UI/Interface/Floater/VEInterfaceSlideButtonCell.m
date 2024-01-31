// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSlideButtonCell.h"
#import "Masonry.h"
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceElementDescription.h"

@implementation VEInterfaceSlideButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self bingTitleColor:[UIColor whiteColor] status:ButtonStatusNone];
        [self bingTitleColor:[UIColor colorFromHexString:@"#FE3355"] status:ButtonStatusActive];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((contentRect.size.width - 24) * 0.5, 6, 24, 24);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, 36, contentRect.size.width, contentRect.size.height - 36);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(72, 56);
}

@end

@interface VEInterfaceSlideButtonCell ()

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation VEInterfaceSlideButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self clear];
}

- (void)initializeElements {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.stackView = [[UIStackView alloc] init];
    self.stackView.spacing = 0;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    self.stackView.alignment = UIStackViewAlignmentCenter;
    [self.contentView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.top.offset(8);
    }];
}

- (void)setButtons:(NSArray<VEInterfaceSlideButton *> *)buttons {
    _buttons = buttons;
    [buttons enumerateObjectsUsingBlock:^(VEInterfaceSlideButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.stackView addArrangedSubview:obj];
        [obj addTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)clear {
    NSArray<__kindof UIView *> *arrangedSubviews = self.stackView.arrangedSubviews;
    [arrangedSubviews enumerateObjectsUsingBlock:^(VEInterfaceSlideButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.stackView removeArrangedSubview:obj];
        [obj removeFromSuperview];
        [obj removeTarget:self action:@selector(onButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }];
    _buttons = nil;
}

- (void)onButtonPressed:(VEInterfaceSlideButton *)sender {
    if (self.elementDescription.elementNotify) {
        self.elementDescription.elementNotify(sender, sender.elementID, @(YES));
    }
}

@end
