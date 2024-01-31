// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@interface VEInterfaceSlideMenuCell : UITableViewCell

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UILabel *titleLabel;

- (void)highlightLeftButton:(BOOL)left;

@end
