// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
#import "AlertActionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlertActionView : UIView

@property (nonatomic, copy) void (^clickButtonBlock)(void);

- (instancetype)initWithTitle:(NSString *)title
                     describe:(NSString *)describe
              alertActionList:(NSArray *)alertActionList
               alertUserModel:(AlertUserModel *)alertUserModel;

@end

NS_ASSUME_NONNULL_END
