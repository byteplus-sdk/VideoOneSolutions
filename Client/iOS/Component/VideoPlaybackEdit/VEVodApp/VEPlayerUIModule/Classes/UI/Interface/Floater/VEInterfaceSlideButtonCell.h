// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <ToolKit/ToolKit.h>

@interface VEInterfaceSlideButton : BaseButton

@property (nonatomic, copy) NSString *elementID;

@end

@interface VEInterfaceSlideButtonCell : UITableViewCell

@property (nonatomic, strong) NSArray<VEInterfaceSlideButton *> *buttons;

@end
