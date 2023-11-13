// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseIMModel : NSObject

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, strong) UIImage *iconImage;

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, copy) void (^clickBlock)(BaseIMModel *model);

@end

NS_ASSUME_NONNULL_END
