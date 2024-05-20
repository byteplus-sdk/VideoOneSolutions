// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SectionListView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIColor+String.h>

@interface SectionListItemView : UIButton

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation SectionListItemView

- (instancetype)initWithMessage:(NSString *)message {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.right.equalTo(@-16);
            make.top.height.equalTo(self);
        }];
        
        self.messageLabel.text = message;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.layer.cornerRadius = 36 / 2;
}

#pragma mark - Publish Action

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorFromHexString:@"#E2EEFF"];
        self.messageLabel.textColor = [UIColor colorFromHexString:@"#0066FC"];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.messageLabel.textColor = [UIColor colorFromHexString:@"#737A87"];
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.userInteractionEnabled = NO;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _messageLabel.textColor = [UIColor colorFromHexString:@"#737A87"];
        _messageLabel.userInteractionEnabled = NO;
    }
    return _messageLabel;
}

@end

@interface SectionListView ()

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, copy) NSArray<BaseFunctionSection *> *sectionList;
@property (nonatomic, assign) NSInteger selectedDefault;

@end

@implementation SectionListView

- (instancetype)initWithList:(NSArray<BaseFunctionSection *> *)sectionList {
    self = [super init];
    if (self) {
        self.selectedDefault = 0;
        self.sectionList = sectionList;
        [self addSubvieAndMakeConstraints];
        if (self.clickBlock) {
            self.clickBlock(self.selectedDefault);
        }
    }
    return self;
}

- (void)itemViewAction:(SectionListItemView *)itemView {
    NSInteger selectedRow = self.selectedDefault;
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        if ([self.contentView.subviews[i] isKindOfClass:[SectionListItemView class]]) {
            SectionListItemView *curItemView = (SectionListItemView *)self.contentView.subviews[i];
            
            if (itemView == curItemView) {
                selectedRow = i;
                itemView.selected = YES;
            } else {
                curItemView.selected = NO;
            }
        }
    }
    if (self.clickBlock) {
        self.clickBlock(selectedRow);
    }
}

- (void)addSubvieAndMakeConstraints {
    [self addSubview:self.mainScrollView];
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self);
    }];
    
    [self.mainScrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mainScrollView);
        make.height.equalTo(self.mainScrollView);
    }];
    
    SectionListItemView *tempItemView = nil;
    for (int i = 0; i < self.sectionList.count; i++) {
        BaseFunctionSection *sectionModel = self.sectionList[i];
        SectionListItemView *itemView = [[SectionListItemView alloc] initWithMessage:sectionModel.functionSectionName];
        [itemView addTarget:self action:@selector(itemViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(self);
            if (tempItemView) {
                make.left.equalTo(tempItemView.mas_right).offset(12);
            } else {
                make.left.equalTo(@0);
            }
        }];
        tempItemView = itemView;
        if (i == self.selectedDefault) {
            // The first one is selected by default
            itemView.selected = YES;
        }
    }
    
    if (tempItemView) {
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(tempItemView);
        }];
    }
}

#pragma mark - Getter

- (UIView *)contentView {
  if (!_contentView) {
      _contentView = [[UIView alloc] init];
      _contentView.backgroundColor = [UIColor clearColor];
  }
  return _contentView;
}

- (UIScrollView *)mainScrollView {
  if (!_mainScrollView) {
      _mainScrollView = [[UIScrollView alloc] init];
      _mainScrollView.showsHorizontalScrollIndicator = NO;
  }
  return _mainScrollView;
}

@end
