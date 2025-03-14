// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <ToolKit/ToolKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MDInterfaceSlideButton : BaseButton

@property (nonatomic, copy) NSString *elementID;

@end

@interface MDInterfaceSlideButtonCell : UITableViewCell

@property (nonatomic, strong) NSArray<MDInterfaceSlideButton *> *buttons;

@end
NS_ASSUME_NONNULL_END
