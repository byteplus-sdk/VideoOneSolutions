// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class LiveSheetModel;

typedef void (^SheetModelClickBlock)(LiveSheetModel *_Nonnull action);

@interface LiveSheetModel : NSObject

@property (nonatomic, strong) NSString *titleStr;

@property (nonatomic, assign) BOOL isDisable;

@property (nonatomic, copy) SheetModelClickBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
