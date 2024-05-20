// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^AlertModelClickBlock)(UIAlertAction * _Nonnull action);

NS_ASSUME_NONNULL_BEGIN

@interface VELAlertAction : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) AlertModelClickBlock alertModelClickBlock;

+ (instancetype)actionWithTitle:(NSString *)title block:(AlertModelClickBlock)block;
@end

NS_ASSUME_NONNULL_END
