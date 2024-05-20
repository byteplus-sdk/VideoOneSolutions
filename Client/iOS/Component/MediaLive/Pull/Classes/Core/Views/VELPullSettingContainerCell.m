// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPullSettingContainerCell.h"
@interface VELPullSettingContainerCell ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContainer;
@end
@implementation VELPullSettingContainerCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setupUI];
    }
    return self;
}
- (void)_setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    [self.contentView addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    self.scrollContainer = [[UIView alloc] init];
    [self.scrollView addSubview:self.scrollContainer];
    [self.scrollContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}

- (void)setViewModel:(__kindof VELPullSettingViewModel *)viewModel {
    if (_viewModel != viewModel) {
        _viewModel = viewModel;
        [self.scrollContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.scrollContainer addSubview:viewModel.settingsView];
        [viewModel.settingsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollContainer);
        }];        
    }
}
@end
