// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^AlertModelClickBlock)(UIAlertAction *_Nonnull action);

NS_ASSUME_NONNULL_BEGIN

@interface AlertActionModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, copy) AlertModelClickBlock alertModelClickBlock;

@end

@interface AlertUserModel : NSObject

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) NSString *userName;

@end

NS_ASSUME_NONNULL_END
