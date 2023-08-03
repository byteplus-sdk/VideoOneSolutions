// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>
#import "AlertActionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlertActionViewController : UIViewController

@property (nonatomic, copy) void (^clickButtonBlock)(void);

- (instancetype)initWithTitle:(NSString *)title
                     describe:(NSString *)describe;

- (void)addAction:(AlertActionModel *)alertAction;

- (void)addAlertUser:(AlertUserModel *)alertUserModel;

@end

NS_ASSUME_NONNULL_END
