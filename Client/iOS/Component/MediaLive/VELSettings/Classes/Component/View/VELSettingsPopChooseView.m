// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsPopChooseView.h"
#import <MediaLive/VELCommon.h>
#import <Masonry/Masonry.h>
#import "VELSettingsPopupMenuView.h"
@interface VELSettingsPopChooseView ()
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) VELUIButton *menuTitleBtn;
@property (nonatomic, strong) VELSettingsPopupMenuView *menuView;
@end

@implementation VELSettingsPopChooseView

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.titleLabel];
    [container addSubview:self.menuTitleBtn];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).mas_offset(self.model.insets.top);
        make.left.equalTo(self.container).mas_offset(self.model.insets.left);
        make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
    }];
    [self.menuTitleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).mas_offset(self.model.insets.top);
        make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
        make.width.mas_greaterThanOrEqualTo(self.model.size.width * 0.2);
    }];
}

- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    self.titleLabel.text = self.model.title;
    self.titleLabel.textAttributes = self.model.titleAttributes;
    if (self.model.selectIndex >= 0 && self.model.selectIndex < self.model.menuStrings.count) {
        NSString *menuTitle = [self.model.menuStrings objectAtIndex:self.model.selectIndex];
        [self setupMenuHold:menuTitle];
    }
    self.menuView.menuModels = self.model.menuModels;
    self.menuView.selectIndex = self.model.selectIndex;
    __weak __typeof__(self)weakSelf = self;
    [self.menuView setDidSelectedModelBlock:^(VELSettingsPopupMenuView * _Nonnull menuView, __kindof VELSettingsBaseViewModel * _Nonnull model, NSInteger index) {
        __strong __typeof__(weakSelf)self = weakSelf;
        BOOL shouldSelect = YES;
        if (self.model.menuSelectedBlock) {
            shouldSelect &= self.model.menuSelectedBlock(index);
        }
        if (self.model.menuModelSelectedBlock) {
            shouldSelect &= self.model.menuModelSelectedBlock(model, index);
        }
        if (shouldSelect) {
            self.model.selectIndex = index;
            VELSettingsButtonViewModel *btnModel = (VELSettingsButtonViewModel *)model;
            [self setupMenuHold:btnModel.title];
        }
    }];
    self.menuTitleBtn.layer.borderColor = self.model.menuHoldBorderColor.CGColor;
    self.menuTitleBtn.layer.borderWidth = 1;
    self.menuTitleBtn.layer.cornerRadius = 4;
    self.menuView.backgroundColor = self.model.containerBackgroundColor;
    [self setupMenuHold:((VELSettingsButtonViewModel *)self.model.selectModel).title];
}

- (void)setupMenuHold:(NSString *)str {
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str?:@"" attributes:self.model.menuHoldTitleAttributes];
    [self.menuTitleBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
}

- (void)menuButtonDidClick {
    self.menuView.sourceView = self.menuTitleBtn;
    self.menuView.selectIndex = self.model.selectIndex;
    [self.menuView showWithAnimated:YES];
}

- (VELSettingsPopupMenuView *)menuView {
    if (!_menuView) {
        _menuView = [[VELSettingsPopupMenuView alloc] init];
    }
    return _menuView;
}

- (VELUIButton *)menuTitleBtn {
    if (!_menuTitleBtn) {
        _menuTitleBtn = [[VELUIButton alloc] init];
        _menuTitleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _menuTitleBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_menuTitleBtn setContentHuggingPriority:(UILayoutPriorityDefaultHigh) forAxis:(UILayoutConstraintAxisHorizontal)];
        [_menuTitleBtn setContentCompressionResistancePriority:(UILayoutPriorityDefaultHigh) forAxis:(UILayoutConstraintAxisHorizontal)];
        [_menuTitleBtn addTarget:self action:@selector(menuButtonDidClick) forControlEvents:(UIControlEventTouchUpInside)];
        _menuTitleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_menuTitleBtn setTitleColor:UIColor.blackColor forState:(UIControlStateNormal)];
        
    }
    return _menuTitleBtn;
}

- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[VELUILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = UIColor.whiteColor;
        [_titleLabel setContentHuggingPriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
        [_titleLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
    }
    return _titleLabel;
}
@end
