// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
#import "VELUILabel.h"

@interface VELToastContentView : UIView
@property(nonatomic, strong) UIView *customView;
@property(nonatomic, strong, readonly) VELUILabel *textLabel;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong, readonly) VELUILabel *detailTextLabel;
@property(nonatomic, copy) NSString *detailText;

@end
